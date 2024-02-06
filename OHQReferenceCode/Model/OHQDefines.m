//
//  OHQDefines.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQDefines.h"

// Convert OHQDeviceManagerState value to text
NSString * OHQDeviceManagerStateDescription(OHQDeviceManagerState value) {
    NSString *ret = nil;
    switch (value) {
        case OHQDeviceManagerStateUnknown:      ret = @"Unknown";      break;
        case OHQDeviceManagerStateUnsupported:  ret = @"Unsupported";  break;
        case OHQDeviceManagerStateUnauthorized: ret = @"Unauthorized"; break;
        case OHQDeviceManagerStatePoweredOff:   ret = @"Powered Off";   break;
        case OHQDeviceManagerStatePoweredOn:    ret = @"Powered On";    break;
        default: break;
    }
    return ret;
}

// Convert OHQDeviceManagerAuthorization value to text
NSString * OHQDeviceManagerAuthorizationDescription(OHQDeviceManagerAuthorization value) {
    NSString *ret = nil;
    switch (value) {
        case OHQDeviceManagerAuthorizationDenied:         ret = @"Denied";          break;
        case OHQDeviceManagerAuthorizationAllowed:        ret = @"Allowed";         break;
        case OHQDeviceManagerAuthorizationNotDetermined:  ret = @"Not Determined";  break;
        case OHQDeviceManagerAuthorizationRestricted:     ret = @"Restricted";      break;
        default: break;
    }
    return ret;
}

// Convert OHQConnectionState value to text
NSString * OHQConnectionStateDescription(OHQConnectionState value) {
    NSString *ret = nil;
    switch (value) {
        case OHQConnectionStateDisconnected:  ret = @"Disconnected";  break;
        case OHQConnectionStateConnecting:    ret = @"Connecting";    break;
        case OHQConnectionStateConnected:     ret = @"Connected";     break;
        case OHQConnectionStateDisconnecting: ret = @"Disconnecting"; break;
        default: break;
    }
    return ret;
}

// Convert OHQCompletionReason value to text
NSString * OHQCompletionReasonDescription(OHQCompletionReason value) {
    NSString *ret = @"Unknown";
    switch (value) {
        case OHQCompletionReasonDisconnected:             ret = @"Disconnected";                break;
        case OHQCompletionReasonCanceled:                 ret = @"Canceled";                    break;
        case OHQCompletionReasonPoweredOff:               ret = @"Powered Off";                 break;
        case OHQCompletionReasonBusy:                     ret = @"Busy";                        break;
        case OHQCompletionReasonInvalidDeviceIdentifier:  ret = @"Invalid Device Identifier";   break;
        case OHQCompletionReasonFailedToConnect:          ret = @"Failed to Connect";           break;
        case OHQCompletionReasonFailedToTransfer:         ret = @"Failed to Transfer";          break;
        case OHQCompletionReasonFailedToRegisterUser:     ret = @"Failed to Register User";     break;
        case OHQCompletionReasonFailedToAuthenticateUser: ret = @"Failed to Authenticate User"; break;
        case OHQCompletionReasonFailedToDeleteUser:       ret = @"Failed to Delete User";       break;
        case OHQCompletionReasonFailedToSetUserData:      ret = @"Failed to Set User Data";     break;
        case OHQCompletionReasonOperationNotSupported:    ret = @"Operation not Supported";     break;
        case OHQCompletionReasonConnectionTimedOut:       ret = @"Connection Timed Out";        break;
        default: break;
    }
    return ret;
}

