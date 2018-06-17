/**
 * author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2017 PubNub, Inc.
 */
#import "CENChatBuilderInterface.h"
#import "CENInterfaceBuilder+Private.h"


#pragma mark Interface implementation

@implementation CENChatBuilderInterface


#pragma mark - Configuration

- (CENChatBuilderInterface * (^)(NSString *name))name {
    
    return ^CENChatBuilderInterface * (NSString *name) {
        if ([name isKindOfClass:[NSString class]]) {
            [self setArgument:name forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (CENChatBuilderInterface * (^)(BOOL isPrivate))private {
    
    return ^CENChatBuilderInterface * (BOOL isPrivate) {
        [self setArgument:@(isPrivate) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (CENChatBuilderInterface * (^)(BOOL shouldAutoConnect))autoConnect {
    
    return ^CENChatBuilderInterface * (BOOL shouldAutoConnect) {
        [self setArgument:@(shouldAutoConnect) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (CENChatBuilderInterface * (^)(NSDictionary *meta))meta {
    
    return ^CENChatBuilderInterface * (NSDictionary *meta) {
        if ([meta isKindOfClass:[NSDictionary class]]) {
            [self setArgument:meta forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (CENChatBuilderInterface * (^)(NSString *group))group {
    
    return ^CENChatBuilderInterface * (NSString *group) {
        if ([group isKindOfClass:[NSString class]]) {
            [self setArgument:group forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Call

- (CENChat * (^)(void))create {
    
    [self setFlag:NSStringFromSelector(_cmd)];
    
    return ^CENChat * {
        return [self performWithReturnValue];
    };
}

- (CENChat * (^)(void))get {
    
    [self setFlag:NSStringFromSelector(_cmd)];
    
    return ^CENChat * {
        return [self performWithReturnValue];
    };
}

#pragma mark -


@end
