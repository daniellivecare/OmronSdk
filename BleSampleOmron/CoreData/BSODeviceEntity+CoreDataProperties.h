//
//  BSODeviceEntity+CoreDataProperties.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODeviceEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BSODeviceEntity (CoreDataProperties)

+ (NSFetchRequest<BSODeviceEntity *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSNumber *consentCode;
@property (nullable, nonatomic, retain) NSNumber *databaseChangeIncrement;
@property (nullable, nonatomic, retain) NSNumber *databaseUpdateFlag;
@property (nonatomic) int16_t deviceCategory;
@property (nullable, nonatomic, retain) NSUUID *identifier;
@property (nullable, nonatomic, retain) NSNumber *lastSequenceNumber;
@property (nullable, nonatomic, copy) NSString *localName;
@property (nullable, nonatomic, copy) NSString *modelName;
@property (nonatomic) int16_t protocol;
@property (nullable, nonatomic, retain) NSNumber *userIndex;
@property (nullable, nonatomic, retain) BSOUserEntity *user;

@end

NS_ASSUME_NONNULL_END
