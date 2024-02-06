//
//  BSOSessionViewController.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOSessionData.h"
#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@protocol BSOSessionViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface BSOSessionViewController : UIViewController

@property (weak, nonatomic) id<BSOSessionViewControllerDelegate> delegate;
@property (strong, nonatomic) NSUUID *deviceIdentifier;
@property (nullable, copy, nonatomic) NSDictionary<OHQSessionOptionKey,id> *options;

@end

@protocol BSOSessionViewControllerDelegate <NSObject>

@optional
- (void)sessionViewControllerWillStartSession:(BSOSessionViewController *)viewController;
- (NSString *)sessionViewController:(BSOSessionViewController *)viewController completionMessageForData:(BSOSessionData *)data;

@required
- (void)sessionViewControllerDidCancelSessionByUserOperation:(BSOSessionViewController *)viewController;
- (void)sessionViewController:(BSOSessionViewController *)viewController didCompleteSessionWithData:(BSOSessionData *)data;

@end

NS_ASSUME_NONNULL_END
