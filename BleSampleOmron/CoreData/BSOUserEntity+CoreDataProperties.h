//
//  BSOUserEntity+CoreDataProperties.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOUserEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BSOUserEntity (CoreDataProperties)

+ (NSFetchRequest<BSOUserEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *dateOfBirth;
@property (nullable, nonatomic, copy) NSString *gender;
@property (nullable, nonatomic, retain) NSNumber *height;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSOrderedSet<BSODeviceEntity *> *registeredDevices;

@end

@interface BSOUserEntity (CoreDataGeneratedAccessors)

- (void)insertObject:(BSODeviceEntity *)value inRegisteredDevicesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromRegisteredDevicesAtIndex:(NSUInteger)idx;
- (void)insertRegisteredDevices:(NSArray<BSODeviceEntity *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeRegisteredDevicesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInRegisteredDevicesAtIndex:(NSUInteger)idx withObject:(BSODeviceEntity *)value;
- (void)replaceRegisteredDevicesAtIndexes:(NSIndexSet *)indexes withRegisteredDevices:(NSArray<BSODeviceEntity *> *)values;
- (void)addRegisteredDevicesObject:(BSODeviceEntity *)value;
- (void)removeRegisteredDevicesObject:(BSODeviceEntity *)value;
- (void)addRegisteredDevices:(NSOrderedSet<BSODeviceEntity *> *)values;
- (void)removeRegisteredDevices:(NSOrderedSet<BSODeviceEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
