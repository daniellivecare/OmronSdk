//
//  BSOHistoryEntity+CoreDataProperties.h
//  BleSampleOmron
//  
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOHistoryEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BSOHistoryEntity (CoreDataProperties)

+ (NSFetchRequest<BSOHistoryEntity *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSNumber *batteryLevel;
@property (nullable, nonatomic, copy) NSDate *completionDate;
@property (nullable, nonatomic, retain) NSNumber *consentCode;
@property (nonatomic) int16_t deviceCategory;
@property (nullable, nonatomic, copy) NSDate *deviceTime;
@property (nullable, nonatomic, retain) NSUUID *identifier;
@property (nullable, nonatomic, copy) NSString *localName;
@property (nullable, nonatomic, copy) NSString *log;
@property (nullable, nonatomic, copy) NSString *logHeader;
@property (nullable, nonatomic, retain) NSArray *measurementRecords;
@property (nullable, nonatomic, copy) NSString *modelName;
@property (nonatomic) int16_t operation;
@property (nonatomic) int16_t protocol;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, retain) NSDictionary *userData;
@property (nullable, nonatomic, retain) NSNumber *userIndex;
@property (nullable, nonatomic, copy) NSString *userName;
@property (nullable, nonatomic, copy) NSString *bluetoothAuthorization;
@property (nullable, nonatomic, copy) NSString *bluetoothStatus;

@end

NS_ASSUME_NONNULL_END
