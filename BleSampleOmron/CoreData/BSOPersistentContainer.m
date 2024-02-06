//
//  BSOPersistentContainer.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOPersistentContainer.h"

static NSString * const ContainerName = @"BleSampleOmron";
static NSString * const SQLiteStoreName = @"BleSampleOmron.sqlite";

@interface BSOPersistentContainer ()

@property (copy, readwrite) NSString *name;
@property (strong, readwrite) NSManagedObjectContext *viewContext;
@property (strong, readwrite) NSManagedObjectModel *managedObjectModel;
@property (strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, readonly) NSURL *applicationSupportDirectory;

- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model;

@end

@implementation BSOPersistentContainer

+ (BSOPersistentContainer *)sharedPersistentContainer {
    static BSOPersistentContainer *sharedPersistentContainer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPersistentContainer = [[BSOPersistentContainer alloc] initWithName:ContainerName];
    });
    return sharedPersistentContainer;
}

- (instancetype)initWithName:(NSString *)name {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:name withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:URL];
    return [self initWithName:name managedObjectModel:model];
}

- (instancetype)initWithName:(NSString *)name managedObjectModel:(NSManagedObjectModel *)model {
    self = [super init];
    if (self) {
        self.name = name;
        self.managedObjectModel = model;
        self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        BOOL isDirectory = NO;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:self.applicationSupportDirectory.path isDirectory:&isDirectory];
        if (!exists || !isDirectory) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtURL:self.applicationSupportDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
                abort();
            }
        }
        
        NSError *error = nil;
        NSURL *SQLiteStoreURL = [[self.applicationSupportDirectory URLByAppendingPathComponent:self.name] URLByAppendingPathExtension:@"sqlite"];
        NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
            nil];
        [self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:SQLiteStoreURL options:options error:&error];
        if (error) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
        self.viewContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.viewContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return self;
}

- (void)saveContextChanges:(NSManagedObjectContext *)context {
    if (context && context.hasChanges) {
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}

- (NSManagedObjectContext *)createNewContext {
    NSManagedObjectContext *ret = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    ret.persistentStoreCoordinator = self.persistentStoreCoordinator;
    return ret;
}

- (NSURL *)applicationSupportDirectory {
    return [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].lastObject;
}

@end
