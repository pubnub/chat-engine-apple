/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENMe+Private.h"
#import "CENChatEngine+Private.h"
#import "CENChatEngine+UserPrivate.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENPrivateStructures.h"
#import "CENObject+Private.h"
#import "CENUser+Private.h"
#import "CENChat+Private.h"


#pragma mark - Interface implementation

@implementation CENMe


#pragma mark - Information

+ (NSString *)objectType {
    
    return CENObjectType.me;
}

- (CENSession *)session {
    
    return self.chatEngine.synchronizationSession;
}

- (CENMe * (^)(NSDictionary *state))update {
    
    return ^CENMe * (NSDictionary *state) {
        [self updateState:state];
        
        return self;
    };
}


#pragma mark - State

- (void)assignState:(NSDictionary *)state {
    
    [super updateState:state];
}

- (void)updateState:(NSDictionary *)state {
    
    [self updateState:state withCompletion:nil];
}

- (void)updateState:(NSDictionary *)state withCompletion:(dispatch_block_t)block {
    
    [self fetchStoredStateWithCompletion:^(__unused NSDictionary *fetchedState) {
        [super updateState:state];
        [self.chatEngine propagateLocalUserStateRefreshWithCompletion:block];
    }];
}


#pragma mark - Clean up

- (void)destruct {
    
    [super destruct];
}


#pragma mark - Misc

- (NSString *)description {
    
    return [NSString stringWithFormat:@"<CENMe:%p uuid: '%@'>", self, self.uuid];
}

#pragma mark -


@end
