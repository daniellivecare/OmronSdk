//
//  UIColor+BleSampleOmron.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "UIColor+BleSampleOmron.h"

@implementation UIColor (BleSampleOmron)

+ (UIColor *)colorWithColorCodeString:(NSString *)colorCode {
    NSMutableCharacterSet *cs = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [cs addCharactersInString:@"#"];
    NSString *cc = [colorCode stringByTrimmingCharactersInSet:cs];
    UIColor *ret = nil;
    if (cc.length == 6) {
        unsigned int r, g, b;
        [[NSScanner scannerWithString:[cc substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[cc substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[cc substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
        ret = [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:1.0];
    }
    return ret;
}

+ (UIColor *)appBaseColor {
    return [UIColor colorWithColorCodeString:@"#0067B4"];
}

+ (UIColor *)bloodPressureMonitorColor {
    return [UIColor colorWithColorCodeString:@"#E91E63"];
}

+ (UIColor *)lightBloodPressureMonitorColor {
    return [UIColor colorWithColorCodeString:@"#F6DEF5"];
}

+ (UIColor *)weightScaleColor {
    return [UIColor colorWithColorCodeString:@"#FFAB00"];
}

+ (UIColor *)lightWeightScaleColor {
    return [UIColor colorWithColorCodeString:@"#FFE082"];
}

+ (UIColor *)bodyCompositionMonitorColor {
    return [UIColor colorWithColorCodeString:@"#2ECC71"];
}

+ (UIColor *)lightBodyCompositionMonitorColor {
    return [UIColor colorWithColorCodeString:@"#DFF6E0"];
}

+ (UIColor *)pulseOximeterColor {
    return [UIColor colorWithColorCodeString:@"#00A2E8"];
}

+ (UIColor *)lightPulseOximeterColor {
    return [UIColor colorWithColorCodeString:@"#B9EDFF"];
}

+ (UIColor *)thermometerColor {
    return [UIColor colorWithColorCodeString:@"#990099"];
}

+ (UIColor *)lightThermometerColor {
    return [UIColor colorWithColorCodeString:@"#cdade5"];
}

+ (UIColor *)bluetoothBaseColor {
    return [UIColor colorWithColorCodeString:@"#0C69FA"];
}

+ (UIColor *)destructiveAlertTextColor {
    return [UIColor colorWithColorCodeString:@"#FF3B30"];
}

+ (UIColor *)colorWithDeviceCategory:(OHQDeviceCategory)category {
    UIColor *ret = nil;
    switch (category) {
        case OHQDeviceCategoryBloodPressureMonitor:
            ret = [UIColor bloodPressureMonitorColor];
            break;
        case OHQDeviceCategoryWeightScale:
            ret = [UIColor weightScaleColor];
            break;
        case OHQDeviceCategoryBodyCompositionMonitor:
            ret = [UIColor bodyCompositionMonitorColor];
            break;
        case OHQDeviceCategoryPulseOximeter:
            ret = [UIColor pulseOximeterColor];
            break;
        case OHQDeviceCategoryHealthThermometer:
            ret = [UIColor thermometerColor];
            break;
        default:
            break;
    }
    return ret;
}

+ (UIColor *)lightColorWithDeviceCategory:(OHQDeviceCategory)category {
    UIColor *ret = nil;
    switch (category) {
        case OHQDeviceCategoryBloodPressureMonitor:
            ret = [UIColor lightBloodPressureMonitorColor];
            break;
        case OHQDeviceCategoryWeightScale:
            ret = [UIColor lightWeightScaleColor];
            break;
        case OHQDeviceCategoryBodyCompositionMonitor:
            ret = [UIColor lightBodyCompositionMonitorColor];
            break;
        case OHQDeviceCategoryPulseOximeter:
            ret = [UIColor lightPulseOximeterColor];
            break;
        case OHQDeviceCategoryHealthThermometer:
            ret = [UIColor lightThermometerColor];
            break;
        default:
            break;
    }
    return ret;
}

+ (UIColor *)colorWithProtocol:(BSOProtocol)protocol {
    UIColor *ret = nil;
    switch (protocol) {
        case BSOProtocolBluetoothStandard:
            ret = [UIColor bluetoothBaseColor];
            break;
        case BSOProtocolOmronExtension:
            ret = [UIColor appBaseColor];
            break;
        default:
            break;
    }
    return ret;
}

+ (UIColor *)scanFilterColorWithDeviceCategory:(OHQDeviceCategory)category {
    UIColor *ret = nil;
    switch (category) {
        case OHQDeviceCategoryBloodPressureMonitor:
        case OHQDeviceCategoryWeightScale:
        case OHQDeviceCategoryBodyCompositionMonitor:
        case OHQDeviceCategoryPulseOximeter:
        case OHQDeviceCategoryHealthThermometer:
            ret = [UIColor blackColor];
            break;
        default:
            break;
    }
    return ret;
}

@end
