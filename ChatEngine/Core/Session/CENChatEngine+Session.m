/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+Session.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+ChatPrivate.h"
#import "CENChatEngine+Private.h"
#import "CENChatEngine+User.h"
#import "CENSession+Private.h"
#import "CENObject+Private.h"
#import "CENChat+Private.h"
#import "CENError.h"
#import "CENMe.h"


@implementation CENChatEngine (Session)


#pragma mark - Configuration

- (void)listenSynchronizationEvents {
    
    [self.synchronizationSession listenEvents];
}


#pragma mark - Synchronization

- (void)synchronizeSession {
    
    [self.synchronizationSession restore];
}

- (void)synchronizeSessionWithCompletion:(void(^)(NSString *group,
                                                  NSArray<NSString *> *chats))block {
    
    NSString *nSpace = self.configuration.globalChannel;
    
    for (NSString *group in @[CENChatGroup.custom]) {
        NSString *groupName = [@[nSpace, self.me.uuid, group] componentsJoinedByString:@"#"];
        
        [self channelsForGroup:groupName
                withCompletion:^(NSArray<NSString *> *chats, PNErrorStatus *errorStatus) {
                    
            if (!errorStatus) {
                block(group, chats);
                
                return;
            }
            
            NSString *description = @"There was a problem restoring your session from PubNub "
                                     "servers.";
            NSError *error = [CENError errorFromPubNubStatus:errorStatus
                                             withDescription:description];
            
            [self throwError:error forScope:@"sync"
                        from:self.synchronizationSession
               propagateFlow:CEExceptionPropagationFlow.direct];
        }];
    }
}


#pragma mark - Events synchronization

- (void)synchronizeSessionChatJoin:(CENChat *)chat {
    
    if (![chat.group isEqualToString:CENChatGroup.custom] || [chat isEqual:self.global]) {
        return;
    }
    
    [self.synchronizationSession joinChat:chat];
}

- (void)synchronizeSessionChatLeave:(CENChat *)chat {
    
    if (![chat.group isEqualToString:CENChatGroup.custom] || [chat isEqual:self.global]) {
        return;
    }
    
    [self.synchronizationSession leaveChat:chat];
}


#pragma mark - Clean up

- (void)destroySession {
    
    [self.synchronizationSession destruct];
    self.synchronizationSession = nil;
}


#pragma mark - Misc

- (CENChat *)synchronizationChat {
    
    NSString *nspace = self.configuration.globalChannel;
    NSString *name = [@[nspace, @"user", self.me.uuid, @"me.#sync"] componentsJoinedByString:@"#"];
    
    return [self createChatWithName:name
                              group:CENChatGroup.system
                            private:NO
                        autoConnect:YES
                           metaData:@{ }];
}

#pragma mark -


@end
