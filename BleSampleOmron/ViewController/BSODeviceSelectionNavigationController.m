//
//  BSODeviceSelectionNavigationController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODeviceSelectionNavigationController.h"
#import "BSODiscoveredDeviceSelectionViewController.h"

@interface BSODeviceSelectionNavigationController () <BSODiscoveredDeviceSelectionViewControllerDelegate>

@end

@implementation BSODeviceSelectionNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *rootViewController = self.viewControllers.firstObject;
    if ([rootViewController isKindOfClass:[BSODiscoveredDeviceSelectionViewController class]]) {
        BSODiscoveredDeviceSelectionViewController *vc = (BSODiscoveredDeviceSelectionViewController *)rootViewController;
        vc.delegate = self;
        vc.allowUserInteractionOfCategoryFilterSetting = YES;
        vc.pairingModeDeviceOnly = NO;
        vc.categoryToFilter = OHQDeviceCategoryAny;
        vc.registeredDeviceUUIDs = nil;
    }
    else {
        abort();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Discovered device selection view controller delegate

- (void)discoveredDeviceSelectionViewController:(BSODiscoveredDeviceSelectionViewController *)viewController didSelectDevice:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo {
    if ([self.delegate respondsToSelector:@selector(deviceSelectionNavigationController:didSelectDevice:)]) {
        [self.delegate deviceSelectionNavigationController:self didSelectDevice:deviceInfo];
    }
}

@end
