//
//  BSODeviceSelectionNavigationController.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@protocol BSODeviceSelectionNavigationControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface BSODeviceSelectionNavigationController : UINavigationController

@end

@interface BSODeviceSelectionNavigationController (DelegateProperty)

@property (nullable, weak, nonatomic) id<BSODeviceSelectionNavigationControllerDelegate> delegate;

@end

@protocol BSODeviceSelectionNavigationControllerDelegate <UINavigationControllerDelegate>

@optional
- (void)deviceSelectionNavigationController:(BSODeviceSelectionNavigationController *)navController didSelectDevice:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo;

@end

NS_ASSUME_NONNULL_END
