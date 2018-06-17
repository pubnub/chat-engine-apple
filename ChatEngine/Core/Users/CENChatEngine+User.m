/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine.h"
#import "CENChatEngine+UserPrivate.h"

#if CHATENGINE_USE_BUILDER_INTERFACE
    #import "CENChatEngine+UserBuilderInterface.h"
    #import "CENInterfaceBuilder+Private.h"
    #import "CENUserBuilderInterface.h"
#endif // CHATENGINE_USE_BUILDER_INTERFACE

#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+Private.h"
#import "CENChat+Private.h"
#import "CENUser+Private.h"
#import "CENMe+Private.h"
#import "CENSession.h"


#pragma mark Interface implementation

@implementation CENChatEngine (User)


#pragma mark - Information

- (NSDictionary<NSString *,CENUser *> *)users {
    
    return self.usersManager.users;
}

- (CENMe *)me {
    
    return self.usersManager.me;
}


#pragma mark - User

#if CHATENGINE_USE_BUILDER_INTERFACE

- (CENUserBuilderInterface * (^)(NSString *))User {
    
    CENUserBuilderInterface *builder = [CENUserBuilderInterface builderWithExecutionBlock:^id(NSArray<NSString *> *flags,
                                                                                            NSDictionary *arguments) {
        CENUser *user = nil;
        NSString *uuid = arguments[@"uuid"];
        NSDictionary *state = arguments[NSStringFromSelector(@selector(state))];
        
        if ([flags containsObject:NSStringFromSelector(@selector(create))]) {
            user = [self createUserWithUUID:uuid state:state];
        } else {
            user = [self userWithUUID:uuid];
        }
        
        return user;
    }];
    
    return ^CENUserBuilderInterface * (NSString *uuid) {
        [builder setArgument:uuid forParameter:@"uuid"];
        
        return builder;
    };
}

#endif // CHATENGINE_USE_BUILDER_INTERFACE

- (CENUser *)createUserWithUUID:(NSString *)uuid state:(NSDictionary *)state {
    
    return [self.usersManager createUserWithUUID:uuid state:state];
}

- (CENUser *)userWithUUID:(NSString *)uuid {
    
    return [self.usersManager userWithUUID:uuid];
}


#pragma mark - State

- (void)updateLocalUserState:(nullable NSDictionary *)state withCompletion:(dispatch_block_t)block {
    
    [self.me updateState:state withCompletion:block];
}

- (void)propagateLocalUserStateRefreshWithCompletion:(dispatch_block_t)block {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.global setState:self.me.state withCompletion:block];
    });
}

- (void)fetchUserState:(CENUser *)user withCompletion:(void(^)(NSDictionary *state))block {
    
    NSArray *routeSeries = @[@{ @"route": @"user_state", @"method": @"get", @"query": @{ @"user": user.uuid } }];
    
    __weak __typeof__(self) weakSelf = self;
    [self.functionsClient callRouteSeries:routeSeries withCompletion:^(BOOL success, NSArray *responses) {
        if (!success) {
            [weakSelf throwError:responses.firstObject forScope:@"getState" from:user propagateFlow:CEExceptionPropagationFlow.middleware];
            
            return;
        }
        
        if ([responses.firstObject isKindOfClass:[NSDictionary class]]) {
            block(responses.firstObject);
        }
    }];
}


#pragma mark - Clean up

- (void)destroyUsers {
    
    [self.usersManager destroy];
}

#pragma mark -


@end
