//
//  OHQStateMachine.m
//  OHQReferenceCode
//
//  Copyright © 2017 Omron Healthcare Co., Ltd. All rights reserved.
//

#import "OHQStateMachine.h"
#import "OHQLog.h"

///---------------------------------------------------------------------------------------
#pragma mark - OHQStateNode class
///---------------------------------------------------------------------------------------

NS_ASSUME_NONNULL_BEGIN

@interface OHQStateNode : NSObject
- (instancetype)initWithState:(OHQState *)state;
- (instancetype)initWithState:(OHQState *)state parentStateNode:(nullable OHQStateNode *)parentStateNode;
@property (strong, nonatomic) OHQState *state;
@property (nullable, nonatomic, weak) OHQStateNode *parentStateNode;
@property (readonly) NSArray<OHQState *> *stateHierarchy;
@end

NS_ASSUME_NONNULL_END

@implementation OHQStateNode

- (instancetype)initWithState:(OHQState *)state {
    return [self initWithState:state parentStateNode:nil];
}

- (instancetype)initWithState:(OHQState *)state parentStateNode:(OHQStateNode *)parentStateNode {
    self = [super init];
    if (self) {
        _state = state;
        _parentStateNode = parentStateNode;
    }
    return self;
}

- (NSArray<OHQStateNode *> *)stateNodeHierarchy {
    NSMutableArray<OHQStateNode *> *ret = [@[] mutableCopy];
    for (OHQStateNode *node = self; node; node = node.parentStateNode) {
        [ret insertObject:node atIndex:0];
    }
    return ret.copy;
}

- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if ([object isKindOfClass:[self class]]) {
        typeof(self) other = object;
        ret = [self.state isKindOfClass:[other class]];
    }
    return ret;
}

- (NSUInteger)hash {
    return [self.state hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@[%@]", super.description, NSStringFromClass([self.state class])];
}

@end

///---------------------------------------------------------------------------------------
#pragma mark - OHQStateMachine class
///---------------------------------------------------------------------------------------

NS_ASSUME_NONNULL_BEGIN

@interface OHQStateMachine ()
@property (readwrite, assign, nonatomic) BOOL active;
@property (readwrite, strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) NSMutableSet<OHQStateNode *> *stateNodes;
@property (nullable, weak, nonatomic) OHQStateNode* currentStateNode;
@end

NS_ASSUME_NONNULL_END

@implementation OHQStateMachine

///---------------------------------------------------------------------------------------
#pragma mark - Public methods
///---------------------------------------------------------------------------------------

- (instancetype)init {
    return [self initWithQueue:nil];
}

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    self = [super init];
    if (self) {
        self.queue = (queue ? queue : dispatch_get_main_queue());
        self.active = NO;
        self.stateNodes = [NSMutableSet set];
        self.currentStateNode = nil;
    }
    return self;
}

- (void)addState:(OHQState *)state {
    if (!state) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"%s: state cannot be nil", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    if (self.active) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:[NSString stringWithFormat:@"%s: operation cannot be performed during state machine running", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    OHQStateNode *node = [[OHQStateNode alloc] initWithState:state];
    if ([self.stateNodes containsObject:node]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: %@ class already has been added", __PRETTY_FUNCTION__, NSStringFromClass([state class])]
                                     userInfo:nil];
    }
    [state setValue:self forKey:@"stateMachine"];
    [self.stateNodes addObject:node];
}

- (void)addState:(OHQState *)state toParentState:(OHQState *)parentState {
    if (!state) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"%s: state cannot be nil", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    if (self.active) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:[NSString stringWithFormat:@"%s: operation cannot be performed during state machine running", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    OHQStateNode *parentStateNode = [self ohq_nodeForState:parentState];
    if (!parentStateNode) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: parentState must have been added", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    OHQStateNode *node = [[OHQStateNode alloc] initWithState:state parentStateNode:parentStateNode];
    if ([self.stateNodes containsObject:node]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: %@ class already has been added", __PRETTY_FUNCTION__, NSStringFromClass([state class])]
                                     userInfo:nil];
    }
    [state setValue:self forKey:@"stateMachine"];
    [self.stateNodes addObject:node];
}

- (void)addState:(OHQState *)state toParentStateClass:(nonnull Class)parentStateClass {
    OHQState *parentState = [self stateForClass:parentStateClass];
    if (!parentState) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: parentStateClass must have been added", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    [self addState:state toParentState:parentState];
}

