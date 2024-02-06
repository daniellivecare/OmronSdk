//
//  NSDate+BleSampleOmron.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (BleSampleOmron)

+ (instancetype)dateWithLocalTimeString:(NSString *)localTimeString format:(NSString *)dateFormat;
- (NSString *)localTimeStringWithFormat:(NSString *)dateFormat;

@end
