//
//  BSODiscoveredDeviceSelectionViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODiscoveredDeviceSelectionViewController.h"
#import "BSODiscoveredDeviceCell.h"
#import "BSOAdvertisementDataViewController.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "BSODeviceEntity+CoreDataClass.h"
#import "UIColor+BleSampleOmron.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "BSOBluetoothCheckViewController.h"
#import "OHQDeviceManager.h"

static const NSTimeInterval TableReloadInterval = 1.0;
static void * const KVOContext = (void *)&KVOContext;
typedef void(^AlertActionBlock)(UIAlertAction *act);

NS_ASSUME_NONNULL_BEGIN

@interface BSODiscoveredDeviceSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filterButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic) NSMutableOrderedSet<NSUUID *> *deviceIdentifiers;
@property (strong, nonatomic) NSMutableDictionary<NSUUID *,NSDictionary<OHQDeviceInfoKey,id> *> *deviceInfoCache;
@property (strong, nonatomic) dispatch_source_t reloadTimer;
@property (nullable, copy, nonatomic) NSArray<NSDictionary<OHQDeviceInfoKey,id> *> *deviceInfoSnapshot;
@property (nullable, copy, nonatomic) dispatch_block_t stopScanCompletionBlock;
@property (assign, nonatomic) BOOL reloadTimerRunning;
@property (assign, nonatomic) BOOL readyToScan;
@property (strong, nonatomic) BSOBluetoothCheckViewController *bleCheck;

@end

NS_ASSUME_NONNULL_END

@implementation BSODiscoveredDeviceSelectionViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _advertisementDataViewMode = NO;
        _allowUserInteractionOfCategoryFilterSetting = NO;
        _pairingModeDeviceOnly = YES;
        _categoryToFilter = OHQDeviceCategoryAny;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        _bleCheck = [BSOBluetoothCheckViewController new];
        self.readyToScan = false;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = [BSODiscoveredDeviceCell rowHeight];
    
    self.deviceIdentifiers = [NSMutableOrderedSet orderedSet];
    self.deviceInfoCache = [@{} mutableCopy];
    self.stopScanCompletionBlock = nil;
    self.reloadTimerRunning = NO;
    
    self.reloadTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.reloadTimer, DISPATCH_TIME_NOW, TableReloadInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.reloadTimer, ^{
        __block NSMutableArray *orderedDeviceInfoArray = [@[] mutableCopy];
        [self.deviceIdentifiers enumerateObjectsUsingBlock:^(NSUUID * _Nonnull deviceIdentifier, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *deviceInfo = self.deviceInfoCache[deviceIdentifier];
            if (!deviceInfo) {
                return;
            }
            if (!self.pairingModeDeviceOnly) {
                [orderedDeviceInfoArray addObject:deviceInfo];
                return;
            }
            NSDictionary *manufactureData = deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataManufacturerDataKey];
            if (!manufactureData) {
                [orderedDeviceInfoArray addObject:deviceInfo];
                return;
            }
            UInt16 companyIdentifier = [manufactureData[OHQManufacturerDataCompanyIdentifierKey] unsignedShortValue];
            if (companyIdentifier != OHQOmronHealthcareCompanyIdentifier) {
                [orderedDeviceInfoArray addObject:deviceInfo];
                return;
            }
            BOOL isPairingMode = [manufactureData[OHQManufacturerDataIsPairingMode] boolValue];
            if (isPairingMode) {
                [orderedDeviceInfoArray addObject:deviceInfo];
                return;
            }
        }];
        self.deviceInfoSnapshot = orderedDeviceInfoArray;
        [self.tableView reloadData];
    });
    
    if (self.frostedViewController) {
        self.menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_menu"]
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(barButtonItemDidAction:)];
        self.navigationItem.leftBarButtonItem = self.menuButton;
    }
    else {
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }
    self.navigationItem.rightBarButtonItem = (_allowUserInteractionOfCategoryFilterSetting ? self.filterButton : nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[OHQDeviceManager sharedManager] addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew) context:KVOContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self bso_stopScanWithBlock:nil];
    [self bso_pausePeriodicUpdateForTable];
    
    [[OHQDeviceManager sharedManager] removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != KVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([object isEqual:[OHQDeviceManager sharedManager]] && [keyPath isEqualToString:@"state"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkBluetooth];
        });
    }
}

#pragma mark - Public method

