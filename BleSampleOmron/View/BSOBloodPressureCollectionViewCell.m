//
//  BSOBloodPressureCollectionViewCell.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOBloodPressureCollectionViewCell.h"
#import "NSDate+BleSampleOmron.h"

static NSNumberFormatter *_decimalStyleFormatter = nil;

@interface BSOBloodPressureCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *sequenceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *systolicLabel;
@property (weak, nonatomic) IBOutlet UILabel *systolicUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *diastolicLabel;
@property (weak, nonatomic) IBOutlet UILabel *diastolicUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *pulseRateLabel;

@end

@implementation BSOBloodPressureCollectionViewCell

+ (void)initialize {
    if (self == [BSOBloodPressureCollectionViewCell class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _decimalStyleFormatter = [NSNumberFormatter new];
            _decimalStyleFormatter.numberStyle = NSNumberFormatterDecimalStyle;
            _decimalStyleFormatter.nilSymbol = @"-";
            _decimalStyleFormatter.minimumFractionDigits = 1;
            _decimalStyleFormatter.maximumFractionDigits = 1;
        });
    }
}

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

+ (CGSize)requiredSize {
    return CGSizeMake(250.0, 300.0);
}

- (void)setTimeStamp:(NSDate *)timeStamp {
    _timeStamp = timeStamp;
    self.timeStampLabel.text = (_timeStamp ? [_timeStamp localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : @"0000-00-00 00:00:00");
}

- (void)setUserIndex:(NSNumber *)userIndex {
    _userIndex = userIndex;
    self.userIndexLabel.text = (_userIndex ? [NSString stringWithFormat:@"%ld", (long)_userIndex.integerValue] : @"-");
}

- (void)setSequenceNumber:(NSNumber *)sequenceNumber {
    _sequenceNumber = sequenceNumber;
    self.sequenceNumberLabel.text = (_sequenceNumber ? [NSString stringWithFormat:@"# %ld", (long)_sequenceNumber.integerValue] : @"");
}

- (void)setPressureUnit:(NSString *)pressureUnit {
    _pressureUnit = pressureUnit;
    if (_pressureUnit) {
        self.systolicUnitLabel.text = _pressureUnit;
        self.diastolicUnitLabel.text = _pressureUnit;
    }
    else {
        self.systolicUnitLabel.text = @"";
        self.diastolicUnitLabel.text = @"";
    }
}

- (void)setSystolic:(NSNumber *)systolic {
    _systolic = systolic;
    int systolicValue = [_systolic intValue];
    _systolic = [NSNumber numberWithInt:systolicValue];
    self.systolicLabel.text = [_systolic stringValue];
}

- (void)setDiastolic:(NSNumber *)diastolic {
    _diastolic = diastolic;
    int diastolicValue = [_diastolic intValue];
    _diastolic = [NSNumber numberWithInt:diastolicValue];
    self.diastolicLabel.text = [_diastolic stringValue];
}

- (void)setPulseRate:(NSNumber *)pulseRate {
    _pulseRate = pulseRate;
    int pulseRateValue = [_pulseRate intValue];
    _pulseRate = [NSNumber numberWithInt:pulseRateValue];
    self.pulseRateLabel.text = [_pulseRate stringValue];
}

@end
