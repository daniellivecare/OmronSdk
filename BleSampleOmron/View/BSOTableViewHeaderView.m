//
//  BSOTableViewHeaderView.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOTableViewHeaderView.h"

@implementation BSOTableViewHeaderView

+ (UINib *)nib {
    return [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

+ (CGFloat)requiredHeight {
    return 60.0f;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
}

@end