- (void)startWithInitialState:(OHQState *)initialState {
    if (!self.stateNodes.count) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: state not added", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    if (self.active) {
        @throw [NSException exceptionWithName:NSGenericException
                                       reason:[NSString stringWithFormat:@"%s: operation cannot be performed during state machine running", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    OHQStateNode *initialStateNode = [self ohq_nodeForState:initialState];
    if (!initialStateNode) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: initialState must have been added", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    
    self.active = YES;
    dispatch_async(self.queue, ^{
        [self ohq_transitionToStateWithNode:initialStateNode];
    });
}

- (void)startWithInitialStateClass:(Class)initialStateClass {
    OHQState *initialState = [self stateForClass:initialStateClass];
    if (!initialState) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: initialStateClass must have been added", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    [self startWithInitialState:initialState];
}

- (void)stop {
    if (self.active) {
        dispatch_async(self.queue, ^{
            [self ohq_transitionToStateWithNode:nil];
            self.active = NO;
        });
    }
}

- (OHQState *)stateForClass:(Class)stateClass {
    __block OHQState *ret = nil;
    [self.stateNodes enumerateObjectsUsingBlock:^(OHQStateNode * _Nonnull node, BOOL * _Nonnull stop) {
        if ([node.state isKindOfClass:stateClass]) {
            ret = node.state;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)transitionToState:(OHQState *)state {
    if (!state) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"%s: state cannot be nil", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    OHQStateNode *node = [self ohq_nodeForState:state];
    if (!node) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: state must have been added", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    dispatch_async(self.queue, ^{
        if (self.active) {
            [self ohq_transitionToStateWithNode:node];
        }
    });
}

- (void)transitionToStateClass:(Class)stateClass {
    OHQState *state = [self stateForClass:stateClass];
    if (!state) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"%s: stateClass must have been added", __PRETTY_FUNCTION__]
                                     userInfo:nil];
    }
    [self transitionToState:state];
}

- (void)updateWithEvent:(NSUInteger)event object:(id)object {
    dispatch_async(self.queue, ^{
        if (self.active) {
            [self ohq_updateWithEvent:event object:object];
        }
    });
}

- (void)updateWithEvent:(NSUInteger)event object:(id)object afterDelay:(NSTimeInterval)delay {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.queue, ^{
        if (self.active) {
            [self ohq_updateWithEvent:event object:object];
        }
    });
}

- (OHQState *)currentState {
    return self.currentStateNode.state;
}

///---------------------------------------------------------------------------------------
#pragma mark - Private methods
///---------------------------------------------------------------------------------------

- (OHQStateNode *)ohq_nodeForState:(OHQState *)state {
    __block OHQStateNode *ret = nil;
    [self.stateNodes enumerateObjectsUsingBlock:^(OHQStateNode * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.state isEqual:state]) {
            ret = obj;
            *stop = YES;
        }
    }];
    return ret;
}

- (void)ohq_transitionToStateWithNode:(OHQStateNode *)node {
    if (![self.currentStateNode isEqual:node]) {
        NSMutableOrderedSet<OHQStateNode *> *exitNodes = [NSMutableOrderedSet orderedSetWithArray:self.currentStateNode.stateNodeHierarchy];
        NSMutableOrderedSet<OHQStateNode *> *enterNodes = [NSMutableOrderedSet orderedSetWithArray:node.stateNodeHierarchy];
        while (exitNodes.count > 0 && enterNodes.count > 0 && [exitNodes.firstObject.state isEqual:enterNodes.firstObject.state]) {
            [exitNodes removeObjectAtIndex:0];
            [enterNodes removeObjectAtIndex:0];
        }
        [exitNodes enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OHQStateNode * _Nonnull exitNode, NSUInteger idx, BOOL * _Nonnull stop) {
            OHQLogI(@"%@ exit", NSStringFromClass([exitNode.state class]));
            [exitNode.state willExit];
            self.currentStateNode = (exitNode.parentStateNode ? exitNode.parentStateNode : nil);
        }];
        [enterNodes enumerateObjectsUsingBlock:^(OHQStateNode * _Nonnull enterNode, NSUInteger idx, BOOL * _Nonnull stop) {
            OHQLogI(@"%@ enter", NSStringFromClass([enterNode.state class]));
            [enterNode.state didEnter];
            self.currentStateNode = enterNode;
        }];
    }
}

- (void)ohq_updateWithEvent:(NSUInteger)event object:(id)object {
    if (self.currentStateNode) {
        NSArray<OHQStateNode *> *stateNodeArray = self.currentStateNode.stateNodeHierarchy;
        [stateNodeArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(OHQStateNode * _Nonnull node, NSUInteger idx, BOOL * _Nonnull stop) {
            *stop = [node.state shouldHandleEvent:event withObject:object];
        }];
    }
}

@end
