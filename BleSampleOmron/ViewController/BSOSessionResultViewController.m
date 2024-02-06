//
//  BSOSessionResultViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOSessionResultViewController.h"
#import "BSODefines.h"
#import "BSODeviceInfoCell.h"
#import "BSOMeasurementsCell.h"
#import "BSOBloodPressureCollectionViewCell.h"
#import "BSOWeightCollectionViewCell.h"
#import "BSOBodyCompositionCollectionViewCell.h"
#import "BSOPulseOximeterCollectionViewCell.h"
#import "BSOThermometerCollectionViewCell.h"
#import "BSOMeasurementRecordViewController.h"
#import "BSOTableViewHeaderView.h"
#import "BSOSessionData.h"
#import "BSOPersistentContainer.h"
#import "BSOHistoryEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"
#import "UIColor+BleSampleOmron.h"
#import "OHQReferenceCode.h"
#import "BSOLogZipUtils.h"

typedef NS_ENUM(NSUInteger, RowType) {
    RowTypeDeviceInfo,
    RowTypeCompletionDate,
    RowTypeSessionStatus,
    RowTypeMeasurements,
    RowTypeNoMeasurements,
    RowTypeUserIndex,
    RowTypeConsentCode,
    RowTypeDateOfBirth,
    RowTypeHeight,
    RowTypeGender,
};

typedef NSString * CellIdentifier;
static CellIdentifier const DeviceInfoCellIdentifier = @"DeviceInfoCell";
static CellIdentifier const RightDetailCellIdentifier = @"RightDetailCell";
static CellIdentifier const MeasurementsCellIdentifier = @"MeasurementsCell";

static NSDictionary<NSNumber *,CellIdentifier> *_cellIdentifierDictionary;

static NSString * const SectionHeaderTitleKey = @"sectionHeaderTitle";
static NSString * const SectionRowsKey = @"sectionRows";

@interface BSOSessionResultViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIDocumentInteractionControllerDelegate, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property (weak, nonatomic) IBOutlet UICollectionView *measurementsCollectionView;

@property (strong, nonatomic) BSOHistoryEntity *historyEntity;
@property (copy, nonatomic) NSDictionary<CellIdentifier,NSNumber *> *cellHeightDictionary;
@property (copy, nonatomic) NSArray<NSMutableDictionary *> *tableItems;
@property (strong, nonatomic) UIDocumentInteractionController *documentInteractionController;
@property (strong, nonatomic) BSOMeasurementRecordViewController *measurementRecordViewController;
@property (strong, nonatomic) BSOLogZipUtils *zipUtils;

@end

@implementation BSOSessionResultViewController

