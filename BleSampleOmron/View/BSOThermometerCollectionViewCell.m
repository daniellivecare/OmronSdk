//
//  BSOThermometerCollectionViewCell.m
//  BleSampleOmron
//
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOThermometerCollectionViewCell.h"
#import "NSDate+BleSampleOmron.h"

static NSNumberFormatter *_decimalStyleFormatter = nil;

@interface BSOThermometerCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureUnitLabel;

@end

@implementation BSOThermometerCollectionViewCell

+ (void)initialize {
    if (self == [BSOThermometerCollectionViewCell class]) {
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
    return CGSizeMake(250.0, 150.0);
}

- (void)setTimeStamp:(NSDate *)timeStamp {
    _timeStamp = timeStamp;
    self.timeStampLabel.text = (_timeStamp ? [_timeStamp localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"] : @"0000-00-00 00:00:00");
}


- (void)setTemperatureUnit:(NSString *)temperatureUnit {
    _temperatureUnit = temperatureUnit;
    self.temperatureUnitLabel.text = (_temperatureUnit ? _temperatureUnit : @"");
}

- (void)setTemperature:(NSString *)temperature {
    _temperature = temperature;
    self.temperatureLabel.text = _temperature;
}

@end
