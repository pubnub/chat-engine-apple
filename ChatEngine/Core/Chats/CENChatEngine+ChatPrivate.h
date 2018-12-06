/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENChatEngine+Chat.h"


#pragma mark Class forward

@class CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENChatEngine (ChatPrivate)


#pragma mark - Chats management

/**
 * @brief Create and configure new \b {chat CENChat} instance.
 *
 * @param name Unique alphanumeric chat identifier with maximum 50 characters. Usually something
 *     like \c {The Watercooler}, \c {Support}, or \c {Off Topic}. See \b {PubNub Channels https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-}.
 *     PubNub \c channel names are limited to \c 92 characters. If a user exceeds this limit while
 *     creating chat, an \c error will be thrown. The limit includes the prefixes and suffixes added
 *     by the chat engine as listed \b {here pubnub-channel-topology}.
 *     \b Default: \a NSUUID
 * @param group Chats list group identifier. Available groups described in \b {CENChatGroup}
 *     structure.
 *     \b Default: \b {CENChatGroup.custom}
 * @param isPrivate Whether chat access should be restricted only to invited users or not.
 * @param meta Information which should be persisted on server. This option require to set
 *     \b {CENConfiguration.enableMeta} to \c YES during \b {ChatEngine CENChatEngine}
 *     configuration.
 *
 * @return Configured and ready to use \b {chat CENChat} instance.
 */
- (CENChat *)createChatWithName:(nullable NSString *)name
                          group:(nullable NSString *)group
                        private:(BOOL)isPrivate
                    autoConnect:(BOOL)autoConnect
                       metaData:(nullable NSDictionary *)meta;

/**
 * @brief Create and configure \b {CENChatEngine.global} chat.
 *
 * @param channel Name of channel which will represent \b {CENChatEngine.global} chat channel for
 *     all connected clients.
 *     \b Default: \c global
 */
- (void)createGlobalChatWithChannel:(nullable NSString *)channel;

/**
 * @brief Create and configure \b {chat CENChat} which can be used for direct \b {user CENUser}
 * signaling.
 *
 * @param user \b {User CENUser} for which unique direct \b {chat CENChat} should be created.
 *
 * @return Configured and ready to use direct \b {chat CENChat}.
 */
- (CENChat *)createDirectChatForUser:(CENUser *)user;

/**
 * @brief Create and configure \b {chat CENChat} which can be used for \b {user CENUser} updates
 * handling.
 *
 * @param user \b {User CENUser} for which unique feed \b {chat CENChat} should be created.
 *
 * @return Configured and ready to use feed \b {chat CENChat}.
 */
- (CENChat *)createFeedChatForUser:(CENUser *)user;

/**
 * @brief Remove particular \b {chat CENChat} from local chat cache.
 *
 * @param chat \b {Chat CENChat} which should be removed from cache.
 */
- (void)removeChat:(CENChat *)chat;


#pragma mark - Chat meta

/**
 * @brief Fetch \b {chats CENChat} metadata from persistent server's storage.
 *
 * @param chat \b {Chat CENChat} for which meta should be fetched.
 * @param block Fetch completion handler block which pass service response if request was
 *     \c successful or \c error in case of failure.
 */
- (void)fetchMetaForChat:(CENChat *)chat
          withCompletion:(void(^)(BOOL success, NSArray *responses))block;

/**
 * @brief Push \b {chat CENChat} metadata to persistent server's storage.
 *
 * @param chat \b {Chat CENChat} for which meta should be pushed.
 * @param representation \b {Chat CENChat} dictionary representation.
 */
- (void)pushUpdatedChatMeta:(CENChat *)chat withRepresentation:(NSDictionary *)representation;


#pragma mark - Chat state

/**
 * @brief Associate state with \b {local user CENMe} for specific \b {chat CENChat}.
 *
 * @param chat \b {Chat CENChat} for which user's state should be updated.
 * @param data \a NSDictionary with data which should be associated with \b {local user CENMe} for
 *     specified \c chat.
 * @param block Update completion handler block which pass error if update did fail.
 */
- (void)updateChatState:(CENChat *)chat
               withData:(NSDictionary *)data
             completion:(void(^)(NSError * __nullable error))block;


#pragma mark - Chat connection

/**
 * @brief Complete \b {chat CENChat} registration for \b {local user CENMe}.
 *
 * @param chat \b {Chat CENChat} for which \b {local user CENMe} should be granted with read / write
 *     access rights.
 * @param block Connection completion handler block.
 */
- (void)connectToChat:(CENChat *)chat withCompletion:(dispatch_block_t)block;

/**
 * @breif Wake up all sleeping \b {CENChatEngine.chats} to start receiving live updates.
 */
- (void)connectChats;

/**
 * @brief Reset all chats' connection \c hasConnected property to \c NO.
 *
 * @discussion State reset allow to perform on chats same actions as happens during initial
 * connection.
 *
 * @since 0.10.0
 */
- (void)resetChatsConnection;

/**
 * @brief Put all \b {CENChatEngine.chats} to sleep and stop live updates handling.
 */
- (void)disconnectChats;


#pragma mark - Participation

/**
 * @brief Invite remote \b {user CENUser} to \b {chat CENChat} and grant him with read / write
 *     access rights.
 *
 * @param chat \b {Chat CENChat} to which \c user should be invited.
 * @param user \b {User CENUser} which should be invited to \c chat.
 */
- (void)inviteToChat:(CENChat *)chat user:(CENUser *)user;

/**
 * @brief Leave specific \b {chat CENChat} and notify other participants about this.
 *
 * @param chat \b {Chat CENChat} which \b {local user CENMe} would like to leave.
 */
- (void)leaveChat:(CENChat *)chat;

/**
 * @brief Retrieve list of currently active \b {users CENUser} in specified chat.
 *
 * @param chat \b {Chat CENChat} for which participants list should be audited.
 */
- (void)fetchParticipantsForChat:(CENChat *)chat;


#pragma mark - Clean up

/**
 * @brief \b {ChatEngine CENChatEngine} destroy clean up method to remove any cached
 * \b {chat CENChat} instance.
 */
- (void)destroyChats;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
