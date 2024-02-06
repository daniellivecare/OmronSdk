//
//  BSOPersistentContainer.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BSOPersistentContainer : NSObject

+ (BSOPersistentContainer *)sharedPersistentContainer;

@property (copy, readonly) NSString *name;
@property (strong, readonly) NSManagedObjectContext *viewContext;
@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSManagedObjectContext *)createNewContext;
- (void)saveContextChanges:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END
