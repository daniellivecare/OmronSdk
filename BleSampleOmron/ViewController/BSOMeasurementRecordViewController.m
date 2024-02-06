//
//  BSOMeasurementRecordViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOMeasurementRecordViewController.h"
#import "NSDate+BleSampleOmron.h"

static NSString * const SectionHeaderTitleKey = @"sectionHeaderTitle";
static NSString * const SectionRowsKey = @"sectionRows";
static NSString * const RowTextKey = @"rowText";

static NSNumberFormatter *_decimalStyleFormatter = nil;
static NSNumberFormatter *_percentStyleFormatter = nil;

@interface BSOMeasurementRecordViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *sequenceNumberLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;

@property (copy, nonatomic) NSArray<NSDictionary *> *tableItems;

@end

@implementation BSOMeasurementRecordViewController

+ (void)initialize {
    if (self == [BSOMeasurementRecordViewController class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _decimalStyleFormatter = [NSNumberFormatter new];
            _decimalStyleFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            _decimalStyleFormatter.maximumFractionDigits = 3;
            _decimalStyleFormatter.minimumFractionDigits = 0;
            _percentStyleFormatter = [NSNumberFormatter new];
            _percentStyleFormatter.numberStyle = NSNumberFormatterPercentStyle;
            _percentStyleFormatter.maximumFractionDigits = 3;
            _percentStyleFormatter.minimumFractionDigits = 0;
        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDate *timeStamp = self.measurementRecord[OHQMeasurementRecordTimeStampKey];
    NSNumber *userIndex = self.measurementRecord[OHQMeasurementRecordUserIndexKey];
    NSNumber *sequenceNumber = self.measurementRecord[OHQMeasurementRecordSequenceNumberKey];
    self.timeStampLabel.text = (timeStamp ? [timeStamp localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : @"Detail");
    self.userIndexLabel.text = (userIndex ? [NSString stringWithFormat:@"%d", userIndex.intValue] : @"-");
    self.sequenceNumberLabel.text = (sequenceNumber ? [NSString stringWithFormat:@"# %@", sequenceNumber] : @"");
    
    NSMutableArray *tableItems = [@[] mutableCopy];
    NSString *bloodPressureUnit = self.measurementRecord[OHQMeasurementRecordBloodPressureUnitKey];
    NSString *weightUnit = self.measurementRecord[OHQMeasurementRecordWeightUnitKey];
    NSString *heightUnit = self.measurementRecord[OHQMeasurementRecordHeightUnitKey];
    NSString *temperatureUnit = self.measurementRecord[OHQMeasurementRecordBodyTemperatureUnitKey];

    NSNumber *systolic = self.measurementRecord[OHQMeasurementRecordSystolicKey];
    if (systolic) {
        NSString *systolicText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:systolic], bloodPressureUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Systolic",
                                SectionRowsKey: @[@{RowTextKey: systolicText}]}];
    }
    NSNumber *diastolic = self.measurementRecord[OHQMeasurementRecordDiastolicKey];
    if (diastolic) {
        NSString *diastolicText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:diastolic], bloodPressureUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Diastolic",
                                SectionRowsKey: @[@{RowTextKey: diastolicText}]}];
    }
    NSNumber *meanArterialPressure = self.measurementRecord[OHQMeasurementRecordMeanArterialPressureKey];
    if (meanArterialPressure) {
        NSString *meanArterialPressureText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:meanArterialPressure], bloodPressureUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Mean Arterial Pressure",
                                SectionRowsKey: @[@{RowTextKey: meanArterialPressureText}]}];
    }
    NSNumber *spo2 = self.measurementRecord[OHQMeasurementRecordPulseOximeterSpo2Key];
    float spo2Float = [spo2 floatValue] / 100;
    NSNumber *spo2Value = [NSNumber numberWithFloat:spo2Float];
    if (spo2) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"SpO2",
                                SectionRowsKey: @[@{RowTextKey: [_percentStyleFormatter stringFromNumber:spo2Value]}]}];
    }
    NSNumber *pulseRate = self.measurementRecord[OHQMeasurementRecordPulseRateKey];
    if (pulseRate) {
        NSString *pulseRateText = [NSString stringWithFormat:@"%@ bpm", [_decimalStyleFormatter stringFromNumber:pulseRate]];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Pulse Rate",
                                SectionRowsKey: @[@{RowTextKey: pulseRateText}]}];
    }
    NSNumber *bloodPressureMeasurementStatus = self.measurementRecord[OHQMeasurementRecordBloodPressureMeasurementStatusKey];
    if (bloodPressureMeasurementStatus) {
        OHQBloodPressureMeasurementStatus status = bloodPressureMeasurementStatus.unsignedShortValue;
        if (status != 0) {
            NSMutableArray *rows = [@[] mutableCopy];
            if (status & OHQBloodPressureMeasurementStatusBodyMovementDetected) {
                [rows addObject:@{RowTextKey: OHQBloodPressureMeasurementStatusDescription(OHQBloodPressureMeasurementStatusBodyMovementDetected)}];
            }
            if (status & OHQBloodPressureMeasurementStatusCuffTooLoose) {
                [rows addObject:@{RowTextKey: OHQBloodPressureMeasurementStatusDescription(OHQBloodPressureMeasurementStatusCuffTooLoose)}];
            }
            if (status & OHQBloodPressureMeasurementStatusIrregularPulseDetected) {
                [rows addObject:@{RowTextKey: OHQBloodPressureMeasurementStatusDescription(OHQBloodPressureMeasurementStatusIrregularPulseDetected)}];
            }
            if (status & OHQBloodPressureMeasurementStatusPulseRateTooHigher) {
                [rows addObject:@{RowTextKey: OHQBloodPressureMeasurementStatusDescription(OHQBloodPressureMeasurementStatusPulseRateTooHigher)}];
            }
            if (status & OHQBloodPressureMeasurementStatusPulseRateTooLower) {
                [rows addObject:@{RowTextKey: OHQBloodPressureMeasurementStatusDescription(OHQBloodPressureMeasurementStatusPulseRateTooLower)}];
            }
            if (status & OHQBloodPressureMeasurementStatusImproperMeasurementPosition) {
                [rows addObject:@{RowTextKey: OHQBloodPressureMeasurementStatusDescription(OHQBloodPressureMeasurementStatusImproperMeasurementPosition)}];
            }
            if (rows.count) {
                [tableItems addObject:@{SectionHeaderTitleKey: @"Measurement Status", SectionRowsKey: rows}];
            }
        }
    }
    NSNumber *weight = self.measurementRecord[OHQMeasurementRecordWeightKey];
    if (weight) {
        NSString *weightText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:weight], weightUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Weight",
                                SectionRowsKey: @[@{RowTextKey: weightText}]}];
    }
    NSNumber *height = self.measurementRecord[OHQMeasurementRecordHeightKey];
    if (height) {
        NSString *heightText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:height], heightUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Height",
                                SectionRowsKey: @[@{RowTextKey: heightText}]}];
    }
    NSNumber *BMI = self.measurementRecord[OHQMeasurementRecordBMIKey];
    if (BMI) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"BMI",
                                SectionRowsKey: @[@{RowTextKey: [_decimalStyleFormatter stringFromNumber:BMI]}]}];
    }
    NSNumber *bodyFatPercentage = self.measurementRecord[OHQMeasurementRecordBodyFatPercentageKey];
    if (bodyFatPercentage) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Body Fat Percentage",
                                SectionRowsKey: @[@{RowTextKey: [_percentStyleFormatter stringFromNumber:bodyFatPercentage]}]}];
    }
    NSNumber *basalMetabolism = self.measurementRecord[OHQMeasurementRecordBasalMetabolismKey];
    if (basalMetabolism) {
        NSString *basalMetabolismText = [NSString stringWithFormat:@"%@ kJ", [_decimalStyleFormatter stringFromNumber:basalMetabolism]];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Basal Metabolism",
                                SectionRowsKey: @[@{RowTextKey: basalMetabolismText}]}];
    }
    NSNumber *musclePercentage = self.measurementRecord[OHQMeasurementRecordMusclePercentageKey];
    if (musclePercentage) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Muscle Percentage",
                                SectionRowsKey: @[@{RowTextKey: [_percentStyleFormatter stringFromNumber:musclePercentage]}]}];
    }
    NSNumber *muscleMass = self.measurementRecord[OHQMeasurementRecordMuscleMassKey];
    if (muscleMass) {
        NSString *muscleMassText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:muscleMass], weightUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Muscle Mass",
                                SectionRowsKey: @[@{RowTextKey: muscleMassText}]}];
    }
    NSNumber *fatFreeMass = self.measurementRecord[OHQMeasurementRecordFatFreeMassKey];
    if (fatFreeMass) {
        NSString *fatFreeMassText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:fatFreeMass], weightUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Fat Free Mass",
                                SectionRowsKey: @[@{RowTextKey: fatFreeMassText}]}];
    }
    NSNumber *softLeanMass = self.measurementRecord[OHQMeasurementRecordSoftLeanMassKey];
    if (softLeanMass) {
        NSString *softLeanMassText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:softLeanMass], weightUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Soft Lean Mass",
                                SectionRowsKey: @[@{RowTextKey: softLeanMassText}]}];
    }
    NSNumber *bodyWaterMass = self.measurementRecord[OHQMeasurementRecordBodyWaterMassKey];
    if (bodyWaterMass) {
        NSString *bodyWaterMassText = [NSString stringWithFormat:@"%@ %@", [_decimalStyleFormatter stringFromNumber:bodyWaterMass], weightUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Body Water Mass",
                                SectionRowsKey: @[@{RowTextKey: bodyWaterMassText}]}];
    }
    NSNumber *impedance = self.measurementRecord[OHQMeasurementRecordImpedanceKey];
    if (impedance) {
        NSString *impedanceText = [NSString stringWithFormat:@"%@ Ω", [_decimalStyleFormatter stringFromNumber:impedance]];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Impedance",
                                SectionRowsKey: @[@{RowTextKey: impedanceText}]}];
    }
    NSNumber *skeletalMusclePercentage = self.measurementRecord[OHQMeasurementRecordSkeletalMusclePercentageKey];
    if (skeletalMusclePercentage) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Skeletal Muscle Percentage",
                                SectionRowsKey: @[@{RowTextKey: [_percentStyleFormatter stringFromNumber:skeletalMusclePercentage]}]}];
    }
    NSNumber *visceralFatLevel = self.measurementRecord[OHQMeasurementRecordVisceralFatLevelKey];
    if (visceralFatLevel) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Visceral Fat Level",
                                SectionRowsKey: @[@{RowTextKey: [_decimalStyleFormatter stringFromNumber:visceralFatLevel]}]}];
    }
    NSNumber *bodyAge = self.measurementRecord[OHQMeasurementRecordBodyAgeKey];
    if (bodyAge) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Body Age",
                                SectionRowsKey: @[@{RowTextKey: bodyAge.stringValue}]}];
    }
    NSNumber *bodyFatPercentageStageEvaluation = self.measurementRecord[OHQMeasurementRecordBodyFatPercentageStageEvaluationKey];
    if (bodyFatPercentageStageEvaluation) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Body Fat Percentage Stage Evaluation",
                                SectionRowsKey: @[@{RowTextKey: bodyFatPercentageStageEvaluation.stringValue}]}];
    }
    NSNumber *skeletalMusclePercentageStageEvaluation = self.measurementRecord[OHQMeasurementRecordSkeletalMusclePercentageStageEvaluationKey];
    if (skeletalMusclePercentageStageEvaluation) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Skeletal Muscle Percentage Stage Evaluation",
                                SectionRowsKey: @[@{RowTextKey: skeletalMusclePercentageStageEvaluation.stringValue}]}];
    }
    NSNumber *visceralFatLevelStageEvaluation = self.measurementRecord[OHQMeasurementRecordVisceralFatLevelStageEvaluationKey];
    if (visceralFatLevelStageEvaluation) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Visceral Fat Level Stage Evaluation",
                                SectionRowsKey: @[@{RowTextKey: visceralFatLevelStageEvaluation.stringValue}]}];
    }
    NSString *temperature = self.measurementRecord[OHQMeasurementRecordBodyTemperatureKey];
    if (temperature) {
        NSString *temperatureText = [NSString stringWithFormat:@"%@ %@", temperature, temperatureUnit];
        [tableItems addObject:@{SectionHeaderTitleKey: @"Body Temperature",
                                SectionRowsKey: @[@{RowTextKey: temperatureText}]}];
    }
    NSString *temperatureType = self.measurementRecord[OHQMeasurementRecordBodyTemperatureTypeKey];
    if (temperatureType) {
        [tableItems addObject:@{SectionHeaderTitleKey: @"Measurement Site",
                                SectionRowsKey: @[@{RowTextKey: temperatureType}]}];
    }
    self.tableItems = tableItems;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (IBAction)barButtonItemDidAction:(id)barButtonItem {
    if ([barButtonItem isEqual:self.closeButton]) {
        [self dismissViewControllerAnimated:YES completion:nil];
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
    return [self.tableItems[section][SectionRowsKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.tableItems[indexPath.section][SectionRowsKey][indexPath.row][RowTextKey];
    return cell;
}

@end
