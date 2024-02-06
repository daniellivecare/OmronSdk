//
//  OHQLog.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQDefines.h"
#import "OHQLogStore.h"
#import <Foundation/Foundation.h>

#ifdef OHQ_OPTION_ENABLE_LOG
#define OHQLogE(format, ...) OHQLog(OHQLogLevelError,   format, ##__VA_ARGS__)
#define OHQLogW(format, ...) OHQLog(OHQLogLevelWarning, format, ##__VA_ARGS__)
#define OHQLogI(format, ...) OHQLog(OHQLogLevelInfo,    format, ##__VA_ARGS__)
#define OHQLogD(format, ...) OHQLog(OHQLogLevelDebug,   format, ##__VA_ARGS__)
#define OHQLogV(format, ...) OHQLog(OHQLogLevelVerbose, format, ##__VA_ARGS__)
#define OHQFuncLogE(format, ...) OHQFuncLog(OHQLogLevelError,   __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#define OHQFuncLogW(format, ...) OHQFuncLog(OHQLogLevelWarning, __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#define OHQFuncLogI(format, ...) OHQFuncLog(OHQLogLevelInfo,    __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#define OHQFuncLogD(format, ...) OHQFuncLog(OHQLogLevelDebug,   __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#define OHQFuncLogV(format, ...) OHQFuncLog(OHQLogLevelVerbose, __PRETTY_FUNCTION__, __LINE__, format, ##__VA_ARGS__)
#else // OHQ_OPTION_ENABLE_LOG
#define OHQLogE(format, ...)
#define OHQLogW(format, ...)
#define OHQLogI(format, ...)
#define OHQLogD(format, ...)
#define OHQLogV(format, ...)
#define OHQFuncLogE(format, ...)
#define OHQFuncLogW(format, ...)
#define OHQFuncLogI(format, ...)
#define OHQFuncLogD(format, ...)
#define OHQFuncLogV(format, ...)
#endif // OHQ_OPTION_ENABLE_LOG

extern void OHQLog(OHQLogLevel level, NSString *formatString, ...) NS_FORMAT_FUNCTION(2,3) NS_NO_TAIL_CALL;
extern void OHQFuncLog(OHQLogLevel level, const char *function, int line, NSString *formatString, ...) NS_FORMAT_FUNCTION(4,5) NS_NO_TAIL_CALL;
