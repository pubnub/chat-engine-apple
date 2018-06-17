/**
 * author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2017 PubNub, Inc.
 */
#import "CENChatSearchBuilderInterface.h"
#import "CENInterfaceBuilder+Private.h"
#import "CENSearch.h"
#import "CENUser.h"


#pragma mark Interface implementation

@implementation CENChatSearchBuilderInterface


#pragma mark - Configuration

- (CENChatSearchBuilderInterface * (^)(NSString *event))event {
    
    return ^CENChatSearchBuilderInterface * (NSString *event) {
        if ([event isKindOfClass:[NSString class]]) {
            [self setArgument:event forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (CENChatSearchBuilderInterface * (^)(CENUser *sender))sender {
    
    return ^CENChatSearchBuilderInterface * (CENUser *sender) {
        if ([sender isKindOfClass:[CENUser class]]) {
            [self setArgument:sender forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (CENChatSearchBuilderInterface * (^)(NSInteger limit))limit {
    
    return ^CENChatSearchBuilderInterface * (NSInteger limit) {
        [self setArgument:@(limit) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (CENChatSearchBuilderInterface * (^)(NSInteger pages))pages {
    
    return ^CENChatSearchBuilderInterface * (NSInteger pages) {
        [self setArgument:@(pages) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (CENChatSearchBuilderInterface * (^)(NSInteger count))count {
    
    return ^CENChatSearchBuilderInterface * (NSInteger count) {
        [self setArgument:@(count) forParameter:NSStringFromSelector(_cmd)];
        
        return self;
    };
}

- (CENChatSearchBuilderInterface * (^)(NSNumber *start))start {
    
    return ^CENChatSearchBuilderInterface * (NSNumber *start) {
        if ([start isKindOfClass:[NSNumber class]]) {
            [self setArgument:start forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}

- (CENChatSearchBuilderInterface * (^)(NSNumber *end))end {
    
    return ^CENChatSearchBuilderInterface * (NSNumber *end) {
        if ([end isKindOfClass:[NSNumber class]]) {
            [self setArgument:end forParameter:NSStringFromSelector(_cmd)];
        }
        
        return self;
    };
}


#pragma mark - Call

- (CENSearch * (^)(void))create {
    
    return ^CENSearch * {
        return [self performWithReturnValue];
    };
}

#pragma mark -


@end
