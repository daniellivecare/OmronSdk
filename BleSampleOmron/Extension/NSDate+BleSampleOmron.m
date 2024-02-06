//
//  NSDate+BleSampleOmron.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "NSDate+BleSampleOmron.h"

static NSString * const DefaultDateFormat = @"yyyy-MM-dd HH:mm:ss";

@implementation NSDate (BleSampleOmron)

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [NSDateFormatter new];
        dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
    });
    return dateFormatter;
}

+ (instancetype)dateWithLocalTimeString:(NSString *)localTimeString format:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[self class] dateFormatter];
    formatter.dateFormat = (dateFormat ? dateFormat : DefaultDateFormat);
    return [formatter dateFromString:localTimeString];
}

- (NSString *)localTimeStringWithFormat:(NSString *)dateFormat {
    NSDateFormatter *formatter = [[self class] dateFormatter];
    formatter.dateFormat = (dateFormat ? dateFormat : DefaultDateFormat);
    return [formatter stringFromDate:self];
}

@end
