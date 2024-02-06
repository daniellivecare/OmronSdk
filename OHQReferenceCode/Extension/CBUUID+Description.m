//
//  CBUUID+Description.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "CBUUID+Description.h"

@implementation CBUUID (Description)

- (NSString *)description {
    static NSDictionary *UUIDDescriptions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"UUIDDescriptions" ofType:@"plist"];
        UUIDDescriptions = [NSDictionary dictionaryWithContentsOfFile:path];
    });
    
    NSString *ret = nil;
    NSString *description = UUIDDescriptions[self.UUIDString.uppercaseString];
    if (description) {
        ret = [NSString stringWithFormat:@"%@ (%@)", description, self.UUIDString];
    }
    else {
        ret = [NSString stringWithFormat:@"Unknown (%@)", self.UUIDString];
    }
    return ret;
}

@end
