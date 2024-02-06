//
//  OHQDevice.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQDevice.h"
#import "OHQLog.h"
#import "CBUUID+Description.h"
#import <CoreBluetooth/CoreBluetooth.h>

#define OHQ_INLINE NS_INLINE
#define OHQ_UNUSED __attribute__((unused))

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of UUIDs
///---------------------------------------------------------------------------------------

/*
 + Device Information (org.bluetooth.service.device_information)
    - Model Number String (org.bluetooth.characteristic.model_number_string)
 + Battery (org.bluetooth.service.battery_service)
    - Battery Level (org.bluetooth.characteristic.battery_level)
 + Current Time (org.bluetooth.service.current_time)
    - Current Time (org.bluetooth.characteristic.current_time)
 + User Data (org.bluetooth.service.user_data)
    - User Control Point (org.bluetooth.characteristic.user_control_point)
    - User Index (org.bluetooth.characteristic.user_index)
    - Database Change Increment (org.bluetooth.characteristic.database_change_increment)
    - Date of Birth (org.bluetooth.characteristic.date_of_birth)
    - Height (org.bluetooth.characteristic.height)
    - Gender (org.bluetooth.characteristic.gender)
 + Omron Option (Omron Original)
    - Record Access Control Point (org.bluetooth.characteristic.record_access_control_point)
    - OHQ Body Composition Measurement (Omron Original)
 + Blood Pressure (org.bluetooth.service.blood_pressure) <Blood Pressure Monitor Only>
    - Blood Pressure Feature (org.bluetooth.characteristic.blood_pressure_feature)
    - Blood Pressure Measurement (org.bluetooth.characteristic.blood_pressure_measurement)
 + Weight Scale (org.bluetooth.service.weight_scale) <Weight Scale and Body Composition Monitor Only>
    + Body Composition (org.bluetooth.service.body_composition)  <Body Composition Monitor Only>
        - Body Composition Feature (org.bluetooth.characteristic.body_composition_feature)
        - Body Composition Measurement (org.bluetooth.characteristic.body_composition_measurement)
    - Weight Scale Feature (org.bluetooth.characteristic.weight_scale_feature)
    - Weight Measurement (org.bluetooth.characteristic.weight_measurement)
 + Omron Custom Pulse Oximeter (Omron Original) <Pulse Oximeter Only>
    - Omron Custom PLX Features (Omron Original)
    - Omron Custom PLX Spot-Check Measurement (Omron Original)
    - Omron Custom PLX Record Access Control Point (Omron Original)
 + Health Thermometer (org.bluetooth.service.health_thermometer) <Body Thermometer Only>
    - Temperature Measurement (org.bluetooth.characteristic.temperature_measurement)

 */

// Service UUID Strings
static NSString * const BatteryServiceUUIDString = @"180F";
static NSString * const BloodPressureServiceUUIDString = @"1810";
static NSString * const BodyCompositionServiceUUIDString = @"181B";
static NSString * const CurrentTimeServiceUUIDString = @"1805";
static NSString * const DeviceInformationServiceUUIDString = @"180A";
static NSString * const OmronOptionServiceUUIDString = @"5DF5E817-A945-4F81-89C0-3D4E9759C07C";
static NSString * const UserDataServiceUUIDString = @"181C";
static NSString * const WeightScaleServiceUUIDString = @"181D";
static NSString * const OmronCustomPlxServiceUUIDString = @"6E400001-B5A3-F393-EFA9-E50E24DCCA9E";
static NSString * const HealthThermometerServiceUUIDString = @"1809";

// Service UUIDs
static CBUUID * _batteryServiceUUID = nil;
static CBUUID * _bloodPressureServiceUUID = nil;
static CBUUID * _bodyCompositionServiceUUID = nil;
static CBUUID * _currentTimeServiceUUID = nil;
static CBUUID * _deviceInformationServiceUUID = nil;
static CBUUID * _omronOptionServiceUUID = nil;
static CBUUID * _userDataServiceUUID = nil;
static CBUUID * _weightScaleServiceUUID = nil;
static CBUUID * _omronCustomPulseOximeterServiceUUID = nil;
static CBUUID * _healthThermometerServiceUUID = nil;

// Characteristic UUID Strings
static NSString * const BatteryLevelCharacteristicUUIDString = @"2A19";
static NSString * const BloodPressureFeatureCharacteristicUUIDString = @"2A49";
static NSString * const BloodPressureMeasurementCharacteristicUUIDString = @"2A35";
static NSString * const BodyCompositionFeatureCharacteristicUUIDString = @"2A9B";
static NSString * const BodyCompositionMeasurementCharacteristicUUIDString = @"2A9C";
static NSString * const CurrentTimeCharacteristicUUIDString = @"2A2B";
static NSString * const DatabaseChangeIncrementCharacteristicUUIDString = @"2A99";
static NSString * const DateOfBirthCharacteristicUUIDString = @"2A85";
static NSString * const GenderCharacteristicUUIDString = @"2A8C";
static NSString * const HeightCharacteristicUUIDString = @"2A8E";
static NSString * const ModelNumberStringCharacteristicUUIDString = @"2A24";
static NSString * const OHQBodyCompositionMeasurementCharacteristicUUIDString = @"8FF2DDFB-4A52-4CE5-85A4-D2F97917792A";
static NSString * const RecordAccessControlPointCharacteristicUUIDString = @"2A52";
static NSString * const UserControlPointCharacteristicUUIDString = @"2A9F";
static NSString * const UserIndexCharacteristicUUIDString = @"2A9A";
static NSString * const WeightMeasurementCharacteristicUUIDString = @"2A9D";
static NSString * const WeightScaleFeatureCharacteristicUUIDString = @"2A9E";
static NSString * const OmronCustomPlxFeaturesCharacteristicUUIDString = @"6E4000F0-B5A3-F393-EFA9-E50E24DCCA9E";
static NSString * const OmronCustomPlxSpotCheckMeasurementCharacteristicUUIDString = @"6E4000F1-B5A3-F393-EFA9-E50E24DCCA9E";
static NSString * const OmronCustomPlxRecordAccessControlPointCharacteristicUUIDString = @"6E4000F3-B5A3-F393-EFA9-E50E24DCCA9E";
static NSString * const TemperatureMeasurementCharacteristicUUIDString = @"2A1C";

// Characteristic UUIDs
static CBUUID * _batteryLevelCharacteristicUUID = nil;
static CBUUID * _bloodPressureFeatureCharacteristicUUID = nil;
static CBUUID * _bloodPressureMeasurementCharacteristicUUID = nil;
static CBUUID * _bodyCompositionFeatureCharacteristicUUID = nil;
static CBUUID * _bodyCompositionMeasurementCharacteristicUUID = nil;
static CBUUID * _currentTimeCharacteristicUUID = nil;
static CBUUID * _databaseChangeIncrementCharacteristicUUID = nil;
static CBUUID * _dateOfBirthCharacteristicUUID = nil;
static CBUUID * _genderCharacteristicUUID = nil;
static CBUUID * _heightCharacteristicUUID = nil;
static CBUUID * _modelNumberStringCharacteristicUUID = nil;
static CBUUID * _OHQBodyCompositionMeasurementCharacteristicUUID = nil;
static CBUUID * _recordAccessControlPointCharacteristicUUID = nil;
static CBUUID * _userControlPointCharacteristicUUID = nil;
static CBUUID * _userIndexCharacteristicUUID = nil;
static CBUUID * _weightMeasurementCharacteristicUUID = nil;
static CBUUID * _weightScaleFeatureCharacteristicUUID = nil;
static CBUUID * _omronCustomPlxFeaturesCharacteristicUUID = nil;
static CBUUID * _omronCustomPlxSpotCheckMeasurementCharacteristicUUID = nil;
static CBUUID * _omronCustomPlxRecordAccessControlPointCharacteristicUUID = nil;
static CBUUID * _temperatureMeasurementCharacteristicUUID = nil;

// Descriptor UUIDs
static CBUUID * _presentationFormatDescriptorUUID = nil;

static BOOL _WroteCurrentTime;
static BOOL _ReceivedSpotCheckMeasurement;
const NSInteger _PlxSpotCheckRecordCount = 1;

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (SFloat)
///---------------------------------------------------------------------------------------

typedef UInt16 SFloat;

OHQ_UNUSED OHQ_INLINE
Float32 ConvertSFloatToFloat32(SFloat arg) {
    SInt8 exponent = (SInt8)(arg >> 12);
    SInt16 mantissa = (SInt16)(arg & 0x0FFF);
    return (Float32)(mantissa * pow(10, exponent));
}

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (IEEE-11073 32-bit FLOAT)
///---------------------------------------------------------------------------------------
OHQ_UNUSED OHQ_INLINE
NSString *ConvertUInt32ToString(UInt32 arg) {
    UInt32 nan = 0x007FFFFF;
    if(arg == nan){
        return @"Err";
    }
    else{
        SInt8 exponent = (SInt8)(arg >> 24);
        SInt32 mantissa = (SInt32)(arg & 0x00FFFFFF);
        Float32 f32Temperature = mantissa * pow(10, exponent);
        return [NSString stringWithFormat:@"%.1f", roundf(f32Temperature*10)/10];
    }
}

//The sample code when using a thermometer displaying Fahrenheit is as follows.
//OHQ_UNUSED OHQ_INLINE
//NSString *ConvertUInt32ToString_F(UInt32 arg) {
//    UInt32 nan = 0x007FFFFF;
//    if(arg == nan){
//        return @"Err";
//    }
//    else{
//        SInt8 exponent = (SInt8)(arg >> 24);
//        SInt32 mantissa = (SInt32)(arg & 0x00FFFFFF);
//        Float32 f32Temperature = mantissa * pow(10, exponent) * 9 / 5 + 32;
//        return [NSString stringWithFormat:@"%.1f", roundf(f32Temperature*10)/10];
//    }
//}

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (UInt24)
///---------------------------------------------------------------------------------------

#pragma pack(1)

typedef struct {
    UInt8 i[3];
} UInt24;

#pragma pack()

OHQ_UNUSED OHQ_INLINE
UInt32 ConvertUInt24ToUInt32(UInt24 arg) {
    return ((arg.i[0] & 0xFF) | (arg.i[1] & 0xFF) << 8 | (arg.i[2] & 0xFF) << 16);
}

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Date / DateTime / CurrentTime)
///---------------------------------------------------------------------------------------

#pragma pack(1)

typedef struct {
    UInt16 year;
    UInt8 month;
    UInt8 day;
} Date;

typedef struct {
    UInt16 year;
    UInt8 month;
    UInt8 day;
    UInt8 hours;
    UInt8 minutes;
    UInt8 seconds;
} DateTime;

typedef struct {
    DateTime dateTime;
    UInt8 dayOfWeek;
    UInt8 fractions256;
    UInt8 adjustReason;
} CurrentTime;

#pragma pack()  // structure 1byte alignment end

OHQ_UNUSED OHQ_INLINE
NSDate * ConvertDateToNSDate(Date arg) {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = arg.year;
    components.month = arg.month;
    components.day = arg.day;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    calendar.timeZone = [NSTimeZone localTimeZone];
    return [calendar dateFromComponents:components];
}

OHQ_UNUSED OHQ_INLINE
Date ConvertNSDateToDate(NSDate *arg) {
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    calendar.timeZone = [NSTimeZone localTimeZone];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:arg];
    Date ret = {0};
    ret.year = components.year;
    ret.month = components.month;
    ret.day = components.day;
    return ret;
}

OHQ_UNUSED OHQ_INLINE
NSDate * ConvertDateTimeToNSDate(DateTime arg) {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year = arg.year;
    components.month = arg.month;
    components.day = arg.day;
    components.hour = arg.hours;
    components.minute = arg.minutes;
    components.second = arg.seconds;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    calendar.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    calendar.timeZone = [NSTimeZone localTimeZone];
    return [calendar dateFromComponents:components];
}

OHQ_UNUSED OHQ_INLINE
BOOL IsInvalidDateTime(DateTime arg) {
    DateTime zeroDateTime;
    
    memset(&zeroDateTime, 0, sizeof(DateTime));

    if(!memcmp(&arg, &zeroDateTime, sizeof(DateTime))){
        return YES;
    }
    
    return NO;
}

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Characteristic Presentation Format)
///---------------------------------------------------------------------------------------

typedef UInt8 CharacteristicFormat;

#pragma pack(1)

typedef struct {
    CharacteristicFormat format;
    SInt8 exponent;
    UInt16 unitUUIDValue;
    BOOL isAdopted;
    UInt16 description;
} CharacteristicPresentationFormat;

#pragma pack()  // structure 1byte alignment end

OHQ_UNUSED
static NSString * CharacteristicFormatDescription(CharacteristicFormat arg) {
    static NSArray *FormatDescriptions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"FormatDescriptions" ofType:@"plist"];
        FormatDescriptions = [NSArray arrayWithContentsOfFile:path];
    });
    NSString *ret = @"Unknown";
    if (arg < FormatDescriptions.count) {
        ret = FormatDescriptions[arg];
    }
    return ret;
}

OHQ_UNUSED
static NSString * CharacteristicPresentationFormatDescription(CharacteristicPresentationFormat arg) {
    CBUUID *unitUUID = [CBUUID UUIDWithString:[NSString stringWithFormat:@"%04X", arg.unitUUIDValue]];
    NSString *formatString = CharacteristicFormatDescription(arg.format);
    return [NSString stringWithFormat:@"%@ [type:%@ exp:%d]", unitUUID, formatString, arg.exponent];
}

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (User Control Point [UCP])
///---------------------------------------------------------------------------------------

typedef NS_ENUM(UInt8, UCPOpCode) {
    UCPOpCodeReserved = 0x00,
    UCPOpCodeRegisterNewUser = 0x01,
    UCPOpCodeConsent = 0x02,
    UCPOpCodeDeleteUserData = 0x03,
    UCPOpCodeResponseCode = 0x20,
    UCPOpCodeRegisterNewUserWithUserIndex = 0x40,
};

typedef NS_ENUM(UInt8, UCPResponseValue) {
    UCPResponseValueReserved = 0x00,
    UCPResponseValueSuccess = 0x01,
    UCPResponseValueOpCodeNotSupported = 0x02,
    UCPResponseValueInvalidParameter = 0x03,
    UCPResponseValueOperationFailed = 0x04,
    UCPResponseValueUserNotAuthorized = 0x05,
};

#pragma pack(1) // structure 1byte alignment begin

typedef struct {
    UCPOpCode opCode;
    union {
        UInt16 consentCode;
        struct { UInt8 userIndex; UInt16 consentCode; } requestWithUserIndex;
        struct { UCPOpCode requestOpCode; UCPResponseValue value; UInt8 userIndex; } responseWithUserIndex;
        struct { UCPOpCode requestOpCode; UCPResponseValue value; } generalResponse;
    } operand;
} UCPCommand;

#pragma pack() // structure 1byte alignment end

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Record Access Control Point [RACP])
///---------------------------------------------------------------------------------------

static const UInt16 RACPInvalidSequenceNumber = 0;

typedef NS_ENUM(UInt8, RACPOpCode) {
    RACPOpCodeReserved = 0x00,
    RACPOpCodeReportStoredRecords = 0x01,
    RACPOpCodeDeleteStoredRecords = 0x02,
    RACPOpCodeReportNumberOfStoredRecords = 0x04,
    RACPOpCodeNumberOfStoredRecordsResponse = 0x05,
    RACPOpCodeResponseCode = 0x06,
    RACPOpCodeReportSequenceNumberOfLatestRecord = 0x10,
    RACPOpCodeSequenceNumberOfLatestRecordResponse = 0x11,
};

typedef NS_ENUM(UInt8, RACPOperator) {
    RACPOperatorNull = 0x00,
    RACPOperatorAllRecords = 0x01,
    RACPOperatorGreaterThanOrEqualTo = 0x03,
};

typedef NS_ENUM(UInt8, RACPFilterType) {
    RACPFilterTypeReserved = 0x00,
    RACPFilterTypeSequenceNumber = 0x01,
    RACPFilterTypeUserFacingTime = 0x02,
};

typedef NS_ENUM(UInt8, RACPResponseValue) {
    RACPResponseValueReserved = 0x00,
    RACPResponseValueSuccess = 0x01,
    RACPResponseValueOpCodeNotSupported = 0x02,
    RACPResponseValueInvalidOperator = 0x03,
    RACPResponseValueOperatorNotSupported = 0x04,
    RACPResponseValueInvalidOperand = 0x05,
    RACPResponseValueNoRecordsFound = 0x06,
    RACPResponseValueAbortUnsuccessful = 0x07,
    RACPResponseValueProcedureNotCompleted = 0x08,
    RACPResponseValueOperandNotSupported = 0x09,
};

#pragma pack(1) // structure 1byte alignment begin

typedef struct {
    RACPOpCode opCode;
    RACPOperator operator;
    union {
        struct { RACPFilterType filterType; UInt16 value; } filterCriteria;
        struct { RACPOpCode requestOpCode; RACPResponseValue value; } generalResponse;
        UInt16 numberOfRecords;
        UInt16 sequenceNumber;
    } operand;
} RACPCommand;

#pragma pack() // structure 1byte alignment end

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Blood Pressure)
///---------------------------------------------------------------------------------------

typedef NS_OPTIONS(UInt8, BloodPressureMeasurementFlags) {
    BloodPressureMeasurementFlagKpaUnit = 1 << 0,
    BloodPressureMeasurementFlagTimeStampPresent = 1 << 1,
    BloodPressureMeasurementFlagPulseRatePresent = 1 << 2,
    BloodPressureMeasurementFlagUserIDPresent = 1 << 3,
    BloodPressureMeasurementFlagStatusPresent = 1 << 4,
};

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Weight)
///---------------------------------------------------------------------------------------

typedef NS_OPTIONS(UInt8, WeightMeasurementFlags) {
    WeightMeasurementFlagImperialUnit = 1 << 0,
    WeightMeasurementFlagTimeStampPresent = 1 << 1,
    WeightMeasurementFlagUserIDPresent = 1 << 2,
    WeightMeasurementFlagBMIAndHeightPresent = 1 << 3,
};

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Body Composition)
///---------------------------------------------------------------------------------------

