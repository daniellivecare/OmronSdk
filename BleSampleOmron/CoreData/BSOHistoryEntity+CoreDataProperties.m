//
//  BSOHistoryEntity+CoreDataProperties.m
//  BleSampleOmron
//
//  Copyright © 2021 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOHistoryEntity+CoreDataProperties.h"

@implementation BSOHistoryEntity (CoreDataProperties)

+ (NSFetchRequest<BSOHistoryEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"History"];
}

@dynamic batteryLevel;
@dynamic completionDate;
@dynamic consentCode;
@dynamic deviceCategory;
@dynamic deviceTime;
@dynamic identifier;
@dynamic localName;
@dynamic log;
@dynamic logHeader;
@dynamic measurementRecords;
@dynamic modelName;
@dynamic operation;
@dynamic protocol;
@dynamic status;
@dynamic userData;
@dynamic userIndex;
@dynamic userName;
@dynamic bluetoothAuthorization;
@dynamic bluetoothStatus;

@end
