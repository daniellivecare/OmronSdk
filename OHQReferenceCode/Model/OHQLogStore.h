//
//  OHQLogStore.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Log Level */
typedef NS_ENUM(NSUInteger, OHQLogLevel) {
    OHQLogLevelError,
    OHQLogLevelWarning,
    OHQLogLevelInfo,
    OHQLogLevelDebug,
    OHQLogLevelVerbose,
};

@interface OHQLogStore : NSObject

+ (OHQLogStore *)sharedStore;

@property (readonly) NSUInteger numberOfLogRecords;

- (void)append:(OHQLogLevel)level timeStamp:(NSDate *)timeStamp log:(NSString *)log;
- (void)removeAllLogRecords;
- (NSArray<NSString *> *)logRecordsWithLevel:(OHQLogLevel)level;
- (NSArray<NSString *> *)logRecordsWithLevel:(OHQLogLevel)level range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
