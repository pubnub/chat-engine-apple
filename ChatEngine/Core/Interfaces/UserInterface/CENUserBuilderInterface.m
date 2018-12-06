/**
 * author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
#import "CENUserBuilderInterface.h"
#import "CENInterfaceBuilder+Private.h"
#import "CENUser.h"


#pragma mark Interface implementation

@implementation CENUserBuilderInterface


#pragma mark - Configuration

- (CENUserBuilderInterface * (^)(NSDictionary *state))state {
    
    return ^CENUserBuilderInterface * (NSDictionary *state) {
        if ([state isKindOfClass:[NSDictionary class]]) {
            [self setArgument:state forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Call

- (CENUser * (^)(void))create {
    
    [self setFlag:NSStringFromSelector(_cmd)];
    
    return ^CENUser * {
        return [self performWithReturnValue];
    };
}

- (CENUser * (^)(void))get {
    
    [self setFlag:NSStringFromSelector(_cmd)];
    
    return ^CENUser * {
        return [self performWithReturnValue];
    };
}

#pragma mark -


@end
