//
//  BSOWeightCollectionViewCell.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOWeightCollectionViewCell.h"
#import "NSDate+BleSampleOmron.h"

static NSNumberFormatter *_decimalStyleFormatter = nil;

@interface BSOWeightCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIndexLabel;
@property (weak, nonatomic) IBOutlet UILabel *sequenceNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightUnitLabel;

@end

@implementation BSOWeightCollectionViewCell

+ (void)initialize {
    if (self == [BSOWeightCollectionViewCell class]) {
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

- (void)setUserIndex:(NSNumber *)userIndex {
    _userIndex = userIndex;
    self.userIndexLabel.text = (_userIndex ? [NSString stringWithFormat:@"%ld", (long)_userIndex.integerValue] : @"-");
}

- (void)setSequenceNumber:(NSNumber *)sequenceNumber {
    _sequenceNumber = sequenceNumber;
    self.sequenceNumberLabel.text = (_sequenceNumber ? [NSString stringWithFormat:@"# %ld", (long)_sequenceNumber.integerValue] : @"");
}

- (void)setWeightUnit:(NSString *)weightUnit {
    _weightUnit = weightUnit;
    self.weightUnitLabel.text = (_weightUnit ? _weightUnit : @"");
}

- (void)setWeight:(NSNumber *)weight {
    _weight = weight;
    self.weightLabel.text = [_decimalStyleFormatter stringFromNumber:_weight];
}

@end
