//
//  OHQState.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OHQStateMachine;

NS_ASSUME_NONNULL_BEGIN

@interface OHQState : NSObject

+ (instancetype)state;

- (void)didEnter;
- (void)willExit;
- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(nullable id)object;

@property (nullable, nonatomic, readonly, weak) OHQStateMachine *stateMachine;

@end

NS_ASSUME_NONNULL_END
