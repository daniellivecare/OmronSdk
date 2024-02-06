//
//  BSODiscoveredDeviceSelectionViewController.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@protocol BSODiscoveredDeviceSelectionViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface BSODiscoveredDeviceSelectionViewController : UITableViewController

@property (nullable, weak, nonatomic) id<BSODiscoveredDeviceSelectionViewControllerDelegate> delegate;
@property (nullable, copy, nonatomic) NSArray<NSUUID *> *registeredDeviceUUIDs;
@property (assign, nonatomic) BOOL advertisementDataViewMode;
@property (assign, nonatomic) BOOL allowUserInteractionOfCategoryFilterSetting;
@property (assign, nonatomic) BOOL pairingModeDeviceOnly;
@property (assign, nonatomic) OHQDeviceCategory categoryToFilter;

@end

@protocol BSODiscoveredDeviceSelectionViewControllerDelegate <NSObject>

- (void)discoveredDeviceSelectionViewController:(BSODiscoveredDeviceSelectionViewController *)viewController didSelectDevice:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo;

@end

NS_ASSUME_NONNULL_END