typedef NS_OPTIONS(UInt16, BodyCompositionMeasurementFlags) {
    BodyCompositionMeasurementFlagImperialUnit = 1 << 0,
    BodyCompositionMeasurementFlagTimeStampPresent = 1 << 1,
    BodyCompositionMeasurementFlagUserIDPresent = 1 << 2,
    BodyCompositionMeasurementFlagBasalMetabolismPresent = 1 << 3,
    BodyCompositionMeasurementFlagMusclePercentagePresent = 1 << 4,
    BodyCompositionMeasurementFlagMuscleMassPresent = 1 << 5,
    BodyCompositionMeasurementFlagFatFreeMassPresent = 1 << 6,
    BodyCompositionMeasurementFlagSoftLeanMassPresent = 1 << 7,
    BodyCompositionMeasurementFlagBodyWaterMassPresent = 1 << 8,
    BodyCompositionMeasurementFlagImpedancePresent = 1 << 9,
    BodyCompositionMeasurementFlagWeightPresent = 1 << 10,
    BodyCompositionMeasurementFlagHeightPresent = 1 << 11,
    BodyCompositionMeasurementFlagMultiplePacketMeasurement = 1 << 12,
};

typedef NS_OPTIONS(UInt32, OmronExtendedBodyCompositionMeasurementFlags) {
    OmronExtendedBodyCompositionMeasurementFlagImperialUnit = 1 << 0,
    OmronExtendedBodyCompositionMeasurementFlagSequenceNumberPresent = 1 << 1,
    OmronExtendedBodyCompositionMeasurementFlagWeightPresent = 1 << 2,
    OmronExtendedBodyCompositionMeasurementFlagTimeStampPresent = 1 << 3,
    OmronExtendedBodyCompositionMeasurementFlagUserIDPresent = 1 << 4,
    OmronExtendedBodyCompositionMeasurementFlagBMIAndHeightPresent = 1 << 5,
    OmronExtendedBodyCompositionMeasurementFlagBodyFatPercentagePresent = 1 << 6,
    OmronExtendedBodyCompositionMeasurementFlagBasalMetabolismPresent = 1 << 7,
    OmronExtendedBodyCompositionMeasurementFlagMusclePercentagePresent = 1 << 8,
    OmronExtendedBodyCompositionMeasurementFlagMuscleMassPresent = 1 << 9,
    OmronExtendedBodyCompositionMeasurementFlagFatFreeMassPresent = 1 << 10,
    OmronExtendedBodyCompositionMeasurementFlagSoftLeanMassPresent = 1 << 11,
    OmronExtendedBodyCompositionMeasurementFlagBodyWaterMassPresent = 1 << 12,
    OmronExtendedBodyCompositionMeasurementFlagImpedancePresent = 1 << 13,
    OmronExtendedBodyCompositionMeasurementFlagSkeletalMusclePercentagePresent = 1 << 14,
    OmronExtendedBodyCompositionMeasurementFlagVisceralFatLevelPresent = 1 << 15,
    OmronExtendedBodyCompositionMeasurementFlagBodyAgePresent = 1 << 16,
    OmronExtendedBodyCompositionMeasurementFlagBodyFatPercentageStageEvaluationPresent = 1 << 17,
    OmronExtendedBodyCompositionMeasurementFlagSkeletalMusclePercentageStageEvaluationPresent = 1 << 18,
    OmronExtendedBodyCompositionMeasurementFlagVisceralFatLevelStageEvaluationPresent = 1 << 19,
    OmronExtendedBodyCompositionMeasurementFlagMultiplePacketMeasurement = 1 << 20,
};

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Pulse Oximeter)
///---------------------------------------------------------------------------------------

typedef NS_OPTIONS(UInt16, PulseOximeterFeaturesFlags) {
    PulseOximeterFeaturesFlagsMeasurementStatusSupport                      = 1 << 0,
    PulseOximeterFeaturesFlagsDeviceAndSensorStatusSupport                  = 1 << 1,
    PulseOximeterFeaturesFlagsMeasurementStorageForSpotCheckMeasurements    = 1 << 2,
    PulseOximeterFeaturesFlagsTimeStampForSpotCheckMeasurements             = 1 << 3,
    PulseOximeterFeaturesFlagsSpO2PrFastMetric                              = 1 << 4,
    PulseOximeterFeaturesFlagsSpO2PrSlowMetric                              = 1 << 5,
    PulseOximeterFeaturesFlagsPulseAmplitudeIndexField                      = 1 << 6,
    PulseOximeterFeaturesFlagsMultipleBondsFeature                          = 1 << 7,
};

typedef NS_OPTIONS(UInt8, PulseOximeterSpotCheckMeasurementFlags) {
    PulseOximeterSpotCheckMeasurementFlagsTimeStamp             = 1 << 0,
    PulseOximeterSpotCheckMeasurementFlagsMeasurementStatus     = 1 << 1,
    PulseOximeterSpotCheckMeasurementFlagsDeviceAndSensorStatus = 1 << 2,
    PulseOximeterSpotCheckMeasurementFlagsPulseAmplitudeIndex   = 1 << 3,
    PulseOximeterSpotCheckMeasurementFlagsDeviceClockIsNotSet   = 1 << 4,
};

///---------------------------------------------------------------------------------------
#pragma mark - Private definition of GATT (Health Thermometer)
///---------------------------------------------------------------------------------------

typedef NS_OPTIONS(UInt8, TemperatureMeasurementFlags) {
    TemperatureMeasurementFlagImperialUnit = 1 << 0,
    TemperatureMeasurementFlagTimeStampPresent = 1 << 1,
    TemperatureMeasurementFlagTypePresent = 1 << 2,
};

///---------------------------------------------------------------------------------------
#pragma mark - Category declaration
///---------------------------------------------------------------------------------------

