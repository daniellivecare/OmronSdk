//
//  BSOUserEntity+CoreDataProperties.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOUserEntity+CoreDataProperties.h"

@implementation BSOUserEntity (CoreDataProperties)

+ (NSFetchRequest<BSOUserEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"User"];
}

@dynamic dateOfBirth;
@dynamic gender;
@dynamic height;
@dynamic name;
@dynamic registeredDevices;

@end
