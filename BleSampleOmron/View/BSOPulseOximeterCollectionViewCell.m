//
//  BSOPulseOximeterCollectionViewCell.m
//  BleSampleOmron
//
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOPulseOximeterCollectionViewCell.h"
#import "NSDate+BleSampleOmron.h"

static NSNumberFormatter *_decimalStyleFormatter = nil;

@interface BSOPulseOximeterCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *spo2Label;
@property (weak, nonatomic) IBOutlet UILabel *pulseRateLabel;

@end

@implementation BSOPulseOximeterCollectionViewCell

+ (void)initialize {
    if (self == [BSOPulseOximeterCollectionViewCell class]) {
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
    return CGSizeMake(250.0, 225.0);
}

- (void)setTimeStamp:(NSDate *)timeStamp {
    _timeStamp = timeStamp;
    self.timeStampLabel.text = (_timeStamp ? [_timeStamp localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : @"0000-00-00 00:00:00");
}

- (void)setSpo2: (NSNumber *)spo2 {
    _spo2 = spo2;
    int spo2Value = [_spo2 intValue];
    _spo2 = [NSNumber numberWithInt:spo2Value];
    self.spo2Label.text = [_spo2 stringValue];
}

- (void)setPulseRate: (NSNumber *)pulseRate {
    _pulseRate = pulseRate;
    int pulseRateValue = [_pulseRate intValue];
    _pulseRate = [NSNumber numberWithInt:pulseRateValue];
    self.pulseRateLabel.text = [_pulseRate stringValue];
}

@end
