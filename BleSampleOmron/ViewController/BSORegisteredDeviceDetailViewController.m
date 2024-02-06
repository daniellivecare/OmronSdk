//
//  BSORegisteredDeviceDetailViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSORegisteredDeviceDetailViewController.h"
#import "BSODefines.h"
#import "BSOSessionViewController.h"
#import "BSOSessionResultNavigationController.h"
#import "BSOSessionData.h"
#import "BSOPersistentContainer.h"
#import "UIColor+BleSampleOmron.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "BSODeviceEntity+CoreDataClass.h"
#import "BSOHistoryEntity+CoreDataClass.h"
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import "OHQDeviceManager.h"

typedef NS_ENUM(NSUInteger, RowType) {
    RowTypeLocalName,
    RowTypeProtocol,
    RowTypeUserIndex,
    RowTypeConsentCode,
    RowTypeLastSequenceNumber,
    RowTypeForgetButton,
};

static NSString * const SectionHeaderTitleKey = @"sectionTitle";
static NSString * const SectionRowsKey = @"sectionRows";

static CLLocationManager *_locationManager;

@interface BSORegisteredDeviceDetailViewController () <UITextFieldDelegate, BSOSessionViewControllerDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *sequenceNumberField;
@property (weak, nonatomic) IBOutlet UIButton *forgetButton;

@property (copy, nonatomic) NSArray<NSDictionary *> *tableItems;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BSOUserEntity *userEntity;
@property (strong, nonatomic) BSODeviceEntity *deviceEntity;

@end

@implementation BSORegisteredDeviceDetailViewController

+ (void)initialize {
    if (self == [BSORegisteredDeviceDetailViewController class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _locationManager = [CLLocationManager new];
        });
    }
}

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
    
    [self.userEntity.registeredDevices enumerateObjectsUsingBlock:^(BSODeviceEntity * _Nonnull deviceEntity, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([deviceEntity.identifier isEqual:self.deviceIdentifier]) {
            self.deviceEntity = deviceEntity;
            *stop = YES;
        }
    }];
    if (!self.deviceEntity) {
        abort();
    }

    self.navigationItem.title = self.deviceEntity.modelName;
    self.tableView.rowHeight = 44.0f;
    
    NSMutableArray<NSDictionary *> *tableItems = [@[@{SectionHeaderTitleKey: @"Local Name", SectionRowsKey: @[@(RowTypeLocalName)]},
                                                    @{SectionHeaderTitleKey: @"Protocol", SectionRowsKey: @[@(RowTypeProtocol)]}] mutableCopy];
    if (self.deviceEntity.userIndex) {
        NSMutableArray<NSNumber *> *registrationInfomationRows = [@[@(RowTypeUserIndex), @(RowTypeConsentCode)] mutableCopy];
        if (self.deviceEntity.lastSequenceNumber) {
            [registrationInfomationRows addObject:@(RowTypeLastSequenceNumber)];
        }
        [tableItems addObject:@{SectionHeaderTitleKey: @"Registration Information", SectionRowsKey: registrationInfomationRows}];
    }
    [tableItems addObject:@{SectionRowsKey: @[@(RowTypeForgetButton)]}];
    self.tableItems = tableItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)buttonDidTouchUpInside:(UIButton *)button {
    if ([button isEqual:self.forgetButton]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteUserDataAction = [UIAlertAction actionWithTitle:@"Delete User from Device" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"showSessionViewController" sender:self.forgetButton];
        }];
        UIAlertAction *forgetDeviceAction = [UIAlertAction actionWithTitle:@"Forget Device" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            BSOPersistentContainer *container = [BSOPersistentContainer sharedPersistentContainer];
            NSManagedObjectContext *context = container.viewContext;
            [context deleteObject:self.deviceEntity];
            [container saveContextChanges:context];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        if (self.deviceEntity.userIndex) {
            [alertController addAction:deleteUserDataAction];
        }
        [alertController addAction:forgetDeviceAction];
        
        [alertController addAction:cancelAction];
        alertController.popoverPresentationController.sourceView = self.forgetButton;
        alertController.popoverPresentationController.sourceRect = self.forgetButton.frame;
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSessionViewController"]) {
        BSOSessionViewController *vc = segue.destinationViewController;
        vc.deviceIdentifier = self.deviceIdentifier;
        vc.options = @{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                       OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey: @YES,
                       OHQSessionOptionUserIndexKey: self.deviceEntity.userIndex,
                       OHQSessionOptionDeleteUserDataKey: @YES,
                       OHQSessionOptionConnectionWaitTimeKey: @60.0};
        vc.delegate = self;
    }
}

#pragma mark - Text field delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.sequenceNumberField]) {
        NSScanner *scanner = [NSScanner scannerWithString:textField.text];
        NSInteger sequenceNumber = 0;
        if ([scanner scanInteger:&sequenceNumber]) {
            if (![self.deviceEntity.lastSequenceNumber isEqualToNumber:@(sequenceNumber)]) {
                self.deviceEntity.lastSequenceNumber = @(sequenceNumber);
                [[BSOPersistentContainer sharedPersistentContainer] saveContextChanges:self.context];
            }
        }
        else {
            textField.text = @"0";
            self.deviceEntity.lastSequenceNumber = @0;
            [[BSOPersistentContainer sharedPersistentContainer] saveContextChanges:self.context];
        }
    }
}

#pragma mark - Session view controller delegate

