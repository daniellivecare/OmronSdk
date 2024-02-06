//
//  BSOUserHomeViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOUserHomeViewController.h"
#import "BSODefines.h"
#import "BSORegisteredDeviceCell.h"
#import "BSORegisteredDeviceDetailViewController.h"
#import "BSOSessionViewController.h"
#import "BSOSessionResultNavigationController.h"
#import "BSOSessionData.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "BSODeviceEntity+CoreDataClass.h"
#import "BSOHistoryEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"
#import "OHQReferenceCode.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "OHQDeviceManager.h"

static const NSTimeInterval TableReloadInterval = 1.0;
static void * const KVOContext = (void *)&KVOContext;

@interface BSOUserHomeViewController () <BSOSessionViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (copy, nonatomic) NSDictionary<NSUUID *,NSDictionary<OHQDeviceInfoKey,id> *> *deviceInfoSnapshot;
@property (copy, nonatomic) dispatch_block_t stopScanCompletionBlock;
@property (strong, nonatomic) NSMutableDictionary<NSUUID *,NSDictionary<OHQDeviceInfoKey,id> *> *deviceInfoCache;
@property (strong, nonatomic) dispatch_source_t reloadTimer;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BSOUserEntity *userEntity;
@property (strong, nonatomic) BSODeviceEntity *deviceEntity;
@property (assign, nonatomic) BOOL reloadTimerRunning;

@end

