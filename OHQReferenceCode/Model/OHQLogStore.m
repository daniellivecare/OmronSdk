//
//  OHQLogStore.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQLogStore.h"

static NSString * const LogDataLevelKey = @"level";
static NSString * const LogDataBodyKey = @"log";

@interface OHQLogStore ()
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *logRecords;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation OHQLogStore

- (instancetype)init {
    self = [super init];
    if (self) {
        self.logRecords = [@[] mutableCopy];
        self.dateFormatter = [NSDateFormatter new];
        self.dateFormatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        self.dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        self.dateFormatter.timeZone = [NSTimeZone localTimeZone];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    }
    return self;
}

+ (OHQLogStore *)sharedStore {
    static OHQLogStore *_sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedStore = [[OHQLogStore alloc] init];
    });
    return _sharedStore;
}

- (NSUInteger)numberOfLogRecords {
    return self.logRecords.count;
}

- (void)append:(OHQLogLevel)level timeStamp:(NSDate *)timeStamp log:(NSString *)log {
    NSString *timeStampString = [self.dateFormatter stringFromDate:timeStamp];
    NSString *fullLog = [NSString stringWithFormat:@"%@ %@",timeStampString, log];
    
    @synchronized (self) {
        [self.logRecords addObject:@{LogDataLevelKey: @(level), LogDataBodyKey: fullLog}];
    }
}

- (void)removeAllLogRecords {
    @synchronized (self) {
        [self.logRecords removeAllObjects];
    }
}

- (NSArray<NSString *> *)logRecordsWithLevel:(OHQLogLevel)level {
    NSArray<NSDictionary<NSString *, id> *> *logRecords;
    @synchronized (self) {
        logRecords = [self.logRecords copy];
    }
    NSPredicate *levelPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary<NSString *,id> * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([evaluatedObject[LogDataLevelKey] intValue] <= level);
    }];
    NSArray<NSDictionary<NSString *, id> *> *filteredLogRecords = [logRecords filteredArrayUsingPredicate:levelPredicate];
    __block NSMutableArray<NSString *> *ret = [@[] mutableCopy];
    [filteredLogRecords enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret addObject:obj[LogDataBodyKey]];
    }];
    return ret;
}

- (NSArray<NSString *> *)logRecordsWithLevel:(OHQLogLevel)level range:(NSRange)range {
    NSArray<NSDictionary<NSString *, id> *> *logRecords;
    @synchronized (self) {
        logRecords = [self.logRecords subarrayWithRange:range];
    }
    NSPredicate *levelPredicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary<NSString *,id> * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return ([evaluatedObject[LogDataLevelKey] intValue] <= level);
    }];
    NSArray<NSDictionary<NSString *, id> *> *filteredLogRecords = [logRecords filteredArrayUsingPredicate:levelPredicate];
    __block NSMutableArray<NSString *> *ret = [@[] mutableCopy];
    [filteredLogRecords enumerateObjectsUsingBlock:^(NSDictionary<NSString *,id> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ret addObject:obj[LogDataBodyKey]];
    }];
    return ret;
}

@end