+ (void)initialize {
    if (self == [BSOSessionResultViewController class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _cellIdentifierDictionary = @{@(RowTypeDeviceInfo): DeviceInfoCellIdentifier,
                                          @(RowTypeCompletionDate): RightDetailCellIdentifier,
                                          @(RowTypeSessionStatus): RightDetailCellIdentifier,
                                          @(RowTypeMeasurements): MeasurementsCellIdentifier,
                                          @(RowTypeNoMeasurements): RightDetailCellIdentifier,
                                          @(RowTypeUserIndex): RightDetailCellIdentifier,
                                          @(RowTypeConsentCode): RightDetailCellIdentifier,
                                          @(RowTypeDateOfBirth): RightDetailCellIdentifier,
                                          @(RowTypeHeight): RightDetailCellIdentifier,
                                          @(RowTypeGender): RightDetailCellIdentifier};
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [BSOHistoryEntity fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", self.historyIdentifier];
    NSManagedObjectContext *context = [BSOPersistentContainer sharedPersistentContainer].viewContext;
    self.historyEntity = [context executeFetchRequest:fetchRequest error:nil].firstObject;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.measurementRecordViewController = [storyboard instantiateViewControllerWithIdentifier:@"MeasurementRecordViewController"];
    
    [self.tableView registerNib:[BSOTableViewHeaderView nib] forHeaderFooterViewReuseIdentifier:[BSOTableViewHeaderView reuseIdentifier]];
    
    NSMutableDictionary *cellHeightDictionary = [@{} mutableCopy];
    CGFloat (^heightForCellIdentifier)(NSString *) = ^(NSString *cellIdentifier) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        return cell.frame.size.height;
    };
    cellHeightDictionary[DeviceInfoCellIdentifier] = @(heightForCellIdentifier(DeviceInfoCellIdentifier));
    cellHeightDictionary[RightDetailCellIdentifier] = @(heightForCellIdentifier(RightDetailCellIdentifier));
    CGFloat measurementsCellHeight = heightForCellIdentifier(MeasurementsCellIdentifier);
    CGFloat collectionViewCellHeight = CGFLOAT_MIN;
    switch (self.historyEntity.deviceCategory) {
        case OHQDeviceCategoryBloodPressureMonitor:
            collectionViewCellHeight = [BSOBloodPressureCollectionViewCell requiredSize].height;
            break;
        case OHQDeviceCategoryWeightScale:
            collectionViewCellHeight = [BSOWeightCollectionViewCell requiredSize].height;
            break;
        case OHQDeviceCategoryBodyCompositionMonitor:
            collectionViewCellHeight = [BSOBodyCompositionCollectionViewCell requiredSize].height;
            break;
        case OHQDeviceCategoryPulseOximeter:
            collectionViewCellHeight = [BSOPulseOximeterCollectionViewCell requiredSize].height;
            break;
        case OHQDeviceCategoryHealthThermometer:
            collectionViewCellHeight = [BSOThermometerCollectionViewCell requiredSize].height;
            break;
        default:
            break;
    }
    cellHeightDictionary[MeasurementsCellIdentifier] = @(measurementsCellHeight + collectionViewCellHeight);
    self.cellHeightDictionary = cellHeightDictionary;
    
    NSMutableArray *tableItems = [@[] mutableCopy];
    {
        NSMutableArray *rows = [@[@(RowTypeDeviceInfo), @(RowTypeCompletionDate), @(RowTypeSessionStatus)] mutableCopy];
        if (self.historyEntity.measurementRecords) {
            if (self.historyEntity.measurementRecords.count) {
                [rows addObject:@(RowTypeMeasurements)];
            }
            else {
                [rows addObject:@(RowTypeNoMeasurements)];
            }
        }
        [tableItems addObject:@{SectionRowsKey: rows}];
    }
    {
        NSMutableArray *rows = [@[] mutableCopy];
        if (self.historyEntity.userIndex) {
            [rows addObjectsFromArray:@[@(RowTypeUserIndex), @(RowTypeConsentCode)]];
        }
        if (self.historyEntity.userData) {
            if (self.historyEntity.userData[OHQUserDataDateOfBirthKey]) {
                [rows addObject:@(RowTypeDateOfBirth)];
            }
            if (self.historyEntity.userData[OHQUserDataHeightKey]) {
                [rows addObject:@(RowTypeHeight)];
            }
            if (self.historyEntity.userData[OHQUserDataGenderKey]) {
                [rows addObject:@(RowTypeGender)];
            }
        }
        if (rows.count) {
            [tableItems addObject:[@{SectionHeaderTitleKey: @"User Information", SectionRowsKey: rows} mutableCopy]];
        }
    }
    self.tableItems = tableItems;
    self.zipUtils = [[BSOLogZipUtils alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.measurementRecordViewController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Action

- (IBAction)barButtonItemDidAction:(UIBarButtonItem *)barButtonItem {
    if ([barButtonItem isEqual:self.actionButton]) {
        NSString *parameterFileName = [NSString stringWithFormat:@"%@", [self.historyEntity.completionDate localTimeStringWithFormat:@"yyyyMMddHHmmss"]];
        BOOL isHistory = YES;
        NSURL *resultZipURL = [self.zipUtils createZipFile:isHistory fileName:parameterFileName];
        
        if (resultZipURL) {
            // show interaction controller
            self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:resultZipURL];
            self.documentInteractionController.delegate = self;
            [self.documentInteractionController presentOptionsMenuFromBarButtonItem:barButtonItem animated:YES];
        }
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat ret = [BSOTableViewHeaderView requiredHeight];
    if (section == 0) {
        ret = 0.1f;
    }
    return ret;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableItems[section][SectionHeaderTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.tableItems[section][SectionRowsKey] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *rowTypeNumber = self.tableItems[indexPath.section][SectionRowsKey][indexPath.row];
    NSString *cellIdentifier = _cellIdentifierDictionary[rowTypeNumber];
    NSNumber *rowHeightNumber = self.cellHeightDictionary[cellIdentifier];
    return rowHeightNumber.floatValue;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BSOTableViewHeaderView *view = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[BSOTableViewHeaderView reuseIdentifier]];
    view.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RowType rowType = [self.tableItems[indexPath.section][SectionRowsKey][indexPath.row] unsignedIntegerValue];
    NSString *cellIdentifier = _cellIdentifierDictionary[@(rowType)];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    switch (rowType) {
        case RowTypeDeviceInfo: {
            BSODeviceInfoCell *infoCell = (BSODeviceInfoCell *)cell;
            infoCell.category = self.historyEntity.deviceCategory;
            infoCell.protocol = self.historyEntity.protocol;
            infoCell.modelName = self.historyEntity.modelName;
            infoCell.localName = self.historyEntity.localName;
            infoCell.deviceTime = self.historyEntity.deviceTime;
            infoCell.batteryLevel = self.historyEntity.batteryLevel;
            break;
        }
        case RowTypeCompletionDate: {
            cell.textLabel.text = @"Date";
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = [self.historyEntity.completionDate localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
            break;
        }
        case RowTypeSessionStatus: {
            cell.textLabel.text = BSOOperationDescription(self.historyEntity.operation);
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = self.historyEntity.status;
            break;
        }
        case RowTypeMeasurements: {
            BSOMeasurementsCell *measurementsCell = (BSOMeasurementsCell *)cell;
            measurementsCell.dataCountLabel.text = [NSString stringWithFormat:@"%d data", (unsigned int)self.historyEntity.measurementRecords.count];
            
            if (self.historyEntity.deviceCategory == OHQDeviceCategoryPulseOximeter) {
                NSSortDescriptor *sortAscNumber;
                sortAscNumber = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:YES];
                NSArray *sortAscArray;
                sortAscArray = [NSArray arrayWithObjects:sortAscNumber, nil];
                NSArray *sortArray;
                sortArray = [self.historyEntity.measurementRecords sortedArrayUsingDescriptors:sortAscArray];
                self.historyEntity.measurementRecords = sortArray;
            }
            
            self.measurementsCollectionView = measurementsCell.collectionView;
            self.measurementsCollectionView.delegate = self;
            self.measurementsCollectionView.dataSource = self;
            [self.measurementsCollectionView registerNib:[BSOBloodPressureCollectionViewCell nib] forCellWithReuseIdentifier:[BSOBloodPressureCollectionViewCell reuseIdentifier]];
            [self.measurementsCollectionView registerNib:[BSOWeightCollectionViewCell nib] forCellWithReuseIdentifier:[BSOWeightCollectionViewCell reuseIdentifier]];
            [self.measurementsCollectionView registerNib:[BSOBodyCompositionCollectionViewCell nib] forCellWithReuseIdentifier:[BSOBodyCompositionCollectionViewCell reuseIdentifier]];
            [self.measurementsCollectionView registerNib:[BSOPulseOximeterCollectionViewCell nib] forCellWithReuseIdentifier:[BSOPulseOximeterCollectionViewCell reuseIdentifier]];
            [self.measurementsCollectionView registerNib:[BSOThermometerCollectionViewCell nib] forCellWithReuseIdentifier:[BSOThermometerCollectionViewCell reuseIdentifier]];
            break;
        }
        case RowTypeNoMeasurements: {
            cell.textLabel.text = @"Measurements";
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = @"0 data";
            break;
        }
        case RowTypeUserIndex: {
            cell.textLabel.text = @"User Index";
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", self.historyEntity.userIndex.unsignedIntValue];
            break;
        }
        case RowTypeConsentCode: {
            cell.textLabel.text = @"Consent Code";
            UInt16 consentCode = (self.historyEntity.consentCode ? self.historyEntity.consentCode.unsignedShortValue : OHQDefaultConsentCode);
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"0x%04X", consentCode];
            break;
        }
        case RowTypeDateOfBirth: {
            cell.textLabel.text = @"Date of Birth";
            NSDate *dateOfBirth = self.historyEntity.userData[OHQUserDataDateOfBirthKey];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = [dateOfBirth localTimeStringWithFormat:@"yyyy-MM-dd"];
            break;
        }
        case RowTypeHeight: {
            cell.textLabel.text = @"Height";
            NSNumber *height = self.historyEntity.userData[OHQUserDataHeightKey];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ cm", height];
            break;
        }
        case RowTypeGender: {
            cell.textLabel.text = @"Gender";
            OHQGender gender = self.historyEntity.userData[OHQUserDataGenderKey];
            cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir-Book" size:17.0];
            cell.detailTextLabel.text = ([gender isEqualToString:OHQGenderMale] ? @"Male" : @"Female");
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - Collection view data source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.historyEntity.measurementRecords.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *ret = nil;
    NSDictionary<OHQMeasurementRecordKey,id> *measurementRecord = self.historyEntity.measurementRecords[indexPath.row];
    
    switch (self.historyEntity.deviceCategory) {
        case OHQDeviceCategoryBloodPressureMonitor: {
            BSOBloodPressureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BSOBloodPressureCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
            cell.timeStamp = measurementRecord[OHQMeasurementRecordTimeStampKey];
            cell.userIndex = measurementRecord[OHQMeasurementRecordUserIndexKey];
            cell.sequenceNumber = measurementRecord[OHQMeasurementRecordSequenceNumberKey];
            cell.pressureUnit = measurementRecord[OHQMeasurementRecordBloodPressureUnitKey];
            cell.systolic = measurementRecord[OHQMeasurementRecordSystolicKey];
            cell.diastolic = measurementRecord[OHQMeasurementRecordDiastolicKey];
            cell.pulseRate = measurementRecord[OHQMeasurementRecordPulseRateKey];
            ret = cell;
            break;
        }
        case OHQDeviceCategoryWeightScale: {
            BSOWeightCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BSOWeightCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
            cell.timeStamp = measurementRecord[OHQMeasurementRecordTimeStampKey];
            cell.userIndex = measurementRecord[OHQMeasurementRecordUserIndexKey];
            cell.sequenceNumber = measurementRecord[OHQMeasurementRecordSequenceNumberKey];
            cell.weightUnit = measurementRecord[OHQMeasurementRecordWeightUnitKey];
            cell.weight = measurementRecord[OHQMeasurementRecordWeightKey];
            ret = cell;
            break;
        }
        case OHQDeviceCategoryBodyCompositionMonitor: {
            BSOBodyCompositionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BSOBodyCompositionCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
            cell.timeStamp = measurementRecord[OHQMeasurementRecordTimeStampKey];
            cell.userIndex = measurementRecord[OHQMeasurementRecordUserIndexKey];
            cell.sequenceNumber = measurementRecord[OHQMeasurementRecordSequenceNumberKey];
            cell.weightUnit = measurementRecord[OHQMeasurementRecordWeightUnitKey];
            cell.weight = measurementRecord[OHQMeasurementRecordWeightKey];
            cell.bodyFatPercentage = measurementRecord[OHQMeasurementRecordBodyFatPercentageKey];
            ret = cell;
            break;
        }
        case OHQDeviceCategoryPulseOximeter: {
            BSOPulseOximeterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: [BSOPulseOximeterCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
            cell.timeStamp = measurementRecord[OHQMeasurementRecordTimeStampKey];
            cell.spo2 = measurementRecord[OHQMeasurementRecordPulseOximeterSpo2Key];
            cell.pulseRate = measurementRecord[OHQMeasurementRecordPulseRateKey];
            ret = cell;
            break;
        }
        case OHQDeviceCategoryHealthThermometer: {
            BSOThermometerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[BSOThermometerCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
            cell.timeStamp = measurementRecord[OHQMeasurementRecordTimeStampKey];
            cell.temperatureUnit = measurementRecord[OHQMeasurementRecordBodyTemperatureUnitKey];
            cell.temperature = measurementRecord[OHQMeasurementRecordBodyTemperatureKey];
            ret = cell;
            break;
        }

        default:
            ret = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
            break;
    }
    ret.backgroundColor = [UIColor lightColorWithDeviceCategory:self.historyEntity.deviceCategory];
    
    return ret;
}

#pragma mark - Collection view delegate 

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary<OHQMeasurementRecordKey,id> *measurementRecord = self.historyEntity.measurementRecords[indexPath.row];
    self.measurementRecordViewController.measurementRecord = measurementRecord;
    
    self.measurementRecordViewController.modalPresentationStyle = UIModalPresentationPopover;
    self.measurementRecordViewController.preferredContentSize = [UIScreen mainScreen].bounds.size;
    
    UIPopoverPresentationController *popoverPresentationController = self.measurementRecordViewController.popoverPresentationController;
    popoverPresentationController.delegate = self;
    popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell) {
        popoverPresentationController.sourceView = cell;
        CGRect sourceFrame = cell.frame;
        if (sourceFrame.origin.x < collectionView.contentOffset.x) {
            CGFloat leadingX = collectionView.contentOffset.x - sourceFrame.origin.x;
            CGRect sourceRect = CGRectMake(leadingX, 0, cell.bounds.size.width - leadingX, cell.bounds.size.height);
            popoverPresentationController.sourceRect = sourceRect;
        }
        else {
            CGFloat right = collectionView.contentOffset.x + collectionView.bounds.size.width;
            if (sourceFrame.origin.x + sourceFrame.size.width > right) {
                CGFloat trailingX = sourceFrame.origin.x + sourceFrame.size.width - right;
                CGRect sourceRect = CGRectMake(0, 0, cell.bounds.size.width - trailingX, cell.bounds.size.height);
                popoverPresentationController.sourceRect = sourceRect;
            }
            else {
                popoverPresentationController.sourceRect = cell.bounds;
            }
        }
    }
    [self presentViewController:self.measurementRecordViewController animated:YES completion:NULL];
}

#pragma mark - Collection view delegate flow layout

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize ret = CGSizeZero;
    switch (self.historyEntity.deviceCategory) {
        case OHQDeviceCategoryBloodPressureMonitor:
            ret = [BSOBloodPressureCollectionViewCell requiredSize];
            break;
        case OHQDeviceCategoryWeightScale:
            ret = [BSOWeightCollectionViewCell requiredSize];
            break;
        case OHQDeviceCategoryBodyCompositionMonitor:
            ret = [BSOBodyCompositionCollectionViewCell requiredSize];
            break;
        case OHQDeviceCategoryPulseOximeter:
            ret = [BSOPulseOximeterCollectionViewCell requiredSize];
            break;
        case OHQDeviceCategoryHealthThermometer:
            ret = [BSOThermometerCollectionViewCell requiredSize];
            break;
        default:
            break;
    }
    return ret;
}

#pragma mark - Popover presentation controller delegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationNone;
}

@end
