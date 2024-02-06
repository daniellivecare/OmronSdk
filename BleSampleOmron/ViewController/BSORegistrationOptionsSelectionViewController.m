//
//  BSORegistrationOptionsSelectionViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSORegistrationOptionsSelectionViewController.h"
#import "BSODefines.h"
#import "BSOSessionViewController.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"

typedef NS_ENUM(NSUInteger, RowType) {
    RowTypeDevice,
    RowTypeBluetoothStandardProtocol,
    RowTypeOmronExtensionProtocol,
    RowTypeUserIndex,
    RowTypeRegistrationButton,
};

static NSString * const SectionHeaderTitleKey = @"sectionHeader";
static NSString * const SectionRowsKey = @"sectionRows";

static NSString * const SubtitleCellIdentifier = @"SubtitleCell";
static NSString * const BasicCellIdentifier = @"BasicCell";
static NSString * const SegmentedControlCellIdentifier = @"SegmentedControlCell";
static NSString * const ButtonCellIdentifier = @"ButtonCell";

static NSString * const UnknownModelName = @"Unknown Device";
static NSString * const UnknownLocalName = @"---";

static const NSInteger ButtonCellControlTag = 1;
static const NSInteger SegmentedControlCellControlTag = 1;

@interface BSORegistrationOptionsSelectionViewController ()

@property (copy, nonatomic) NSArray<NSDictionary<NSString *,id> *> *tableItems;
@property (assign, nonatomic) BSOProtocol protocol;
@property (strong, nonatomic) NSNumber *userIndex;
@property (assign, nonatomic) BOOL omronExtensionSupported;

@end

@implementation BSORegistrationOptionsSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *manufacturerData = self.deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataManufacturerDataKey];
    UInt16 companyIdentifier = [manufacturerData[OHQManufacturerDataCompanyIdentifierKey] unsignedShortValue];
    self.omronExtensionSupported = (companyIdentifier == OHQOmronHealthcareCompanyIdentifier && ![manufacturerData[OHQManufacturerDataIsBluetoothStandardMode] boolValue]);
    self.protocol = (self.omronExtensionSupported ? BSOProtocolOmronExtension : BSOProtocolBluetoothStandard);
    self.userIndex = (self.omronExtensionSupported ? @1 : nil);
    self.tableItems = [@[] mutableCopy];
    [self bso_updateTableItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)segmentedControlDidChangeValue:(UISegmentedControl *)sender {
    self.userIndex = @(sender.selectedSegmentIndex);
}