- (void)setCategoryToFilter:(OHQDeviceCategory)categoryToFilter {
    if (_categoryToFilter != categoryToFilter) {
        _categoryToFilter = categoryToFilter;
        UIColor *filterColor = [UIColor scanFilterColorWithDeviceCategory:categoryToFilter];
        if (filterColor) {
            self.filterButton.tintColor = filterColor;
        }
        else {
            self.filterButton.tintColor = [UIColor whiteColor];
        }
    }
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)sender {
    if ([sender isEqual:self.cancelButton]) {
        [self performSegueWithIdentifier:@"unwindToRoot" sender:self];
    }
    else if ([sender isEqual:self.filterButton]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        alertController.popoverPresentationController.barButtonItem = sender;
        
        UIAlertAction *defaultAction1 = [UIAlertAction actionWithTitle:@"Blood Pressure Monitor" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.categoryToFilter != OHQDeviceCategoryBloodPressureMonitor) {
                self.categoryToFilter = OHQDeviceCategoryBloodPressureMonitor;
                [self bso_scanForDevices];
            }
        }];
        UIAlertAction *defaultAction2 = [UIAlertAction actionWithTitle:@"Body Composition Monitor / Weight Scale" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //In Omron device, body composition service is secondary service of weight scale service, it is not included in advertisement data, so we can not distinguish between weight scale and body composition monitor by scanning.
            if (self.categoryToFilter != OHQDeviceCategoryWeightScale) {
                self.categoryToFilter = OHQDeviceCategoryWeightScale;
                [self bso_scanForDevices];
            }
        }];
        UIAlertAction *defaultAction3 = [UIAlertAction actionWithTitle:@"Pulse Oximeter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.categoryToFilter != OHQDeviceCategoryPulseOximeter) {
                self.categoryToFilter = OHQDeviceCategoryPulseOximeter;
                [self bso_scanForDevices];
            }
        }];
        UIAlertAction *defaultAction4 = [UIAlertAction actionWithTitle:@"Thermometer" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.categoryToFilter != OHQDeviceCategoryHealthThermometer) {
                self.categoryToFilter = OHQDeviceCategoryHealthThermometer;
                [self bso_scanForDevices];
            }
        }];
        UIAlertAction *defaultAction5 = [UIAlertAction actionWithTitle:@"No Filter" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.categoryToFilter != OHQDeviceCategoryAny) {
                self.categoryToFilter = OHQDeviceCategoryAny;
                [self bso_scanForDevices];
            }
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:defaultAction1];
        [alertController addAction:defaultAction2];
        [alertController addAction:defaultAction3];
        [alertController addAction:defaultAction4];
        [alertController addAction:defaultAction5];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:^{}];
    }
    else if ([sender isEqual:self.menuButton]) {
        // show drawer
        [self.frostedViewController presentMenuViewController];
    }
}

#pragma mark - Navigation

- (IBAction)unwindToDiscoveredDeviceSelectionViewController:(UIStoryboardSegue *)segue {
    // do nothing
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        NSDictionary<OHQDeviceInfoKey,id> *deviceInfo = self.deviceInfoSnapshot[indexPath.row];
        if ([segue.destinationViewController isKindOfClass:[BSOAdvertisementDataViewController class]]) {
            BSOAdvertisementDataViewController *destinationViewController = segue.destinationViewController;
            destinationViewController.advertisementData = deviceInfo[OHQDeviceInfoAdvertisementDataKey];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = self.deviceInfoSnapshot.count;
    
    if ([OHQDeviceManager sharedManager].state == OHQDeviceManagerStatePoweredOn ||
        self.readyToScan) {
        self.navigationItem.title = @"SCANNING...";
        if (numberOfRows == 0 && self.pairingModeDeviceOnly) {
            self.navigationItem.prompt = @"Please put the device in pairing mode.";
            self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        }
        else {
            self.navigationItem.prompt = nil;
        }
    }
    else {
        self.navigationItem.title = @"SCAN";
        self.navigationItem.prompt = nil;
    }
    [self.navigationController.navigationBar sizeToFit];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSODiscoveredDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary<OHQDeviceInfoKey,id> *deviceInfo = self.deviceInfoSnapshot[indexPath.row];
    cell.modelName = deviceInfo[OHQDeviceInfoModelNameKey];
    cell.localName = deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataLocalNameKey];
    cell.RSSI = deviceInfo[OHQDeviceInfoRSSIKey];
    cell.category = [deviceInfo[OHQDeviceInfoCategoryKey] unsignedIntegerValue];
    cell.registered = [self.registeredDeviceUUIDs containsObject:deviceInfo[OHQDeviceInfoIdentifierKey]];
    cell.accessoryType = (self.advertisementDataViewMode ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryDetailDisclosureButton);
    
    NSMutableArray *supportedProtocols = [@[@(BSOProtocolBluetoothStandard)] mutableCopy];
    NSDictionary *manufacturerData = deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataManufacturerDataKey];
    if (manufacturerData) {
        UInt16 companyIdentifier = [manufacturerData[OHQManufacturerDataCompanyIdentifierKey] unsignedShortValue];
        BOOL isBluetoothStandardMode = [manufacturerData[OHQManufacturerDataIsBluetoothStandardMode] boolValue];
        if (companyIdentifier == OHQOmronHealthcareCompanyIdentifier && !isBluetoothStandardMode) {
            [supportedProtocols addObject:@(BSOProtocolOmronExtension)];
        }
    }
    cell.supportedProtocols = supportedProtocols;
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<OHQDeviceInfoKey,id> *deviceInfo = self.deviceInfoSnapshot[indexPath.row];
    NSDictionary *manufactureData = [deviceInfo objectForKey:OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataManufacturerDataKey];
    NSArray<NSDictionary<OHQRecordInfoKey,id> *> *recordInfoArray = manufactureData[OHQManufacturerDataRecordInfoArrayKey];
    __block BOOL breakdown = NO;
    [recordInfoArray enumerateObjectsUsingBlock:^(NSDictionary<OHQRecordInfoKey,id> * _Nonnull recordInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger numberOfRecords = [recordInfo[OHQRecordInfoNumberOfRecordsKey] integerValue];
            NSInteger lastSequenceNumber = [recordInfo[OHQRecordInfoLastSequenceNumberKey] integerValue];
        if (numberOfRecords != 0 && lastSequenceNumber == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Equipment failure" message:nil preferredStyle:UIAlertControllerStyleAlert];
            NSLog(@"Equipment failure");
            breakdown = YES;
            [self presentViewController:alertController animated:YES completion:^(){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2*NSEC_PER_SEC)),
                dispatch_get_main_queue(),^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        }
    }];
    if (breakdown) {
        return;
    }
    if (self.advertisementDataViewMode) {
        [self performSegueWithIdentifier:@"showAdvertisementDataViewController" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    }
    else if (![self.registeredDeviceUUIDs containsObject:deviceInfo[OHQDeviceInfoIdentifierKey]]) {
        [self.delegate discoveredDeviceSelectionViewController:self didSelectDevice:[deviceInfo copy]];
        [NSNotificationCenter.defaultCenter removeObserver:self];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showAdvertisementDataViewController" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Private method

- (void)bso_scanForDevices {
    [[OHQDeviceManager sharedManager] writeBluetoothStatusToLog];
    [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:self.categoryToFilter usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUUID *identifier = deviceInfo[OHQDeviceInfoIdentifierKey];
            [self.deviceIdentifiers addObject:identifier];
            self.deviceInfoCache[identifier] = deviceInfo;
        });
    } completion:^(OHQCompletionReason aReason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (aReason) {
                case OHQCompletionReasonCanceled: {
                    if (self.stopScanCompletionBlock) {
                        self.stopScanCompletionBlock();
                    }
                    break;
                }
                case OHQCompletionReasonBusy: {
                    [self bso_stopScanWithBlock:^{
                        [self bso_removeAllCache];
                        [self bso_scanForDevices];
                    }];
                    break;
                }
                default: {
                    break;
                }
            }
        });
    }];
}

