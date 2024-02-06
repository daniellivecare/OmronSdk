//
//  CBUUID+Description.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBUUID (Description)

@property (readonly, copy) NSString *description;

@end

NS_ASSUME_NONNULL_END
