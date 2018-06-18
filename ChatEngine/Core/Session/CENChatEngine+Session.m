/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+Session.h"
#import "CENChatEngine+ChatInterface.h"
#import "CENChatEngine+PubNubPrivate.h"
#import "CENChatEngine+EventEmitter.h"
#import "CENChatEngine+Private.h"
#import "CENChatEngine+User.h"
#import "CENSession+Private.h"
#import "CENObject+Private.h"
#import "CENErrorCodes.h"
#import "CENStructures.h"
#import "CENError.h"
#import "CENChat.h"
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

- (void)synchronizeSessionChatsWithCompletion:(void(^)(NSString *group, NSArray<NSString *> *chats))block {
    
    NSString *chatsNamespace = self.configuration.globalChannel;
    
    for (NSString *group in @[CENChatGroup.custom, CENChatGroup.system]) {
        NSString *channelGroup = [@[chatsNamespace, self.me.uuid, group] componentsJoinedByString:@"#"];
        
        [self channelsForGroup:channelGroup withCompletion:^(NSArray<NSString *> *chats, PNErrorStatus *errorStatus) {
            if (!errorStatus) {
                block(group, chats);
                
                return;
            }
            
            NSString *description = @"There was a problem restoring your session from PubNub servers.";
            NSError *error = [CENError errorFromPubNubStatus:errorStatus withDescription:description];
            
            [self throwError:error forScope:@"sync" from:self propagateFlow:CEExceptionPropagationFlow.direct];
        }];
    }
}


#pragma mark - Events synchronization

- (void)synchronizeSessionChatJoin:(CENChat *)chat {
    
    [self.synchronizationSession joinChat:chat];
}

- (void)synchronizeSessionChatLeave:(CENChat *)chat {
    
    [self.synchronizationSession leaveChat:chat];
}


#pragma mark - Clean up

- (void)destroySession {
    
    [self.synchronizationSession destruct];
    self.synchronizationSession = nil;
}


#pragma mark - Misc

- (CENChat *)synchronizationChat {
    
    NSString *chatsNamespace = self.configuration.globalChannel;
    NSString *syncChatName = [@[chatsNamespace, @"user", self.me.uuid, @"me.", @"sync"] componentsJoinedByString:@"#"];
    
    return [self createChatWithName:syncChatName group:CENChatGroup.system private:NO autoConnect:YES metaData:@{ }];
}

#pragma mark -


@end
