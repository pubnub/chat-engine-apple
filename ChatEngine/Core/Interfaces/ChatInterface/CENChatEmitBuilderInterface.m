/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
#import "CENChatEmitBuilderInterface.h"
#import "CENInterfaceBuilder+Private.h"


#pragma mark Interface implementation

@implementation CENChatEmitBuilderInterface


#pragma mark - Configuration

- (CENChatEmitBuilderInterface * (^)(NSDictionary *data))data {
    
    return ^CENChatEmitBuilderInterface * (NSDictionary *data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            [self setArgument:data forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Call

- (CENEvent * (^)(void))perform {
    
    return ^CENEvent * {
        return [self performWithReturnValue];
    };
}

#pragma mark -


@end