@interface CBService (OHQDevice)
- (nullable CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID;
@end

@implementation CBService (OHQDevice)

- (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID {
    __block CBCharacteristic *ret = nil;
    [self.characteristics enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(CBCharacteristic * _Nonnull characteristic, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([characteristic.UUID isEqual:characteristicUUID]) {
            ret = characteristic;
            *stop = YES;
        }
    }];
    return ret;
}

@end

@interface CBCharacteristic (OHQDevice)
- (nullable CBDescriptor *)descriptorWithUUID:(CBUUID *)descriptorUUID;
@end

@implementation CBCharacteristic (OHQDevice)

- (CBDescriptor *)descriptorWithUUID:(CBUUID *)descriptorUUID {
    __block CBDescriptor *ret = nil;
    [self.descriptors enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(CBDescriptor * _Nonnull descriptor, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([descriptor.UUID isEqual:descriptorUUID]) {
            ret = descriptor;
            *stop = YES;
        }
    }];
    return ret;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Declaration for state machine
///---------------------------------------------------------------------------------------

typedef NS_ENUM(NSUInteger, StateMachineEvent) {
    StateMachineEventNone = 0,
    StateMachineEventStartTransfer,
    StateMachineEventCancelTransfer,
    StateMachineEventDidDiscoverServices,
    StateMachineEventDidDiscoverIncludedServices,
    StateMachineEventDidDiscoverCharacteristics,
    StateMachineEventDidDiscoverDescriptors,
    StateMachineEventDidUpdateNotificationStateForCharacteristic,
    StateMachineEventDidUpdateValueForCharacteristic,
    StateMachineEventDidUpdateValueForDescriptor,
    StateMachineEventDidWriteValueForCharacteristic,
};

typedef NSString * EventAttachedDataKey;
EventAttachedDataKey const EventAttachedDataServiceKey = @"service";
EventAttachedDataKey const EventAttachedDataCharacteristicKey = @"characteristic";
EventAttachedDataKey const EventAttachedDataDescriptorKey = @"descriptor";
EventAttachedDataKey const EventAttachedDataErrorKey = @"error";

@interface InactiveState : OHQState
@end

@interface ActiveState : OHQState
@end

@interface ServicesDiscoveringState : OHQState
@end

@interface IncludedServicesDiscoveringState : OHQState
@end

@interface CharacteristicsDiscoveringState : OHQState
@end

@interface DescriptorsDiscoveringState : OHQState
@end

@interface AttributesDiscoveredState : OHQState
@end

@interface DeviceFeatureVerifyingState : OHQState
@end

@interface DescriptorValuesReadingState : OHQState
@end

@interface CharacteristicValuesReadingState : OHQState
@end

@interface NotificationEnablingState : OHQState
@end

@interface NotificationEnabledState : OHQState
@end

@interface UserRegisteringState : OHQState
@end

@interface UserAuthenticatingState : OHQState
@end

@interface UserAuthenticatedState : OHQState
@end

@interface UserDataDeletingState : OHQState
@end

@interface DatabaseChangeIncrementNotificationWaitingState : OHQState
@end

@interface UserDataReadingState : OHQState
@end

@interface UserDataWritingState : OHQState
@end

@interface MeasurementRecordAccessControllingState : OHQState
@end

@interface PlxMeasurementRecordAccessControllingState : OHQState
@end

///---------------------------------------------------------------------------------------
#pragma mark - OHQDevice class
///---------------------------------------------------------------------------------------

NS_ASSUME_NONNULL_BEGIN

@interface OHQDevice () <CBPeripheralDelegate>

@property (readwrite, nonatomic, strong) CBPeripheral *peripheral;
@property (nullable, nonatomic, copy) OHQDataObserverBlock dataObserverBlock;
@property (nullable, nonatomic, copy) NSDictionary<OHQSessionOptionKey,id> *options;
@property (nonatomic, assign) OHQDeviceCategory deviceCategory;
@property (nullable, nonatomic, copy) NSArray<OHQUserDataKey> *supportedUserDataKeys;
@property (nullable, nonatomic, copy) NSData *heightCharacteristicPresentationFormatData;
@property (nullable, nonatomic, strong) NSNumber *registeredUserIndex;
@property (nullable, nonatomic, strong) NSNumber *latestDatabaseChangeIncrement;
@property (nullable, nonatomic, strong) NSMutableDictionary<OHQUserDataKey,id> *latestUserData;
@property (nullable, nonatomic, strong) NSMutableArray<NSDictionary<OHQMeasurementRecordKey,id> *> *temporaryMeasurementRecords;
@property (readonly, nullable) NSArray<CBService *> *allServices;

@property (nonatomic, assign) PulseOximeterFeaturesFlags mPulseOximeterFeatures;
@property (nonatomic, assign) NSInteger mPlxpReortedNumberOfMeasurement;
@property (nonatomic, assign) NSInteger mPlxpNumberOfRecords;
@property (nonatomic, assign) BOOL mPlxpIsCheckNumberOfRecords;
@property (nonatomic, assign) BOOL mPlxpWaitingSportCheckMeasurement;

- (nullable CBService *)serviceWithUUID:(CBUUID *)serviceUUID;
- (void)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs;
- (void)discoverIncludedServices:(nullable NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;
- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic;
- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic;
- (void)readValueForDescriptor:(CBDescriptor *)descriptor;
- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor;
- (void)abortTransferWithReason:(OHQCompletionReason)reason;

@end

NS_ASSUME_NONNULL_END

@implementation OHQDevice

+ (void)initialize {
    if (self == [OHQDevice class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _batteryServiceUUID = [CBUUID UUIDWithString:BatteryServiceUUIDString];
            _bloodPressureServiceUUID = [CBUUID UUIDWithString:BloodPressureServiceUUIDString];
            _bodyCompositionServiceUUID = [CBUUID UUIDWithString:BodyCompositionServiceUUIDString];
            _currentTimeServiceUUID = [CBUUID UUIDWithString:CurrentTimeServiceUUIDString];
            _deviceInformationServiceUUID = [CBUUID UUIDWithString:DeviceInformationServiceUUIDString];
            _omronOptionServiceUUID = [CBUUID UUIDWithString:OmronOptionServiceUUIDString];
            _userDataServiceUUID = [CBUUID UUIDWithString:UserDataServiceUUIDString];
            _weightScaleServiceUUID = [CBUUID UUIDWithString:WeightScaleServiceUUIDString];
            _omronCustomPulseOximeterServiceUUID = [CBUUID UUIDWithString:OmronCustomPlxServiceUUIDString];
            _healthThermometerServiceUUID = [CBUUID UUIDWithString:HealthThermometerServiceUUIDString];
            _batteryLevelCharacteristicUUID = [CBUUID UUIDWithString:BatteryLevelCharacteristicUUIDString];
            _bloodPressureFeatureCharacteristicUUID = [CBUUID UUIDWithString:BloodPressureFeatureCharacteristicUUIDString];
            _bloodPressureMeasurementCharacteristicUUID = [CBUUID UUIDWithString:BloodPressureMeasurementCharacteristicUUIDString];
            _bodyCompositionFeatureCharacteristicUUID = [CBUUID UUIDWithString:BodyCompositionFeatureCharacteristicUUIDString];
            _bodyCompositionMeasurementCharacteristicUUID = [CBUUID UUIDWithString:BodyCompositionMeasurementCharacteristicUUIDString];
            _currentTimeCharacteristicUUID = [CBUUID UUIDWithString:CurrentTimeCharacteristicUUIDString];
            _databaseChangeIncrementCharacteristicUUID = [CBUUID UUIDWithString:DatabaseChangeIncrementCharacteristicUUIDString];
            _dateOfBirthCharacteristicUUID = [CBUUID UUIDWithString:DateOfBirthCharacteristicUUIDString];
            _genderCharacteristicUUID = [CBUUID UUIDWithString:GenderCharacteristicUUIDString];
            _heightCharacteristicUUID = [CBUUID UUIDWithString:HeightCharacteristicUUIDString];
            _modelNumberStringCharacteristicUUID = [CBUUID UUIDWithString:ModelNumberStringCharacteristicUUIDString];
            _OHQBodyCompositionMeasurementCharacteristicUUID = [CBUUID UUIDWithString:OHQBodyCompositionMeasurementCharacteristicUUIDString];
            _recordAccessControlPointCharacteristicUUID = [CBUUID UUIDWithString:RecordAccessControlPointCharacteristicUUIDString];
            _userControlPointCharacteristicUUID = [CBUUID UUIDWithString:UserControlPointCharacteristicUUIDString];
            _userIndexCharacteristicUUID = [CBUUID UUIDWithString:UserIndexCharacteristicUUIDString];
            _weightMeasurementCharacteristicUUID = [CBUUID UUIDWithString:WeightMeasurementCharacteristicUUIDString];
            _weightScaleFeatureCharacteristicUUID = [CBUUID UUIDWithString:WeightScaleFeatureCharacteristicUUIDString];
            _presentationFormatDescriptorUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicFormatString];
            _omronCustomPlxFeaturesCharacteristicUUID = [CBUUID UUIDWithString:OmronCustomPlxFeaturesCharacteristicUUIDString];
            _omronCustomPlxSpotCheckMeasurementCharacteristicUUID = [CBUUID UUIDWithString:OmronCustomPlxSpotCheckMeasurementCharacteristicUUIDString];
            _omronCustomPlxRecordAccessControlPointCharacteristicUUID = [CBUUID UUIDWithString:OmronCustomPlxRecordAccessControlPointCharacteristicUUIDString];
            _temperatureMeasurementCharacteristicUUID = [CBUUID UUIDWithString:TemperatureMeasurementCharacteristicUUIDString];
        });
    }
}

- (BOOL)isEqual:(id)other {
    BOOL ret = NO;
    if (other == self) {
        ret = YES;
    }
    else if ([super isEqual:other]) {
        ret = YES;
    }
    else if ([other isKindOfClass:[self class]]) {
        typeof(self) otherItem = other;
        if ([otherItem.peripheral isEqual:self.peripheral]) {
            ret = YES;
        }
    }
    return ret;
}

- (NSUInteger)hash {
    return self.peripheral.hash;
}

///---------------------------------------------------------------------------------------
#pragma mark - Public methods
///---------------------------------------------------------------------------------------

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral queue:(dispatch_queue_t)queue {
    OHQFuncLogD(@"[IN] peripheral:%@ queue:%@", peripheral, queue);
    
    self = [super initWithQueue:queue];
    if (self) {
        self.peripheral = peripheral;
        self.peripheral.delegate = self;
        self.dataObserverBlock = nil;
        self.options = nil;
        self.deviceCategory = OHQDeviceCategoryUnknown;
        self.heightCharacteristicPresentationFormatData = nil;
        self.registeredUserIndex = nil;
        self.latestDatabaseChangeIncrement = nil;
        self.latestUserData = nil;
        self.temporaryMeasurementRecords = nil;
        
        [self addState:[InactiveState state]];
        [self addState:[ActiveState state]];
        [self addState:[ServicesDiscoveringState state] toParentStateClass:[ActiveState class]];
        [self addState:[IncludedServicesDiscoveringState state] toParentStateClass:[ActiveState class]];
        [self addState:[CharacteristicsDiscoveringState state] toParentStateClass:[ActiveState class]];
        [self addState:[DescriptorsDiscoveringState state] toParentStateClass:[ActiveState class]];
        [self addState:[AttributesDiscoveredState state] toParentStateClass:[ActiveState class]];
        [self addState:[DeviceFeatureVerifyingState state] toParentStateClass:[AttributesDiscoveredState class]];
        [self addState:[DescriptorValuesReadingState state] toParentStateClass:[AttributesDiscoveredState class]];
        [self addState:[CharacteristicValuesReadingState state] toParentStateClass:[AttributesDiscoveredState class]];
        [self addState:[NotificationEnablingState state] toParentStateClass:[AttributesDiscoveredState class]];
        [self addState:[NotificationEnabledState state] toParentStateClass:[AttributesDiscoveredState class]];
        [self addState:[UserRegisteringState state] toParentStateClass:[NotificationEnabledState class]];
        [self addState:[UserAuthenticatingState state] toParentStateClass:[NotificationEnabledState class]];
        [self addState:[UserDataDeletingState state] toParentStateClass:[NotificationEnabledState class]];
        [self addState:[DatabaseChangeIncrementNotificationWaitingState state] toParentStateClass:[NotificationEnabledState class]];
        [self addState:[UserDataReadingState state] toParentStateClass:[NotificationEnabledState class]];
        [self addState:[UserDataWritingState state] toParentStateClass:[NotificationEnabledState class]];
        [self addState:[MeasurementRecordAccessControllingState state] toParentStateClass:[NotificationEnabledState class]];
        [self addState:[PlxMeasurementRecordAccessControllingState state] toParentStateClass:[NotificationEnabledState class]];
        
        [self startWithInitialState:[self stateForClass:[InactiveState class]]];
    }
    return self;
}

- (void)startTransferWithDataObserverBlock:(OHQDataObserverBlock)dataObserver options:(NSDictionary<OHQSessionOptionKey,id> *)options {
    OHQFuncLogD(@"[IN] dataObserver:%@ options:%@", dataObserver, options);
    
    self.dataObserverBlock = dataObserver;
    self.options = options;
    self.deviceCategory = OHQDeviceCategoryUnknown;
    self.supportedUserDataKeys = nil;
    self.heightCharacteristicPresentationFormatData = nil;
    self.registeredUserIndex = nil;
    self.latestDatabaseChangeIncrement = nil;
    self.temporaryMeasurementRecords = nil;
    
    [self updateWithEvent:StateMachineEventStartTransfer object:nil];
}

- (void)cancelTransfer {
    OHQFuncLogD(@"[IN]");
    
    [self updateWithEvent:StateMachineEventCancelTransfer object:nil];
}

- (NSArray<NSDictionary<OHQMeasurementRecordKey,id> *> *)measurementRecords {
    return [self.temporaryMeasurementRecords copy];
}

///---------------------------------------------------------------------------------------
#pragma mark - Peripheral delegate
///---------------------------------------------------------------------------------------

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ error:%@", peripheral, error);
    
    [self updateWithEvent:StateMachineEventDidDiscoverServices object:(error ? @{EventAttachedDataErrorKey: error} : nil)];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ service:%@ error:%@", peripheral, service, error);
    
    NSMutableDictionary *obj = [@{EventAttachedDataServiceKey: service} mutableCopy];
    obj[EventAttachedDataErrorKey] = error;
    [self updateWithEvent:StateMachineEventDidDiscoverIncludedServices object:obj];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ service:%@ error:%@", peripheral, service, error);
    
    NSMutableDictionary *obj = [@{EventAttachedDataServiceKey: service} mutableCopy];
    obj[EventAttachedDataErrorKey] = error;
    [self updateWithEvent:StateMachineEventDidDiscoverCharacteristics object:obj];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    
    NSMutableDictionary *obj = [@{EventAttachedDataCharacteristicKey: characteristic} mutableCopy];
    obj[EventAttachedDataErrorKey] = error;
    [self updateWithEvent:StateMachineEventDidDiscoverDescriptors object:obj];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ descriptor:%@ error:%@", peripheral, descriptor, error);
    
    NSMutableDictionary *obj = [@{EventAttachedDataDescriptorKey: descriptor} mutableCopy];
    obj[EventAttachedDataErrorKey] = error;
    [self updateWithEvent:StateMachineEventDidUpdateValueForDescriptor object:obj];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    
    NSMutableDictionary *obj = [@{EventAttachedDataCharacteristicKey: characteristic} mutableCopy];
    obj[EventAttachedDataErrorKey] = error;
    [self updateWithEvent:StateMachineEventDidUpdateNotificationStateForCharacteristic object:obj];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    
    NSMutableDictionary *obj = [@{EventAttachedDataCharacteristicKey: characteristic} mutableCopy];
    obj[EventAttachedDataErrorKey] = error;
    [self updateWithEvent:StateMachineEventDidUpdateValueForCharacteristic object:obj];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    OHQFuncLogD(@"[IN] peripheral:%@ characteristic:%@ error:%@", peripheral, characteristic, error);
    
    NSMutableDictionary *obj = [@{EventAttachedDataCharacteristicKey: characteristic} mutableCopy];
    obj[EventAttachedDataErrorKey] = error;
    [self updateWithEvent:StateMachineEventDidWriteValueForCharacteristic object:obj];
}

///---------------------------------------------------------------------------------------
#pragma mark - Internal methods
///---------------------------------------------------------------------------------------

- (NSArray<CBService *> *)allServices {
    __block NSMutableArray<CBService *> *allServices = nil;
    if (self.peripheral.services.count) {
        allServices = [@[] mutableCopy];
        [self.peripheral.services enumerateObjectsUsingBlock:^(CBService * _Nonnull primaryService, NSUInteger idx, BOOL * _Nonnull stop) {
            [allServices addObject:primaryService];
            [allServices addObjectsFromArray:primaryService.includedServices];
        }];
    }
    return [allServices copy];
}

- (CBService *)serviceWithUUID:(CBUUID *)serviceUUID {
    __block CBService *ret = nil;
    [self.allServices enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(CBService * _Nonnull discoveredService, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([discoveredService.UUID isEqual:serviceUUID]) {
            ret = discoveredService;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs {
    OHQLogD(@"-[CBPeripheral(%@) discoverServices:] serviceUUIDs:%@", self.peripheral.identifier, serviceUUIDs);
    [self.peripheral discoverServices:serviceUUIDs];
}

- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service {
    OHQLogD(@"-[CBPeripheral(%@) discoverIncludedServices:forService:] includedServiceUUIDs:%@ service:%@", self.peripheral.identifier, includedServiceUUIDs, service);
    [self.peripheral discoverIncludedServices:includedServiceUUIDs forService:service];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service {
    OHQLogD(@"-[CBPeripheral(%@) discoverCharacteristics:forService:] characteristicUUIDs:%@ service:%@", self.peripheral.identifier, characteristicUUIDs, service);
    [self.peripheral discoverCharacteristics:characteristicUUIDs forService:service];
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic {
    OHQLogD(@"-[CBPeripheral(%@) readValueForCharacteristic:] characteristic:%@", self.peripheral.identifier, characteristic);
    [self.peripheral readValueForCharacteristic:characteristic];
}

- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type {
    OHQLogD(@"-[CBPeripheral(%@) writeValue:forCharacteristic:type:] data:%@ characteristic:%@ type:%@", self.peripheral.identifier, data, characteristic, @(type));
    [self.peripheral writeValue:data forCharacteristic:characteristic type:type];
}

- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic {
    OHQLogD(@"-[CBPeripheral(%@) setNotifyValue:forCharacteristic:] enabled:%@ characteristic:%@", self.peripheral.identifier, @(enabled), characteristic);
    [self.peripheral setNotifyValue:enabled forCharacteristic:characteristic];
}

- (void)discoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic {
    OHQLogD(@"-[CBPeripheral(%@) discoverDescriptorsForCharacteristic:] characteristic:%@", self.peripheral.identifier, characteristic);
    [self.peripheral discoverDescriptorsForCharacteristic:characteristic];
}

- (void)readValueForDescriptor:(CBDescriptor *)descriptor {
    OHQLogD(@"-[CBPeripheral(%@) readValueForDescriptor:] descriptor:%@", self.peripheral.identifier, descriptor);
    [self.peripheral readValueForDescriptor:descriptor];
}

- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor {
    OHQLogD(@"-[CBPeripheral(%@) writeValue:forDescriptor:] data:%@ descriptor:%@", self.peripheral.identifier, data, descriptor);
    [self.peripheral writeValue:data forDescriptor:descriptor];
}

- (void)abortTransferWithReason:(OHQCompletionReason)reason {
    if ([self.delegate respondsToSelector:@selector(device:didAbortTransferWithReason:)]) {
        [self.delegate device:self didAbortTransferWithReason:reason];
    }
    [self transitionToStateClass:[InactiveState class]];
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Inactive State
///---------------------------------------------------------------------------------------

@implementation InactiveState

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventStartTransfer: {
            handled = YES;
            device.mPulseOximeterFeatures = 0;
            device.mPlxpNumberOfRecords = 0;
            device.mPlxpReortedNumberOfMeasurement = 0;
            device.mPlxpIsCheckNumberOfRecords = NO;
            device.mPlxpWaitingSportCheckMeasurement = NO;
            [device transitionToStateClass:[ServicesDiscoveringState class]];
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Active State
///---------------------------------------------------------------------------------------

@implementation ActiveState

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    
    switch (event) {
        case StateMachineEventCancelTransfer: {
            handled = YES;
            
            [self.stateMachine transitionToStateClass:[InactiveState class]];
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Services Discovering State
///---------------------------------------------------------------------------------------

@implementation ServicesDiscoveringState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    NSMutableSet *serviceUUIDSet = [NSMutableSet set];
    [serviceUUIDSet addObjectsFromArray:@[_deviceInformationServiceUUID, _batteryServiceUUID, _currentTimeServiceUUID,
                                          _bloodPressureServiceUUID, _weightScaleServiceUUID, _bodyCompositionServiceUUID,
                                          _omronCustomPulseOximeterServiceUUID, _healthThermometerServiceUUID]];
    if ([device.options[OHQSessionOptionRegisterNewUserKey] boolValue] || device.options[OHQSessionOptionUserIndexKey]) {
        [serviceUUIDSet addObject:_userDataServiceUUID];
    }
    if ([device.options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] boolValue]) {
        [serviceUUIDSet addObject:_omronOptionServiceUUID];
    }
    if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
        if ([device.options[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] boolValue]) {
            [serviceUUIDSet addObject:_omronOptionServiceUUID];
        }
    }
    
    [device discoverServices:serviceUUIDSet.allObjects];
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidDiscoverServices: {
            NSError *error = object[EventAttachedDataErrorKey];
            handled = YES;
            
            if (error) {
                OHQFuncLogE(@"error:%@", error);
                [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                break;
            }
            
            [device transitionToStateClass:[IncludedServicesDiscoveringState class]];
            break;
        }
        default:
            break;
    }
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Included Services Discovering State
///---------------------------------------------------------------------------------------

@interface IncludedServicesDiscoveringState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;

@end

@implementation IncludedServicesDiscoveringState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    self.attributesOfInterest = [@[] mutableCopy];
    void (^discoverIncludedService)(CBService *, NSArray<CBUUID *> *) = ^(CBService *service, NSArray<CBUUID *> *includedServiceUUIDs) {
        if (service) {
            [self.attributesOfInterest addObject:service];
            dispatch_async(device.queue, ^{
                [device discoverIncludedServices:includedServiceUUIDs forService:service];
            });
        }
    };
    
    CBService *bodyCompositionService = [device serviceWithUUID:_bodyCompositionServiceUUID];
    CBService *weightScaleService = [device serviceWithUUID:_weightScaleServiceUUID];
    if (!weightScaleService || !bodyCompositionService) {
        discoverIncludedService(weightScaleService, @[_bodyCompositionServiceUUID]);
        discoverIncludedService(bodyCompositionService, @[_weightScaleServiceUUID]);
    }
    
    if (!self.attributesOfInterest.count) {
        [device transitionToStateClass:[CharacteristicsDiscoveringState class]];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidDiscoverIncludedServices: {
            CBService *service = object[EventAttachedDataServiceKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:service]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                [self.attributesOfInterest removeObject:service];
                if (!self.attributesOfInterest.count) {
                    [device transitionToStateClass:[CharacteristicsDiscoveringState class]];
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Characteristics Discovering State
///---------------------------------------------------------------------------------------

@interface CharacteristicsDiscoveringState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;

@end

@implementation CharacteristicsDiscoveringState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    self.attributesOfInterest = [@[] mutableCopy];
    void (^discoverCharacteristics)(CBService *, NSArray<CBUUID *> *) = ^(CBService *service, NSArray<CBUUID *> *characteristicUUIDs) {
        if (service) {
            [self.attributesOfInterest addObject:service];
            dispatch_async(device.queue, ^{
                [device discoverCharacteristics:characteristicUUIDs forService:service];
            });
        }
    };
    
    CBService *deviceInformationService = [device serviceWithUUID:_deviceInformationServiceUUID];
    discoverCharacteristics(deviceInformationService, @[_modelNumberStringCharacteristicUUID]);
    
    CBService *batteryService = [device serviceWithUUID:_batteryServiceUUID];
    discoverCharacteristics(batteryService, @[_batteryLevelCharacteristicUUID]);
    
    CBService *currentTimeService = [device serviceWithUUID:_currentTimeServiceUUID];
    discoverCharacteristics(currentTimeService, @[_currentTimeCharacteristicUUID]);
    
    CBService *bloodPressureService = [device serviceWithUUID:_bloodPressureServiceUUID];
    if (bloodPressureService) {
        NSMutableArray *characteristicUUIDs = [@[_bloodPressureFeatureCharacteristicUUID] mutableCopy];
        if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
            [characteristicUUIDs addObject:_bloodPressureMeasurementCharacteristicUUID];
        }
        discoverCharacteristics(bloodPressureService, characteristicUUIDs);
    }
    
    CBService *weightScaleService = [device serviceWithUUID:_weightScaleServiceUUID];
    if (weightScaleService) {
        NSMutableArray *characteristicUUIDs = [@[_weightScaleFeatureCharacteristicUUID] mutableCopy];
        if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
            [characteristicUUIDs addObject:_weightMeasurementCharacteristicUUID];
        }
        discoverCharacteristics(weightScaleService, characteristicUUIDs);
    }
    
    CBService *bodyCompositionService = [device serviceWithUUID:_bodyCompositionServiceUUID];
    if (bodyCompositionService) {
        NSMutableArray *characteristicUUIDs = [@[_bodyCompositionFeatureCharacteristicUUID] mutableCopy];
        if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
            [characteristicUUIDs addObject:_bodyCompositionMeasurementCharacteristicUUID];
        }
        discoverCharacteristics(bodyCompositionService, characteristicUUIDs);
        
        CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
        if (userDataService && ([device.options[OHQSessionOptionRegisterNewUserKey] boolValue] || device.options[OHQSessionOptionUserIndexKey])) {
            NSMutableArray *characteristicUUIDs = [@[_userControlPointCharacteristicUUID, _databaseChangeIncrementCharacteristicUUID] mutableCopy];
            if (device.options[OHQSessionOptionUserDataKey]) {
                [characteristicUUIDs addObjectsFromArray:@[_dateOfBirthCharacteristicUUID, _heightCharacteristicUUID, _genderCharacteristicUUID]];
            }
            discoverCharacteristics(userDataService, characteristicUUIDs);
        }
        
        CBService *omronOptionService = [device serviceWithUUID:_omronOptionServiceUUID];
        if (omronOptionService && [device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
            NSMutableArray *characteristicUUIDs = [@[] mutableCopy];
            if ([device.options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] boolValue]) {
                [characteristicUUIDs addObject:_recordAccessControlPointCharacteristicUUID];
            }
            if (characteristicUUIDs.count) {
                discoverCharacteristics(omronOptionService, characteristicUUIDs);
            }
            if ([device.options[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] boolValue]) {
                [characteristicUUIDs addObjectsFromArray:@[_OHQBodyCompositionMeasurementCharacteristicUUID]];
            }
        }
    }
    
    CBService *omronCustomPulseOximeterServiceUUID = [device serviceWithUUID:_omronCustomPulseOximeterServiceUUID];
    if (omronCustomPulseOximeterServiceUUID) {
        NSMutableArray *characteristicUUIDs = [@[] mutableCopy];
        [characteristicUUIDs addObject:_omronCustomPlxFeaturesCharacteristicUUID];
        [characteristicUUIDs addObject:_omronCustomPlxSpotCheckMeasurementCharacteristicUUID];
        if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
            [characteristicUUIDs addObject:_omronCustomPlxRecordAccessControlPointCharacteristicUUID];
        }
        discoverCharacteristics(omronCustomPulseOximeterServiceUUID, characteristicUUIDs);
    }

    CBService *healthThermometerService = [device serviceWithUUID:_healthThermometerServiceUUID];
    if (healthThermometerService) {
        NSMutableArray *characteristicUUIDs = [@[_temperatureMeasurementCharacteristicUUID] mutableCopy];
        if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
            [characteristicUUIDs addObject:_temperatureMeasurementCharacteristicUUID];
        }
        discoverCharacteristics(healthThermometerService, characteristicUUIDs);
    }
    

}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidDiscoverCharacteristics: {
            CBService *service = object[EventAttachedDataServiceKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:service]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    if (!service.isPrimary && [error.domain isEqualToString:CBErrorDomain] && error.code == CBErrorUUIDNotAllowed) {
                        // !!!: Ignore errors due to Core Bluetooth bugs.
                        OHQFuncLogE(@"error:%@ ignore", error);
                    }
                    else {
                        [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                        break;
                    }
                }

                [self.attributesOfInterest removeObject:service];
                if (!self.attributesOfInterest.count) {
                    [device transitionToStateClass:[DescriptorsDiscoveringState class]];
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Descriptors Discovering State
///---------------------------------------------------------------------------------------

@interface DescriptorsDiscoveringState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;

@end

@implementation DescriptorsDiscoveringState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    self.attributesOfInterest = [@[] mutableCopy];
    void (^discoverDescriptors)(CBCharacteristic *) = ^(CBCharacteristic *characteristic) {
        if (characteristic) {
            [self.attributesOfInterest addObject:characteristic];
            dispatch_async(device.queue, ^{
                [device discoverDescriptorsForCharacteristic:characteristic];
            });
        }
    };
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    CBCharacteristic *heightCharacteristic = [userDataService characteristicWithUUID:_heightCharacteristicUUID];
    discoverDescriptors(heightCharacteristic);
    
    if (!self.attributesOfInterest.count) {
        [device transitionToStateClass:[DeviceFeatureVerifyingState class]];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidDiscoverDescriptors: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:characteristic]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                [self.attributesOfInterest removeObject:characteristic];
                if (!self.attributesOfInterest.count) {
                    [device transitionToStateClass:[DeviceFeatureVerifyingState class]];
                }
            }
            break;
        }
        default:
            break;
    }

    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Attributes Discovered State
///---------------------------------------------------------------------------------------

@implementation AttributesDiscoveredState

@end

///---------------------------------------------------------------------------------------
#pragma mark - Device Feature Verifying State
///---------------------------------------------------------------------------------------

@implementation DeviceFeatureVerifyingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    CBService *bloodPressureService = [device serviceWithUUID:_bloodPressureServiceUUID];
    CBService *weightScaleService = [device serviceWithUUID:_weightScaleServiceUUID];
    CBService *bodyCompositionService = [device serviceWithUUID:_bodyCompositionServiceUUID];
    CBService *omronCunstomPulseOximeterService = [device serviceWithUUID:_omronCustomPulseOximeterServiceUUID];
    CBService *healthThermometerService = [device serviceWithUUID:_healthThermometerServiceUUID];
    if (bloodPressureService) {
        device.deviceCategory = OHQDeviceCategoryBloodPressureMonitor;
    }
    else if (bodyCompositionService) {
        device.deviceCategory = OHQDeviceCategoryBodyCompositionMonitor;
    }
    else if (weightScaleService) {
        device.deviceCategory = OHQDeviceCategoryWeightScale;
    }
    else if (omronCunstomPulseOximeterService) {
        device.deviceCategory = OHQDeviceCategoryPulseOximeter;
    }
    else if (healthThermometerService) {
        device.deviceCategory = OHQDeviceCategoryHealthThermometer;
    }
    
    if (device.deviceCategory != OHQDeviceCategoryUnknown) {
        device.dataObserverBlock(OHQDataTypeDeviceCategory, @(device.deviceCategory));
    }
    else {
        // measurement service is missing.
        [device abortTransferWithReason:OHQCompletionReasonOperationNotSupported];
        return;
    }
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    if (userDataService) {
        NSMutableDictionary<OHQUserDataKey,CBCharacteristic *> *userDataCharacteristics = [@{} mutableCopy];
        userDataCharacteristics[OHQUserDataDateOfBirthKey] = [userDataService characteristicWithUUID:_dateOfBirthCharacteristicUUID];
        userDataCharacteristics[OHQUserDataHeightKey] = [userDataService characteristicWithUUID:_heightCharacteristicUUID];
        userDataCharacteristics[OHQUserDataGenderKey] = [userDataService characteristicWithUUID:_genderCharacteristicUUID];
        device.supportedUserDataKeys = userDataCharacteristics.allKeys;
    }
    else {
        if (device.options[OHQSessionOptionUserIndexKey]) {
            // Required service is missing. [Register new user with user index / consent / delete user data]
            [device abortTransferWithReason:OHQCompletionReasonOperationNotSupported];
            return;
        }
    }
    
    if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
        BOOL useExtendedMeasurements = NO;
        if ([device.options[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] boolValue]) {
            CBService *omronOptionService = [device serviceWithUUID:_omronOptionServiceUUID];
            CBCharacteristic *OHQBodyCompositionMeasurementCharacteristic = [omronOptionService characteristicWithUUID:_OHQBodyCompositionMeasurementCharacteristicUUID];
            if (OHQBodyCompositionMeasurementCharacteristic) {
                useExtendedMeasurements = YES;
            }
        }
        if (!useExtendedMeasurements) {
            if (bloodPressureService) {
                CBCharacteristic *measurementCharacteristic = [bloodPressureService characteristicWithUUID:_bloodPressureMeasurementCharacteristicUUID];
                if (!measurementCharacteristic) {
                    // Required characteristic is missing.
                    [device abortTransferWithReason:OHQCompletionReasonOperationNotSupported];
                    return;
                }
            }
            if (bodyCompositionService) {
                CBCharacteristic *measurementCharacteristic = [bodyCompositionService characteristicWithUUID:_bodyCompositionMeasurementCharacteristicUUID];
                if (!measurementCharacteristic) {
                    // Required characteristic is missing.
                    [device abortTransferWithReason:OHQCompletionReasonOperationNotSupported];
                    return;
                }
            }
            if (weightScaleService) {
                CBCharacteristic *measurementCharacteristic = [weightScaleService characteristicWithUUID:_weightMeasurementCharacteristicUUID];
                if (!measurementCharacteristic) {
                    // Required characteristic is missing.
                    [device abortTransferWithReason:OHQCompletionReasonOperationNotSupported];
                    return;
                }
            }
            if (healthThermometerService) {
                CBCharacteristic *measurementCharacteristic = [healthThermometerService characteristicWithUUID:_temperatureMeasurementCharacteristicUUID];
                if (!measurementCharacteristic) {
                    // Required characteristic is missing.
                    [device abortTransferWithReason:OHQCompletionReasonOperationNotSupported];
                    return;
                }
            }
        }
    }
    
    if (omronCunstomPulseOximeterService) {
        CBCharacteristic *omronCustomPlxFeaturesCharacteristic = [omronCunstomPulseOximeterService characteristicWithUUID:_omronCustomPlxFeaturesCharacteristicUUID];
        CBCharacteristic *omronCustomPlxSpotCheckMeasurementCharacteristic = [omronCunstomPulseOximeterService characteristicWithUUID:_omronCustomPlxSpotCheckMeasurementCharacteristicUUID];
        CBCharacteristic *omronCustomPlxRecordAccessControlPointCharacteristic = [omronCunstomPulseOximeterService characteristicWithUUID:_omronCustomPlxFeaturesCharacteristicUUID];
        if (!omronCustomPlxFeaturesCharacteristic || !omronCustomPlxSpotCheckMeasurementCharacteristic || !omronCustomPlxRecordAccessControlPointCharacteristic) {
            // Required characteristic is missing.
            [device abortTransferWithReason:OHQCompletionReasonOperationNotSupported];
            return;
        }
    }
    
    [device transitionToStateClass:[DescriptorValuesReadingState class]];
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Descriptor Values Reading State
///---------------------------------------------------------------------------------------

@interface DescriptorValuesReadingState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;

@end

@implementation DescriptorValuesReadingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    self.attributesOfInterest = [@[] mutableCopy];
    void (^readDescriptor)(CBDescriptor *) = ^(CBDescriptor *descriptor) {
        if (descriptor) {
            [self.attributesOfInterest addObject:descriptor];
            dispatch_async(device.queue, ^{
                [device readValueForDescriptor:descriptor];
            });
        }
    };
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    CBCharacteristic *heightCharacteristic = [userDataService characteristicWithUUID:_heightCharacteristicUUID];
    CBDescriptor *heightPresentationFormatDescriptor = [heightCharacteristic descriptorWithUUID:_presentationFormatDescriptorUUID];
    readDescriptor(heightPresentationFormatDescriptor);
    
    if (!self.attributesOfInterest.count) {
        [device transitionToStateClass:[CharacteristicValuesReadingState class]];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidUpdateValueForDescriptor: {
            CBDescriptor *descriptor = object[EventAttachedDataDescriptorKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:descriptor]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                if ([descriptor.UUID isEqual:_presentationFormatDescriptorUUID]) {
                    CharacteristicPresentationFormat characteristicPresentationFormat = {0};
                    memcpy(&characteristicPresentationFormat, [descriptor.value bytes], sizeof(characteristicPresentationFormat));
                    OHQLogI(@"%@ format:%@",descriptor, CharacteristicPresentationFormatDescription(characteristicPresentationFormat));
                    
                    if ([descriptor.characteristic.UUID isEqual:_heightCharacteristicUUID]) {
                        device.heightCharacteristicPresentationFormatData = descriptor.value;
                    }
                }
                
                [self.attributesOfInterest removeObject:descriptor];
                if (!self.attributesOfInterest.count) {
                    [device transitionToStateClass:[CharacteristicValuesReadingState class]];
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Characteristic Values Reading State
///---------------------------------------------------------------------------------------

@interface CharacteristicValuesReadingState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;

@end

@implementation CharacteristicValuesReadingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    self.attributesOfInterest = [@[] mutableCopy];
    void (^readCharacteristic)(CBCharacteristic *) = ^(CBCharacteristic *characteristic) {
        if (characteristic) {
            [self.attributesOfInterest addObject:characteristic];
            dispatch_async(device.queue, ^{
                [device readValueForCharacteristic:characteristic];
            });
        }
    };
    
    CBService *deviceInformationService = [device serviceWithUUID:_deviceInformationServiceUUID];
    CBCharacteristic *modelNumberStringCharacteristic = [deviceInformationService characteristicWithUUID:_modelNumberStringCharacteristicUUID];
    readCharacteristic(modelNumberStringCharacteristic);
    
    if (device.deviceCategory == OHQDeviceCategoryPulseOximeter) {
        CBService *batteryService = [device serviceWithUUID:_batteryServiceUUID];
        CBCharacteristic *batteryLevelCharacteristic = [batteryService characteristicWithUUID:_batteryLevelCharacteristicUUID];
        readCharacteristic(batteryLevelCharacteristic);
    }
    
    CBService *bloodPressureService = [device serviceWithUUID:_bloodPressureServiceUUID];
    CBCharacteristic *bloodPressureFeatureCharacteristic = [bloodPressureService characteristicWithUUID:_bloodPressureFeatureCharacteristicUUID];
    readCharacteristic(bloodPressureFeatureCharacteristic);
    
    CBService *weightScaleService = [device serviceWithUUID:_weightScaleServiceUUID];
    CBCharacteristic *weightScaleFeatureCharacteristic = [weightScaleService characteristicWithUUID:_weightScaleFeatureCharacteristicUUID];
    readCharacteristic(weightScaleFeatureCharacteristic);
    
    CBService *bodyCompositionService = [device serviceWithUUID:_bodyCompositionServiceUUID];
    CBCharacteristic *bodyCompositionFeatureCharacteristic = [bodyCompositionService characteristicWithUUID:_bodyCompositionFeatureCharacteristicUUID];
    readCharacteristic(bodyCompositionFeatureCharacteristic);
    
    CBService *omronCunstomPulseOximeterService = [device serviceWithUUID:_omronCustomPulseOximeterServiceUUID];
    CBCharacteristic *omronCustomPlxFeaturesCharacteristic = [omronCunstomPulseOximeterService characteristicWithUUID:_omronCustomPlxFeaturesCharacteristicUUID];
    readCharacteristic(omronCustomPlxFeaturesCharacteristic);
    
    if (!self.attributesOfInterest.count) {
        [device transitionToStateClass:[NotificationEnablingState class]];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:characteristic]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                if ([characteristic.UUID isEqual:_modelNumberStringCharacteristicUUID]) {
                    NSString *modelName = nil;
                    if (characteristic.value != nil) {
                        modelName = [[NSString alloc] initWithBytes:characteristic.value.bytes length:characteristic.value.length encoding:NSUTF8StringEncoding];
                    }
                    device.dataObserverBlock(OHQDataTypeModelName, modelName);
                }
                if ([characteristic.UUID isEqual:_batteryLevelCharacteristicUUID]) {
                    UInt8 batteryLevelValue = 0;
                    if (characteristic.value != nil) {
                        memcpy(&batteryLevelValue, characteristic.value.bytes, sizeof(batteryLevelValue));
                    }
                    float actualbatteryLevelValue = batteryLevelValue * 0.01f;
                    device.dataObserverBlock(OHQDataTypeBatteryLevel, @(actualbatteryLevelValue));
                }
                if ([characteristic.UUID isEqual:_bloodPressureFeatureCharacteristicUUID]) {
                    OHQLogI(@"peripheral(%@) BloodPressureFeature:%@", device.peripheral.identifier, characteristic.value);
                }
                if ([characteristic.UUID isEqual:_weightScaleFeatureCharacteristicUUID]) {
                    OHQLogI(@"peripheral(%@) WeightScaleFeature:%@", device.peripheral.identifier, characteristic.value);
                }
                if ([characteristic.UUID isEqual:_bodyCompositionFeatureCharacteristicUUID]) {
                    OHQLogI(@"peripheral(%@) BodyCompositionFeature:%@", device.peripheral.identifier, characteristic.value);
                }
                
                if ([characteristic.UUID isEqual:_omronCustomPlxFeaturesCharacteristicUUID]) {
                    OHQLogI(@"peripheral(%@) OmronCustomPlxFeatures:%@", device.peripheral.identifier, characteristic.value);
                    const void *pt = characteristic.value.bytes;
                    PulseOximeterFeaturesFlags pulseOximeterFetureFlags;
                    memcpy(&pulseOximeterFetureFlags, pt, sizeof(pulseOximeterFetureFlags));
                    device.mPulseOximeterFeatures = pulseOximeterFetureFlags;
                }
                
                [self.attributesOfInterest removeObject:characteristic];
                if (!self.attributesOfInterest.count) {
                    [device transitionToStateClass:[NotificationEnablingState class]];
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Notification Enabling State
///---------------------------------------------------------------------------------------

@interface NotificationEnablingState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;
@property (assign, nonatomic) NSUInteger retryCount;

@end

@implementation NotificationEnablingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
        device.temporaryMeasurementRecords = [@[] mutableCopy];
    }
    _WroteCurrentTime =NO;
    _ReceivedSpotCheckMeasurement = NO;
    
    self.attributesOfInterest = [@[] mutableCopy];
    void (^addCharacteristicOfInterest)(CBCharacteristic *) = ^(CBCharacteristic *characteristic) {
        if (characteristic) {
            [self.attributesOfInterest addObject:characteristic];
        }
    };
    
    CBService *currentTimeService = [device serviceWithUUID:_currentTimeServiceUUID];
    CBCharacteristic *currentTimeCharacteristic = [currentTimeService characteristicWithUUID:_currentTimeCharacteristicUUID];
    addCharacteristicOfInterest(currentTimeCharacteristic);
    
    CBService *batteryService = [device serviceWithUUID:_batteryServiceUUID];
    CBCharacteristic *batteryLevelCharacteristic = [batteryService characteristicWithUUID:_batteryLevelCharacteristicUUID];
    addCharacteristicOfInterest(batteryLevelCharacteristic);
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    CBCharacteristic *userControlPointCharacteristic = [userDataService characteristicWithUUID:_userControlPointCharacteristicUUID];
    CBCharacteristic *databaseChangeIncrementCharacteristic = [userDataService characteristicWithUUID:_databaseChangeIncrementCharacteristicUUID];
    if ([device.options[OHQSessionOptionRegisterNewUserKey] boolValue] || device.options[OHQSessionOptionUserIndexKey]) {
        addCharacteristicOfInterest(userControlPointCharacteristic);
    }
    
    if ([self ohq_isUnregisterMode:device] == NO) {
        addCharacteristicOfInterest(databaseChangeIncrementCharacteristic);
    }
    
    CBService *omronOptionService = [device serviceWithUUID:_omronOptionServiceUUID];
    CBCharacteristic *recordAccessControlPointCharacteristic = [omronOptionService characteristicWithUUID:_recordAccessControlPointCharacteristicUUID];
    CBCharacteristic *OHQBodyCompositionMeasurementCharacteristic = [omronOptionService characteristicWithUUID:_OHQBodyCompositionMeasurementCharacteristicUUID];
    CBService *bloodPressureService = [device serviceWithUUID:_bloodPressureServiceUUID];
    CBCharacteristic *bloodPressureMeasurementCharacteristic = [bloodPressureService characteristicWithUUID:_bloodPressureMeasurementCharacteristicUUID];
    CBService *weightScaleService = [device serviceWithUUID:_weightScaleServiceUUID];
    CBCharacteristic *weightMeasurementCharacteristic = [weightScaleService characteristicWithUUID:_weightMeasurementCharacteristicUUID];
    CBService *bodyCompositionService = [device serviceWithUUID:_bodyCompositionServiceUUID];
    CBCharacteristic *bodyCompositionMeasurementCharacteristic = [bodyCompositionService characteristicWithUUID:_bodyCompositionMeasurementCharacteristicUUID];
    CBService *healthThermometerService = [device serviceWithUUID:_healthThermometerServiceUUID];
    CBCharacteristic *temperatureMeasurementCharacteristic = [healthThermometerService characteristicWithUUID:_temperatureMeasurementCharacteristicUUID];
    if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue]) {
        if ([device.options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] boolValue]) {
            
            if ([self ohq_isUnregisterMode:device] == NO) {
                addCharacteristicOfInterest(recordAccessControlPointCharacteristic);
            }
        }
        if (OHQBodyCompositionMeasurementCharacteristic && [device.options[OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey] boolValue]) {
            addCharacteristicOfInterest(OHQBodyCompositionMeasurementCharacteristic);
        }
        else {
            addCharacteristicOfInterest(bodyCompositionMeasurementCharacteristic);
            addCharacteristicOfInterest(weightMeasurementCharacteristic);
            addCharacteristicOfInterest(temperatureMeasurementCharacteristic);
        }
        addCharacteristicOfInterest(bloodPressureMeasurementCharacteristic);
    }
    
    if (device.deviceCategory == OHQDeviceCategoryPulseOximeter) {
        CBService *omronCunstomPulseOximeterService = [device serviceWithUUID:_omronCustomPulseOximeterServiceUUID];
        if( device.mPulseOximeterFeatures & PulseOximeterFeaturesFlagsMeasurementStorageForSpotCheckMeasurements ){
            CBCharacteristic *omronCustomPlxRecordAccessControlPointCharacteristic = [omronCunstomPulseOximeterService characteristicWithUUID:_omronCustomPlxRecordAccessControlPointCharacteristicUUID];
            if(nil != omronCustomPlxRecordAccessControlPointCharacteristic) {
                addCharacteristicOfInterest(omronCustomPlxRecordAccessControlPointCharacteristic);
            } else {
                device.mPlxpIsCheckNumberOfRecords = YES;
            }
        } else {
           device.mPlxpIsCheckNumberOfRecords = YES;
        }
        CBCharacteristic *omronCustomPlxSpotCheckMeasurementCharacteristic = [omronCunstomPulseOximeterService characteristicWithUUID:_omronCustomPlxSpotCheckMeasurementCharacteristicUUID];
        if (omronCustomPlxSpotCheckMeasurementCharacteristic) {
            addCharacteristicOfInterest(omronCustomPlxSpotCheckMeasurementCharacteristic);
        }
    }
    if (self.attributesOfInterest.count) {
        self.retryCount = 0;
        [self ohq_enableNotificationForCharacteristic:(CBCharacteristic *)self.attributesOfInterest.firstObject];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidUpdateNotificationStateForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:characteristic]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
#ifdef OHQ_OPTION_ENABLE_RETRY_FOR_NOTIFICATION_ACTIVATION
                    if ([error.domain isEqualToString:CBATTErrorDomain] && error.code == CBATTErrorInsufficientAuthentication && self.retryCount <= OHQ_OPTION_RETRY_COUNT_FOR_NOTIFICATION_ACTIVATION) {
                        self.retryCount += 1;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(OHQ_OPTION_RETRY_INTERVAL_FOR_NOTIFICATION_ACTIVATION * NSEC_PER_SEC)), device.queue, ^{
                            [self ohq_enableNotificationForCharacteristic:characteristic];
                        });
                    }
                    else {
                        [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    }
#else // OHQ_OPTION_ENABLE_RETRY_FOR_NOTIFICATION_ACTIVATION
                    [device ohq_abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
#endif // OHQ_OPTION_ENABLE_RETRY_FOR_NOTIFICATION_ACTIVATION
                    break;
                }
                
                [self.attributesOfInterest removeObject:characteristic];
                if (self.attributesOfInterest.count) {
                    self.retryCount = 0;
                    [self ohq_enableNotificationForCharacteristic:(CBCharacteristic *)self.attributesOfInterest.firstObject];
                }
                else {
                    [device transitionToStateClass:[NotificationEnabledState class]];
                }
            }
            break;
        }
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_omronCustomPlxSpotCheckMeasurementCharacteristicUUID]) {
                // Processing when omronPLXSpotCheckMeasurementCharacteristic (measurement data) is received before the state transition.
                handled = YES;
                _ReceivedSpotCheckMeasurement = YES;
                [self ohq_device:device didUpdateValueForOmronCustomPLXSpotCheckMeasurementCharacteristic:characteristic error:error];
            }
            else if ([characteristic.UUID isEqual:_currentTimeCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                CurrentTime currentTimeValue = {0};
                memcpy(&currentTimeValue, characteristic.value.bytes, sizeof(currentTimeValue));
                OHQFuncLogI(@"CurrentTime:%04d-%02d-%02d %02d:%02d:%02d DayOfWeek:%d Fractions256:%d AdjustReason:0x%02X",
                            currentTimeValue.dateTime.year, currentTimeValue.dateTime.month, currentTimeValue.dateTime.day,
                            currentTimeValue.dateTime.hours, currentTimeValue.dateTime.minutes, currentTimeValue.dateTime.seconds,
                            currentTimeValue.dayOfWeek, currentTimeValue.fractions256, currentTimeValue.adjustReason);
                
                device.dataObserverBlock(OHQDataTypeCurrentTime, ConvertDateTimeToNSDate(currentTimeValue.dateTime));

                if( _WroteCurrentTime == NO){
                    _WroteCurrentTime = YES;
                    CBService *currentTimeService = [device serviceWithUUID:_currentTimeServiceUUID];
                    CBCharacteristic *currentTimeCharacteristic = [currentTimeService characteristicWithUUID:_currentTimeCharacteristicUUID];
                    [self ohq_device:device writeOfCurrentTimeCharacteristicsForPeripheral:currentTimeCharacteristic];
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

- (void)ohq_enableNotificationForCharacteristic:(CBCharacteristic *)characteristic {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    [device setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForOmronCustomPLXSpotCheckMeasurementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSMutableDictionary *dict = [@{} mutableCopy];
    const void *pt = characteristic.value.bytes;
    
    PulseOximeterSpotCheckMeasurementFlags flagsValue;
    memcpy(&flagsValue, pt, sizeof(flagsValue));
    pt += sizeof(flagsValue);
    
    SFloat spo2Value;
    memcpy(&spo2Value, pt, sizeof(spo2Value));
    dict[OHQMeasurementRecordPulseOximeterSpo2Key] = @(ConvertSFloatToFloat32(spo2Value));
    pt += sizeof(spo2Value);
    
    SFloat pulseRateValue;
    memcpy(&pulseRateValue, pt, sizeof(pulseRateValue));
    dict[OHQMeasurementRecordPulseRateKey] = @(ConvertSFloatToFloat32(pulseRateValue));
    pt += sizeof(pulseRateValue);
    
    if ((device.mPulseOximeterFeatures & PulseOximeterFeaturesFlagsTimeStampForSpotCheckMeasurements) &&
        (flagsValue & PulseOximeterSpotCheckMeasurementFlagsTimeStamp) &&
        !(flagsValue & PulseOximeterSpotCheckMeasurementFlagsDeviceClockIsNotSet)
    ) {
        DateTime timeStampValue;
        memcpy(&timeStampValue, pt, sizeof(timeStampValue));
        if(IsInvalidDateTime(timeStampValue) == NO){
            dict[OHQMeasurementRecordTimeStampKey] = ConvertDateTimeToNSDate(timeStampValue);
        }
        pt += sizeof(timeStampValue);
    }
    
    [device.temporaryMeasurementRecords addObject:[dict copy]];
    
    device.mPlxpReortedNumberOfMeasurement++;
}

- (BOOL)ohq_isUnregisterMode:(OHQDevice *) device {
    if (device.deviceCategory == OHQDeviceCategoryBodyCompositionMonitor && [device.options[OHQSessionOptionRegisterNewUserKey] boolValue] && device.options[OHQSessionOptionUserIndexKey]) {
        NSNumber *guestUserIndex = [NSNumber numberWithInt:255];
        NSNumber *currentUserIndex = [NSNumber numberWithInt:[device.options[OHQSessionOptionUserIndexKey] intValue]];
        if (guestUserIndex == currentUserIndex) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)ohq_device:(OHQDevice *)device writeOfCurrentTimeCharacteristicsForPeripheral:(CBCharacteristic *)characteristic {
    
    void (^writeCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *aCharacteristic, NSData *data) {
        [device writeValue:data forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
    };
    
    NSDate              *date       = [NSDate date];
    NSCalendar          *calendar   = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents    *components = [calendar components:NSCalendarUnitYear      |
                                                        NSCalendarUnitMonth     |
                                                        NSCalendarUnitDay       |
                                                        NSCalendarUnitHour      |
                                                        NSCalendarUnitMinute    |
                                                        NSCalendarUnitSecond    |
                                                        NSCalendarUnitWeekday
                                               fromDate:date];
    CurrentTime currentTimeValue = {0};
    currentTimeValue.adjustReason       = 1;
    currentTimeValue.dateTime.year      = components.year;
    currentTimeValue.dateTime.month     = components.month;
    currentTimeValue.dateTime.day       = components.day;
    currentTimeValue.dateTime.hours     = components.hour;
    currentTimeValue.dateTime.minutes   = components.minute;
    currentTimeValue.dateTime.seconds   = components.second;
    currentTimeValue.dayOfWeek          = ((components.weekday == 1) ? 7 : (components.weekday -1));
                                            // weekday:1 to 7 = Sunday to Saturday
                                            // -> dayOfWeek:1 to 7 = Monday to Sunday
    
    OHQFuncLogI(@"CurrentTime:%04d-%02d-%02d %02d:%02d:%02d DayOfWeek:%d Fractions256:%d AdjustReason:0x%02X",
                currentTimeValue.dateTime.year, currentTimeValue.dateTime.month, currentTimeValue.dateTime.day,
                currentTimeValue.dateTime.hours, currentTimeValue.dateTime.minutes, currentTimeValue.dateTime.seconds,
                currentTimeValue.dayOfWeek, currentTimeValue.fractions256, currentTimeValue.adjustReason);
    
    device.dataObserverBlock(OHQDataTypeCurrentTime, ConvertDateTimeToNSDate(currentTimeValue.dateTime));

    NSData *data = [NSData dataWithBytes:&currentTimeValue length:sizeof(CurrentTime)];
    writeCharacteristic(characteristic, data);
    return;
}
@end

///---------------------------------------------------------------------------------------
#pragma mark - Notification Enabled State
///---------------------------------------------------------------------------------------

@interface NotificationEnabledState ()

@property (nonatomic, copy) NSDictionary<OHQMeasurementRecordKey,id> *pertialMeasurementData;

@end

@implementation NotificationEnabledState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    CBCharacteristic *userControlPointCharacteristic = [userDataService characteristicWithUUID:_userControlPointCharacteristicUUID];
    
    if (userControlPointCharacteristic && [device.options[OHQSessionOptionRegisterNewUserKey] boolValue]) {
        [device transitionToStateClass:[UserRegisteringState class]];
    }
    else if (userControlPointCharacteristic && device.options[OHQSessionOptionUserIndexKey]) {
        [device transitionToStateClass:[UserAuthenticatingState class]];
    }
    else if (device.deviceCategory == OHQDeviceCategoryPulseOximeter) {
        if( _WroteCurrentTime == NO){
            _WroteCurrentTime = YES;
            CBService *currentTimeService = [device serviceWithUUID:_currentTimeServiceUUID];
            if(nil != currentTimeService){
                CBCharacteristic *currentTimeCharacteristic = [currentTimeService characteristicWithUUID:_currentTimeCharacteristicUUID];
                [self ohq_device:device writeOfCurrentTimeCharacteristicsForPeripheral:currentTimeCharacteristic];
            }
        }
        if(_ReceivedSpotCheckMeasurement == YES){
            [device transitionToStateClass:[PlxMeasurementRecordAccessControllingState class]];
        }
    }
    else if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] &&
             [device.options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] boolValue]) {
        [device transitionToStateClass:[MeasurementRecordAccessControllingState class]];
    }
    else {
        // do nothing
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_batteryLevelCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                UInt8 batteryLevelValue = 0;
                memcpy(&batteryLevelValue, characteristic.value.bytes, sizeof(batteryLevelValue));
                float actualbatteryLevelValue = batteryLevelValue * 0.01f;
                device.dataObserverBlock(OHQDataTypeBatteryLevel, @(actualbatteryLevelValue));
            }
            else if ([characteristic.UUID isEqual:_currentTimeCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                CurrentTime currentTimeValue = {0};
                memcpy(&currentTimeValue, characteristic.value.bytes, sizeof(currentTimeValue));
                OHQFuncLogI(@"CurrentTime:%04d-%02d-%02d %02d:%02d:%02d DayOfWeek:%d Fractions256:%d AdjustReason:0x%02X",
                            currentTimeValue.dateTime.year, currentTimeValue.dateTime.month, currentTimeValue.dateTime.day,
                            currentTimeValue.dateTime.hours, currentTimeValue.dateTime.minutes, currentTimeValue.dateTime.seconds,
                            currentTimeValue.dayOfWeek, currentTimeValue.fractions256, currentTimeValue.adjustReason);
                
                device.dataObserverBlock(OHQDataTypeCurrentTime, ConvertDateTimeToNSDate(currentTimeValue.dateTime));
                
                if( _WroteCurrentTime == NO){
                    _WroteCurrentTime = YES;
                    CBService *currentTimeService = [device serviceWithUUID:_currentTimeServiceUUID];
                    CBCharacteristic *currentTimeCharacteristic = [currentTimeService characteristicWithUUID:_currentTimeCharacteristicUUID];
                    [self ohq_device:device writeOfCurrentTimeCharacteristicsForPeripheral:currentTimeCharacteristic];
                }
            }
            if ([characteristic.UUID isEqual:_databaseChangeIncrementCharacteristicUUID]) {
                handled = YES;

                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                UInt32 deviceDatabaseChangeIncrementValue = 0;
                memcpy(&deviceDatabaseChangeIncrementValue, characteristic.value.bytes, sizeof(deviceDatabaseChangeIncrementValue));
                
                OHQLogD(@"peripheral(%@) DatabaseChangeIncrement:%u", device.peripheral.identifier, (unsigned int)deviceDatabaseChangeIncrementValue);
            }
            else if ([characteristic.UUID isEqual:_bloodPressureMeasurementCharacteristicUUID]) {
                handled = YES;
                [self ohq_device:device didUpdateValueForBloodPressureMeasurementCharacteristic:characteristic error:error];
            }
            else if ([characteristic.UUID isEqual:_weightMeasurementCharacteristicUUID]) {
                handled = YES;
                [self ohq_device:device didUpdateValueForWeightMeasurementCharacteristic:characteristic error:error];
            }
            else if ([characteristic.UUID isEqual:_bodyCompositionMeasurementCharacteristicUUID]) {
                handled = YES;
                [self ohq_device:device didUpdateValueForBodyCompositionMeasurementCharacteristic:characteristic error:error];
            }
            else if ([characteristic.UUID isEqual:_OHQBodyCompositionMeasurementCharacteristicUUID]) {
                handled = YES;
                [self ohq_device:device didUpdateValueForOHQBodyCompositionMeasurementCharacteristic:characteristic error:error];
            }
            else if ([characteristic.UUID isEqual:_omronCustomPlxSpotCheckMeasurementCharacteristicUUID]) {
                handled = YES;
                _ReceivedSpotCheckMeasurement = YES;
                [self ohq_device:device didUpdateValueForOmronCustomPLXSpotCheckMeasurementCharacteristic:characteristic error:error];
                [device transitionToStateClass:[PlxMeasurementRecordAccessControllingState class]];
            }
            else if ([characteristic.UUID isEqual:_temperatureMeasurementCharacteristicUUID]) {
                handled = YES;
                [self ohq_device:device didUpdateValueForTemperatureMeasurementCharacteristic:characteristic error:error];
            }
            break;
        }
        case StateMachineEventDidWriteValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_currentTimeCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    if (device.deviceCategory == OHQDeviceCategoryPulseOximeter) {
                        OHQFuncLogE(@"error:%@", error);
                        [device abortTransferWithReason:OHQCompletionReasonFailedToRegisterUser];
                        break;
                    }
                    else {
                        // If the slave sends error response in CTS,
                        // you don't retry and should send next request.
                        OHQFuncLogW(@"error:%@", error);
                    }
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForBloodPressureMeasurementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSMutableDictionary *dict = [@{} mutableCopy];
    const void *pt = characteristic.value.bytes;
    
    BloodPressureMeasurementFlags flagsValue;
    memcpy(&flagsValue, pt, sizeof(flagsValue));
    dict[OHQMeasurementRecordBloodPressureUnitKey] = (flagsValue & BloodPressureMeasurementFlagKpaUnit ? @"kPa" : @"mmHg");
    pt += sizeof(flagsValue);
    
    SFloat systolicValue;
    memcpy(&systolicValue, pt, sizeof(systolicValue));
    dict[OHQMeasurementRecordSystolicKey] = @(ConvertSFloatToFloat32(systolicValue));
    pt += sizeof(systolicValue);
    
    SFloat diastolicValue;
    memcpy(&diastolicValue, pt, sizeof(diastolicValue));
    dict[OHQMeasurementRecordDiastolicKey] = @(ConvertSFloatToFloat32(diastolicValue));
    pt += sizeof(diastolicValue);
    
    SFloat meanArterialPressureValue;
    memcpy(&meanArterialPressureValue, pt, sizeof(meanArterialPressureValue));
    dict[OHQMeasurementRecordMeanArterialPressureKey] = @(ConvertSFloatToFloat32(meanArterialPressureValue));
    pt += sizeof(meanArterialPressureValue);
    
    if (flagsValue & BloodPressureMeasurementFlagTimeStampPresent) {
        DateTime timeStampValue;
        memcpy(&timeStampValue, pt, sizeof(timeStampValue));
        if(IsInvalidDateTime(timeStampValue) == NO){
            dict[OHQMeasurementRecordTimeStampKey] = ConvertDateTimeToNSDate(timeStampValue);
        }
        pt += sizeof(timeStampValue);
    }
    
    if (flagsValue & BloodPressureMeasurementFlagPulseRatePresent) {
        SFloat pulseRateValue;
        memcpy(&pulseRateValue, pt, sizeof(pulseRateValue));
        dict[OHQMeasurementRecordPulseRateKey] = @(ConvertSFloatToFloat32(pulseRateValue));
        pt += sizeof(pulseRateValue);
    }
    
    if (flagsValue & BloodPressureMeasurementFlagUserIDPresent) {
        UInt8 userIDValue;
        memcpy(&userIDValue, pt, sizeof(userIDValue));
        dict[OHQMeasurementRecordUserIndexKey] = @(userIDValue);
        pt += sizeof(userIDValue);
    }
    
    if (flagsValue & BloodPressureMeasurementFlagStatusPresent) {
        UInt16 measurementStatusValue;
        memcpy(&measurementStatusValue, pt, sizeof(measurementStatusValue));
        dict[OHQMeasurementRecordBloodPressureMeasurementStatusKey] = @(measurementStatusValue);
    }
    
    [device.temporaryMeasurementRecords addObject:[dict copy]];
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForWeightMeasurementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSMutableDictionary *dict = [@{} mutableCopy];
    const void *pt = characteristic.value.bytes;
    
    WeightMeasurementFlags flagsValue;
    memcpy(&flagsValue, pt, sizeof(flagsValue));
    dict[OHQMeasurementRecordWeightUnitKey] = ((flagsValue & WeightMeasurementFlagImperialUnit) ? @"lb" : @"kg");
    pt += sizeof(flagsValue);
    
    UInt16 weightValue;
    memcpy(&weightValue, pt, sizeof(weightValue));
    float actualWeightValue = weightValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.01f : 0.005f);
    dict[OHQMeasurementRecordWeightKey] = @(actualWeightValue);
    pt += sizeof(weightValue);
    
    NSDate *newDataTimeStamp = nil;
    if (flagsValue & WeightMeasurementFlagTimeStampPresent) {
        DateTime timeStampValue;
        memcpy(&timeStampValue, pt, sizeof(timeStampValue));
        if(IsInvalidDateTime(timeStampValue) == NO){
            newDataTimeStamp = ConvertDateTimeToNSDate(timeStampValue);
            dict[OHQMeasurementRecordTimeStampKey] = newDataTimeStamp;
        }
        pt += sizeof(timeStampValue);
    }
    
    if (flagsValue & WeightMeasurementFlagUserIDPresent) {
        UInt8 userIDValue;
        memcpy(&userIDValue, pt, sizeof(userIDValue));
        dict[OHQMeasurementRecordUserIndexKey] = @(userIDValue);
        pt += sizeof(userIDValue);
    }
    
    if (flagsValue & WeightMeasurementFlagBMIAndHeightPresent) {
        dict[OHQMeasurementRecordHeightUnitKey] = ((flagsValue & WeightMeasurementFlagImperialUnit) ? @"in" : @"cm");
        
        UInt16 BMIValue;
        memcpy(&BMIValue, pt, sizeof(BMIValue));
        float actualBMIValue = BMIValue * 0.1f;
        dict[OHQMeasurementRecordBMIKey] = @(actualBMIValue);
        pt += sizeof(BMIValue);
        
        UInt16 heightValue;
        memcpy(&heightValue, pt, sizeof(heightValue));
        float actualHeightValue = heightValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.1f : 0.001f * 100.0f);
        dict[OHQMeasurementRecordHeightKey] = @(actualHeightValue);
    }
    
    void (^addMeasurementRecord)(NSDictionary *) = ^(NSDictionary *dict) {
        __block NSInteger relatedRecordIndex = NSNotFound;
        __block NSMutableDictionary<OHQMeasurementRecordKey,id> *relatedRecord = nil;
        [device.temporaryMeasurementRecords enumerateObjectsUsingBlock:^(NSDictionary<OHQMeasurementRecordKey,id> * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDate *timeStamp = record[OHQMeasurementRecordTimeStampKey];
            if ([timeStamp isEqualToDate:newDataTimeStamp]) {
                relatedRecord = [record mutableCopy];
                relatedRecordIndex = idx;
                *stop = YES;
            }
        }];
        if (relatedRecordIndex == NSNotFound) {
            [device.temporaryMeasurementRecords addObject:[dict copy]];
        }
        else {
            [relatedRecord addEntriesFromDictionary:dict];
            device.temporaryMeasurementRecords[relatedRecordIndex] = [relatedRecord copy];
        }
    };
    
    addMeasurementRecord(dict);
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForBodyCompositionMeasurementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSMutableDictionary *dict = [@{} mutableCopy];
    const void *pt = characteristic.value.bytes;
    
    BodyCompositionMeasurementFlags flagsValue;
    memcpy(&flagsValue, pt, sizeof(flagsValue));
    if (flagsValue & (BodyCompositionMeasurementFlagMuscleMassPresent |
                      BodyCompositionMeasurementFlagFatFreeMassPresent |
                      BodyCompositionMeasurementFlagSoftLeanMassPresent |
                      BodyCompositionMeasurementFlagBodyWaterMassPresent |
                      BodyCompositionMeasurementFlagWeightPresent)) {
        dict[OHQMeasurementRecordWeightUnitKey] = (flagsValue & WeightMeasurementFlagImperialUnit ? @"lb" : @"kg");
    }
    if (flagsValue & BodyCompositionMeasurementFlagHeightPresent) {
        dict[OHQMeasurementRecordHeightUnitKey] = (flagsValue & WeightMeasurementFlagImperialUnit ? @"in" : @"cm");
    }
    pt += sizeof(flagsValue);
    
    UInt16 bodyFatPercentageValue;
    memcpy(&bodyFatPercentageValue, pt, sizeof(bodyFatPercentageValue));
    float actualBodyFatPercentageValue = bodyFatPercentageValue * 0.1f * 0.01f;
    dict[OHQMeasurementRecordBodyFatPercentageKey] = @(actualBodyFatPercentageValue);
    pt += sizeof(bodyFatPercentageValue);
    
    NSDate *newDataTimeStamp = nil;
    if (flagsValue & BodyCompositionMeasurementFlagTimeStampPresent) {
        DateTime timeStampValue;
        memcpy(&timeStampValue, pt, sizeof(timeStampValue));
        if(IsInvalidDateTime(timeStampValue) == NO){
            newDataTimeStamp = ConvertDateTimeToNSDate(timeStampValue);
            dict[OHQMeasurementRecordTimeStampKey] = newDataTimeStamp;
        }
        pt += sizeof(timeStampValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagUserIDPresent) {
        UInt8 userIDValue;
        memcpy(&userIDValue, pt, sizeof(userIDValue));
        dict[OHQMeasurementRecordUserIndexKey] = @(userIDValue);
        pt += sizeof(userIDValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagBasalMetabolismPresent) {
        UInt16 basalMetabolismValue;
        memcpy(&basalMetabolismValue, pt, sizeof(basalMetabolismValue));
        dict[OHQMeasurementRecordBasalMetabolismKey] = @(basalMetabolismValue);
        pt += sizeof(basalMetabolismValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagMusclePercentagePresent) {
        UInt16 musclePercentageValue;
        memcpy(&musclePercentageValue, pt, sizeof(musclePercentageValue));
        float actualMusclePercentageValue = musclePercentageValue * 0.1f * 0.01f;
        dict[OHQMeasurementRecordMusclePercentageKey] = @(actualMusclePercentageValue);
        pt += sizeof(musclePercentageValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagMuscleMassPresent) {
        UInt16 muscleMassValue;
        memcpy(&muscleMassValue, pt, sizeof(muscleMassValue));
        float actualMuscleMassValue = muscleMassValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.01f : 0.005f);
        dict[OHQMeasurementRecordMuscleMassKey] = @(actualMuscleMassValue);
        pt += sizeof(muscleMassValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagFatFreeMassPresent) {
        UInt16 fatFreeMassValue;
        memcpy(&fatFreeMassValue, pt, sizeof(fatFreeMassValue));
        float actualFatFreeMassValue = fatFreeMassValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.01f : 0.005f);
        dict[OHQMeasurementRecordFatFreeMassKey] = @(actualFatFreeMassValue);
        pt += sizeof(fatFreeMassValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagSoftLeanMassPresent) {
        UInt16 softLeanMassValue;
        memcpy(&softLeanMassValue, pt, sizeof(softLeanMassValue));
        float actualSoftLeanMassValue = softLeanMassValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.01f : 0.005f);
        dict[OHQMeasurementRecordSoftLeanMassKey] = @(actualSoftLeanMassValue);
        pt += sizeof(softLeanMassValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagBodyWaterMassPresent) {
        UInt16 bodyWaterMassValue;
        memcpy(&bodyWaterMassValue, pt, sizeof(bodyWaterMassValue));
        float actualBodyWaterMassValue = bodyWaterMassValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.01f : 0.005f);
        dict[OHQMeasurementRecordBodyWaterMassKey] = @(actualBodyWaterMassValue);
        pt += sizeof(bodyWaterMassValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagImpedancePresent) {
        UInt16 impedanceValue;
        memcpy(&impedanceValue, pt, sizeof(impedanceValue));
        float actualImpedanceValue = impedanceValue * 0.1f;
        dict[OHQMeasurementRecordImpedanceKey] = @(actualImpedanceValue);
        pt += sizeof(impedanceValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagWeightPresent) {
        UInt16 weightValue;
        memcpy(&weightValue, pt, sizeof(weightValue));
        float actualWeightValue = weightValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.01f : 0.005f);
        dict[OHQMeasurementRecordWeightKey] = @(actualWeightValue);
        pt += sizeof(weightValue);
    }
    
    if (flagsValue & BodyCompositionMeasurementFlagHeightPresent) {
        UInt16 heightValue;
        memcpy(&heightValue, pt, sizeof(heightValue));
        float actualHeightValue = heightValue * (flagsValue & WeightMeasurementFlagImperialUnit ? 0.1f : 0.001f * 0.01f);
        dict[OHQMeasurementRecordHeightKey] = @(actualHeightValue);
    }
    
    void (^addMeasurementRecord)(NSDictionary *) = ^(NSDictionary *dict) {
        __block NSInteger relatedRecordIndex = NSNotFound;
        __block NSMutableDictionary<OHQMeasurementRecordKey,id> *relatedRecord = nil;
        [device.temporaryMeasurementRecords enumerateObjectsUsingBlock:^(NSDictionary<OHQMeasurementRecordKey,id> * _Nonnull record, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDate *timeStamp = record[OHQMeasurementRecordTimeStampKey];
            if ([timeStamp isEqualToDate:newDataTimeStamp]) {
                relatedRecord = [record mutableCopy];
                relatedRecordIndex = idx;
                *stop = YES;
            }
        }];
        if (relatedRecordIndex == NSNotFound) {
            [device.temporaryMeasurementRecords addObject:[dict copy]];
        }
        else {
            [relatedRecord addEntriesFromDictionary:dict];
            device.temporaryMeasurementRecords[relatedRecordIndex] = [relatedRecord copy];
        }
    };
    
    if (flagsValue & BodyCompositionMeasurementFlagMultiplePacketMeasurement) {
        NSDictionary<OHQMeasurementRecordKey,id> *previousPartialData = self.pertialMeasurementData;
        if (previousPartialData) {
            [dict addEntriesFromDictionary:previousPartialData];
            self.pertialMeasurementData = nil;
            addMeasurementRecord(dict);
        }
        else {
            self.pertialMeasurementData = [dict copy];
        }
    }
    else {
        addMeasurementRecord(dict);
    }
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForOHQBodyCompositionMeasurementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSMutableDictionary *dict = [@{} mutableCopy];
    const void *pt = characteristic.value.bytes;
    
    UInt24 flagsRawValue;
    memcpy(&flagsRawValue, pt, sizeof(flagsRawValue));
    OmronExtendedBodyCompositionMeasurementFlags flagsValue = ConvertUInt24ToUInt32(flagsRawValue);
    if (flagsValue & (OmronExtendedBodyCompositionMeasurementFlagWeightPresent |
                      OmronExtendedBodyCompositionMeasurementFlagMuscleMassPresent |
                      OmronExtendedBodyCompositionMeasurementFlagFatFreeMassPresent |
                      OmronExtendedBodyCompositionMeasurementFlagSoftLeanMassPresent |
                      OmronExtendedBodyCompositionMeasurementFlagBodyWaterMassPresent)) {
        dict[OHQMeasurementRecordWeightUnitKey] = (flagsValue & OmronExtendedBodyCompositionMeasurementFlagImperialUnit ? @"lb" : @"kg");
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagBMIAndHeightPresent) {
        dict[OHQMeasurementRecordHeightUnitKey] = (flagsValue & OmronExtendedBodyCompositionMeasurementFlagImperialUnit ? @"in" : @"cm");
    }
    pt += sizeof(flagsRawValue);
    
    float (^resolution)(float, float) = ^(float SIResolution, float imperialResolution) {
        return (flagsValue & OmronExtendedBodyCompositionMeasurementFlagImperialUnit ? imperialResolution : SIResolution);
    };
    
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagSequenceNumberPresent) {
        UInt16 sequenceNumberValue;
        memcpy(&sequenceNumberValue, pt, sizeof(sequenceNumberValue));
        dict[OHQMeasurementRecordSequenceNumberKey] = @(sequenceNumberValue);
        pt += sizeof(sequenceNumberValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagWeightPresent) {
        UInt16 weightValue;
        memcpy(&weightValue, pt, sizeof(weightValue));
        float actualWeightValue = weightValue * resolution(0.005f, 0.01f);
        dict[OHQMeasurementRecordWeightKey] = @(actualWeightValue);
        pt += sizeof(weightValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagTimeStampPresent) {
        DateTime timeStampValue;
        memcpy(&timeStampValue, pt, sizeof(timeStampValue));
        if(IsInvalidDateTime(timeStampValue) == NO){
            dict[OHQMeasurementRecordTimeStampKey] = ConvertDateTimeToNSDate(timeStampValue);
        }
        pt += sizeof(timeStampValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagUserIDPresent) {
        UInt8 userIndexValue;
        memcpy(&userIndexValue, pt, sizeof(userIndexValue));
        dict[OHQMeasurementRecordUserIndexKey] = @(userIndexValue);
        pt += sizeof(userIndexValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagBMIAndHeightPresent) {
        UInt16 BMIValue;
        memcpy(&BMIValue, pt, sizeof(BMIValue));
        float actualBMIValue = BMIValue * 0.1f;
        dict[OHQMeasurementRecordBMIKey] = @(actualBMIValue);
        pt += sizeof(BMIValue);
        
        UInt16 heightValue;
        memcpy(&heightValue, pt, sizeof(heightValue));
        float actualHeightValue = heightValue * resolution(0.001f * 100.0f, 0.1f);
        dict[OHQMeasurementRecordHeightKey] = @(actualHeightValue);
        pt += sizeof(heightValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagBodyFatPercentagePresent) {
        UInt16 bodyFatPercentageValue;
        memcpy(&bodyFatPercentageValue, pt, sizeof(bodyFatPercentageValue));
        float actualBodyFatPercentageValue = bodyFatPercentageValue * 0.1f * 0.01f;
        dict[OHQMeasurementRecordBodyFatPercentageKey] = @(actualBodyFatPercentageValue);
        pt += sizeof(bodyFatPercentageValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagBasalMetabolismPresent) {
        UInt16 basalMetabolismValue;
        memcpy(&basalMetabolismValue, pt, sizeof(basalMetabolismValue));
        dict[OHQMeasurementRecordBasalMetabolismKey] = @(basalMetabolismValue);
        pt += sizeof(basalMetabolismValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagMusclePercentagePresent) {
        UInt16 musclePercentageValue;
        memcpy(&musclePercentageValue, pt, sizeof(musclePercentageValue));
        float actualMusclePercentageValue = musclePercentageValue * 0.1f * 0.01f;
        dict[OHQMeasurementRecordMusclePercentageKey] = @(actualMusclePercentageValue);
        pt += sizeof(musclePercentageValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagMuscleMassPresent) {
        UInt16 muscleMassValue;
        memcpy(&muscleMassValue, pt, sizeof(muscleMassValue));
        float actualMuscleMassValue = muscleMassValue * resolution(0.005f, 0.01f);
        dict[OHQMeasurementRecordMuscleMassKey] = @(actualMuscleMassValue);
        pt += sizeof(muscleMassValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagFatFreeMassPresent) {
        UInt16 fatFreeMassValue;
        memcpy(&fatFreeMassValue, pt, sizeof(fatFreeMassValue));
        float actualFatFreeMassValue = fatFreeMassValue * resolution(0.005f, 0.01f);
        dict[OHQMeasurementRecordFatFreeMassKey] = @(actualFatFreeMassValue);
        pt += sizeof(fatFreeMassValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagSoftLeanMassPresent) {
        UInt16 softLeanMassValue;
        memcpy(&softLeanMassValue, pt, sizeof(softLeanMassValue));
        float actualSoftLeanMassValue = softLeanMassValue * resolution(0.005f, 0.01f);
        dict[OHQMeasurementRecordSoftLeanMassKey] = @(actualSoftLeanMassValue);
        pt += sizeof(softLeanMassValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagBodyWaterMassPresent) {
        UInt16 bodyWaterMassValue;
        memcpy(&bodyWaterMassValue, pt, sizeof(bodyWaterMassValue));
        float actualBodyWaterMassValue = bodyWaterMassValue * resolution(0.005f, 0.01f);
        dict[OHQMeasurementRecordBodyWaterMassKey] = @(actualBodyWaterMassValue);
        pt += sizeof(bodyWaterMassValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagImpedancePresent) {
        UInt16 impedanceValue;
        memcpy(&impedanceValue, pt, sizeof(impedanceValue));
        float actualImpedanceValue = impedanceValue * 0.1f;
        dict[OHQMeasurementRecordImpedanceKey] = @(actualImpedanceValue);
        pt += sizeof(impedanceValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagSkeletalMusclePercentagePresent) {
        UInt16 skeletalMusclePercentageValue;
        memcpy(&skeletalMusclePercentageValue, pt, sizeof(skeletalMusclePercentageValue));
        float actualSkeletalMusclePercentageValue = skeletalMusclePercentageValue * 0.1f * 0.01f;
        dict[OHQMeasurementRecordSkeletalMusclePercentageKey] = @(actualSkeletalMusclePercentageValue);
        pt += sizeof(skeletalMusclePercentageValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagVisceralFatLevelPresent) {
        UInt8 visceralFatLevelValue;
        memcpy(&visceralFatLevelValue, pt, sizeof(visceralFatLevelValue));
        float actualVisceralFatLevelValue = visceralFatLevelValue * 0.5f;
        dict[OHQMeasurementRecordVisceralFatLevelKey] = @(actualVisceralFatLevelValue);
        pt += sizeof(visceralFatLevelValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagBodyAgePresent) {
        UInt8 bodyAgeValue;
        memcpy(&bodyAgeValue, pt, sizeof(bodyAgeValue));
        dict[OHQMeasurementRecordBodyAgeKey] = @(bodyAgeValue);
        pt += sizeof(bodyAgeValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagBodyFatPercentageStageEvaluationPresent) {
        UInt8 bodyFatPercentageStageEvaluationValue;
        memcpy(&bodyFatPercentageStageEvaluationValue, pt, sizeof(bodyFatPercentageStageEvaluationValue));
        dict[OHQMeasurementRecordBodyFatPercentageStageEvaluationKey] = @(bodyFatPercentageStageEvaluationValue);
        pt += sizeof(bodyFatPercentageStageEvaluationValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagSkeletalMusclePercentageStageEvaluationPresent) {
        UInt8 skeletalMusclePercentageStageEvaluationValue;
        memcpy(&skeletalMusclePercentageStageEvaluationValue, pt, sizeof(skeletalMusclePercentageStageEvaluationValue));
        dict[OHQMeasurementRecordSkeletalMusclePercentageStageEvaluationKey] = @(skeletalMusclePercentageStageEvaluationValue);
        pt += sizeof(skeletalMusclePercentageStageEvaluationValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagVisceralFatLevelStageEvaluationPresent) {
        UInt8 visceralFatLevelStageEvaluationValue;
        memcpy(&visceralFatLevelStageEvaluationValue, pt, sizeof(visceralFatLevelStageEvaluationValue));
        dict[OHQMeasurementRecordVisceralFatLevelStageEvaluationKey] = @(visceralFatLevelStageEvaluationValue);
    }
    if (flagsValue & OmronExtendedBodyCompositionMeasurementFlagMultiplePacketMeasurement) {
        NSDictionary<OHQMeasurementRecordKey,id> *previousPartialData = self.pertialMeasurementData;
        if (previousPartialData) {
            [dict addEntriesFromDictionary:previousPartialData];
            self.pertialMeasurementData = nil;
            [device.temporaryMeasurementRecords addObject:[dict copy]];
        }
        else {
            self.pertialMeasurementData = [dict copy];
        }
    }
    else {
        [device.temporaryMeasurementRecords addObject:[dict copy]];
    }
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForOmronCustomPLXSpotCheckMeasurementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if ((device.mPlxpIsCheckNumberOfRecords == YES) &&
        (device.mPlxpReortedNumberOfMeasurement  == (device.mPlxpNumberOfRecords + _PlxSpotCheckRecordCount))
    ){
        // Protection processing when data is received after the reception of all data items is completed for the start of transfer.
        //  note:Because measurement data may be notified before disconnection after memory data transfer by pairing.
        return;
    }

    NSMutableDictionary *dict = [@{} mutableCopy];
    const void *pt = characteristic.value.bytes;
    
    PulseOximeterSpotCheckMeasurementFlags flagsValue;
    memcpy(&flagsValue, pt, sizeof(flagsValue));
    pt += sizeof(flagsValue);
    
    SFloat spo2Value;
    memcpy(&spo2Value, pt, sizeof(spo2Value));
    dict[OHQMeasurementRecordPulseOximeterSpo2Key] = @(ConvertSFloatToFloat32(spo2Value));
    pt += sizeof(spo2Value);
    
    SFloat pulseRateValue;
    memcpy(&pulseRateValue, pt, sizeof(pulseRateValue));
    dict[OHQMeasurementRecordPulseRateKey] = @(ConvertSFloatToFloat32(pulseRateValue));
    pt += sizeof(pulseRateValue);
    
    if ((device.mPulseOximeterFeatures & PulseOximeterFeaturesFlagsTimeStampForSpotCheckMeasurements) &&
        (flagsValue & PulseOximeterSpotCheckMeasurementFlagsTimeStamp) &&
        !(flagsValue & PulseOximeterSpotCheckMeasurementFlagsDeviceClockIsNotSet)
    ) {
        DateTime timeStampValue;
        memcpy(&timeStampValue, pt, sizeof(timeStampValue));
        if(IsInvalidDateTime(timeStampValue) == NO){
            dict[OHQMeasurementRecordTimeStampKey] = ConvertDateTimeToNSDate(timeStampValue);
        }
        pt += sizeof(timeStampValue);
    }
    
    [device.temporaryMeasurementRecords addObject:[dict copy]];
    
    device.mPlxpReortedNumberOfMeasurement++;
    if ( (device.mPlxpWaitingSportCheckMeasurement == YES)) {
        if (device.mPlxpReortedNumberOfMeasurement  == (device.mPlxpNumberOfRecords + _PlxSpotCheckRecordCount)) {
            if (device.mPlxpNumberOfRecords != 0 ) {
                void (^writeCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *aCharacteristic, NSData *data) {
                    [device writeValue:data forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
                };

                CBService *omronCustomPulseOximeterService = [device serviceWithUUID:_omronCustomPulseOximeterServiceUUID];
                CBCharacteristic *recordAccessControlPointCharacteristic = [omronCustomPulseOximeterService characteristicWithUUID:_omronCustomPlxRecordAccessControlPointCharacteristicUUID];
                
                if(nil != recordAccessControlPointCharacteristic){

                    RACPCommand request = {0};
                    size_t size = 0;
                    request.opCode = RACPOpCodeDeleteStoredRecords;
                    size += sizeof(request.opCode);
                    request.operator = RACPOperatorAllRecords;
                    size += sizeof(request.operator);
                    NSData *data = [NSData dataWithBytes:&request length:size];
                    writeCharacteristic(recordAccessControlPointCharacteristic, data);
                }else{
                    [device transitionToStateClass:[InactiveState class]];
                }
            } else {
                [device transitionToStateClass:[InactiveState class]];
            }
        }
    }
    
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForTemperatureMeasurementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSMutableDictionary *dict = [@{} mutableCopy];
    const void *pt = characteristic.value.bytes;
    
    //Flags
    TemperatureMeasurementFlags flagsValue;
    memcpy(&flagsValue, pt, sizeof(flagsValue));

    dict[OHQMeasurementRecordBodyTemperatureUnitKey] = ((flagsValue & TemperatureMeasurementFlagImperialUnit) ? @"℉" : @"℃");
////The sample code when using a thermometer displaying Fahrenheit is as follows.
//  dict[OHQMeasurementRecordBodyTemperatureUnitKey] = @"℉";

    pt += sizeof(flagsValue);
    
    //Temperature Value
    UInt32 temperatureValue;
    memcpy(&temperatureValue, pt, sizeof(temperatureValue));
  
    NSString *strTemperature = ConvertUInt32ToString(temperatureValue);
////The sample code when using a thermometer displaying Fahrenheit is as follows.
//  NSString *strTemperature = ConvertUInt32ToString_F(temperatureValue);

    dict[OHQMeasurementRecordBodyTemperatureKey] = strTemperature;
    pt += sizeof(temperatureValue);
    
    //Time Stamp
    if (flagsValue & TemperatureMeasurementFlagTimeStampPresent) {
        DateTime timeStampValue;
        memcpy(&timeStampValue, pt, sizeof(timeStampValue));
        if(IsInvalidDateTime(timeStampValue) == NO){
            dict[OHQMeasurementRecordTimeStampKey] = ConvertDateTimeToNSDate(timeStampValue);
        }
        pt += sizeof(timeStampValue);
    }
    
    //Temperature Type
    if (flagsValue & TemperatureMeasurementFlagTypePresent) {
        UInt8 temperatureTypeValue;
        memcpy(&temperatureTypeValue, pt, sizeof(temperatureTypeValue));
        switch (temperatureTypeValue){
            case 0x01:
                dict[OHQMeasurementRecordBodyTemperatureTypeKey] = @"Underarm";
                break;
            case 0x02:
                dict[OHQMeasurementRecordBodyTemperatureTypeKey] = @"Body (general)";
                break;
            case 0x06:
                dict[OHQMeasurementRecordBodyTemperatureTypeKey] = @"Oral";
                break;
            default:
                dict[OHQMeasurementRecordBodyTemperatureTypeKey] = nil;
                break;
        }
        pt += sizeof(temperatureTypeValue);
    }
    
    [device.temporaryMeasurementRecords addObject:[dict copy]];
}

- (void)ohq_device:(OHQDevice *)device writeOfCurrentTimeCharacteristicsForPeripheral:(CBCharacteristic *)characteristic {
    
    void (^writeCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *aCharacteristic, NSData *data) {
        [device writeValue:data forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
    };
    
    NSDate              *date       = [NSDate date];
    NSCalendar          *calendar   = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents    *components = [calendar components:NSCalendarUnitYear      |
                                                        NSCalendarUnitMonth     |
                                                        NSCalendarUnitDay       |
                                                        NSCalendarUnitHour      |
                                                        NSCalendarUnitMinute    |
                                                        NSCalendarUnitSecond    |
                                                        NSCalendarUnitWeekday
                                               fromDate:date];
    CurrentTime currentTimeValue = {0};
    currentTimeValue.dateTime.year      = components.year;
    currentTimeValue.dateTime.month     = components.month;
    currentTimeValue.dateTime.day       = components.day;
    currentTimeValue.dateTime.hours     = components.hour;
    currentTimeValue.dateTime.minutes   = components.minute;
    currentTimeValue.dateTime.seconds   = components.second;
    currentTimeValue.dayOfWeek          = ((components.weekday == 1) ? 7 : (components.weekday -1));
                                            // weekday:1 to 7 = Sunday to Saturday
                                            // -> dayOfWeek:1 to 7 = Monday to Sunday
    
    OHQFuncLogI(@"CurrentTime:%04d-%02d-%02d %02d:%02d:%02d DayOfWeek:%d Fractions256:%d AdjustReason:0x%02X",
                currentTimeValue.dateTime.year, currentTimeValue.dateTime.month, currentTimeValue.dateTime.day,
                currentTimeValue.dateTime.hours, currentTimeValue.dateTime.minutes, currentTimeValue.dateTime.seconds,
                currentTimeValue.dayOfWeek, currentTimeValue.fractions256, currentTimeValue.adjustReason);
    
    device.dataObserverBlock(OHQDataTypeCurrentTime, ConvertDateTimeToNSDate(currentTimeValue.dateTime));

    NSData *data = [NSData dataWithBytes:&currentTimeValue length:sizeof(CurrentTime)];
    writeCharacteristic(characteristic, data);
    return;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - User Registering State
///---------------------------------------------------------------------------------------

@implementation UserRegisteringState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    CBCharacteristic *userControlPointCharacteristic = [userDataService characteristicWithUUID:_userControlPointCharacteristicUUID];
    
    if (!userControlPointCharacteristic) {
        [device abortTransferWithReason:OHQCompletionReasonFailedToRegisterUser];
        return;
    }
    
    NSNumber *userIndex = device.options[OHQSessionOptionUserIndexKey];
    NSNumber *customConsentCode = device.options[OHQSessionOptionConsentCodeKey];
    UInt16 consentCodeValue = (customConsentCode ? customConsentCode.unsignedShortValue : OHQDefaultConsentCode);
    
    UCPCommand command = {0};
    size_t size = 0;
    NSData *data = nil;
    if (userIndex) {
        // register new user with user index
        command.opCode = UCPOpCodeRegisterNewUserWithUserIndex;
        size += sizeof(command.opCode);
        command.operand.requestWithUserIndex.userIndex = userIndex.unsignedCharValue;
        command.operand.requestWithUserIndex.consentCode = consentCodeValue;
        size += sizeof(command.operand.requestWithUserIndex);
        data = [NSData dataWithBytes:&command length:size];
    }
    else {
        // register new user
        command.opCode = UCPOpCodeRegisterNewUser;
        size += sizeof(command.opCode);
        command.operand.consentCode = consentCodeValue;
        size += sizeof(command.operand.consentCode);
        data = [NSData dataWithBytes:&command length:size];
    }
    
    [device writeValue:data forCharacteristic:userControlPointCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidWriteValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_userControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToRegisterUser];
                    break;
                }
            }
            break;
        }
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_userControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToRegisterUser];
                    break;
                }
                
                UCPCommand response = {0};
                memcpy(&response, characteristic.value.bytes, characteristic.value.length);
                
                if (response.opCode != UCPOpCodeResponseCode) {
                    break;
                }
                switch (response.operand.generalResponse.requestOpCode) {
                    case UCPOpCodeRegisterNewUser: {
                        if (response.operand.responseWithUserIndex.value == UCPResponseValueSuccess) {
                            UInt8 userIndexValue = response.operand.responseWithUserIndex.userIndex;
                            device.registeredUserIndex = @(userIndexValue);
                            device.dataObserverBlock(OHQDataTypeRegisteredUserIndex, @(userIndexValue));
                            
                            if (device.options[OHQSessionOptionUserDataKey]) {
                                [device transitionToStateClass:[UserAuthenticatingState class]];
                            }
                            else {
                                [device transitionToStateClass:[NotificationEnabledState class]];
                            }
                        }
                        else {
                            [device abortTransferWithReason:OHQCompletionReasonFailedToRegisterUser];
                        }
                        break;
                    }
                    case UCPOpCodeRegisterNewUserWithUserIndex: {
                        if (response.operand.generalResponse.value == UCPResponseValueSuccess) {
                            UInt8 userIndexValue = [device.options[OHQSessionOptionUserIndexKey] unsignedCharValue];
                            device.dataObserverBlock(OHQDataTypeRegisteredUserIndex, @(userIndexValue));
                            
                            if (device.options[OHQSessionOptionUserDataKey]) {
                                [device transitionToStateClass:[UserAuthenticatingState class]];
                            }
                            else {
                                [device transitionToStateClass:[NotificationEnabledState class]];
                            }
                        }
                        else {
                            [device abortTransferWithReason:OHQCompletionReasonFailedToRegisterUser];
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - User Authenticating State
///---------------------------------------------------------------------------------------

@interface UserAuthenticatingState ()

@property (strong, nonatomic) NSNumber *authenticatingUserIndex;

@end

@implementation UserAuthenticatingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    CBCharacteristic *userControlPointCharacteristic = [userDataService characteristicWithUUID:_userControlPointCharacteristicUUID];
    
    self.authenticatingUserIndex = device.options[OHQSessionOptionUserIndexKey];
    if (!self.authenticatingUserIndex) {
        self.authenticatingUserIndex = device.registeredUserIndex;
    }
    
    if (userControlPointCharacteristic && self.authenticatingUserIndex) {
        UInt8 userIndexValue = self.authenticatingUserIndex.unsignedCharValue;
        NSNumber *customConsentCode = device.options[OHQSessionOptionConsentCodeKey];
        UInt16 consentCodeValue = (customConsentCode ? customConsentCode.unsignedShortValue : OHQDefaultConsentCode);
        
        // consent
        UCPCommand command = {0};
        size_t size = 0;
        command.opCode = UCPOpCodeConsent;
        size += sizeof(command.opCode);
        command.operand.requestWithUserIndex.userIndex = userIndexValue;
        command.operand.requestWithUserIndex.consentCode = consentCodeValue;
        size += sizeof(command.operand.requestWithUserIndex);
        NSData *data = [NSData dataWithBytes:&command length:size];
        
        [device writeValue:data forCharacteristic:userControlPointCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidWriteValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_userControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToAuthenticateUser];
                    break;
                }
            }
            break;
        }
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_userControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToAuthenticateUser];
                    break;
                }
                
                UCPCommand response = {0};
                memcpy(&response, characteristic.value.bytes, characteristic.value.length);
                
                if (response.opCode != UCPOpCodeResponseCode) {
                    break;
                }
                
                if (response.operand.generalResponse.requestOpCode == UCPOpCodeConsent) {
                    if (response.operand.generalResponse.value == UCPResponseValueSuccess) {
                        // consent success
                        device.dataObserverBlock(OHQDataTypeAuthenticatedUserIndex, self.authenticatingUserIndex);
                        
                        if ([device.options[OHQSessionOptionDeleteUserDataKey] boolValue]) {
                            [device transitionToStateClass:[UserDataDeletingState class]];
                        }
                        else if (device.options[OHQSessionOptionDatabaseChangeIncrementValueKey]) {
                            [device transitionToStateClass:[DatabaseChangeIncrementNotificationWaitingState class]];
                        }
                        else if (device.options[OHQSessionOptionUserDataKey]) {
                            NSDictionary *userData = device.options[OHQSessionOptionUserDataKey];
                            
                            __block NSMutableArray<OHQUserDataKey> *missingUserDataKeys = [@[] mutableCopy];
                            [device.supportedUserDataKeys enumerateObjectsUsingBlock:^(OHQUserDataKey  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (!userData[key]) {
                                    [missingUserDataKeys addObject:key];
                                }
                            }];
                            if (missingUserDataKeys.count) {
                                OHQLogW(@"User data setting failed because incomplete user data was specified. missing:%@", missingUserDataKeys);
                                [device abortTransferWithReason:OHQCompletionReasonFailedToSetUserData];
                                break;
                            }
                            
                            device.latestUserData = [userData mutableCopy];
                            [device transitionToStateClass:[UserDataWritingState class]];
                        }
                        else if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] &&
                                 [device.options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] boolValue]) {
                            [device transitionToStateClass:[MeasurementRecordAccessControllingState class]];
                        }
                        else {
                            [device transitionToStateClass:[NotificationEnabledState class]];
                        }
                    }
                    else {
                        [device abortTransferWithReason:OHQCompletionReasonFailedToAuthenticateUser];
                    }
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - User Data Deleting State
///---------------------------------------------------------------------------------------

@implementation UserDataDeletingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    CBCharacteristic *userControlPointCharacteristic = [userDataService characteristicWithUUID:_userControlPointCharacteristicUUID];
    
    if (userControlPointCharacteristic) {
        // delete user data
        UCPCommand command = {0};
        size_t size = 0;
        command.opCode = UCPOpCodeDeleteUserData;
        size += sizeof(command.opCode);
        NSData *data = [NSData dataWithBytes:&command length:size];
        
        [device writeValue:data forCharacteristic:userControlPointCharacteristic type:CBCharacteristicWriteWithResponse];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidWriteValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_userControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToDeleteUser];
                    break;
                }
            }
            break;
        }
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_userControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToDeleteUser];
                    break;
                }
                
                UCPCommand response = {0};
                memcpy(&response, characteristic.value.bytes, characteristic.value.length);
                
                if (response.opCode != UCPOpCodeResponseCode) {
                    break;
                }
                switch (response.operand.generalResponse.requestOpCode) {
                    case UCPOpCodeDeleteUserData: {
                        if (response.operand.generalResponse.value == UCPResponseValueSuccess) {
                            UInt8 userIndexValue = [device.options[OHQSessionOptionUserIndexKey] unsignedCharValue];
                            device.dataObserverBlock(OHQDataTypeDeletedUserIndex, @(userIndexValue));
                            
                            [device transitionToStateClass:[NotificationEnabledState class]];
                        }
                        else {
                            [device abortTransferWithReason:OHQCompletionReasonFailedToDeleteUser];
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Database Change Increment Notification Waiting State
///---------------------------------------------------------------------------------------

@implementation DatabaseChangeIncrementNotificationWaitingState

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;

    switch (event) {
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_databaseChangeIncrementCharacteristicUUID]) {
                handled = YES;
                
                [self ohq_device:device didUpdateValueForDatabaseChangeIncrementCharacteristic:characteristic error:error];
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForDatabaseChangeIncrementCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        OHQFuncLogE(@"error:%@", error);
        [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
        return;
    }
    
    UInt32 currentDatabaseChangeIncrementValue = 0;
    memcpy(&currentDatabaseChangeIncrementValue, characteristic.value.bytes, sizeof(currentDatabaseChangeIncrementValue));
    
    NSNumber *appDatabaseChangeIncrement = device.options[OHQSessionOptionDatabaseChangeIncrementValueKey];
    UInt32 appDatabaseChangeIncrementValue = appDatabaseChangeIncrement.unsignedIntValue;
    
    if (currentDatabaseChangeIncrementValue > appDatabaseChangeIncrementValue) {
        OHQLogD(@"User Data Synchronization case a : Server(%u) > Client(%u)",
                (unsigned int)currentDatabaseChangeIncrementValue, (unsigned int)appDatabaseChangeIncrementValue);
        device.latestUserData = [@{} mutableCopy];
        device.latestDatabaseChangeIncrement = @(currentDatabaseChangeIncrementValue);
        [device transitionToStateClass:[UserDataReadingState class]];
    }
    else {
        NSDictionary *userData = device.options[OHQSessionOptionUserDataKey];
        __block NSMutableArray<OHQUserDataKey> *missingUserDataKeys = [@[] mutableCopy];
        [device.supportedUserDataKeys enumerateObjectsUsingBlock:^(OHQUserDataKey  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!userData[key]) {
                [missingUserDataKeys addObject:key];
            }
        }];
        
        BOOL userDataUpdateFlag = [device.options[OHQSessionOptionUserDataUpdateFlagKey] boolValue];
        if (currentDatabaseChangeIncrementValue == 0) {
            // User is not initialized
            if (missingUserDataKeys.count) {
                OHQLogW(@"User data setting failed because incomplete user data was specified. missing:%@", missingUserDataKeys);
                [device abortTransferWithReason:OHQCompletionReasonFailedToSetUserData];
                return;
            }
            userDataUpdateFlag = YES;
        }
        
        device.latestUserData = [userData mutableCopy];
        if (currentDatabaseChangeIncrementValue < appDatabaseChangeIncrementValue) {
            OHQLogD(@"User Data Synchronization case b : Server(%u) < Client(%u)",
                    (unsigned int)currentDatabaseChangeIncrementValue, (unsigned int)appDatabaseChangeIncrementValue);
            device.latestDatabaseChangeIncrement = appDatabaseChangeIncrement;
        }
        else if (userDataUpdateFlag) {
            OHQLogD(@"User Data Synchronization case c : Server(%u) == Client(%u) (Updated)",
                    (unsigned int)currentDatabaseChangeIncrementValue, (unsigned int)appDatabaseChangeIncrementValue);
            device.latestDatabaseChangeIncrement = @(currentDatabaseChangeIncrementValue + 1);
        }
        else {
            OHQLogD(@"User Data Synchronization case d : Server(%u) == Client(%u)",
                    (unsigned int)currentDatabaseChangeIncrementValue, (unsigned int)appDatabaseChangeIncrementValue);
            device.latestDatabaseChangeIncrement = @(currentDatabaseChangeIncrementValue);
        }
        
        if (missingUserDataKeys.count) {
            [device transitionToStateClass:[UserDataReadingState class]];
        }
        else {
            [device transitionToStateClass:[UserDataWritingState class]];
        }
    }
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - User Data Reading State
///---------------------------------------------------------------------------------------

@interface UserDataReadingState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;

@end

@implementation UserDataReadingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    self.attributesOfInterest = [@[] mutableCopy];
    void (^readCharacteristic)(CBCharacteristic *) = ^(CBCharacteristic *characteristic) {
        if (characteristic) {
            [self.attributesOfInterest addObject:characteristic];
            dispatch_async(device.queue, ^{
                [device readValueForCharacteristic:characteristic];
            });
        }
    };
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    NSArray<OHQUserDataKey> *latestUserDataKeys = device.latestUserData.allKeys;
    if (![latestUserDataKeys containsObject:OHQUserDataDateOfBirthKey]) {
        CBCharacteristic *dateOfBirthCharacteristic = [userDataService characteristicWithUUID:_dateOfBirthCharacteristicUUID];
        readCharacteristic(dateOfBirthCharacteristic);
    }
    if (![latestUserDataKeys containsObject:OHQUserDataHeightKey]) {
        CBCharacteristic *heightCharacteristic = [userDataService characteristicWithUUID:_heightCharacteristicUUID];
        readCharacteristic(heightCharacteristic);
    }
    if (![latestUserDataKeys containsObject:OHQUserDataGenderKey]) {
        CBCharacteristic *genderCharacteristic = [userDataService characteristicWithUUID:_genderCharacteristicUUID];
        readCharacteristic(genderCharacteristic);
    }
    
    if (!self.attributesOfInterest.count) {
        [device transitionToStateClass:[UserDataWritingState class]];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:characteristic]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                if ([characteristic.UUID isEqual:_dateOfBirthCharacteristicUUID]) {
                    Date dateOfBirthValue = {0};
                    memcpy(&dateOfBirthValue, characteristic.value.bytes, characteristic.value.length);
                    NSDate *dateOfBirth = ConvertDateToNSDate(dateOfBirthValue);
                    device.latestUserData[OHQUserDataDateOfBirthKey] = dateOfBirth;
                }
                else if ([characteristic.UUID isEqual:_heightCharacteristicUUID] && device.heightCharacteristicPresentationFormatData) {
                    CharacteristicPresentationFormat characteristicPresentationFormat = {0};
                    memcpy(&characteristicPresentationFormat, device.heightCharacteristicPresentationFormatData.bytes, sizeof(characteristicPresentationFormat));
                    UInt16 heightValue = 0;
                    memcpy(&heightValue, characteristic.value.bytes, characteristic.value.length);
                    float actualHeightValue = heightValue * pow(10, characteristicPresentationFormat.exponent) * 100;
                    device.latestUserData[OHQUserDataHeightKey] = @(actualHeightValue);
                }
                else if ([characteristic.UUID isEqual:_genderCharacteristicUUID]) {
                    UInt8 genderValue = 0;
                    memcpy(&genderValue, characteristic.value.bytes, characteristic.value.length);
                    OHQGender gender = (genderValue == 0 ? OHQGenderMale : OHQGenderFemale);
                    device.latestUserData[OHQUserDataGenderKey] = gender;
                }
                
                [self.attributesOfInterest removeObject:characteristic];
                if (!self.attributesOfInterest.count) {
                    [device transitionToStateClass:[UserDataWritingState class]];
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - User Data Writing State
///---------------------------------------------------------------------------------------

@interface UserDataWritingState ()

@property (strong, nonatomic) NSMutableArray<CBAttribute *> *attributesOfInterest;
@property (strong, nonatomic) NSMutableDictionary<OHQUserDataKey,id> *updatedUserData;
@property (strong, nonatomic) NSNumber *updatedDatabaseChangeIncrement;

@end

@implementation UserDataWritingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    self.updatedUserData = [@{} mutableCopy];
    self.attributesOfInterest = [@[] mutableCopy];
    void (^writeValueForCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *characteristic, NSData *data) {
        if (characteristic) {
            [self.attributesOfInterest addObject:characteristic];
            dispatch_async(device.queue, ^{
                [device writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            });
        }
    };
    
    CBService *userDataService = [device serviceWithUUID:_userDataServiceUUID];
    
    CBCharacteristic *dateOfBirthCharacteristic = [userDataService characteristicWithUUID:_dateOfBirthCharacteristicUUID];
    NSDate *dateOfBirth = device.latestUserData[OHQUserDataDateOfBirthKey];
    if (dateOfBirthCharacteristic && dateOfBirth) {
        Date dateOfBirthValue = ConvertNSDateToDate(dateOfBirth);
        NSData *data = [NSData dataWithBytes:&dateOfBirthValue length:sizeof(dateOfBirthValue)];
        writeValueForCharacteristic(dateOfBirthCharacteristic, data);
    }
    
    CBCharacteristic *heightCharacteristic = [userDataService characteristicWithUUID:_heightCharacteristicUUID];
    NSNumber *height = device.latestUserData[OHQUserDataHeightKey];
    if (heightCharacteristic && height && device.heightCharacteristicPresentationFormatData) {
        CharacteristicPresentationFormat characteristicPresentationFormat = {0};
        memcpy(&characteristicPresentationFormat, device.heightCharacteristicPresentationFormatData.bytes, sizeof(characteristicPresentationFormat));
        
        float actualHeightValue = height.floatValue; // in centimeters
        float actualHeightValueInMeters = actualHeightValue * 0.01; // in meters
        UInt16 heightValue = (UInt16)(actualHeightValueInMeters * pow(10, -characteristicPresentationFormat.exponent));
        
        NSData *data = [NSData dataWithBytes:&heightValue length:sizeof(heightValue)];
        writeValueForCharacteristic(heightCharacteristic, data);
    }
    
    CBCharacteristic *genderCharacteristic = [userDataService characteristicWithUUID:_genderCharacteristicUUID];
    OHQGender gender = device.latestUserData[OHQUserDataGenderKey];
    if (genderCharacteristic && gender) {
        UInt8 genderValue = ([gender isEqualToString:OHQGenderMale] ? 0 : 1);
        NSData *data = [NSData dataWithBytes:&genderValue length:sizeof(genderValue)];
        writeValueForCharacteristic(genderCharacteristic, data);
    }
    
    CBCharacteristic *databaseChangeIncrementCharacteristic = [userDataService characteristicWithUUID:_databaseChangeIncrementCharacteristicUUID];
    if (databaseChangeIncrementCharacteristic && device.latestDatabaseChangeIncrement) {
        UInt32 latestDatabaseChangeIncrementValue = device.latestDatabaseChangeIncrement.unsignedIntValue;
        NSData *data = [NSData dataWithBytes:&latestDatabaseChangeIncrementValue length:sizeof(latestDatabaseChangeIncrementValue)];
        writeValueForCharacteristic(databaseChangeIncrementCharacteristic, data);
    }
    
    if (!self.attributesOfInterest.count) {
        [self ohq_didWriteAllUserData];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidWriteValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([self.attributesOfInterest containsObject:characteristic]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
                
                if ([characteristic.UUID isEqual:_dateOfBirthCharacteristicUUID]) {
                    self.updatedUserData[OHQUserDataDateOfBirthKey] = device.latestUserData[OHQUserDataDateOfBirthKey];
                }
                else if ([characteristic.UUID isEqual:_heightCharacteristicUUID]) {
                    self.updatedUserData[OHQUserDataHeightKey] = device.latestUserData[OHQUserDataHeightKey];
                }
                else if ([characteristic.UUID isEqual:_genderCharacteristicUUID]) {
                    self.updatedUserData[OHQUserDataGenderKey] = device.latestUserData[OHQUserDataGenderKey];
                }
                else if ([characteristic.UUID isEqual:_databaseChangeIncrementCharacteristicUUID]) {
                    self.updatedDatabaseChangeIncrement = device.latestDatabaseChangeIncrement;
                }
                
                [self.attributesOfInterest removeObject:characteristic];
                if (!self.attributesOfInterest.count) {
                    [self ohq_didWriteAllUserData];
                }
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

- (void)ohq_didWriteAllUserData {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    if (self.updatedUserData.count) {
        device.dataObserverBlock(OHQDataTypeUserData, self.updatedUserData);
    }
    if (self.updatedDatabaseChangeIncrement) {
        device.dataObserverBlock(OHQDataTypeDatabaseChangeIncrement, self.updatedDatabaseChangeIncrement);
    }
    
    if ([device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] &&
        [device.options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] boolValue]) {
        [device transitionToStateClass:[MeasurementRecordAccessControllingState class]];
    }
    else {
        [device transitionToStateClass:[NotificationEnabledState class]];
    }
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - Measurement Record Access Controlling State
///---------------------------------------------------------------------------------------

@implementation MeasurementRecordAccessControllingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    void (^writeCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *characteristic, NSData *data) {
        if (characteristic) {
            [device writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
    };
    
    CBService *omronOptionService = [device serviceWithUUID:_omronOptionServiceUUID];
    CBCharacteristic *recordAccessControlPointCharacteristic = [omronOptionService characteristicWithUUID:_recordAccessControlPointCharacteristicUUID];
    if (recordAccessControlPointCharacteristic && [device.options[OHQSessionOptionReadMeasurementRecordsKey] boolValue] &&
        [device.options[OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey] boolValue]) {
        // report number of stored records
        NSNumber *firstRecordSequenceNumber = device.options[OHQSessionOptionSequenceNumberOfFirstRecordToReadKey];
        RACPCommand command = {0};
        size_t size = 0;
        command.opCode = RACPOpCodeReportNumberOfStoredRecords;
        size += sizeof(command.opCode);
        if (!firstRecordSequenceNumber) {
            command.operator = RACPOperatorAllRecords;
            size += sizeof(command.operator);
        } else {
            command.operator = RACPOperatorGreaterThanOrEqualTo;
            size += sizeof(command.operator);
            command.operand.filterCriteria.filterType = RACPFilterTypeSequenceNumber;
            command.operand.filterCriteria.value = firstRecordSequenceNumber.unsignedShortValue;
            size += sizeof(command.operand.filterCriteria);
        }
        NSData *data = [NSData dataWithBytes:&command length:size];
        writeCharacteristic(recordAccessControlPointCharacteristic, data);
    }
    else {
        [device transitionToStateClass:[NotificationEnabledState class]];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidWriteValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_recordAccessControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
            }
            break;
        }
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_recordAccessControlPointCharacteristicUUID]) {
                handled = YES;
                [self ohq_device:device didUpdateValueForRecordAccessControlPointCharacteristic:characteristic error:error];
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForRecordAccessControlPointCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    RACPCommand response = {0};
    memcpy(&response, characteristic.value.bytes, characteristic.value.length);
    
    void (^writeCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *aCharacteristic, NSData *data) {
        [device writeValue:data forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
    };
    
    switch (response.opCode) {
        case RACPOpCodeNumberOfStoredRecordsResponse: {
            RACPCommand request = {0};
            size_t size = 0;
            if (response.operand.numberOfRecords > 0) {
                NSNumber *firstRecordSequenceNumber = device.options[OHQSessionOptionSequenceNumberOfFirstRecordToReadKey];
                request.opCode = RACPOpCodeReportStoredRecords;
                size += sizeof(request.opCode);
                if (!firstRecordSequenceNumber) {
                    request.operator = RACPOperatorAllRecords;
                    size += sizeof(request.operator);
                }
                else {
                    request.operator = RACPOperatorGreaterThanOrEqualTo;
                    size += sizeof(request.operator);
                    request.operand.filterCriteria.filterType = RACPFilterTypeSequenceNumber;
                    request.operand.filterCriteria.value = firstRecordSequenceNumber.unsignedShortValue;
                    size += sizeof(request.operand.filterCriteria);
                }
            }
            else {
                request.opCode = RACPOpCodeReportSequenceNumberOfLatestRecord;
                size += sizeof(request.opCode);
                request.operator = RACPOperatorNull;
                size += sizeof(request.operator);
            }
            NSData *data = [NSData dataWithBytes:&request length:size];
            writeCharacteristic(characteristic, data);
            break;
        }
        case RACPOpCodeResponseCode: {
            if (response.operand.generalResponse.requestOpCode == RACPOpCodeReportStoredRecords && response.operand.generalResponse.value == RACPResponseValueSuccess) {
                RACPCommand request;
                size_t size = 0;
                request.opCode = RACPOpCodeReportSequenceNumberOfLatestRecord;
                size += sizeof(request.opCode);
                request.operator = RACPOperatorNull;
                size += sizeof(request.operator);
                NSData *data = [NSData dataWithBytes:&request length:size];
                writeCharacteristic(characteristic, data);
            }
            break;
        }
        case RACPOpCodeSequenceNumberOfLatestRecordResponse: {
            if (response.operand.sequenceNumber != RACPInvalidSequenceNumber) {
                device.dataObserverBlock(OHQDataTypeSequenceNumberOfLatestRecord, @(response.operand.sequenceNumber));
                [device transitionToStateClass:[NotificationEnabledState class]];
            }
            break;
        }
        default:
            break;
    }
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - PXL Measurement Record Access Controlling State
///---------------------------------------------------------------------------------------

@implementation PlxMeasurementRecordAccessControllingState

- (void)didEnter {
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    void (^writeCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *aCharacteristic, NSData *data) {
        [device writeValue:data forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
    };
    
    CBService *omronCustomPulseOximeterService = [device serviceWithUUID:_omronCustomPulseOximeterServiceUUID];
    CBCharacteristic *recordAccessControlPointCharacteristic = [omronCustomPulseOximeterService characteristicWithUUID:_omronCustomPlxRecordAccessControlPointCharacteristicUUID];
    if(nil != recordAccessControlPointCharacteristic){
        // report number of stored records
        RACPCommand command = {0};
        size_t size = 0;
        command.opCode = RACPOpCodeReportNumberOfStoredRecords;
        size += sizeof(command.opCode);
        command.operator = RACPOperatorAllRecords;
        size += sizeof(command.operator);
        NSData *data = [NSData dataWithBytes:&command length:size];
        writeCharacteristic(recordAccessControlPointCharacteristic, data);
    }else{
        [device transitionToStateClass:[InactiveState class]];
    }
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    BOOL handled = NO;
    OHQDevice *device = (OHQDevice *)self.stateMachine;
    
    switch (event) {
        case StateMachineEventDidWriteValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_omronCustomPlxRecordAccessControlPointCharacteristicUUID]) {
                handled = YES;
                
                if (error) {
                    OHQFuncLogE(@"error:%@", error);
                    [device abortTransferWithReason:OHQCompletionReasonFailedToTransfer];
                    break;
                }
            }
            break;
        }
        case StateMachineEventDidUpdateValueForCharacteristic: {
            CBCharacteristic *characteristic = object[EventAttachedDataCharacteristicKey];
            NSError *error = object[EventAttachedDataErrorKey];
            
            if ([characteristic.UUID isEqual:_omronCustomPlxRecordAccessControlPointCharacteristicUUID]) {
                handled = YES;
                [self ohq_device:device didUpdateValueForPLXRecordAccessControlPointCharacteristic:characteristic error:error];
            }
            break;
        }
        default:
            break;
    }
    
    return handled;
}

- (void)ohq_device:(OHQDevice *)device didUpdateValueForPLXRecordAccessControlPointCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    RACPCommand response = {0};
    memcpy(&response, characteristic.value.bytes, characteristic.value.length);
    
    void (^writeCharacteristic)(CBCharacteristic *, NSData *) = ^(CBCharacteristic *aCharacteristic, NSData *data) {
        [device writeValue:data forCharacteristic:aCharacteristic type:CBCharacteristicWriteWithResponse];
    };
    
    switch (response.opCode) {
        case RACPOpCodeNumberOfStoredRecordsResponse: {
            device.mPlxpNumberOfRecords = response.operand.numberOfRecords;
            device.mPlxpIsCheckNumberOfRecords = YES;
            if (response.operand.numberOfRecords > 0) {
                RACPCommand request = {0};
                size_t size = 0;
                request.opCode = RACPOpCodeReportStoredRecords;
                size += sizeof(request.opCode);
                request.operator = RACPOperatorAllRecords;
                size += sizeof(request.operator);
                NSData *data = [NSData dataWithBytes:&request length:size];
                writeCharacteristic(characteristic, data);
            }
            else if((device.mPlxpReortedNumberOfMeasurement == _PlxSpotCheckRecordCount)) {
                [device transitionToStateClass:[InactiveState class]];
            }
            break;
        }
        case RACPOpCodeResponseCode: {
            if (response.operand.generalResponse.requestOpCode == RACPOpCodeReportStoredRecords && response.operand.generalResponse.value == RACPResponseValueSuccess) {
                if (device.mPlxpReortedNumberOfMeasurement  == (device.mPlxpNumberOfRecords + _PlxSpotCheckRecordCount)) {
                    RACPCommand request = {0};
                    size_t size = 0;
                    request.opCode = RACPOpCodeDeleteStoredRecords;
                    size += sizeof(request.opCode);
                    request.operator = RACPOperatorAllRecords;
                    size += sizeof(request.operator);
                    NSData *data = [NSData dataWithBytes:&request length:size];
                    writeCharacteristic(characteristic, data);
                } else {
                    //Todo:Add comments
                    device.mPlxpWaitingSportCheckMeasurement = YES;
                }
            }
            else if (response.operand.generalResponse.requestOpCode == RACPOpCodeDeleteStoredRecords && response.operand.generalResponse.value == RACPResponseValueSuccess) {
                [device transitionToStateClass:[InactiveState class]];
            }
            break;
        }
        default:
            break;
    }
}

@end

