//
//  BSOGuestUserHomeViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOGuestUserHomeViewController.h"
#import "BSODeviceSelectionNavigationController.h"
#import "BSOGenderSelectionViewController.h"
#import "BSOSessionViewController.h"
#import "BSOSessionResultNavigationController.h"
#import "BSOPersistentContainer.h"
#import "BSOHistoryEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"
#import "REFrostedViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "OHQReferenceCode.h"
#import "OHQDeviceManager.h"

typedef NS_ENUM(NSUInteger, SectionType) {
    SectionTypeDevice = 0,
    SectionTypeModeChangeButton,
    SectionTypeTransferButton,
    SectionTypeProfile,
};

typedef NS_ENUM(NSUInteger, RowType) {
    RowTypeDevicePlaceholder,
    RowTypeDevice,
    RowTypeSetToNormalMode,
    RowTypeSetToUnregisteredUserMode,
    RowTypeTransfer,
    RowTypeDateOfBirth,
    RowTypeDatePicker,
    RowTypeHeight,
    RowTypeGender,
};

static NSString * const SectionHeaderTitleKey = @"sectionHeaderTitle";
static NSString * const SectionFooterTitleKey = @"sectionFooterTitle";
static NSString * const SectionRowsKey = @"sectionRows";

static NSString * const DevicePlaceholderCellIdentifier = @"DevicePlaceholderCell";
static NSString * const DeviceCellIdentifier = @"DeviceCell";
static NSString * const ButtonCellIdentifier = @"ButtonCell";
static NSString * const DateOfBirthCellIdentifier = @"DateOfBirthCell";
static NSString * const DatePickerCellIdentifier = @"DatePickerCell";
static NSString * const HeightCellIdentifier = @"HeightCell";
static NSString * const GenderCellIdentifier = @"GenderCell";

static NSString * const NormalModeButtonTitle = @"Change the device to normal mode";
static NSString * const UnregisteredUserModeButtonTitle = @"Change the device to unregistered user mode";
static NSString * const TransferButtonTitle = @"Receive measurement records";

static const NSInteger HeightCellTextFieldTag = 1;
static const NSInteger ButtonCellButtonTag = 1;
static const NSInteger DatePickerCellDatePickerTag = 1;

static NSMutableDictionary<OHQDeviceInfoKey,id> *_deviceInfo;
static NSMutableDictionary<OHQUserDataKey,id> *_userData;

@interface BSOGuestUserHomeViewController () <BSODeviceSelectionNavigationControllerDelegate, BSOGenderSelectionViewControllerDelegate, BSOSessionViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (weak, nonatomic) UILabel *modelNameLabel;
@property (weak, nonatomic) UILabel *localNameLabel;
@property (weak, nonatomic) UILabel *dateLabel;
@property (weak, nonatomic) UILabel *genderLabel;
@property (weak, nonatomic) UIButton *normalModeButton;
@property (weak, nonatomic) UIButton *unregisteredUserModeButton;
@property (weak, nonatomic) UIButton *transferButton;
@property (weak, nonatomic) UITextField *heightField;
@property (weak, nonatomic) UIDatePicker *datePicker;

@property (copy, nonatomic) NSArray<NSDictionary<NSString *,id> *> *tableItems;
@property (copy, nonatomic) NSDictionary<OHQSessionOptionKey,id> *options;
@property (assign, nonatomic) BSOOperation operation;
@property (assign, nonatomic) CGFloat datePickerCellHeight;
@property (assign, nonatomic) BOOL datePickerAvailable;

@end

@implementation BSOGuestUserHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_userData) {
        // default guest user profile
        _userData = [@{OHQUserDataDateOfBirthKey: [NSDate dateWithLocalTimeString:@"2001-01-01" format:@"yyyy-MM-dd"],
                       OHQUserDataHeightKey: @171.5,
                       OHQUserDataGenderKey: OHQGenderMale,
                       } mutableCopy];
    }
    
    self.tableView.rowHeight = 44.0f;
    
    UITableViewCell *datePickerCell = [self.tableView dequeueReusableCellWithIdentifier:DatePickerCellIdentifier];
    self.datePickerCellHeight = CGRectGetHeight(datePickerCell.frame);
    self.datePickerAvailable = NO;
    
    self.tableItems = [@[] mutableCopy];
    [self bso_updateTableItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    [self.view endEditing:YES];
    if ([barButtonItem isEqual:self.menuButton]) {
        // show drawer
        [self.frostedViewController presentMenuViewController];
    }
}

