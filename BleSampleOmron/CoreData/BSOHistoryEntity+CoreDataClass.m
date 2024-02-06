//
//  BSOHistoryEntity+CoreDataClass.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOHistoryEntity+CoreDataClass.h"
#import "BSODefines.h"
#import "NSDate+BleSampleOmron.h"
#import "OHQReferenceCode.h"
#import "OHQDeviceManager.h"

@implementation BSOHistoryEntity

+ (NSString *)entityName {
    return @"History";
}

+ (instancetype)insertNewEntityInContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

- (NSString *)descriptionToExport {
    __block NSMutableString *text = [@"" mutableCopy];
    if (self.logHeader.length) {
        [text appendString:self.logHeader];
    }
    void (^appendAttribute)(NSString *, id) = ^(NSString *name, id data) {
        if (data) {
            [text appendFormat:@"# %@\r\n%@\r\n", name, data];
        }
    };

    appendAttribute(@"BluetoothSettings", self.bluetoothStatus);
    appendAttribute(@"BluetoothPermisson", self.bluetoothAuthorization);
    appendAttribute(@"Date", [self.completionDate localTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"]);
    appendAttribute(@"User Name", self.userName);
    appendAttribute(@"Operation", BSOOperationDescription(self.operation));
    appendAttribute(@"Protocol", BSOProtocolDescription(self.protocol));
    appendAttribute(@"Model Name", self.modelName);
    appendAttribute(@"Local Name", self.localName);
    appendAttribute(@"Status", self.status);
    appendAttribute(@"Device Category", OHQDeviceCategoryDescription(self.deviceCategory));
    appendAttribute(@"User Index", self.userIndex);
    appendAttribute(@"User Data", self.userData);
    appendAttribute(@"Device Time", self.deviceTime);
    appendAttribute(@"Battery Level", self.batteryLevel ? [NSString stringWithFormat:@"%d %%", (int)(self.batteryLevel.floatValue * 100.0f)] : nil);
    appendAttribute(@"Measurement Records", self.measurementRecords);
    appendAttribute(@"Log", self.log);
    return [text copy];
}

@end
