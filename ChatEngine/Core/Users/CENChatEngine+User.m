/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
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
#import "CENLogMacro.h"
#import "CENError.h"


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
    
    CENInterfaceCallCompletionBlock block = ^id (NSArray<NSString *> *flags, NSDictionary *args) {
        CENUser *user = nil;
        NSString *uuid = args[@"uuid"];
        NSDictionary *state = args[NSStringFromSelector(@selector(state))];
        
        if ([flags containsObject:NSStringFromSelector(@selector(create))]) {
            user = [self createUserWithUUID:uuid state:state];
        } else {
            user = [self userWithUUID:uuid];
        }
        
        return user;
    };
    
    CENUserBuilderInterface *builder = [CENUserBuilderInterface builderWithExecutionBlock:block];
    
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
    
    CELogAPICall(self.logger, @"<ChatEngine::API> Get '%@' user.", uuid);
    
    return [self.usersManager userWithUUID:uuid];
}


#pragma mark - State

- (void)fetchUserState:(CENUser *)user
               forChat:(CENChat *)chat
        withCompletion:(void(^)(NSDictionary *state))block {
    
    NSArray *routeSeries = @[@{
        @"route": @"user_state",
        @"method": @"get",
        @"query": @{ @"user": user.uuid, @"channel": chat.channel }
    }];

    [self.functionClient callRouteSeries:routeSeries
                          withCompletion:^(BOOL success, NSArray *responses) {
                              
        if (!success) {
            NSString *description = @"Something went wrong while making a request to chat server.";
            NSError *error = [CENError errorFromPubNubFunctionError:responses
                                                    withDescription:description];
            
            [self throwError:error
                    forScope:@"restoreState.network"
                        from:user
               propagateFlow:CEExceptionPropagationFlow.direct];
            
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
