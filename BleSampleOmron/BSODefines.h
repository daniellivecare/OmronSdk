//
//  BSODefines.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/** App Config key */
typedef NSString * BSOAppConfigKey NS_STRING_ENUM;
extern BSOAppConfigKey const BSOAppConfigCurrentUserNameKey;

/** Guest User Name */
extern NSString * const BSOGuestUserName;

/** Protocol Type */
typedef NS_ENUM(SInt16, BSOProtocol) {
    BSOProtocolNone = 0,
    BSOProtocolBluetoothStandard,
    BSOProtocolOmronExtension,
};

/** Operation Type */
typedef NS_ENUM(SInt16, BSOOperation) {
    BSOOperationNone = 0,
    BSOOperationRegister,
    BSOOperationTransfer,
    BSOOperationDelete,
};

extern NSString * BSOProtocolDescription(BSOProtocol value);
extern NSString * BSOOperationDescription(BSOOperation value);
extern NSString * BSOLogHeaderString(NSDate *timeStamp);
