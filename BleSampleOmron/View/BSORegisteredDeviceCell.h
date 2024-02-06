//
//  BSORegisteredDeviceCell.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODefines.h"
#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@interface BSORegisteredDeviceCell : UITableViewCell

+ (CGFloat)rowHeight;

@property (assign, nonatomic) OHQDeviceCategory category;
@property (assign, nonatomic) BOOL hasUpdatedData;
@property (assign, nonatomic) BOOL isBreakdown;
@property (strong, nonatomic) NSString *modelName;
@property (strong, nonatomic) NSString *localName;
@property (strong, nonatomic) NSNumber *userIndex;
@property (assign, nonatomic) BSOProtocol protocol;

@end