- (IBAction)buttonDidTouchUpInside:(UIButton *)button {
    if ([button isEqual:self.normalModeButton]) {
        self.operation = BSOOperationDelete;
        self.options = @{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                         OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey: @YES,
                         OHQSessionOptionDeleteUserDataKey: @YES,
                         OHQSessionOptionConsentCodeKey: @0,
                         OHQSessionOptionUserIndexKey: @0xFF,
                         OHQSessionOptionConnectionWaitTimeKey: @60.0};
    }
    else if ([button isEqual:self.unregisteredUserModeButton]) {
        self.operation = BSOOperationRegister;
        self.options = @{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                         OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey: @YES,
                         OHQSessionOptionRegisterNewUserKey: @YES,
                         OHQSessionOptionConsentCodeKey: @0,
                         OHQSessionOptionUserIndexKey: @0xFF,
                         OHQSessionOptionConnectionWaitTimeKey: @60.0};
    }
    else if ([button isEqual:self.transferButton]) {
        self.operation = BSOOperationTransfer;
        self.options = @{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                         OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey: @YES,
                         OHQSessionOptionConsentCodeKey: @0,
                         OHQSessionOptionUserIndexKey: @0xFF,
                         OHQSessionOptionUserDataKey: [_userData copy],
                         OHQSessionOptionConnectionWaitTimeKey: @60.0};
    }
    if (self.options) {
        [self performSegueWithIdentifier:@"showSessionViewController" sender:button];
    }
}

