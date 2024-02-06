//
//  BSOBloodPressureCollectionViewCell.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSOBloodPressureCollectionViewCell : UICollectionViewCell

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;
+ (CGSize)requiredSize;

@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) NSNumber *userIndex;
@property (nonatomic, strong) NSNumber *sequenceNumber;
@property (nonatomic, copy) NSString *pressureUnit;
@property (nonatomic, strong) NSNumber *systolic;
@property (nonatomic, strong) NSNumber *diastolic;
@property (nonatomic, strong) NSNumber *pulseRate;

@end
