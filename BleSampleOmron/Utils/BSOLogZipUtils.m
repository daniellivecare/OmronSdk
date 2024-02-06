//
//  BSOLogZipUtils.m
//  BleSampleOmron
//
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOLogZipUtils.h"
#import "BSODefines.h"
#import "BSOHistoryEntity+CoreDataClass.h"
#import "BSOPersistentContainer.h"
#import "OHQReferenceCode.h"
#import "ZipArchive.h"
#import "OHQLogStore.h"

@interface BSOLogZipUtils ()

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (copy, nonatomic) NSArray<BSOHistoryEntity *> *historyEntities;
@property (copy, nonatomic) NSArray<NSString *> *logSnapShot;

@end

@implementation BSOLogZipUtils

- (NSURL *)createZipFile:(BOOL)fromHistory fileName:(NSString *)fileNameString {
    NSURL *retZipURL;
    NSFetchRequest *fetchRequest = [BSOHistoryEntity fetchRequest];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"completionDate" ascending:NO]];
    self.context = [BSOPersistentContainer sharedPersistentContainer].viewContext;
    self.historyEntities = [self.context executeFetchRequest:fetchRequest error:nil];
    self.logSnapShot = [[OHQLogStore sharedStore]
                        logRecordsWithLevel:OHQLogLevelVerbose];
    NSMutableArray *outputFilePaths = [NSMutableArray array];
    NSURL *temporaryDirectoryURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSError *error;
    
    [self bso_removeLogFilesInDirectory:[NSURL fileURLWithPath:NSTemporaryDirectory()]];

    if (self.historyEntities.count) {
        for (int i = 0;i < self.historyEntities.count; i++) {
            BSOHistoryEntity *historyEntity = self.historyEntities[i];
            NSMutableArray *zipCreatePaths = [NSMutableArray array];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *historyFileNameDate = [formatter stringFromDate:historyEntity.completionDate];
            NSString *historyFileName = [NSString stringWithFormat:@"%@.txt", historyFileNameDate];
            NSString *zipHistoryFileName = [NSString stringWithFormat:@"%@.zip", historyFileNameDate];
            
            BOOL isDirectory = NO;
            BOOL exists = [[NSFileManager defaultManager]
                           fileExistsAtPath:temporaryDirectoryURL.path isDirectory:&isDirectory];
            
            if (!exists || !isDirectory) {
                error = nil;
                if (![[NSFileManager defaultManager]
                      createDirectoryAtURL:temporaryDirectoryURL
                      withIntermediateDirectories:YES attributes:nil
                      error:&error]) {
                    abort();
                }
            }
            
            NSURL *historyFileURL = [temporaryDirectoryURL
                                 URLByAppendingPathComponent:historyFileName];
            NSURL *zipHistoryFileURL = [temporaryDirectoryURL
                                 URLByAppendingPathComponent:zipHistoryFileName];
            NSString *zipFilePath = zipHistoryFileURL.path;
            NSString *descriptionToExport = historyEntity.descriptionToExport;
            if ([descriptionToExport writeToURL:historyFileURL atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
                [zipCreatePaths addObject:historyFileURL.path];
                [SSZipArchive createZipFileAtPath:zipFilePath withFilesAtPaths:zipCreatePaths];
                [outputFilePaths addObject:zipFilePath];
            }
        }
        
        if (fromHistory == YES) {
            NSString *dateTimeFileName = [NSString stringWithFormat:@"%@.txt", fileNameString];
            NSURL *dateTimeFileURL = [temporaryDirectoryURL URLByAppendingPathComponent:dateTimeFileName];
            NSString *dateTimeFileContent = @"";
            if ([dateTimeFileContent writeToURL:dateTimeFileURL atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
                [outputFilePaths addObject:dateTimeFileURL.path];
            }
        }
    }
    
    NSArray<NSString *> *logArray = [self.logSnapShot copy];
    if (logArray.count) {
        NSDate *timeStampLog = [NSDate date];
        NSDateFormatter *formatterLog = [[NSDateFormatter alloc] init];
        [formatterLog setDateFormat:@"yyyyMMddHHmmss"];

        NSString *logFileName = [NSString stringWithFormat:@"log_%@.txt", [formatterLog stringFromDate:timeStampLog]];
        
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:temporaryDirectoryURL.path isDirectory:&isDirectory];
        if (!exists || !isDirectory) {
            error = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtURL:temporaryDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error]) {
                abort();
            }
        }
        
        NSURL *logFileURL = [temporaryDirectoryURL URLByAppendingPathComponent:logFileName];
        [self bso_saveArray:logArray toURL:logFileURL usingTimeStamp:timeStampLog completion:^{
            [outputFilePaths addObject:logFileURL.path];
        }];
    }
    
    if (outputFilePaths.count > 0) {
        NSDate *timeStamp = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *outputZipFileName = [NSString stringWithFormat:@"%@.zip", [formatter stringFromDate:timeStamp]];
        NSURL *outputZipURL = [temporaryDirectoryURL
                               URLByAppendingPathComponent:outputZipFileName];
        [SSZipArchive createZipFileAtPath:outputZipURL.path withFilesAtPaths:outputFilePaths];
        retZipURL = outputZipURL;
    }
    
    return retZipURL;
}

- (void)bso_removeLogFilesInDirectory:(NSURL *)directoryURL {
    NSArray<NSString *> *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryURL.path error:nil];
    if (fileNames.count) {
        NSArray<NSString *> *filePaths = [directoryURL.path stringsByAppendingPaths:fileNames];
        NSPredicate *logFileFilteringPredicate = [NSPredicate predicateWithBlock:^BOOL(id _Nullable content, NSDictionary<NSString *,id> * _Nullable bindings) {
            BOOL isDirectory;
            BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:content isDirectory:&isDirectory];
            return (!isDirectory && exists && ([content hasSuffix:@".zip"] || [content hasSuffix:@".txt"]));
        }];
        NSArray<NSString *> *logfiles = [filePaths filteredArrayUsingPredicate:logFileFilteringPredicate];
        [logfiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[NSFileManager defaultManager] removeItemAtPath:obj error:nil];
        }];
    }
}

#pragma mark - Private Methods

- (void)bso_saveArray:(NSArray *)array toURL:(NSURL *)URL usingTimeStamp:(NSDate *)timeStamp completion:(dispatch_block_t)completion {
    __block NSMutableString *text = [BSOLogHeaderString(timeStamp) mutableCopy];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [text appendString:[NSString stringWithFormat:@"%@\r\n", obj]];
    }];
    NSError *error;
    if (![text writeToURL:URL atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        abort();
    }
    if (completion) {
        completion();
    }
}

@end
