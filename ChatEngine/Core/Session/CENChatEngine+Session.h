#import "CENChatEngine.h"


#pragma mark Class forward

@class CENSession, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for user synchronization session
 * management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (Session)


#pragma mark - Configuration

/**
 * @brief Handle \b {chats CENChat} list changes from remote user's devices.
 */
- (void)listenSynchronizationEvents;


#pragma mark - Synchronization

/**
 * @brief Retrieve list of \b {local user CENMe} \b {chats CENChat} from \b PubNub service.
 */
- (void)synchronizeSession;

/**
 * @brief Retrieve list of \b {local user CENMe} \b {chats CENChat} from \b PubNub service with
 * completion handler.
 *
 * @param block Block which called each time when list of \b {chats CENChat} for group has been
 *     received.
 */
- (void)synchronizeSessionWithCompletion:(void(^)(NSString *group,
                                                  NSArray<NSString *> *chats))block;


#pragma mark - Events synchronization

/**
 * @brief Send session synchronization event to add specific \b {chat CENChat} to
 * \b {local user CENMe} chats list.
 *
 * @param chat \b {Chat CENChat} which should be added to \b {local user CENMe} chats list.
 */
- (void)synchronizeSessionChatJoin:(CENChat *)chat;

/**
 * @brief Send session synchronization event to remove specific chat from user's chats list.
 *
 * @param chat \b {Chat CENChat} which should be removed from \b {local user CENMe} chats
 *     list.
 */
- (void)synchronizeSessionChatLeave:(CENChat *)chat;


#pragma mark - Clean up

/**
 * @brief Clean up all used resources.
 *
 * @discussion Clean up all resources which has been provided to create and manage session.
 */
- (void)destroySession;


#pragma mark - Misc

/**
 * @brief Create \b {chat CENChat} for exchange with synchronization events.
 *
 * @return \b {Local user CENMe} session synchronization \b {chat CENChat} instance.
 */
- (CENChat *)synchronizationChat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
