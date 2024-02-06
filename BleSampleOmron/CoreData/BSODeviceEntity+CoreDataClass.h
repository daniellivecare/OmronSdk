//
//  BSODeviceEntity+CoreDataClass.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BSOUserEntity, NSNumber, NSUUID;

NS_ASSUME_NONNULL_BEGIN

@interface BSODeviceEntity : NSManagedObject

+ (NSString *)entityName;
+ (instancetype)insertNewEntityInContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "BSODeviceEntity+CoreDataProperties.h"
