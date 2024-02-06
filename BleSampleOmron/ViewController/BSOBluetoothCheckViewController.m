//
//  BSOBluetoothCheckViewController.m
//  BleSampleOmron
//
//  Created by オムロンヘルスケア on 2020/11/20.
//  Copyright © 2020 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOBluetoothCheckViewController.h"

@interface BSOBluetoothCheckViewController()
@end
@implementation BSOBluetoothCheckViewController

- (id)init
{
    self = [super init];
    return self;
}

- (void)bluetoothPermissionCheck:(UIViewController*)viewController
             settingsActionBlock:(AlertActionBlock)settingsActionBlock
                 skipActionBlock:(AlertActionBlock)skipActionBlock{
    UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings"
                                                       style:UIAlertActionStyleDefault
                                                     handler:settingsActionBlock];
    
    UIAlertAction *skip = [UIAlertAction actionWithTitle:@"Skip"
                                                   style:UIAlertActionStyleDefault
                                                 handler:skipActionBlock];
    
    [self showDialog:viewController
             message:@"You must give \"Ble sample Omron\" access to Bluetooth to sync your data."
      settingsAction:settings
          skipAction:skip];
}


- (void)bluetoothStateCheck:(UIViewController*)viewController
        settingsActionBlock:(AlertActionBlock)settingsActionBlock
            skipActionBlock:(AlertActionBlock)skipActionBlock{
    UIAlertAction *settings = [UIAlertAction actionWithTitle:@"Settings"
                                                       style:UIAlertActionStyleDefault
                                                     handler:settingsActionBlock];
    
    UIAlertAction *skip = [UIAlertAction actionWithTitle:@"Skip"
                                                   style:UIAlertActionStyleDefault
                                                 handler:skipActionBlock];
    
    [self showDialog:viewController
             message:@"Please turn on Bluetooth."
      settingsAction:settings
          skipAction:skip];
}


-(void)showDialog:(UIViewController*)viewController
          message:(NSString*)message
   settingsAction:(UIAlertAction*)settingsAction
       skipAction:(UIAlertAction*)skipAction{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:settingsAction];
    [alert addAction:skipAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}
@end
