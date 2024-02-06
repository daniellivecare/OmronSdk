//
//  BSOUserEntity+CoreDataClass.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BSODeviceEntity, NSNumber;

NS_ASSUME_NONNULL_BEGIN

@interface BSOUserEntity : NSManagedObject

+ (NSString *)entityName;
+ (instancetype)insertNewEntityInContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "BSOUserEntity+CoreDataProperties.h"
