/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENChat.h"
#import "CENObject+Private.h"


#pragma mark Class forward

@class CENChatEngine;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENChat (Private)


#pragma mark - Information

/**
 * @brief Chats group name.
 */
@property (nonatomic, readonly, copy) NSString *group;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure chat instance.
 *
 * @param name Unique alphanumeric chat identifier with maximum 50 characters. Usually something
 *     like \c {The Watercooler}, \c {Support}, or \c {Off Topic}. See \b {PubNub Channels https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-}.
 *     PubNub \c channel names are limited to \c 92 characters. If a user exceeds this limit while
 *     creating chat, an \c error will be thrown. The limit includes the prefixes and suffixes added
 *     by the chat engine as listed \b {here pubnub-channel-topology}.
 * @param nspace Namespace inside of which chat will be created.
 * @param group Chat list group identifier.
 * @param isPrivate Whether \b {chat CENChat} access should be restricted only to invited users or
 *     not.
 * @param meta Chat metadata that will be persisted on the server and populated on creation.
 *     To use this parameter \b {CENConfiguration.enableMeta} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration.
 * @param chatEngine \b {ChatEngine CENChatEngine} client which will manage this chat instance.
 *
 * @return Configured and ready to use chat instance.
 */
+ (nullable instancetype)chatWithName:(NSString *)name
                            namespace:(NSString *)nspace
                                group:(NSString *)group
                              private:(BOOL)isPrivate
                             metaData:(NSDictionary *)meta
                           chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Activity

/**
 * @brief Reset \b {hasConnected} property to \c NO.
 *
 * @discussion State reset allow to perform on chat same actions as happens during initial
 * connection.
 *
 * @since 0.10.0
 */
- (void)resetConnection;

/**
 * @brief Put chat to 'sleep'.
 *
 * @discussion Called by \b {CENChatEngine.disconnect}. Fires disconnection notifications and
 * stores 'sleep' state in memory. Sleep means the chat was previously connected.
 */
- (void)sleep;

/**
 * @brief Awake sleeping chat.
 *
 * @discussion Called by \b {CENChatEngine.reconnect}. Wakes the chat up from sleep state.
 * Re-authenticates with the server, and fires connection events once established.
 */
- (void)wake;


#pragma mark - Participants

/**
 * @brief Ask PubNub for information about \b {users CENUser} in this chat.
 */
- (void)fetchParticipants;


#pragma mark - Meta

/**
 * @brief Update metadata using server response.
 *
 * @param meta Metadata which was stored on server for this chat.
 */
- (void)updateMetaWithFetchedData:(nullable NSDictionary *)meta;


#pragma mark - Handlers

/**
 * @brief Handle local user explicit leave via \b {CENChat.leave}.
 */
- (void)handleLeave;

/**
 * @brief Update list of \b {users CENUser} in this chat based on who is online now.
 *
 * @param users List of users who is currently connected to this chat.
 * @param states Dictionary with user uuids mapped to their states for chat.
 */
- (void)handleRemoteUsersRefresh:(NSArray<CENUser *> *)users
                      withStates:(NSDictionary<NSString *, NSDictionary *> *)states;

/**
 * @brief Update list of \b {users CENUser} in this chat based on who is online now.
 *
 * @param users List of users who is currently connected to this chat.
 */
- (void)handleRemoteUsersHere:(NSArray<CENUser *> *)users;

/**
 * @brief Update list of \b {users CENUser} in this chat with new users.
 *
 * @param users List of users which joined this chat.
 * @param states Dictionary with user uuids mapped to their states for chat.
 * @param onStateChange Whether state has been received with state-change presence event or not.
 */
- (void)handleRemoteUsersJoin:(NSArray<CENUser *> *)users
                   withStates:(NSDictionary<NSString *, NSDictionary *> *)states
                onStateChange:(BOOL)onStateChange;

/**
 * @brief Perform updates when a user has left the chat.
 *
 * @param users List of users which has left chat.
 */
- (void)handleRemoteUsersLeave:(NSArray<CENUser *> *)users;

/**
 * @brief Update users' presence state to 'offline'.
 *
 * @param users List of users which has been disconnected.
 */
- (void)handleRemoteUsersDisconnect:(NSArray<CENUser *> *)users;

/**
 * @brief Update users' state.
 *
 * @param users List of users which updated their state for this chat.
 * @param states Dictionary with user uuids mapped to their states for chat.
 */
- (void)handleRemoteUsers:(NSArray<CENUser *> *)users
              stateChange:(NSDictionary<NSString *, NSDictionary *> *)states;


#pragma mark - Misc

/**
 * @brief Compose chat's channel name using passed information.
 *
 * @param channelName Unique channel name or name of existing chat channel.
 * @param nspace Namespace inside of which chat should belong.
 * @param isPrivate Whether chat will be private or not.
 *
 * @return Name of PubNub channel which can be used to receive real-time updates by chat.
 */
+ (NSString *)internalNameFor:(NSString *)channelName
                  inNamespace:(NSString *)nspace
                      private:(BOOL)isPrivate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
