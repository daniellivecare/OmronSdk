//
//  BSODeviceRegistrationNavigationController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODeviceRegistrationNavigationController.h"
#import "BSODefines.h"
#import "BSODiscoveredDeviceSelectionViewController.h"
#import "BSORegistrationOptionsSelectionViewController.h"
#import "BSOSessionViewController.h"
#import "BSOSessionResultNavigationController.h"
#import "BSOSessionData.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "BSODeviceEntity+CoreDataClass.h"
#import "BSOHistoryEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"
#import "OHQReferenceCode.h"
#import "OHQDeviceManager.h"

@interface BSODeviceRegistrationNavigationController () <BSODiscoveredDeviceSelectionViewControllerDelegate, BSORegistrationOptionsSelectionViewControllerDelegate, BSOSessionViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) BSOUserEntity *userEntity;
@property (assign, nonatomic) BSOProtocol protocol;
@property (copy, nonatomic) NSDictionary<OHQUserDataKey,id> *userData;
@property (copy, nonatomic) NSDictionary<OHQDeviceInfoKey,id> *deviceInfo;
@property (copy, nonatomic) NSDictionary<OHQSessionOptionKey,id> *options;

@end

@implementation BSODeviceRegistrationNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [BSOPersistentContainer sharedPersistentContainer].viewContext;
    
    // retrieve current user entity
    NSString *userName = [[NSUserDefaults standardUserDefaults] valueForKey:BSOAppConfigCurrentUserNameKey];
    if (userName) {
        NSFetchRequest *fetchRequest = [BSOUserEntity fetchRequest];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"name = %@", userName];
        self.userEntity = [self.context executeFetchRequest:fetchRequest error:nil].firstObject;
    }
    if (!self.userEntity) {
        NSLog(@"%s abort", __PRETTY_FUNCTION__);
        abort();
    }
    
    self.protocol = BSOProtocolNone;
    self.userData = @{OHQUserDataDateOfBirthKey: [NSDate dateWithLocalTimeString:self.userEntity.dateOfBirth format:@"yyyy-MM-dd"],
                      OHQUserDataHeightKey: self.userEntity.height,
                      OHQUserDataGenderKey: self.userEntity.gender};
    self.deviceInfo = nil;
    self.options = nil;
    
    // list registered devices
    __block NSMutableArray *registeredDeviceUUIDs = [@[] mutableCopy];
    [self.userEntity.registeredDevices enumerateObjectsUsingBlock:^(BSODeviceEntity * _Nonnull deviceEntity, NSUInteger idx, BOOL * _Nonnull stop) {
        [registeredDeviceUUIDs addObject:deviceEntity.identifier];
    }];
    
    // set up root view
    UIViewController *rootViewController = self.viewControllers.firstObject;
    if ([rootViewController isKindOfClass:[BSODiscoveredDeviceSelectionViewController class]]) {
        BSODiscoveredDeviceSelectionViewController *vc = (BSODiscoveredDeviceSelectionViewController *)rootViewController;
        vc.delegate = self;
        vc.allowUserInteractionOfCategoryFilterSetting = YES;
        vc.pairingModeDeviceOnly = YES;
        vc.categoryToFilter = OHQDeviceCategoryAny;
        vc.registeredDeviceUUIDs = registeredDeviceUUIDs;
    }
    else {
        abort();
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRegistrationOptionsSelectionViewController"]) {
        BSORegistrationOptionsSelectionViewController *vc = segue.destinationViewController;
        vc.deviceInfo = self.deviceInfo;
        vc.userData = self.userData;
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"showSessionViewController"]) {
        BSOSessionViewController *vc = segue.destinationViewController;
        vc.deviceIdentifier = self.deviceInfo[OHQDeviceInfoIdentifierKey];
        vc.options = self.options;
        vc.delegate = self;
    }
}

#pragma mark - Discovered device selection view controller delegate

- (void)discoveredDeviceSelectionViewController:(BSODiscoveredDeviceSelectionViewController *)viewController didSelectDevice:(NSDictionary<OHQDeviceInfoKey,id> *)deviceInfo {
    self.deviceInfo = deviceInfo;
    
    [self performSegueWithIdentifier:@"showRegistrationOptionsSelectionViewController" sender:self];
}

#pragma mark - Registration options selection view controller delegate

- (void)registrationOptionsSelectionViewController:(BSORegistrationOptionsSelectionViewController *)viewController didSelectProtocol:(BSOProtocol)protocol options:(nonnull NSDictionary<OHQSessionOptionKey,id> *)options {
    self.protocol = protocol;
    self.options = options;
    
    [self performSegueWithIdentifier:@"showSessionViewController" sender:self];
}

#pragma mark - Session view controller delegate

- (void)sessionViewControllerDidCancelSessionByUserOperation:(BSOSessionViewController *)viewController {
    [viewController performSegueWithIdentifier:@"unwindToDiscoveredDeviceSelectionViewController" sender:viewController];
}

- (NSString *)sessionViewController:(BSOSessionViewController *)viewController completionMessageForData:(BSOSessionData *)data {
    return ([self bso_validateSessionWithData:data] ? @"Registered !" : @"Failed");
}

