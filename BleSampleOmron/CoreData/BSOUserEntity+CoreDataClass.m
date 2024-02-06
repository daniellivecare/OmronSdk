//
//  BSOUserEntity+CoreDataClass.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOUserEntity+CoreDataClass.h"

@implementation BSOUserEntity

+ (NSString *)entityName {
    return @"User";
}

+ (instancetype)insertNewEntityInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

@end
