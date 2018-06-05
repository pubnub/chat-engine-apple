/**
 * author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2017 PubNub, Inc.
 */
#import "CENPluginsBuilderInterface.h"
#import "CENInterfaceBuilder+Private.h"


#pragma mark Interface implementation

@implementation CENPluginsBuilderInterface


#pragma mark - Configuration


- (CENPluginsBuilderInterface * (^)(NSString *identifier))identifier {
    
    return ^CENPluginsBuilderInterface * (NSString *identifier) {
        if ([identifier isKindOfClass:[NSString class]]) {
            [self setArgument:identifier forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (CENPluginsBuilderInterface * (^)(NSDictionary *configuration))configuration {
    
    return ^CENPluginsBuilderInterface * (NSDictionary *configuration) {
        if ([configuration isKindOfClass:[NSDictionary class]]) {
            [self setArgument:configuration forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Call

- (void (^)(void))store {
    
    [self setFlag:NSStringFromSelector(_cmd)];
    
    return ^{
        return [self performWithBlock:nil];
    };
}

- (void (^)(void))remove {
    
    [self setFlag:NSStringFromSelector(_cmd)];
    
    return ^{
        return [self performWithBlock:nil];
    };
}

- (BOOL (^)(void))exists {
    
    [self setFlag:NSStringFromSelector(_cmd)];
    
    return ^BOOL {
        return ((NSNumber *)[self performWithReturnValue]).boolValue;
    };
}

#pragma mark -


@end
