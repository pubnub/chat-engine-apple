/**
 * author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
#import "CENUserConnectBuilderInterface.h"
#import "CENInterfaceBuilder+Private.h"


#pragma mark Interface implementation

@implementation CENUserConnectBuilderInterface


#pragma mark - Configuration

- (CENUserConnectBuilderInterface * (^)(NSDictionary *state))state {
    
    return ^CENUserConnectBuilderInterface * (NSDictionary *__unused state) {
        return self;
    };
}

- (CENUserConnectBuilderInterface * (^)(id authKey))authKey {
    
    return ^CENUserConnectBuilderInterface * (id authKey) {
        if ([authKey isKindOfClass:[NSString class]] || [authKey isKindOfClass:[NSNumber class]]) {
            [self setArgument:authKey forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (CENUserConnectBuilderInterface * (^)(NSString * globalChannel))globalChannel {
    
    return ^CENUserConnectBuilderInterface * (NSString *globalChannel) {
        if ([globalChannel isKindOfClass:[NSString class]]) {
            [self setArgument:globalChannel forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Call


- (CENChatEngine * (^)(void))perform {
    
    return ^CENChatEngine * {
        return [self performWithReturnValue];
    };
}

#pragma mark -


@end