// Convert OHQDeviceCategory value to text
NSString * OHQDeviceCategoryDescription(OHQDeviceCategory value) {
    NSString *ret = @"Unknown";
    switch (value) {
        case OHQDeviceCategoryBloodPressureMonitor:     ret = @"Blood Pressure Monitor";        break;
        case OHQDeviceCategoryWeightScale:              ret = @"Weight Scale";                  break;
        case OHQDeviceCategoryBodyCompositionMonitor:   ret = @"Body Composition Monitor";      break;
        case OHQDeviceCategoryPulseOximeter:            ret = @"Pulse Oximeter";                break;
        case OHQDeviceCategoryHealthThermometer:        ret = @"Health Thermometer";            break;
        case OHQDeviceCategoryAny:                      ret = @"Any";                           break;
        default: break;
    }
    return ret;
}

// OHQDataType description
NSString * OHQDataTypeDescription(OHQDataType value) {
    NSString *ret = nil;
    switch (value) {
        case OHQDataTypeCurrentTime:                  ret = @"Current Time";                     break;
        case OHQDataTypeBatteryLevel:                 ret = @"Battery Level";                    break;
        case OHQDataTypeModelName:                    ret = @"Model Name";                       break;
        case OHQDataTypeDeviceCategory:               ret = @"Device Category";                  break;
        case OHQDataTypeRegisteredUserIndex:          ret = @"Registered User Index";            break;
        case OHQDataTypeAuthenticatedUserIndex:       ret = @"Authenticated User Index";         break;
        case OHQDataTypeDeletedUserIndex:             ret = @"Deleted User Index";               break;
        case OHQDataTypeUserData:                     ret = @"User Data";                        break;
        case OHQDataTypeDatabaseChangeIncrement:      ret = @"Database Change Increment";        break;
        case OHQDataTypeSequenceNumberOfLatestRecord: ret = @"Sequence Number of Latest Record"; break;
        case OHQDataTypeMeasurementRecords:           ret = @"Measurement Records";              break;
        default: break;
    }
    return ret;
}

NSString * OHQBloodPressureMeasurementStatusDescription(OHQBloodPressureMeasurementStatus value) {
    NSMutableArray<NSString *> *array = [@[] mutableCopy];
    if (value & OHQBloodPressureMeasurementStatusBodyMovementDetected) {
        [array addObject:@"Body Movement Detected"];
    }
    if (value & OHQBloodPressureMeasurementStatusCuffTooLoose) {
        [array addObject:@"Cuff Too Loose"];
    }
    if (value & OHQBloodPressureMeasurementStatusIrregularPulseDetected) {
        [array addObject:@"Irregular Pulse Detected"];
    }
    if (value & OHQBloodPressureMeasurementStatusPulseRateTooHigher) {
        [array addObject:@"Pulse Rate Too Higher"];
    }
    if (value & OHQBloodPressureMeasurementStatusPulseRateTooLower) {
        [array addObject:@"Pulse Rate Too Lower"];
    }
    if (value & OHQBloodPressureMeasurementStatusImproperMeasurementPosition) {
        [array addObject:@"Improper Measurement Position"];
    }
    NSString *ret = nil;
    switch (array.count) {
        case 0: ret = @"None"; break;
        case 1: ret = array.firstObject; break;
        default: ret = array.description; break;
    }
    return ret;
}

// Default Consent Code
const UInt16 OHQDefaultConsentCode = 0x020E;

// Omron Healthcare Company Identifier
const UInt16 OHQOmronHealthcareCompanyIdentifier = 0x020E;

// Device Info key
OHQDeviceInfoKey const OHQDeviceInfoIdentifierKey = @"identifier";
OHQDeviceInfoKey const OHQDeviceInfoAdvertisementDataKey = @"advertisementData";
OHQDeviceInfoKey const OHQDeviceInfoRSSIKey = @"RSSI";
OHQDeviceInfoKey const OHQDeviceInfoModelNameKey = @"modelName";
OHQDeviceInfoKey const OHQDeviceInfoCategoryKey = @"category";

