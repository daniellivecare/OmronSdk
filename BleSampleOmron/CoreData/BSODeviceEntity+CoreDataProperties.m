//
//  BSODeviceEntity+CoreDataProperties.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODeviceEntity+CoreDataProperties.h"

@implementation BSODeviceEntity (CoreDataProperties)

+ (NSFetchRequest<BSODeviceEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Device"];
}

@dynamic consentCode;
@dynamic databaseChangeIncrement;
@dynamic databaseUpdateFlag;
@dynamic deviceCategory;
@dynamic identifier;
@dynamic lastSequenceNumber;
@dynamic localName;
@dynamic modelName;
@dynamic protocol;
@dynamic userIndex;
@dynamic user;

@end
