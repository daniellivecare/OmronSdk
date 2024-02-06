//
//  BSOAdvertisementDataViewController.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@interface BSOAdvertisementDataViewController : UITableViewController

@property (nonatomic, copy) NSDictionary<OHQAdvertisementDataKey, id> *advertisementData;

@end