- (IBAction)datePickerDidUpdateValue:(UIDatePicker *)datePicker {
    _userData[OHQUserDataDateOfBirthKey] = datePicker.date;
    NSIndexPath *indexPath = [self bso_indexPathWithRowType:RowTypeDateOfBirth];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[BSODeviceSelectionNavigationController class]]) {
        BSODeviceSelectionNavigationController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[BSOGenderSelectionViewController class]]) {
        BSOGenderSelectionViewController *vc = segue.destinationViewController;
        vc.gender = _userData[OHQUserDataGenderKey];
        vc.delegate = self;
    }
    else if ([segue.destinationViewController isKindOfClass:[BSOSessionViewController class]]) {
        BSOSessionViewController *vc = segue.destinationViewController;
        vc.deviceIdentifier = _deviceInfo[OHQDeviceInfoIdentifierKey];
        vc.options = self.options;
        vc.delegate = self;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableItems[section][SectionHeaderTitleKey];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.tableItems[section][SectionFooterTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.tableItems[section][SectionRowsKey];
    return rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat ret = self.tableView.rowHeight;
    RowType rowType = [self.tableItems[indexPath.section][SectionRowsKey][indexPath.row] unsignedIntegerValue];
    if (rowType == RowTypeDatePicker) {
        ret = self.datePickerCellHeight;
    }
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RowType rowType = [self.tableItems[indexPath.section][SectionRowsKey][indexPath.row] unsignedIntegerValue];
    UITableViewCell *cell = nil;
    switch (rowType) {
        case RowTypeDevicePlaceholder: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:DevicePlaceholderCellIdentifier];
            break;
        }
        case RowTypeDevice: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:DeviceCellIdentifier];
            self.modelNameLabel = cell.textLabel;
            self.localNameLabel = cell.detailTextLabel;
            self.modelNameLabel.text = _deviceInfo[OHQDeviceInfoModelNameKey];
            self.localNameLabel.text = _deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataLocalNameKey];
            break;
        }
        case RowTypeSetToNormalMode: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
            self.normalModeButton = [cell viewWithTag:ButtonCellButtonTag];
            [self.normalModeButton setTitle:NormalModeButtonTitle forState:UIControlStateNormal];
            self.normalModeButton.enabled = !!_deviceInfo;
            break;
        }
        case RowTypeSetToUnregisteredUserMode: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
            self.unregisteredUserModeButton = [cell viewWithTag:ButtonCellButtonTag];
            [self.unregisteredUserModeButton setTitle:UnregisteredUserModeButtonTitle forState:UIControlStateNormal];
            self.unregisteredUserModeButton.enabled = !!_deviceInfo;
            break;
        }
        case RowTypeTransfer: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
            self.transferButton = [cell viewWithTag:ButtonCellButtonTag];
            [self.transferButton setTitle:TransferButtonTitle forState:UIControlStateNormal];
            self.transferButton.enabled = !!_deviceInfo;
            break;
        }
        case RowTypeDateOfBirth: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:DateOfBirthCellIdentifier];
            self.dateLabel = cell.detailTextLabel;
            NSDate *dateOfBirth = _userData[OHQUserDataDateOfBirthKey];
            self.dateLabel.text = (dateOfBirth ? [dateOfBirth localTimeStringWithFormat:@"yyyy-MM-dd"] : @"-");
            break;
        }
        case RowTypeDatePicker: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:DatePickerCellIdentifier];
            self.datePicker = [cell viewWithTag:DatePickerCellDatePickerTag];
            NSDate *dateOfBirth = _userData[OHQUserDataDateOfBirthKey];
            self.datePicker.date = dateOfBirth;
            self.datePicker.maximumDate = [NSDate date];
            break;
        }
        case RowTypeHeight: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:HeightCellIdentifier];
            self.heightField = [cell viewWithTag:HeightCellTextFieldTag];
            self.heightField.text = [NSString stringWithFormat:@"%@ cm", _userData[OHQUserDataHeightKey]];
            self.heightField.delegate = self;
            break;
        }
        case RowTypeGender: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:GenderCellIdentifier];
            self.genderLabel = cell.detailTextLabel;
            self.genderLabel.text = ([_userData[OHQUserDataGenderKey] isEqualToString:OHQGenderMale] ? @"Male" : @"Female");
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RowType rowType = [self.tableItems[indexPath.section][SectionRowsKey][indexPath.row] unsignedIntegerValue];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (rowType != RowTypeDevicePlaceholder && rowType != RowTypeDevice && rowType != RowTypeGender) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
    if (self.datePickerAvailable) {
        if (rowType != RowTypeDatePicker) {
            [self bso_dismissDatePickerCell];
        }
    }
    else {
        if (rowType == RowTypeDateOfBirth) {
            [self bso_showDatePickerCell];
        }
    }

    if (rowType == RowTypeDevicePlaceholder || rowType == RowTypeDevice) {
        [self performSegueWithIdentifier:@"showDeviceSelectionNavigationController" sender:cell];
    }
    
    if (rowType == RowTypeHeight) {
        [self.heightField becomeFirstResponder];
    }
    else {
        [self.heightField resignFirstResponder];
    }
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self bso_dismissDatePickerCell];
    
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
    NSDecimal decimal = {0};
    [scanner scanDecimal:&decimal];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:decimal];
    textField.text = decimalNumber.stringValue;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSScanner *scanner = [NSScanner scannerWithString:textField.text];
    NSDecimal decimal = {0};
    [scanner scanDecimal:&decimal];
    NSDecimalNumber *decimalNumber = [NSDecimalNumber decimalNumberWithDecimal:decimal];
    _userData[OHQUserDataHeightKey] = decimalNumber;
    
    NSIndexPath *indexPath = [self bso_indexPathWithRowType:RowTypeHeight];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Gender selection view controller delegate

