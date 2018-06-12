#import "CENChatEngine.h"


#pragma mark Class forward

@class CENSession, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine client interface for user synchronization session management.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (Session)


#pragma mark - Configuration

- (void)listenSynchronizationEvents;


#pragma mark - Synchronization

- (void)synchronizeSession;
- (void)synchronizeSessionChatsWithCompletion:(void(^)(NSString *group, NSArray<NSString *> *chats))block;


#pragma mark - Events synchronization

- (void)synchronizeSessionChatJoin:(CENChat *)chat;
- (void)synchronizeSessionChatLeave:(CENChat *)chat;


#pragma mark - Clean up

- (void)destroySession;


#pragma mark - Misc

- (CENChat *)synchronizationChat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
