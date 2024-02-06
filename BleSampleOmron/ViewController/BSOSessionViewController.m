//
//  BSOSessionViewController.m
//  BleSampleOmron
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "BSOSessionViewController.h"
#import "BSODefines.h"
#import "BSOSessionData.h"
#import "BSOPersistentContainer.h"
#import "BSOUserEntity+CoreDataClass.h"
#import "BSODeviceEntity+CoreDataClass.h"
#import "NSDate+BleSampleOmron.h"
#import "BSOBluetoothCheckViewController.h"

typedef NS_ENUM(NSUInteger, SessionViewState) {
    SessionViewStateInitial,
    SessionViewStateWaitingForBluetoothToTurnOn,
    SessionViewStateConnecting,
    SessionViewStateProcessing,
    SessionViewStateCanceled,
    SessionViewStateTimedOut,
    SessionViewStateFinished,
};
typedef void(^AlertActionBlock)(UIAlertAction *act);

static void * const KVOContext = (void *)&KVOContext;

@interface BSOSessionViewController ()

@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressIndicator;
@property (weak, nonatomic) IBOutlet UILabel *completionLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (strong, nonatomic) BSOSessionData *data;
@property (assign, nonatomic) SessionViewState state;
@property (strong, nonatomic) BSOBluetoothCheckViewController *bleCheck;
@property (copy, nonatomic) dispatch_block_t stopScanCompletionBlock;

@end

@implementation BSOSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bleCheck = [BSOBluetoothCheckViewController new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    _state = SessionViewStateInitial;
    _stopScanCompletionBlock = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[OHQDeviceManager sharedManager] addObserver:self forKeyPath:@"state"
                                          options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
                                          context:KVOContext];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self bso_stopScanWithBlock:nil];
    [[OHQDeviceManager sharedManager] removeObserver:self forKeyPath:@"state"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != KVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([object isEqual:[OHQDeviceManager sharedManager]] && [keyPath isEqualToString:@"state"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkBluetooth];
        });
    }
}

-(void)checkBluetooth{
    if ([OHQDeviceManager sharedManager].state == OHQDeviceManagerStatePoweredOn) {
        // Bluetooth ON
        if (self.state == SessionViewStateInitial || self.state == SessionViewStateWaitingForBluetoothToTurnOn) {
            [self bso_scanForDevices];    // Start scanning to confirm advertisement
            [self bso_startSession];
            return;
        }
    }
    else {
        // Bluetooth OFF
        if (self.state == SessionViewStateInitial) {
            self.state = SessionViewStateWaitingForBluetoothToTurnOn;
        }
    }
    
    // Bluetooth permission check
    if (@available(iOS 13.1,*)) {
        if ([CBManager authorization] == CBManagerAuthorizationDenied){
            // permission denied
            AlertActionBlock permissionSettingsActionBlock = ^(UIAlertAction *action){
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL: url];
            };
            AlertActionBlock permissionSkipActionBlock = ^(UIAlertAction *action){
                [self bso_startSession];
            };
            [_bleCheck bluetoothPermissionCheck:self
                            settingsActionBlock:permissionSettingsActionBlock
                                skipActionBlock:permissionSkipActionBlock];
        }
    }
    
    // Bluetooth ON/OFF check
    if ([OHQDeviceManager sharedManager].state != OHQDeviceManagerStatePoweredOn) {
        // Bluetooth OFF
        AlertActionBlock bluetoothSettingsAction = ^(UIAlertAction *action){
            NSString *settingsUrl = @"App-prefs:Bluetooth";
            if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl]
                                                   options:@{}
                                         completionHandler:^(BOOL success) {
                    NSLog(@"URL opened");
                }];
            }
        };
        AlertActionBlock bluetoothSkipAction = ^(UIAlertAction *action){
            [self bso_startSession];
        };
        
        [_bleCheck bluetoothStateCheck:self
                   settingsActionBlock:bluetoothSettingsAction
                       skipActionBlock:bluetoothSkipAction];
    }
    
}

