/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENUserConnectBuilderInterface.h"
#import "CENInterfaceBuilder+Private.h"


#pragma mark Interface implementation

@implementation CENUserConnectBuilderInterface


#pragma mark - Configuration

- (CENUserConnectBuilderInterface * (^)(NSDictionary *state))state {
    
    return ^CENUserConnectBuilderInterface * (NSDictionary *state) {
        if ([state isKindOfClass:[NSDictionary class]]) {
            [self setArgument:state forParameter:NSStringFromSelector(_cmd)];
        }
        
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


#pragma mark - Call


- (CENChatEngine * (^)(void))perform {
    
    return ^CENChatEngine * {
        return [self performWithReturnValue];
    };
}

#pragma mark -


@end