- (void)sessionViewController:(BSOSessionViewController *)viewController didCompleteSessionWithData:(BSOSessionData *)data {
    BOOL registered = [self bso_validateSessionWithData:data];
    
    NSString *deviceStatus = @"-";
    NSString *deviceAuthorization = @"-";
    
    if ([OHQDeviceManager sharedManager].state == OHQDeviceManagerStatePoweredOn) {
        deviceStatus = @"ON";
        if (@available(iOS 13.0, *)) {
            if ([OHQDeviceManager sharedManager].authorization == OHQDeviceManagerAuthorizationAllowed) {
                deviceAuthorization = @"Granted";
            }
        }
    } else {
        if ([OHQDeviceManager sharedManager].state == OHQDeviceManagerStateUnauthorized) {
        } else {
            if (@available(iOS 13.0, *)) {
                if ([OHQDeviceManager sharedManager].authorization == OHQDeviceManagerAuthorizationAllowed) {
                }
            }
        }
    }

    // insert new history
    BSOHistoryEntity *historyEntity = [BSOHistoryEntity insertNewEntityInContext:self.context];
    historyEntity.bluetoothStatus = deviceStatus;
    historyEntity.bluetoothAuthorization = deviceAuthorization;
    historyEntity.batteryLevel = data.batteryLevel;
    historyEntity.completionDate = data.completionDate;
    historyEntity.consentCode = data.options[OHQSessionOptionConsentCodeKey];
    historyEntity.deviceCategory = (data.deviceCategory != OHQDeviceCategoryUnknown ?
                                    data.deviceCategory : [self.deviceInfo[OHQDeviceInfoCategoryKey] unsignedIntegerValue]);
    historyEntity.deviceTime = data.currentTime;
    historyEntity.identifier = [NSUUID UUID];
    historyEntity.localName = self.deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataLocalNameKey];
    historyEntity.log = data.log;
    historyEntity.measurementRecords = data.measurementRecords;
    historyEntity.modelName = (data.modelName ? data.modelName : self.deviceInfo[OHQDeviceInfoModelNameKey]);
    historyEntity.operation = BSOOperationRegister;
    historyEntity.protocol = self.protocol;
    historyEntity.status = (registered ? @"Success" : @"Failure");
    historyEntity.userData = data.userData;
    historyEntity.userIndex = (data.registeredUserIndex ? data.registeredUserIndex : data.options[OHQSessionOptionUserIndexKey]);
    historyEntity.userName = self.userEntity.name;
    historyEntity.logHeader = BSOLogHeaderString(data.completionDate);
    
    if (registered) {
        if (data.userData.count) {
            NSDate *dateOfBirth = data.userData[OHQUserDataDateOfBirthKey];
            NSString *dateOfBirthString = [dateOfBirth localTimeStringWithFormat:@"yyyy-MM-dd"];
            if (dateOfBirthString.length && ![self.userEntity.dateOfBirth isEqualToString:dateOfBirthString]) {
                self.userEntity.dateOfBirth = [dateOfBirth localTimeStringWithFormat:@"yyyy-MM-dd"];
            }
            NSNumber *height = data.userData[OHQUserDataHeightKey];
            if (height && ![self.userEntity.height isEqualToNumber:height]) {
                self.userEntity.height = height;
            }
            OHQGender gender = data.userData[OHQUserDataGenderKey];
            if (gender && ![self.userEntity.gender isEqualToString:gender]) {
                self.userEntity.gender = gender;
            }
            if (self.userEntity.hasChanges) {
                [self.userEntity.registeredDevices enumerateObjectsUsingBlock:^(BSODeviceEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.databaseChangeIncrement && !obj.databaseUpdateFlag.boolValue) {
                        obj.databaseChangeIncrement = @(obj.databaseChangeIncrement.unsignedIntValue + 1);
                        obj.databaseUpdateFlag = @YES;
                    }
                }];
            }
        }
        
        // insert new device
        BSODeviceEntity *deviceEntity = [BSODeviceEntity insertNewEntityInContext:self.context];
        deviceEntity.consentCode = data.options[OHQSessionOptionConsentCodeKey];
        deviceEntity.databaseChangeIncrement = data.databaseChangeIncrement;
        deviceEntity.databaseUpdateFlag = @NO;
        deviceEntity.deviceCategory = data.deviceCategory;
        deviceEntity.identifier = self.deviceInfo[OHQDeviceInfoIdentifierKey];
        deviceEntity.lastSequenceNumber = data.sequenceNumberOfLatestRecord;
        deviceEntity.localName = self.deviceInfo[OHQDeviceInfoAdvertisementDataKey][OHQAdvertisementDataLocalNameKey];
        deviceEntity.modelName = data.modelName;
        deviceEntity.protocol = self.protocol;
        deviceEntity.userIndex = data.registeredUserIndex;
        
        NSMutableOrderedSet *registeredDevices = [NSMutableOrderedSet orderedSetWithOrderedSet:self.userEntity.registeredDevices];
        [registeredDevices addObject:deviceEntity];
        self.userEntity.registeredDevices = registeredDevices;
    }
    
    // save changes
    [[BSOPersistentContainer sharedPersistentContainer] saveContextChanges:self.context];
    
    // present session result
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BSOSessionResultNavigationController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SessionResultNavigationController"];
    vc.historyIdentifier = historyEntity.identifier;
    [viewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Private methods

- (BOOL)bso_validateSessionWithData:(BSOSessionData *)data {
    if (data.completionReason != OHQCompletionReasonDisconnected) {
        return NO;
    }
    if (!data.currentTime && !data.batteryLevel && !data.measurementRecords.count) {
        return NO;
    }
    if ([data.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] && !data.measurementRecords) {
        return NO;
    }
    if (self.protocol == BSOProtocolOmronExtension) {
        if ([data.options[OHQSessionOptionRegisterNewUserKey] boolValue] && !data.registeredUserIndex) {
            return NO;
        }
    }
    if (data.registeredUserIndex && data.options[OHQSessionOptionDatabaseChangeIncrementValueKey] && !data.databaseChangeIncrement) {
        return NO;
    }
    return YES;
}

@end