- (void)setState:(SessionViewState)state {
    if (_state != state) {
        _state = state;
        
        switch (_state) {
            case SessionViewStateInitial: {
                self.progressView.hidden = NO;
                self.progressLabel.font = [UIFont fontWithName:@"Avenir-Book" size:30.0];
                self.progressLabel.text = @"Initializing...";
                if (!self.progressIndicator.isAnimating) {
                    [self.progressIndicator startAnimating];
                }
                self.completionLabel.hidden = YES;
                self.cancelButton.hidden = NO;
                break;
            }
            case SessionViewStateWaitingForBluetoothToTurnOn: {
                self.progressView.hidden = NO;
                self.progressLabel.font = [UIFont fontWithName:@"Avenir-Book" size:22.0];
                self.progressLabel.text = @"";
                if (!self.progressIndicator.isAnimating) {
                    [self.progressIndicator startAnimating];
                }
                self.completionLabel.hidden = YES;
                self.cancelButton.hidden = NO;
                break;
            }
            case SessionViewStateConnecting: {
                self.progressView.hidden = NO;
                self.progressLabel.font = [UIFont fontWithName:@"Avenir-Book" size:30.0];
                self.progressLabel.text = @"Connecting...";
                if (!self.progressIndicator.isAnimating) {
                    [self.progressIndicator startAnimating];
                }
                self.completionLabel.hidden = YES;
                self.cancelButton.hidden = NO;
                break;
            }
            case SessionViewStateProcessing: {
                self.progressView.hidden = NO;
                self.progressLabel.font = [UIFont fontWithName:@"Avenir-Book" size:30.0];
                self.progressLabel.text = @"Processing...";
                if (!self.progressIndicator.isAnimating) {
                    [self.progressIndicator startAnimating];
                }
                self.completionLabel.hidden = YES;
                self.cancelButton.hidden = YES;
                break;
            }
            case SessionViewStateCanceled: {
                self.progressView.hidden = YES;
                self.completionLabel.hidden = NO;
                self.completionLabel.text = @"Canceled";
                self.cancelButton.hidden = YES;
                break;
            }
            case SessionViewStateTimedOut: {
                self.progressView.hidden = YES;
                self.completionLabel.hidden = NO;
                self.completionLabel.text = @"Timed out";
                self.cancelButton.hidden = YES;
                break;
            }
            case SessionViewStateFinished: {
                self.progressView.hidden = YES;
                self.completionLabel.hidden = NO;
                NSString *message = nil;
                if (self.delegate && [self.delegate respondsToSelector:@selector(sessionViewController:completionMessageForData:)]) {
                    message = [self.delegate sessionViewController:self completionMessageForData:self.data];
                }
                self.completionLabel.text = (message ? message : @"Finished");
                self.cancelButton.hidden = YES;
                break;
            }
            default: {
                break;
            }
        }
    }
}

#pragma mark - Actions

- (IBAction)buttonDidTouchUpInside:(UIButton *)sender {
    if ([sender isEqual:self.cancelButton]) {
        if (self.state == SessionViewStateInitial || self.state == SessionViewStateWaitingForBluetoothToTurnOn) {
            self.state = SessionViewStateCanceled;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate sessionViewControllerDidCancelSessionByUserOperation:self];
            });
        }
        else {
            [[OHQDeviceManager sharedManager] cancelSessionWithDevice:self.deviceIdentifier];
        }
    }
}

#pragma mark - Private methods

- (void)bso_startSession {
    if ([self.delegate respondsToSelector:@selector(sessionViewControllerWillStartSession:)]) {
        [self.delegate sessionViewControllerWillStartSession:self];
    }

    [[OHQDeviceManager sharedManager] writeBluetoothStatusToLog];

    self.data = [[BSOSessionData alloc] initWithIdentifier:self.deviceIdentifier options:self.options];
    self.state = SessionViewStateConnecting;
    
    [[OHQDeviceManager sharedManager] startSessionWithDevice:self.deviceIdentifier usingDataObserver:^(OHQDataType aDataType, id _Nonnull data) {
        [self.data addSessionData:data withType:aDataType];
    } connectionObserver:^(OHQConnectionState aState) {
        if (aState == OHQConnectionStateConnected) {
            self.state = SessionViewStateProcessing;
        }
    } completion:^(OHQCompletionReason aReason) {
        self.data.completionReason = aReason;
        
        if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonCanceled) {
            self.state = SessionViewStateCanceled;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate sessionViewControllerDidCancelSessionByUserOperation:self];
            });
            return;
        }
        
        if (self.state == SessionViewStateConnecting && aReason == OHQCompletionReasonConnectionTimedOut) {
            self.state = SessionViewStateTimedOut;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.delegate sessionViewController:self didCompleteSessionWithData:self.data];
            });
            return;
        }
        
        self.state = SessionViewStateFinished;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate sessionViewController:self didCompleteSessionWithData:self.data];
        });
    } options:self.options];
}

- (void)becomeActive:(NSNotification *)notification {
    // App is active again
    [self checkBluetooth];
}

- (void)bso_scanForDevices {
    [[OHQDeviceManager sharedManager] scanForDevicesWithCategory:OHQDeviceCategoryAny usingObserver:^(NSDictionary<OHQDeviceInfoKey,id> * _Nonnull deviceInfo) { // no need deviceInfo
    } completion:^(OHQCompletionReason aReason) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (aReason) {
                case OHQCompletionReasonCanceled: {
                    if (self.stopScanCompletionBlock) {
                        self.stopScanCompletionBlock();
                    }
                    break;
                }
                case OHQCompletionReasonBusy: {
                    [self bso_stopScanWithBlock:^{
                        [self bso_scanForDevices];
                    }];
                    break;
                }
                default: {
                    break;
                }
            }
        });
    }];
}

- (void)bso_stopScanWithBlock:(dispatch_block_t)block {
    self.stopScanCompletionBlock = block;
    [[OHQDeviceManager sharedManager] stopScan];
}

@end
