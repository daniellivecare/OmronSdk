//
//  BSOAppDelegate.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class REFrostedViewController;

@interface BSOAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) REFrostedViewController *frostedViewController;

@end