- (void)sessionViewControllerDidCancelSessionByUserOperation:(BSOSessionViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)sessionViewController:(BSOSessionViewController *)viewController completionMessageForData:(BSOSessionData *)data {
    return ([self bso_validateSessionWithData:data] ? @"Deleted !" : @"Failed");
}

- (void)sessionViewController:(BSOSessionViewController *)viewController didCompleteSessionWithData:(BSOSessionData *)data {
    BOOL deleted = [self bso_validateSessionWithData:data];
    
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

    // insert new history
    BSOHistoryEntity *historyEntity = [BSOHistoryEntity insertNewEntityInContext:self.context];
    historyEntity.bluetoothStatus = deviceStatus;
    historyEntity.bluetoothAuthorization = deviceAuthorization;
    historyEntity.batteryLevel = data.batteryLevel;
    historyEntity.completionDate = data.completionDate;
    historyEntity.consentCode = data.options[OHQSessionOptionConsentCodeKey];
    historyEntity.deviceCategory = (data.deviceCategory != OHQDeviceCategoryUnknown ?
                                    data.deviceCategory : self.deviceEntity.deviceCategory);
    historyEntity.deviceTime = data.currentTime;
    historyEntity.identifier = [NSUUID UUID];
    historyEntity.localName = self.deviceEntity.localName;
    historyEntity.log = data.log;
    historyEntity.measurementRecords = data.measurementRecords;
    historyEntity.modelName = (data.modelName ? data.modelName : self.deviceEntity.modelName);
    historyEntity.operation = BSOOperationDelete;
    historyEntity.protocol = self.deviceEntity.protocol;
    historyEntity.status = (deleted ? @"Success" : @"Failure");
    historyEntity.userData = data.userData;
    historyEntity.userIndex = (data.deletedUserIndex ? data.deletedUserIndex : data.options[OHQSessionOptionUserIndexKey]);
    historyEntity.userName = self.userEntity.name;
    historyEntity.logHeader = BSOLogHeaderString(data.completionDate);

    // delete device entity
    if (deleted) {
        [self.context deleteObject:self.deviceEntity];
    }
    
    // save changes
    [[BSOPersistentContainer sharedPersistentContainer] saveContextChanges:self.context];
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BSOSessionResultNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SessionResultNavigationController"];
    vc.historyIdentifier = historyEntity.identifier;
    [self.navigationController presentViewController:vc animated:YES completion:^{
        if (deleted) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableItems[section][SectionHeaderTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowTypes = self.tableItems[section][SectionRowsKey];
    return rowTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSArray *rowTypes = self.tableItems[indexPath.section][SectionRowsKey];
    RowType rowType = [rowTypes[indexPath.row] unsignedIntegerValue];

    switch (rowType) {
        case RowTypeLocalName: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont fontWithName:@"Avenir-Book" size:15.0];
            cell.textLabel.text = self.deviceEntity.localName;
            break;
        }
        case RowTypeProtocol: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
            cell.textLabel.text = BSOProtocolDescription(self.deviceEntity.protocol);
            break;
        }
        case RowTypeUserIndex: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetailCell" forIndexPath:indexPath];
            cell.textLabel.text = @"User Index";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.deviceEntity.userIndex];
            break;
        }
        case RowTypeConsentCode: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"RightDetailCell" forIndexPath:indexPath];
            cell.textLabel.text = @"Consent Code";
            if (self.deviceEntity.consentCode) {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"0x%04X", self.deviceEntity.consentCode.unsignedShortValue];
            }
            else {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"0x%04X", OHQDefaultConsentCode];
            }
            break;
        }
        case RowTypeLastSequenceNumber: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"RightTextFieldCell" forIndexPath:indexPath];
            UILabel *textLabel = [cell viewWithTag:1];
            textLabel.text = @"Last Sequence Number";
            self.sequenceNumberField = [cell viewWithTag:2];
            self.sequenceNumberField.text = [NSString stringWithFormat:@"%d", self.deviceEntity.lastSequenceNumber.unsignedIntValue];
            self.sequenceNumberField.keyboardType = UIKeyboardTypeNumberPad;
            self.sequenceNumberField.delegate = self;
            break;
        }
        case RowTypeForgetButton: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:@"ButtonCell" forIndexPath:indexPath];
            self.forgetButton = [cell viewWithTag:1];
            self.forgetButton.tintColor = [UIColor destructiveAlertTextColor];
            [self.forgetButton setTitle:@"Forget This Device" forState:0];
            [self.forgetButton addTarget:self action:@selector(buttonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        default: {
            break;
        }
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *rowTypes = self.tableItems[indexPath.section][SectionRowsKey];
    RowType rowType = [rowTypes[indexPath.row] unsignedIntegerValue];
    
    if (rowType == RowTypeLastSequenceNumber) {
        [self.sequenceNumberField becomeFirstResponder];
    }
    else {
        [self.sequenceNumberField resignFirstResponder];
    }
}

#pragma mark - Private methods

- (BOOL)bso_validateSessionWithData:(BSOSessionData *)data {
    if (data.completionReason != OHQCompletionReasonDisconnected) {
        return NO;
    }
    if (!data.currentTime && !data.batteryLevel) {
        return NO;
    }
    if ([data.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] && !data.measurementRecords) {
        return NO;
    }
    if ([data.options[OHQSessionOptionDeleteUserDataKey] boolValue] && !data.deletedUserIndex) {
        return NO;
    }
    return YES;
}

@end
