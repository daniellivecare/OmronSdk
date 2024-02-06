//
//  OHQDevice.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQDefines.h"
#import "OHQStateMachine.h"
#import <Foundation/Foundation.h>

@protocol OHQDeviceDelegate;
@class CBPeripheral;

NS_ASSUME_NONNULL_BEGIN

@interface OHQDevice : OHQStateMachine

@property (nullable, nonatomic, weak) id<OHQDeviceDelegate> delegate;
@property (readonly, nonatomic, strong) CBPeripheral *peripheral;
@property (readonly, nullable, nonatomic, copy) NSArray<NSDictionary<OHQMeasurementRecordKey,id> *> *measurementRecords;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral queue:(nullable dispatch_queue_t)queue;
- (void)startTransferWithDataObserverBlock:(OHQDataObserverBlock)dataObserver options:(nullable NSDictionary<OHQSessionOptionKey,id> *)options;
- (void)cancelTransfer;
- (void)setPairingMode:(bool)mode;

@end

@protocol OHQDeviceDelegate <NSObject>

- (void)device:(OHQDevice *)device didAbortTransferWithReason:(OHQCompletionReason)reason;

@end

NS_ASSUME_NONNULL_END
