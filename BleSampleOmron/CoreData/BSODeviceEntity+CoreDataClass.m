//
//  BSODeviceEntity+CoreDataClass.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODeviceEntity+CoreDataClass.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"

@implementation BSODeviceEntity

+ (NSString *)entityName {
    return @"Device";
}

+ (instancetype)insertNewEntityInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

@end