// Advertisement Data key
OHQAdvertisementDataKey const OHQAdvertisementDataLocalNameKey = @"localName";
OHQAdvertisementDataKey const OHQAdvertisementDataIsConnectable = @"isConnectable";
OHQAdvertisementDataKey const OHQAdvertisementDataServiceUUIDsKey = @"serviceUUIDs";
OHQAdvertisementDataKey const OHQAdvertisementDataServiceDataKey = @"serviceData";
OHQAdvertisementDataKey const OHQAdvertisementDataOverflowServiceUUIDsKey = @"overflowServiceUUIDs";
OHQAdvertisementDataKey const OHQAdvertisementDataSolicitedServiceUUIDsKey = @"solicitedServiceUUIDs";
OHQAdvertisementDataKey const OHQAdvertisementDataTxPowerLevelKey = @"txPowerLevel";
OHQAdvertisementDataKey const OHQAdvertisementDataManufacturerDataKey = @"manufacturerData";

// Manufacturer Data key
OHQManufacturerDataKey const OHQManufacturerDataCompanyIdentifierKey = @"companyIdentifier";
OHQManufacturerDataKey const OHQManufacturerDataCompanyIdentifierDescriptionKey = @"companyIdentifierDescription";
OHQManufacturerDataKey const OHQManufacturerDataNumberOfUserKey = @"numberOfUser";
OHQManufacturerDataKey const OHQManufacturerDataIsPairingMode = @"isPairingMode";
OHQManufacturerDataKey const OHQManufacturerDataTimeNotConfigured = @"timeNotConfigured";
OHQManufacturerDataKey const OHQManufacturerDataRecordInfoArrayKey = @"recordInfoArray";
OHQManufacturerDataKey const OHQManufacturerDataIsBluetoothStandardMode = @"isBluetoothStandardMode";

// Record info key
OHQRecordInfoKey const OHQRecordInfoUserIndexKey = @"userIndex";
OHQRecordInfoKey const OHQRecordInfoLastSequenceNumberKey = @"lastSequenceNumber";
OHQRecordInfoKey const OHQRecordInfoNumberOfRecordsKey = @"numberOfRecords";

// Session Option key
OHQSessionOptionKey const OHQSessionOptionReadMeasurementRecordsKey = @"optReadMeasurementRecords";
OHQSessionOptionKey const OHQSessionOptionAllowControlOfReadingPositionToMeasurementRecordsKey = @"optAllowControlOfReadingPositionToMeasurementRecords";
OHQSessionOptionKey const OHQSessionOptionSequenceNumberOfFirstRecordToReadKey = @"optSequenceNumberOfFirstRecordToRead";
OHQSessionOptionKey const OHQSessionOptionAllowAccessToOmronExtendedMeasurementRecordsKey = @"optAccessToOmronExtendedMeasurementRecords";
OHQSessionOptionKey const OHQSessionOptionRegisterNewUserKey = @"optRegisterNewUser";
OHQSessionOptionKey const OHQSessionOptionDeleteUserDataKey = @"optDeleteUserData";
OHQSessionOptionKey const OHQSessionOptionConsentCodeKey = @"optConsentCode";
OHQSessionOptionKey const OHQSessionOptionUserIndexKey = @"optUserIndex";
OHQSessionOptionKey const OHQSessionOptionUserDataKey = @"optUserData";
OHQSessionOptionKey const OHQSessionOptionDatabaseChangeIncrementValueKey = @"optDatabaseChangeIncrementValue";
OHQSessionOptionKey const OHQSessionOptionUserDataUpdateFlagKey = @"optUserDataUpdateFlag";
OHQSessionOptionKey const OHQSessionOptionConnectionWaitTimeKey = @"optConnectionWaitTime";

// User Data key
OHQUserDataKey const OHQUserDataDateOfBirthKey = @"dateOfBirth";
OHQUserDataKey const OHQUserDataHeightKey = @"height";
OHQUserDataKey const OHQUserDataGenderKey = @"gender";

// Gender
OHQGender const OHQGenderMale = @"male";
OHQGender const OHQGenderFemale = @"female";

