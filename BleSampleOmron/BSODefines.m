//
//  BSODefines.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODefines.h"
#import "NSDate+BleSampleOmron.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

BSOAppConfigKey const BSOAppConfigCurrentUserNameKey = @"currentUserName";

NSString * const BSOGuestUserName = @"Guest";

NSString * BSOProtocolDescription(BSOProtocol value) {
    NSString *ret = nil;
    switch (value) {
        case BSOProtocolNone: ret = @"None"; break;
        case BSOProtocolBluetoothStandard: ret = @"Bluetooth Standard"; break;
        case BSOProtocolOmronExtension: ret = @"Omron Extension"; break;
        default: break;
    }
    return ret;
}

NSString * BSOOperationDescription(BSOOperation value) {
    NSString *ret = nil;
    switch (value) {
        case BSOOperationNone: ret = @"None"; break;
        case BSOOperationRegister: ret = @"Register"; break;
        case BSOOperationTransfer: ret = @"Transfer"; break;
        case BSOOperationDelete: ret = @"Delete"; break;
        default: break;
    }
    return ret;
}

NSString * BSOLogHeaderString(NSDate *timeStamp) {
    struct utsname sysInfo;
    uname(&sysInfo);
    NSMutableString *text = [@"" mutableCopy];
    [text appendString:@"————————————————————————————————————————————————————————————\r\n"];
    NSDictionary<NSString *, id> *bundleInfo = [NSBundle mainBundle].infoDictionary;
    UIDevice *currentDevice = [UIDevice currentDevice];
    [text appendFormat:@"Product: %@ %@\r\n", bundleInfo[(NSString *)kCFBundleNameKey], bundleInfo[(NSString *)kCFBundleVersionKey]];
    [text appendFormat:@"Build: %@ %@\r\n", @__DATE__, @__TIME__];
    NSString *hardType = [NSString stringWithCString:sysInfo.machine encoding:NSUTF8StringEncoding];
    if (hardType == nil) {
        hardType = @"unknown device";
    }
    [text appendFormat:@"DeviceType: %@ (%@ %@)\r\n", hardType, currentDevice.systemName, currentDevice.systemVersion];
    [text appendFormat:@"DeviceName: %@\r\n", currentDevice.name];
    if (timeStamp) {
        [text appendFormat:@"TimeStamp: %@ (%@)\r\n", [timeStamp localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"], [NSTimeZone localTimeZone].name];
    }
    [text appendString:@"————————————————————————————————————————————————————————————\r\n"];
    return [text copy];
}
