//
//  BSODeviceInfoCell.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODefines.h"
#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@interface BSODeviceInfoCell : UITableViewCell

@property (assign, nonatomic) OHQDeviceCategory category;
@property (assign, nonatomic) BSOProtocol protocol;
@property (copy, nonatomic) NSString *modelName;
@property (copy, nonatomic) NSString *localName;
@property (copy, nonatomic) NSDate *deviceTime;
@property (copy, nonatomic) NSNumber *batteryLevel;

@end
