//
//  OHQStateMachine.h
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQState.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OHQStateMachine : NSObject

- (instancetype)initWithQueue:(nullable dispatch_queue_t)queue NS_DESIGNATED_INITIALIZER;

- (void)addState:(OHQState *)state;
- (void)addState:(OHQState *)state toParentState:(OHQState *)parentState;
- (void)addState:(OHQState *)state toParentStateClass:(Class)parentStateClass;
- (void)startWithInitialState:(OHQState *)initialState;
- (void)startWithInitialStateClass:(Class)initialStateClass;
- (void)stop;
- (nullable OHQState *)stateForClass:(Class)stateClass;
- (void)updateWithEvent:(NSUInteger)event object:(nullable id)object;
- (void)updateWithEvent:(NSUInteger)event object:(nullable id)object afterDelay:(NSTimeInterval)delay;
- (void)transitionToState:(OHQState *)state;
- (void)transitionToStateClass:(Class)stateClass;

@property (readonly, strong, nonatomic) dispatch_queue_t queue;
@property (readonly, assign, nonatomic) BOOL active;
@property (readonly, nullable, weak, nonatomic) OHQState* currentState;

@end

NS_ASSUME_NONNULL_END
