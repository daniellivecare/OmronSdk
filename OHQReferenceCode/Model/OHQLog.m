//
//  OHQLog.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQLog.h"
#import <pthread.h>

void OHQLog(OHQLogLevel level, NSString *formatString, ...) {
    static NSString *_productName;
    static int _processIdentifier;
    static NSArray *_levelMarks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _productName = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
        _processIdentifier = [NSProcessInfo processInfo].processIdentifier;
        _levelMarks = @[@"E", @"W", @"I", @"D", @"V"];
    });
    
    va_list args;
    va_start(args, formatString);
    NSString *body = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    
    mach_port_t threadIdentifier = pthread_mach_thread_np(pthread_self());
    NSString *log = [NSString stringWithFormat:@"%@/%@[%d:%x] %@", _levelMarks[level], _productName, _processIdentifier, threadIdentifier, body];
    NSDate *timeStamp = [NSDate date];
    
#ifdef OHQ_OPTION_ENABLE_LOG_OUTPUT_TO_CONSOLE
    NSLog(@"%@ %@", _levelMarks[level], body);
#endif // OHQ_OPTION_ENABLE_LOG_OUTPUT_TO_CONSOLE
    [[OHQLogStore sharedStore] append:level timeStamp:timeStamp log:log];
}

void OHQFuncLog(OHQLogLevel level, const char *function, int line, NSString *formatString, ...) {
    static NSString *_productName;
    static int _processIdentifier;
    static NSArray *_levelMarks;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _productName = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
        _processIdentifier = [NSProcessInfo processInfo].processIdentifier;
        _levelMarks = @[@"E", @"W", @"I", @"D", @"V"];
    });
    
    va_list args;
    va_start(args, formatString);
    NSString *body = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    
    mach_port_t threadIdentifier = pthread_mach_thread_np(pthread_self());
    NSString *log = [NSString stringWithFormat:@"%@/%@[%d:%x] L%d:%s %@", _levelMarks[level], _productName, _processIdentifier, threadIdentifier, line, function, body];
    NSDate *timeStamp = [NSDate date];
    
#ifdef OHQ_OPTION_ENABLE_LOG_OUTPUT_TO_CONSOLE
    NSLog(@"%@ L%d:%s %@", _levelMarks[level], line, function, body);
#endif // OHQ_OPTION_ENABLE_LOG_OUTPUT_TO_CONSOLE
    [[OHQLogStore sharedStore] append:level timeStamp:timeStamp log:log];
}