- (void)bso_stopScanWithBlock:(dispatch_block_t)block {
    self.stopScanCompletionBlock = block;
    [[OHQDeviceManager sharedManager] stopScan];
}

- (void)bso_startPeriodicUpdateForTable {
    if (!_reloadTimerRunning) {
        _reloadTimerRunning = YES;
        dispatch_resume(self.reloadTimer);
    }
}

- (void)bso_pausePeriodicUpdateForTable {
    if (_reloadTimerRunning) {
        dispatch_suspend(self.reloadTimer);
        _reloadTimerRunning = NO;
    }
}

- (void)bso_removeAllCache {
    [self.deviceIdentifiers removeAllObjects];
    [self.deviceInfoCache removeAllObjects];
    self.deviceInfoSnapshot = nil;
}

- (void)becomeActive:(NSNotification *)notification {
    // App is active again
    [self checkBluetooth];
}

-(void)checkBluetooth{
    [self bso_pausePeriodicUpdateForTable];
    [self bso_removeAllCache];
    [self.tableView reloadData];

    // Bluetooth permission check
    if (@available(iOS 13.1,*)) {
        if ([CBManager authorization] == CBManagerAuthorizationDenied){
            AlertActionBlock permissionSettingsActionBlock = ^(UIAlertAction *action){
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL: url];
            };
            
            AlertActionBlock permissionSkipActionBlock = ^(UIAlertAction *action){
                self.readyToScan = true;
            };
            
            // permission denied
            [_bleCheck bluetoothPermissionCheck:self
                            settingsActionBlock:permissionSettingsActionBlock
                                skipActionBlock:permissionSkipActionBlock];
        }
    }
    
    // Bluetooth ON/OFF check
    if ([OHQDeviceManager sharedManager].state != OHQDeviceManagerStatePoweredOn) {
        // Bluetooth OFF
        AlertActionBlock bluetoothSettingsActionBlock = ^(UIAlertAction *action){
            NSString *settingsUrl = @"App-prefs:Bluetooth";
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl]
                                                   options:@{}
                                         completionHandler:^(BOOL success) {
                    NSLog(@"URL opened");
                }];
            }
        };
        
        AlertActionBlock bluetoothSkipActionBlock = ^(UIAlertAction *action){
            self.readyToScan = true;
        };
        
        [_bleCheck bluetoothStateCheck:self
                   settingsActionBlock:bluetoothSettingsActionBlock
                       skipActionBlock:bluetoothSkipActionBlock];
    }
    
    [self bso_scanForDevices];
    [self bso_startPeriodicUpdateForTable];
}

@end
