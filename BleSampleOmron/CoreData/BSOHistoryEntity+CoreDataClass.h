//
//  BSOHistoryEntity+CoreDataClass.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSArray, NSDictionary, NSNumber;

NS_ASSUME_NONNULL_BEGIN

@interface BSOHistoryEntity : NSManagedObject

+ (NSString *)entityName;
+ (instancetype)insertNewEntityInContext:(NSManagedObjectContext *)context;

@property (readonly) NSString *descriptionToExport;

@end

NS_ASSUME_NONNULL_END

#import "BSOHistoryEntity+CoreDataProperties.h"