@implementation BSOUserHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:BSOAppConfigCurrentUserNameKey];
    if (!userName || [userName isEqualToString:BSOGuestUserName]) {
        abort();
    }
    
    NSFetchRequest *fetchRequest = [BSOUserEntity fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", userName];
    self.context = [BSOPersistentContainer sharedPersistentContainer].viewContext;
    self.userEntity = [self.context executeFetchRequest:fetchRequest error:nil].firstObject;
    if (!self.userEntity) {
        abort();
    }
    
    self.tableView.rowHeight = [BSORegisteredDeviceCell rowHeight];
    self.deviceInfoCache = [@{} mutableCopy];
    self.deviceInfoSnapshot = nil;
    self.stopScanCompletionBlock = nil;
    self.reloadTimerRunning = NO;
    
    self.reloadTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.reloadTimer, DISPATCH_TIME_NOW, TableReloadInterval * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.reloadTimer, ^{
        self.deviceInfoSnapshot = [self.deviceInfoCache copy];
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
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
            if ([OHQDeviceManager sharedManager].state == OHQDeviceManagerStatePoweredOn) {
                // Bluetooth ON
                [self bso_scanForDevices];
                [self bso_startPeriodicUpdateForTable];
            }
            else {
                // Bluetooth OFF
                [self bso_pausePeriodicUpdateForTable];
            }
        });
    }
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    if ([barButtonItem isEqual:self.menuButton]) {
        // show drawer
        [self.frostedViewController presentMenuViewController];
    }
    else if ([barButtonItem isEqual:self.addButton]) {
        // register new device
    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        BSODeviceEntity *deviceEntity = self.userEntity.registeredDevices[indexPath.row];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        if ([segue.destinationViewController isKindOfClass:[BSORegisteredDeviceDetailViewController class]]) {
            BSORegisteredDeviceDetailViewController *vc = segue.destinationViewController;
            vc.deviceIdentifier = deviceEntity.identifier;
        }
        else if ([segue.destinationViewController isKindOfClass:[BSOSessionViewController class]]) {
            BSORegisteredDeviceCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if (cell.isBreakdown){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Equipment failure" message:nil preferredStyle:UIAlertControllerStyleAlert];
                NSLog(@"Equipment failure");
                [self presentViewController:alertController animated:YES completion:^(){
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2*NSEC_PER_SEC)),
                                   dispatch_get_main_queue(),^{
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                   });
                }];
            }

            BSOSessionViewController *vc = segue.destinationViewController;
            vc.deviceIdentifier = deviceEntity.identifier;
            NSMutableDictionary<OHQSessionOptionKey,id> *options = [@{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                                                                      OHQSessionOptionConnectionWaitTimeKey: @60.0} mutableCopy];
            if (deviceEntity.userIndex) {
                options[OHQSessionOptionUserIndexKey] = deviceEntity.userIndex;
                options[OHQSessionOptionUserDataKey] = @{OHQUserDataDateOfBirthKey: [NSDate dateWithLocalTimeString:self.userEntity.dateOfBirth format:@"yyyy-MM-dd"],
                                                         OHQUserDataHeightKey: self.userEntity.height,
                                                         OHQUserDataGenderKey: self.userEntity.gender};
                options[OHQSessionOptionUserDataUpdateFlagKey] = deviceEntity.databaseUpdateFlag;
                options[OHQSessionOptionDatabaseChangeIncrementValueKey] = deviceEntity.databaseChangeIncrement;
            }
            if (deviceEntity.protocol == BSOProtocolOmronExtension) {
                options[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] = @YES;
                options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] = @YES;
                if (deviceEntity.lastSequenceNumber) {
                    options[OHQSessionOptionSequenceNumberOfFirstRecordToReadKey] = @(deviceEntity.lastSequenceNumber.unsignedIntegerValue + 1);
                }
                options[OHQSessionOptionDatabaseChangeIncrementValueKey] = deviceEntity.databaseChangeIncrement;
            }
            vc.options = options;
            vc.delegate = self;
        }
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    BSODeviceEntity *deviceEntity = self.userEntity.registeredDevices[indexPath.row];
    NSMutableString *alertMessage = [NSMutableString stringWithString:@"Do you transfer data ?"];
    
    if(deviceEntity.deviceCategory == OHQDeviceCategoryPulseOximeter){
        [alertMessage appendString:@"\nPlease place a finger into the device."];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"CANCEL" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"showSessionViewController" sender:cell];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
     
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userEntity.registeredDevices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BSORegisteredDeviceCell *cell  = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    BSODeviceEntity *deviceEntity = self.userEntity.registeredDevices[indexPath.row];
    NSDictionary<OHQDeviceInfoKey,id> *deviceInfo = self.deviceInfoSnapshot[deviceEntity.identifier];
    BSOProtocol protocol = deviceEntity.protocol;
    
    cell.category = deviceEntity.deviceCategory;
    cell.modelName = deviceEntity.modelName;
    cell.localName = deviceEntity.localName;
    cell.userIndex = deviceEntity.userIndex;
    cell.protocol = protocol;
    
    __block BOOL newDataAvailable = NO;
    __block BOOL breakdown = NO;
    if (deviceInfo && protocol == BSOProtocolOmronExtension) {
        NSDictionary<OHQManufacturerDataKey,id> *manufactureData = deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataManufacturerDataKey];
        NSArray<NSDictionary<OHQRecordInfoKey,id> *> *recordInfoArray = manufactureData[OHQManufacturerDataRecordInfoArrayKey];
        [recordInfoArray enumerateObjectsUsingBlock:^(NSDictionary<OHQRecordInfoKey,id> * _Nonnull recordInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([recordInfo[OHQRecordInfoUserIndexKey] isEqualToNumber:deviceEntity.userIndex]) {
                NSInteger numberOfRecords = [recordInfo[OHQRecordInfoNumberOfRecordsKey] integerValue];
                NSInteger lastSequenceNumber = [recordInfo[OHQRecordInfoLastSequenceNumberKey] integerValue];
                if (numberOfRecords != 0 && lastSequenceNumber == 0) {
                    breakdown = YES;
                }
                newDataAvailable = (numberOfRecords > 0 && lastSequenceNumber > deviceEntity.lastSequenceNumber.integerValue);
                *stop = YES;
            }
        }];
    }
    cell.hasUpdatedData = newDataAvailable;
    cell.isBreakdown = breakdown;
    
    return cell;
}

#pragma mark - Session view controller delegate

- (void)sessionViewControllerDidCancelSessionByUserOperation:(BSOSessionViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)sessionViewController:(BSOSessionViewController *)viewController completionMessageForData:(BSOSessionData *)data {
    return ([self bso_validateSessionWithData:data] ? @"Succeeded !" : @"Failed");
}

