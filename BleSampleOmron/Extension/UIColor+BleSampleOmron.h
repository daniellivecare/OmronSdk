//
//  UIColor+BleSampleOmron.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSODefines.h"
#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@interface UIColor (BleSampleOmron)

+ (UIColor *)colorWithColorCodeString:(NSString *)colorCode;
+ (UIColor *)appBaseColor;
+ (UIColor *)bloodPressureMonitorColor;
+ (UIColor *)lightBloodPressureMonitorColor;
+ (UIColor *)weightScaleColor;
+ (UIColor *)lightWeightScaleColor;
+ (UIColor *)bodyCompositionMonitorColor;
+ (UIColor *)lightBodyCompositionMonitorColor;
+ (UIColor *)pulseOximeterColor;
+ (UIColor *)lightPulseOximeterColor;
+ (UIColor *)thermometerColor;
+ (UIColor *)lightThermometerColor;
+ (UIColor *)bluetoothBaseColor;
+ (UIColor *)destructiveAlertTextColor;
+ (UIColor *)colorWithDeviceCategory:(OHQDeviceCategory)category;
+ (UIColor *)lightColorWithDeviceCategory:(OHQDeviceCategory)category;
+ (UIColor *)colorWithProtocol:(BSOProtocol)protocol;
+ (UIColor *)scanFilterColorWithDeviceCategory:(OHQDeviceCategory)category;
@end
