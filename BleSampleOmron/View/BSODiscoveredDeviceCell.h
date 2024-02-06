//
//  BSODiscoveredDeviceCell.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@interface BSODiscoveredDeviceCell : UITableViewCell

+ (CGFloat)rowHeight;

@property (assign, nonatomic) OHQDeviceCategory category;
@property (strong, nonatomic) NSString *modelName;
@property (strong, nonatomic) NSString *localName;
@property (strong, nonatomic) NSNumber *RSSI;
@property (copy, nonatomic) NSArray *supportedProtocols;
@property (assign, nonatomic) BOOL registered;

@end
