//
//  BSOSessionData.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOSessionData.h"

@interface BSOSessionData ()

@property (readwrite, strong, nonatomic) NSUUID *identifier;
@property (readwrite, nullable, copy, nonatomic) NSDictionary<OHQSessionOptionKey,id> *options;
@property (readwrite, nullable, copy, nonatomic) NSString *modelName;
@property (readwrite, assign, nonatomic) OHQDeviceCategory deviceCategory;
@property (readwrite, nullable, strong, nonatomic) NSDate *currentTime;
@property (readwrite, nullable, strong, nonatomic) NSNumber *batteryLevel;
@property (readwrite, nullable, strong, nonatomic) NSNumber *registeredUserIndex;
@property (readwrite, nullable, strong, nonatomic) NSNumber *authenticatedUserIndex;
@property (readwrite, nullable, strong, nonatomic) NSNumber *deletedUserIndex;
@property (readwrite, nullable, strong, nonatomic) NSNumber *databaseChangeIncrement;
@property (readwrite, nullable, copy, nonatomic) NSDictionary<OHQUserDataKey,id> *userData;
@property (readwrite, nullable, strong, nonatomic) NSNumber *sequenceNumberOfLatestRecord;
@property (readwrite, nullable, copy, nonatomic) NSArray<NSDictionary<OHQMeasurementRecordKey,id> *> *measurementRecords;
@property (readwrite, strong, nonatomic) NSDate *completionDate;
@property (readwrite, nullable, copy, nonatomic) NSString *log;
@property (assign, nonatomic) NSUInteger logStartPosition;
@property (readwrite, nullable, nonatomic) NSString *bluetoothStatus;
@property (readwrite, nullable, nonatomic) NSString *bluetoothAuthorization;

@end

@implementation BSOSessionData

- (instancetype)initWithIdentifier:(NSUUID *)identifier options:(NSDictionary<OHQSessionOptionKey,id> *)options {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.options = options;
        
        self.deviceCategory = OHQDeviceCategoryUnknown;
        self.completionReason = OHQCompletionReasonUnknown;
        self.logStartPosition = [OHQLogStore sharedStore].numberOfLogRecords;
        self.bluetoothStatus = @"-";
        self.bluetoothAuthorization = @"-";
    }
    return self;
}

- (void)addSessionData:(id)data withType:(OHQDataType)type {
    switch (type) {
        case OHQDataTypeCurrentTime: {
            self.currentTime = data;
            break;
        }
        case OHQDataTypeBatteryLevel: {
            self.batteryLevel = data;
            break;
        }
        case OHQDataTypeModelName: {
            self.modelName = data;
            break;
        }
        case OHQDataTypeDeviceCategory: {
            self.deviceCategory = [data shortValue];
            break;
        }
        case OHQDataTypeRegisteredUserIndex: {
            self.registeredUserIndex = data;
            break;
        }
        case OHQDataTypeAuthenticatedUserIndex: {
            self.authenticatedUserIndex = data;
            break;
        }
        case OHQDataTypeDeletedUserIndex: {
            self.deletedUserIndex = data;
            break;
        }
        case OHQDataTypeUserData: {
            self.userData = data;
            break;
        }
        case OHQDataTypeDatabaseChangeIncrement: {
            self.databaseChangeIncrement = data;
            break;
        }
        case OHQDataTypeSequenceNumberOfLatestRecord: {
            self.sequenceNumberOfLatestRecord = data;
            break;
        }
        case OHQDataTypeMeasurementRecords: {
            self.measurementRecords = data;
            break;
        }
        default: {
            break;
        }
    }
}

- (void)setCompletionReason:(OHQCompletionReason)completionReason {
    if (_completionReason != completionReason) {
        self.completionDate = [NSDate date];
        _completionReason = completionReason;
        
        NSRange logRange = NSMakeRange(self.logStartPosition, [OHQLogStore sharedStore].numberOfLogRecords - self.logStartPosition);
        if (logRange.length > 0) {
            NSArray<NSString *> *logRecords = [[OHQLogStore sharedStore] logRecordsWithLevel:OHQLogLevelVerbose range:logRange];
            if (logRecords) {
                __block NSMutableString *temporaryLog = [@"" mutableCopy];
                [logRecords enumerateObjectsUsingBlock:^(NSString * _Nonnull logRecord, NSUInteger idx, BOOL * _Nonnull stop) {
                    [logRecord enumerateLinesUsingBlock:^(NSString * _Nonnull line, BOOL * _Nonnull stop) {
                        [temporaryLog appendFormat:@"%@\r\n", line];
                    }];
                }];
                self.log = [temporaryLog copy];
            }
        }
    }
}

@end
