//
//  BSOGenderSelectionViewController.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@protocol BSOGenderSelectionViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface BSOGenderSelectionViewController : UITableViewController

@property (weak, nonatomic, nullable) id<BSOGenderSelectionViewControllerDelegate> delegate;
@property (strong, nonatomic) OHQGender gender;

@end

@protocol BSOGenderSelectionViewControllerDelegate <NSObject>

- (void)genderSelectionViewControllerDidUpdateValue:(BSOGenderSelectionViewController *)genderSelectionViewController;

@end

NS_ASSUME_NONNULL_END
