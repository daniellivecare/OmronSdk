//
//  BSOLogZipUtils.h
//  BleSampleOmron
//
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BSOLogZipUtils : NSObject
- (NSURL *)createZipFile:(BOOL)fromHistory fileName: (NSString *)fileNameString;
- (void)bso_removeLogFilesInDirectory:(NSURL *)directoryURL;
@end

NS_ASSUME_NONNULL_END
