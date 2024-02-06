//
//  BSOPulseOximeterCollectionViewCell.h
//  BleSampleOmron
//
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSOPulseOximeterCollectionViewCell : UICollectionViewCell

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;
+ (CGSize)requiredSize;

@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) NSNumber *spo2;
@property (nonatomic, strong) NSNumber *pulseRate;

@end