- (IBAction)buttonDidTouchUpInside:(UIButton *)sender {
    NSDictionary<OHQSessionOptionKey,id> *options = [self bso_makeOptions];
    if (options) {
        [self.delegate registrationOptionsSelectionViewController:self didSelectProtocol:self.protocol options:options];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableItems[section][SectionHeaderTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rows = self.tableItems[section][SectionRowsKey];
    return rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RowType rowType = [self.tableItems[indexPath.section][SectionRowsKey][indexPath.row] unsignedIntegerValue];
    UITableViewCell *cell = nil;
    switch (rowType) {
        case RowTypeDevice: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:SubtitleCellIdentifier];
            NSString *modelName = self.deviceInfo[OHQDeviceInfoModelNameKey];
            NSString *localName = self.deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataLocalNameKey];
            cell.textLabel.text = (modelName ? modelName : UnknownModelName);
            cell.detailTextLabel.text = (localName ? localName : UnknownLocalName);
            break;
        }
        case RowTypeBluetoothStandardProtocol: {
            BSOProtocol protocol = BSOProtocolBluetoothStandard;
            cell = [self.tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
            cell.textLabel.text = BSOProtocolDescription(protocol);
            cell.accessoryType = (self.protocol == protocol ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
            break;
        }
        case RowTypeOmronExtensionProtocol: {
            BSOProtocol protocol = BSOProtocolOmronExtension;
            cell = [self.tableView dequeueReusableCellWithIdentifier:BasicCellIdentifier];
            cell.textLabel.text = BSOProtocolDescription(protocol);
            cell.accessoryType = (self.protocol == protocol ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
            break;
        }
        case RowTypeUserIndex: {
            NSDictionary *manufacturerData = self.deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataManufacturerDataKey];
            NSInteger numberOfUsers = [manufacturerData[OHQManufacturerDataNumberOfUserKey] integerValue];
            cell = [self.tableView dequeueReusableCellWithIdentifier:SegmentedControlCellIdentifier];
            UISegmentedControl *control = [cell viewWithTag:SegmentedControlCellControlTag];
            [control removeAllSegments];
            [control insertSegmentWithTitle:@"Auto" atIndex:0 animated:NO];
            for (int i = 1; i <= numberOfUsers; i++) {
                [control insertSegmentWithTitle:[NSString stringWithFormat:@"%d", i] atIndex:i animated:NO];
            }
            control.selectedSegmentIndex = self.userIndex.integerValue;
            [control addTarget:self action:@selector(segmentedControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case RowTypeRegistrationButton: {
            cell = [self.tableView dequeueReusableCellWithIdentifier:ButtonCellIdentifier];
            UIButton *button = [cell viewWithTag:ButtonCellControlTag];
            [button setTitle:@"Start Registration" forState:0];
            [button addTarget:self action:@selector(buttonDidTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RowType rowType = [self.tableItems[indexPath.section][SectionRowsKey][indexPath.row] unsignedIntegerValue];
    
    switch (rowType) {
        case RowTypeBluetoothStandardProtocol: {
            if (self.omronExtensionSupported && self.protocol != BSOProtocolBluetoothStandard) {
                NSIndexPath *indexPathOfUserIndex = [self bso_indexPathWithRowType:RowTypeUserIndex];
                [self.tableView beginUpdates];
                self.protocol = BSOProtocolBluetoothStandard;
                [self bso_updateTableItems];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPathOfUserIndex.section] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
        case RowTypeOmronExtensionProtocol: {
            if (self.omronExtensionSupported && self.protocol != BSOProtocolOmronExtension) {
                [self.tableView beginUpdates];
                self.protocol = BSOProtocolOmronExtension;
                [self bso_updateTableItems];
                NSIndexPath *indexPathOfUserIndex = [self bso_indexPathWithRowType:RowTypeUserIndex];
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPathOfUserIndex.section] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Private methods

- (void)bso_updateTableItems {
    NSMutableArray<NSDictionary<NSString *,id> *> *tableItems = [@[] mutableCopy];
    
    [tableItems addObject:@{SectionHeaderTitleKey: @"Device", SectionRowsKey: @[@(RowTypeDevice)]}];
    if (self.omronExtensionSupported) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Protocol",
                                SectionRowsKey: @[@(RowTypeBluetoothStandardProtocol), @(RowTypeOmronExtensionProtocol)]}];
        if (self.protocol == BSOProtocolOmronExtension) {
            [tableItems addObject:@{SectionHeaderTitleKey: @"User Index", SectionRowsKey: @[@(RowTypeUserIndex)]}];
        }
    }
    else {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Protocol", SectionRowsKey: @[@(RowTypeBluetoothStandardProtocol)]}];
    }
    [tableItems addObject:@{SectionRowsKey: @[@(RowTypeRegistrationButton)]}];
    
    self.tableItems = tableItems;
}

- (NSIndexPath *)bso_indexPathWithRowType:(RowType)rowType {
    __block NSIndexPath *ret = nil;
    [self.tableItems enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger sectionIdx, BOOL * _Nonnull stopSection) {
        NSArray *rows = obj[SectionRowsKey];
        [rows enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger rowIdx, BOOL * _Nonnull stopRow) {
            if (obj.unsignedIntegerValue == rowType) {
                ret = [NSIndexPath indexPathForRow:rowIdx inSection:sectionIdx];
                *stopRow = YES;
            }
        }];
        *stopSection = !!ret;
    }];
    return ret;
}

- (NSDictionary<OHQSessionOptionKey,id> *)bso_makeOptions {
    NSMutableDictionary<OHQSessionOptionKey,id> *ret = [@{OHQSessionOptionReadMeasurementRecordsKey: @YES,
                                                          OHQSessionOptionConnectionWaitTimeKey: @60.0} mutableCopy];
    
    if (self.protocol == BSOProtocolBluetoothStandard) {
        OHQDeviceCategory category = [self.deviceInfo[OHQDeviceInfoCategoryKey] unsignedShortValue];
        switch (category) {
            case OHQDeviceCategoryWeightScale:
            case OHQDeviceCategoryBodyCompositionMonitor:
                ret[OHQSessionOptionRegisterNewUserKey] = @YES;
                ret[OHQSessionOptionUserDataKey] = self.userData;
                ret[OHQSessionOptionUserDataUpdateFlagKey] = @YES;
                ret[OHQSessionOptionDatabaseChangeIncrementValueKey] = @0;
                break;
            default:
                break;
        }
    }
    else if (self.protocol == BSOProtocolOmronExtension) {
        ret[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] = @YES;
        ret[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] = @YES;
        ret[OHQSessionOptionRegisterNewUserKey] = @YES;
        ret[OHQSessionOptionUserDataKey] = self.userData;
        ret[OHQSessionOptionUserDataUpdateFlagKey] = @YES;
        ret[OHQSessionOptionDatabaseChangeIncrementValueKey] = @0;
        if (self.userIndex && ![self.userIndex isEqualToNumber:@0]) {
            ret[OHQSessionOptionUserIndexKey] = self.userIndex;
        }
    }

    return [ret copy];
}

@end
