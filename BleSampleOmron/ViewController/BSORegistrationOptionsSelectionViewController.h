//
//  BSORegistrationOptionsSelectionViewController.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODefines.h"
#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@protocol BSORegistrationOptionsSelectionViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface BSORegistrationOptionsSelectionViewController : UITableViewController

@property (nullable, weak, nonatomic) id<BSORegistrationOptionsSelectionViewControllerDelegate> delegate;
@property (nullable, copy, nonatomic) NSDictionary<OHQDeviceInfoKey,id> *deviceInfo;
@property (nullable, copy, nonatomic) NSDictionary<OHQUserDataKey,id> *userData;

@end

@protocol BSORegistrationOptionsSelectionViewControllerDelegate <NSObject>

- (void)registrationOptionsSelectionViewController:(BSORegistrationOptionsSelectionViewController *)viewController didSelectProtocol:(BSOProtocol)protocol options:(NSDictionary<OHQSessionOptionKey,id> *)options;

@end

NS_ASSUME_NONNULL_END
