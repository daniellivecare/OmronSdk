//
//  BSOMeasurementRecordViewController.h
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQReferenceCode.h"
#import <UIKit/UIKit.h>

@interface BSOMeasurementRecordViewController : UIViewController

@property (copy, nonatomic) NSDictionary<OHQMeasurementRecordKey,id> *measurementRecord;

@end
