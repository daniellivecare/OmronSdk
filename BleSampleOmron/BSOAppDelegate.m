//
//  BSOAppDelegate.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOAppDelegate.h"
#import "BSODefines.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "BSODeviceEntity+CoreDataClass.h"
#import "OHQReferenceCode.h"
#import "REFrostedViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface BSOAppDelegate() <OHQDeviceManagerDataSource>

@property (readwrite, strong, nonatomic) REFrostedViewController *frostedViewController;

@end

@implementation BSOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    // initialize user defaults
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultAppConfig" ofType:@"plist"];
    NSDictionary *defaultAppConfig = [NSDictionary dictionaryWithContentsOfFile:path];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults registerDefaults:defaultAppConfig];
    
    // initialize persistent container
    BSOPersistentContainer *container = [BSOPersistentContainer sharedPersistentContainer];
    
    NSError *error = nil;
    NSArray<BSOUserEntity *> *userEntities = [container.viewContext executeFetchRequest:[BSOUserEntity fetchRequest] error:&error];
    if (!userEntities.count) {
        // set default profiles
        NSString *path = [[NSBundle mainBundle] pathForResource:@"DefaultUserProfiles" ofType:@"plist"];
        NSArray *defaultUserProfiles = [NSArray arrayWithContentsOfFile:path];
        [defaultUserProfiles enumerateObjectsUsingBlock:^(id  _Nonnull defaultUserProfile, NSUInteger idx, BOOL * _Nonnull stop) {
            BSOUserEntity *userEntity = [BSOUserEntity insertNewEntityInContext:container.viewContext];
            [userEntity setValuesForKeysWithDictionary:defaultUserProfile];
        }];
        [container saveContextChanges:container.viewContext];
    }
    
    // initialize OHQ Bluetooth stack
    OHQDeviceManager *manager = [OHQDeviceManager sharedManager];
    manager.dataSource = self;
    
    // setup root view controller
    UIViewController *rootViewController = nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([[userDefaults stringForKey:BSOAppConfigCurrentUserNameKey] isEqualToString:BSOGuestUserName]) {
        rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"GuestUserHomeViewController"];
    }
    else {
        rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserHomeViewController"];
    }
    
    UIViewController *drawerMenuViewController = [storyboard instantiateViewControllerWithIdentifier:@"DrawerMenuViewController"];
    UINavigationController *rootNavigationController = [storyboard instantiateViewControllerWithIdentifier:@"RootNavigationController"];
    rootNavigationController.viewControllers = @[rootViewController];
    self.frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:rootNavigationController menuViewController:drawerMenuViewController];
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGFloat menuWidth = MAX(MIN(CGRectGetWidth(screenRect), CGRectGetHeight(screenRect)) * 0.6, 200.0f);
    self.frostedViewController.menuViewSize = CGSizeMake(menuWidth, 0);
    self.frostedViewController.limitMenuViewSize = YES;
    self.window.rootViewController = self.frostedViewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    BSOPersistentContainer *container = [BSOPersistentContainer sharedPersistentContainer];
    [container saveContextChanges:container.viewContext];
}

- (NSString *)deviceManager:(OHQDeviceManager *)manager localNameForDevice:(NSUUID *)identifier {
    NSString *localName = nil;
    NSFetchRequest *fetchRequest = [BSODeviceEntity fetchRequest];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"identifier = %@", identifier];
    BSODeviceEntity *deviceEntity = [[BSOPersistentContainer sharedPersistentContainer].viewContext executeFetchRequest:fetchRequest error:nil].firstObject;
    if (deviceEntity) {
        localName = deviceEntity.localName;
    }
    return localName;
}

@end
