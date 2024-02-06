//
//  BSOAdvertisementDataViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOAdvertisementDataViewController.h"

static NSString * const SectionHeaderTitleKey = @"sectionHeaderTitle";
static NSString * const SectionRowsKey = @"sectionRows";
static NSString * const RowTextKey = @"rowText";
static NSString * const RowDetailKey = @"rowDetail";

@interface BSOAdvertisementDataViewController ()

@property (nonatomic, copy) NSArray<NSDictionary *> *tableItems;

@end

@implementation BSOAdvertisementDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *tableItems = [@[] mutableCopy];
    
    NSString *localName = self.advertisementData[OHQAdvertisementDataLocalNameKey];
    if (localName) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Local Name", SectionRowsKey: @[@{RowTextKey: localName}]}];
    }
    NSNumber *connectable = self.advertisementData[OHQAdvertisementDataIsConnectable];
    if (connectable) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Connectable", SectionRowsKey: @[@{RowTextKey: (connectable.boolValue ? @"YES" : @"NO")}]}];
    }
    NSArray<CBUUID *> *serviceUUIDs = self.advertisementData[OHQAdvertisementDataServiceUUIDsKey];
    if (serviceUUIDs.count) {
        __block NSMutableArray *rows = [@[] mutableCopy];
        [serviceUUIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [rows addObject:@{RowTextKey: obj}];
        }];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Service UUIDs", SectionRowsKey: rows}];
    }
    NSDictionary *serviceData = self.advertisementData[OHQAdvertisementDataServiceDataKey];
    if (serviceData.count) {
        __block NSMutableArray *rows = [@[] mutableCopy];
        [serviceData enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [rows addObject:@{RowTextKey: key, RowDetailKey: obj}];
        }];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Service Data", SectionRowsKey: rows}];
    }
    NSArray *overflowServiceUUIDs = self.advertisementData[OHQAdvertisementDataOverflowServiceUUIDsKey];
    if (overflowServiceUUIDs.count) {
        __block NSMutableArray *rows = [@[] mutableCopy];
        [overflowServiceUUIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [rows addObject:@{RowTextKey: obj}];
        }];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Overflow Service UUIDs", SectionRowsKey: rows}];
    }
    NSArray *solicitedServiceUUIDs = self.advertisementData[OHQAdvertisementDataSolicitedServiceUUIDsKey];
    if (solicitedServiceUUIDs.count) {
        __block NSMutableArray *rows = [@[] mutableCopy];
        [solicitedServiceUUIDs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [rows addObject:@{RowTextKey: obj}];
        }];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Solicited Service UUIDs", SectionRowsKey: rows}];
    }
    NSNumber *txPowerLevel = self.advertisementData[OHQAdvertisementDataTxPowerLevelKey];
    if (txPowerLevel) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Tx Power Level", SectionRowsKey: @[@{RowTextKey: [NSString stringWithFormat:@"%d dBm", txPowerLevel.intValue]}]}];
    }
    NSDictionary<OHQManufacturerDataKey, id> *manufacturerData = self.advertisementData[OHQAdvertisementDataManufacturerDataKey];
    if (manufacturerData.count) {
        __block NSMutableArray *rows = [@[] mutableCopy];
        
        NSNumber *companyIdentifier = manufacturerData[OHQManufacturerDataCompanyIdentifierKey];
        NSString *companyIdentifierDescription = manufacturerData[OHQManufacturerDataCompanyIdentifierDescriptionKey];
        if (companyIdentifier && companyIdentifierDescription) {
            NSString *companyIdentifierString = [NSString stringWithFormat:@"%@ (0x%04X)", companyIdentifierDescription, companyIdentifier.unsignedShortValue];
            [rows addObject:@{RowTextKey: @"Company Identifier", RowDetailKey: companyIdentifierString}];
        }
        NSNumber *numberOfUser = manufacturerData[OHQManufacturerDataNumberOfUserKey];
        if (numberOfUser) {
            [rows addObject:@{RowTextKey: @"Number of User", RowDetailKey: [NSString stringWithFormat:@"%d", numberOfUser.intValue]}];
        }
        NSNumber *pairable = manufacturerData[OHQManufacturerDataIsPairingMode];
        if (pairable) {
            [rows addObject:@{RowTextKey: @"Pairing Mode", RowDetailKey: (pairable.boolValue ? @"YES" : @"NO")}];
        }
        NSNumber *timeNotConfigured = manufacturerData[OHQManufacturerDataTimeNotConfigured];
        if (timeNotConfigured) {
            [rows addObject:@{RowTextKey: @"Time Not Configured", RowDetailKey: (timeNotConfigured.boolValue ? @"YES" : @"NO")}];
        }
        NSArray<NSDictionary<OHQRecordInfoKey, id> *> *recordInfoArray = manufacturerData[OHQManufacturerDataRecordInfoArrayKey];
        if (recordInfoArray.count) {
            [recordInfoArray enumerateObjectsUsingBlock:^(NSDictionary<OHQRecordInfoKey,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSNumber *userIndex = obj[OHQRecordInfoUserIndexKey];
                NSNumber *lastSequenceNumber = obj[OHQRecordInfoLastSequenceNumberKey];
                NSNumber *numberOfRecords = obj[OHQRecordInfoNumberOfRecordsKey];
                if (userIndex && lastSequenceNumber) {
                    NSString *rowText = [NSString stringWithFormat:@"Last Sequence Number (User Index %d)", userIndex.intValue];
                    [rows addObject:@{RowTextKey: rowText, RowDetailKey: [NSString stringWithFormat:@"%d", lastSequenceNumber.intValue]}];
                }
                if (userIndex && numberOfRecords) {
                    NSString *rowText = [NSString stringWithFormat:@"Number of Records (User Index %d)", userIndex.intValue];
                    [rows addObject:@{RowTextKey: rowText, RowDetailKey: [NSString stringWithFormat:@"%d", numberOfRecords.intValue]}];
                }
            }];
        }
        [tableItems addObject:@{SectionHeaderTitleKey: @"Manufacturer Data", SectionRowsKey: rows}];
    }
    self.tableItems = tableItems;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableItems.count;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableItems[section][SectionHeaderTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableItems[section][SectionRowsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = self.tableItems[indexPath.section][SectionRowsKey][indexPath.row];
    NSString *rowText = row[RowTextKey];
    id rowDetail = row[RowDetailKey];
    
    UITableViewCell *cell = nil;
    if (rowText && rowDetail) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SubtitleCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", rowText];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", rowDetail];
    }
    else if (rowText) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@", rowText];
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        cell.textLabel.text = @"Invalid Data";
    }
    
    return cell;
}

@end
