//
//  BSOTableViewHeaderView.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSOTableViewHeaderView : UITableViewHeaderFooterView

+ (UINib *)nib;
+ (NSString *)reuseIdentifier;
+ (CGFloat)requiredHeight;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