/** Measurement Record key */
OHQMeasurementRecordKey const OHQMeasurementRecordUserIndexKey = @"userIndex";
OHQMeasurementRecordKey const OHQMeasurementRecordTimeStampKey = @"timeStamp";
OHQMeasurementRecordKey const OHQMeasurementRecordSequenceNumberKey = @"sequenceNumber";
OHQMeasurementRecordKey const OHQMeasurementRecordBloodPressureUnitKey = @"bloodPressureUnit";
OHQMeasurementRecordKey const OHQMeasurementRecordSystolicKey = @"systolic";
OHQMeasurementRecordKey const OHQMeasurementRecordDiastolicKey = @"diastolic";
OHQMeasurementRecordKey const OHQMeasurementRecordMeanArterialPressureKey = @"meanArterialPressure";
OHQMeasurementRecordKey const OHQMeasurementRecordPulseRateKey = @"pulseRate";
OHQMeasurementRecordKey const OHQMeasurementRecordBloodPressureMeasurementStatusKey = @"bloodPressureMeasurementStatus";
OHQMeasurementRecordKey const OHQMeasurementRecordWeightUnitKey = @"weightUnit";
OHQMeasurementRecordKey const OHQMeasurementRecordHeightUnitKey = @"heightUnit";
OHQMeasurementRecordKey const OHQMeasurementRecordWeightKey = @"weight";
OHQMeasurementRecordKey const OHQMeasurementRecordHeightKey = @"height";
OHQMeasurementRecordKey const OHQMeasurementRecordBMIKey = @"BMI";
OHQMeasurementRecordKey const OHQMeasurementRecordBodyFatPercentageKey = @"bodyFatPercentage";
OHQMeasurementRecordKey const OHQMeasurementRecordBasalMetabolismKey = @"basalMetabolism";
OHQMeasurementRecordKey const OHQMeasurementRecordMusclePercentageKey = @"musclePercentage";
OHQMeasurementRecordKey const OHQMeasurementRecordMuscleMassKey = @"muscleMass";
OHQMeasurementRecordKey const OHQMeasurementRecordFatFreeMassKey = @"fatFreeMass";
OHQMeasurementRecordKey const OHQMeasurementRecordSoftLeanMassKey = @"softLeanMass";
OHQMeasurementRecordKey const OHQMeasurementRecordBodyWaterMassKey = @"bodyWaterMass";
OHQMeasurementRecordKey const OHQMeasurementRecordImpedanceKey = @"impedance";
OHQMeasurementRecordKey const OHQMeasurementRecordSkeletalMusclePercentageKey = @"skeletalMusclePercentage";
OHQMeasurementRecordKey const OHQMeasurementRecordVisceralFatLevelKey = @"visceralFatLevel";
OHQMeasurementRecordKey const OHQMeasurementRecordBodyAgeKey = @"bodyAge";
OHQMeasurementRecordKey const OHQMeasurementRecordBodyFatPercentageStageEvaluationKey = @"bodyFatPercentageStageEvaluation";
OHQMeasurementRecordKey const OHQMeasurementRecordSkeletalMusclePercentageStageEvaluationKey = @"skeletalMusclePercentageStageEvaluation";
OHQMeasurementRecordKey const OHQMeasurementRecordVisceralFatLevelStageEvaluationKey = @"visceralFatLevelStageEvaluation";
OHQMeasurementRecordKey const OHQMeasurementRecordPulseOximeterSpo2Key = @"pulseOximeterSpo2Key";
OHQMeasurementRecordKey const OHQMeasurementRecordBodyTemperatureKey = @"bodyTemperatureKey";
OHQMeasurementRecordKey const OHQMeasurementRecordBodyTemperatureUnitKey = @"bodyTemperatureUnitKey";
OHQMeasurementRecordKey const OHQMeasurementRecordBodyTemperatureTypeKey = @"bodyTemperatureTypeKey";
