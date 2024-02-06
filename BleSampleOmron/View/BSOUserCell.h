//
//  BSOUserCell.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BSOUserCell : UITableViewCell

+ (CGFloat)rowHeight;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