- (void)genderSelectionViewControllerDidUpdateValue:(BSOGenderSelectionViewController *)genderSelectionViewController {
    _userData[OHQUserDataGenderKey] = genderSelectionViewController.gender;

    NSIndexPath *indexPath = [self bso_indexPathWithRowType:RowTypeGender];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Device selection navigation controller delegate

- (void)deviceSelectionNavigationController:(BSODeviceSelectionNavigationController *)navController didSelectDevice:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo {
    [navController performSegueWithIdentifier:@"unwindToRoot" sender:self];
    
    [self.tableView beginUpdates];
    _deviceInfo = [deviceInfo mutableCopy];
    [self bso_updateTableItems];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
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
    
    NSManagedObjectContext *context = [BSOPersistentContainer sharedPersistentContainer].viewContext;
    
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
    BSOHistoryEntity *historyEntity = [BSOHistoryEntity insertNewEntityInContext:context];
    historyEntity.bluetoothStatus = deviceStatus;
    historyEntity.bluetoothAuthorization = deviceAuthorization;
    historyEntity.batteryLevel = data.batteryLevel;
    historyEntity.completionDate = data.completionDate;
    historyEntity.consentCode = data.options[OHQSessionOptionConsentCodeKey];
    historyEntity.deviceCategory = (data.deviceCategory != OHQDeviceCategoryUnknown ?
                                    data.deviceCategory : [_deviceInfo[OHQDeviceInfoCategoryKey] unsignedIntegerValue]);
    historyEntity.deviceTime = data.currentTime;
    historyEntity.identifier = [NSUUID UUID];
    historyEntity.localName = _deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataLocalNameKey];
    historyEntity.log = data.log;
    historyEntity.measurementRecords = data.measurementRecords;
    historyEntity.modelName = (data.modelName ? data.modelName : _deviceInfo[OHQDeviceInfoModelNameKey]);
    historyEntity.operation = self.operation;
    historyEntity.protocol = BSOProtocolOmronExtension;
    historyEntity.status = (successful ? @"Success" : @"Failure");
    historyEntity.userData = data.userData;
    historyEntity.userIndex = (data.registeredUserIndex ? data.registeredUserIndex : data.options[OHQSessionOptionUserIndexKey]);
    historyEntity.userName = BSOGuestUserName;
    historyEntity.logHeader = BSOLogHeaderString(data.completionDate);
    
    // save changes
    [[BSOPersistentContainer sharedPersistentContainer] saveContextChanges:context];
    
    // close session view controller
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    // present session result
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BSOSessionResultNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SessionResultNavigationController"];
    vc.historyIdentifier = historyEntity.identifier;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Private methods

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
    if ([data.options[OHQSessionOptionRegisterNewUserKey] boolValue] && !data.registeredUserIndex) {
        return NO;
    }
    if ([data.options[OHQSessionOptionDeleteUserDataKey] boolValue] && !data.deletedUserIndex) {
        return NO;
    }
    return YES;
}

- (void)bso_updateTableItems {
    NSMutableArray<NSDictionary<NSString *,id> *> *tableItems = [@[] mutableCopy];
    
    self.tableItems = [@[] mutableCopy];
    [tableItems addObject:@{SectionHeaderTitleKey: @"Device",
                            SectionRowsKey: @[(_deviceInfo ? @(RowTypeDevice) : @(RowTypeDevicePlaceholder))]}];
    [tableItems addObject:@{SectionRowsKey: @[@(RowTypeSetToNormalMode), @(RowTypeSetToUnregisteredUserMode)]}];
    [tableItems addObject:@{SectionFooterTitleKey: @"Receive Guest User's Measurements with specified profile.",
                            SectionRowsKey: @[@(RowTypeTransfer)]}];
    
    NSArray *profileRows = nil;
    if (!self.datePickerAvailable) {
        profileRows = @[@(RowTypeDateOfBirth), @(RowTypeHeight), @(RowTypeGender)];
    }
    else {
        profileRows = @[@(RowTypeDateOfBirth), @(RowTypeDatePicker), @(RowTypeHeight), @(RowTypeGender)];
    }
    [tableItems addObject:@{SectionHeaderTitleKey: @"Profile", SectionRowsKey: profileRows}];
    
    self.tableItems = tableItems;
}

- (void)bso_showDatePickerCell {
    if (!self.datePickerAvailable) {
        [self.tableView beginUpdates];
        self.datePickerAvailable = YES;
        [self bso_updateTableItems];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:SectionTypeProfile]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (void)bso_dismissDatePickerCell {
    if (self.datePickerAvailable) {
        [self.tableView beginUpdates];
        self.datePickerAvailable = NO;
        [self bso_updateTableItems];
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:SectionTypeProfile]] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
}

- (NSIndexPath *)bso_indexPathWithRowType:(RowType)rowType {
    __block NSIndexPath *ret = nil;
    [self.tableItems enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger sectionIdx, BOOL * _Nonnull stop) {
        NSArray<NSNumber *> *rows = obj[SectionRowsKey];
        [rows enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger rowIdx, BOOL * _Nonnull stop) {
            if ([obj isEqualToNumber:@(rowType)]) {
                ret = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
            }
        }];
    }];
    return ret;
}

@end