- (void)sessionViewController:(BSOSessionViewController *)viewController didCompleteSessionWithData:(BSOSessionData *)data {
    BOOL successful = [self bso_validateSessionWithData:data];
    
    // retrieve device entity
    __block BSODeviceEntity *deviceEntity = nil;
    [self.userEntity.registeredDevices enumerateObjectsUsingBlock:^(BSODeviceEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqual:data.identifier]) {
            deviceEntity = obj;
            *stop = YES;
        }
    }];
    
    NSString *deviceStatus = @"-";
    NSString *deviceAuthorization = @"-";
    
    if ([OHQDeviceManager sharedManager].state == OHQDeviceManagerStatePoweredOn) {
        deviceStatus = @"ON";
        if (@available(iOS 13.0, *)) {
            if ([OHQDeviceManager sharedManager].authorization == OHQDeviceManagerAuthorizationAllowed) {
                deviceAuthorization = @"Granted";
            }
        }
    } else {
        if ([OHQDeviceManager sharedManager].state == OHQDeviceManagerStateUnauthorized) {
        } else {
            if (@available(iOS 13.0, *)) {
                if ([OHQDeviceManager sharedManager].authorization == OHQDeviceManagerAuthorizationAllowed) {
                }
            }
        }
    }

    // insert new history entity
    BSOHistoryEntity *historyEntity = [BSOHistoryEntity insertNewEntityInContext:self.context];
    historyEntity.bluetoothStatus = deviceStatus;
    historyEntity.bluetoothAuthorization = deviceAuthorization;
    historyEntity.identifier = [NSUUID UUID];
    historyEntity.batteryLevel = data.batteryLevel;
    historyEntity.completionDate = data.completionDate;
    historyEntity.consentCode = data.options[OHQSessionOptionConsentCodeKey];
    historyEntity.deviceCategory = (data.deviceCategory != OHQDeviceCategoryUnknown ?
                                    data.deviceCategory : deviceEntity.deviceCategory);
    historyEntity.deviceTime = data.currentTime;
    historyEntity.localName = deviceEntity.localName;
    historyEntity.measurementRecords = data.measurementRecords;
    historyEntity.modelName = (data.modelName ? data.modelName : deviceEntity.modelName);
    historyEntity.operation = BSOOperationTransfer;
    historyEntity.protocol = deviceEntity.protocol;
    historyEntity.status = (successful ? @"Success" : @"Failure");
    historyEntity.userData = data.userData;
    historyEntity.userIndex = (data.registeredUserIndex ? data.registeredUserIndex : data.options[OHQSessionOptionUserIndexKey]);
    historyEntity.userName = self.userEntity.name;
    historyEntity.logHeader = BSOLogHeaderString(data.completionDate);
    historyEntity.log = data.log;
    
    if (successful) {
        if (data.userData.count) {
            NSDate *dateOfBirth = data.userData[OHQUserDataDateOfBirthKey];
            NSString *dateOfBirthString = [dateOfBirth localTimeStringWithFormat:@"yyyy-MM-dd"];
            if (dateOfBirthString.length && ![self.userEntity.dateOfBirth isEqualToString:dateOfBirthString]) {
                self.userEntity.dateOfBirth = [dateOfBirth localTimeStringWithFormat:@"yyyy-MM-dd"];
            }
            NSNumber *height = data.userData[OHQUserDataHeightKey];
            if (height && ![self.userEntity.height isEqualToNumber:height]) {
                self.userEntity.height = height;
            }
            OHQGender gender = data.userData[OHQUserDataGenderKey];
            if (gender && ![self.userEntity.gender isEqualToString:gender]) {
                self.userEntity.gender = gender;
            }
            if (self.userEntity.hasChanges) {
                [self.userEntity.registeredDevices enumerateObjectsUsingBlock:^(BSODeviceEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isEqual:deviceEntity] && obj.databaseChangeIncrement && !obj.databaseUpdateFlag.boolValue) {
                        obj.databaseChangeIncrement = @(obj.databaseChangeIncrement.unsignedIntValue + 1);
                        obj.databaseUpdateFlag = @YES;
                    }
                }];
            }
        }
        deviceEntity.lastSequenceNumber = data.sequenceNumberOfLatestRecord;
        deviceEntity.databaseChangeIncrement = data.databaseChangeIncrement;
        deviceEntity.databaseUpdateFlag = @NO;
    }
    
    // save changes
    [[BSOPersistentContainer sharedPersistentContainer] saveContextChanges:self.context];
    
    // close session view controller
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    // show session result view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BSOSessionResultNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SessionResultNavigationController"];
    vc.historyIdentifier = historyEntity.identifier;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Private method

- (BOOL)bso_validateSessionWithData:(BSOSessionData *)data {
    if (data.completionReason != OHQCompletionReasonDisconnected) {
        return NO;
    }
    if (!data.currentTime && !data.batteryLevel && !data.measurementRecords.count) {
        return NO;
    }
    if ([data.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] && !data.measurementRecords) {
        return NO;
    }
    if ((data.deviceCategory == OHQDeviceCategoryPulseOximeter) &&
        (!data.measurementRecords.count)){
        return NO;
    }
    return YES;
}

- (void)bso_scanForDevices {
    [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:OHQDeviceCategoryAny usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUUID *identifier = deviceInfo[OHQDeviceInfoIdentifierKey];
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
    [self.deviceInfoCache removeAllObjects];
    [self.tableView reloadData];
}

@end
