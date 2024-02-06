//
//  BSOThermometerCollectionViewCell.h
//  BleSampleOmron
//
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSOThermometerCollectionViewCell : UICollectionViewCell

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;
+ (CGSize)requiredSize;

@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, copy) NSString *temperatureUnit;
@property (nonatomic, strong) NSString *temperature;

@end
