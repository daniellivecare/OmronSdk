//
//  OHQState.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQState.h"

@interface OHQState ()
@property (readwrite, nullable, weak, nonatomic) OHQStateMachine *stateMachine;
@end

@implementation OHQState

+ (instancetype)state {
    return [[[self class] alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)didEnter {
    // override me
}

- (void)willExit {
    // override me
}

- (BOOL)shouldHandleEvent:(NSUInteger)event withObject:(id)object {
    // override me
    return NO;
}

@end
