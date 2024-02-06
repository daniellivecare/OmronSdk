//
//  BSOSessionResultNavigationController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOSessionResultNavigationController.h"
#import "BSOSessionResultViewController.h"

@implementation BSOSessionResultNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIViewController *rootViewController = self.viewControllers.firstObject;
    if ([rootViewController isKindOfClass:[BSOSessionResultViewController class]]) {
        BSOSessionResultViewController *vc = (BSOSessionResultViewController *)rootViewController;
        vc.historyIdentifier = self.historyIdentifier;
    }
    else {
        abort();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
