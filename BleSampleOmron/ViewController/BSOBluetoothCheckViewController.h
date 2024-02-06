//
//  BSOBluetoothCheckView.h
//  BleSampleOmron
//
//  Created by オムロンヘルスケア on 2020/11/20.
//  Copyright © 2020 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQReferenceCode.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <UIKit/UIKit.h>
typedef void(^AlertActionBlock)(UIAlertAction *act);
@interface BSOBluetoothCheckViewController : UIViewController

- (void)bluetoothPermissionCheck:(UIViewController*)viewController
             settingsActionBlock:(AlertActionBlock)settingsActionBlock
                 skipActionBlock:(AlertActionBlock)skipActionBlock;

- (void)bluetoothStateCheck:(UIViewController*)viewController
        settingsActionBlock:(AlertActionBlock)settingsActionBlock
            skipActionBlock:(AlertActionBlock)skipActionBlock;

@end
