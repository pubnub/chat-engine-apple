#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNPresenceEventData, CENChatEngine, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} chats manager.
 *
 * @discussion Manager responsible for \b {chat CENChat} creation and maintenance.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatsManager : NSObject


#pragma mark - Information

/**
 * @brief Map of channel names to \b {chat CENChat} instance which they represent.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, CENChat *> *chats;

/**
 * @brief Global communication \b {chat CENChat} if \b {CENConfiguration.enableGlobal} is set to
 * \c YES.
 */
@property (nonatomic, nullable, readonly, strong) CENChat *global;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure chats manager.
 *
 * @param chatEngine \b {ChatEngine CENChatEngine} instance for which \b {chats CENChat} should be
 *     managed.
 *
 * @return Configured and ready to use chats manager instance.
 */
+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Instantiate chats manager.
 *
 * @throws \a NSDestinationInvalidException exception in following cases:
 * - attempt to create instance using \c new.
 *
 * @return \c nil.
 */
- (instancetype) __unavailable init;


#pragma mark - Chat connection

/**
 * @brief Wakeup all sleeping chats and notify observers about it.
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
 * @brief Put active chats asleep and notify observers about it.
 */
- (void)disconnectChats;



#pragma mark - Creation

/**
 * @brief Create and configure \b {chat CENChat} instance.
 *
 * @param isGlobal Whether new chat should represent \b {CENChatEngine.global} communication chat or
 *     not.
 * @param name Unique alphanumeric chat identifier with maximum 50 characters. Usually something
 *     like 'The Watercooler', 'Support', or 'Off Topic'. See \b {PubNub Channels https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-}
 *     \b Default: \a NSUUID
 * @param group Chat list group identifier. Available groups described in \b {CENChatGroup}
 *     structure.
 *     \b Default: \b {CENChatGroup.custom}
 * @param isPrivate Whether chat access should be restricted only to invited users or not.
 * @param shouldAutoConnect Whether new instance should be connected after creation or not.
 * @param meta Information which should be persisted on server. This option require to set
 *     \b {CENConfiguration.enableMeta} to \c YES during \b {ChatEngine CENChatEngine}
 *     configuration.
 */
- (CENChat *)createGlobalChat:(BOOL)isGlobal
                     withName:(nullable NSString *)name
                        group:(nullable NSString *)group
                      private:(BOOL)isPrivate
                  autoConnect:(BOOL)shouldAutoConnect
                     metaData:(nullable NSDictionary *)meta;


#pragma mark - Audition

/**
 * @brief Try to find and return previously created \b {chat CENChat} instance.
 *
 * @param name Name of chat which has been created before.
 * @param isPrivate Whether previously created chat is private or not.
 *
 * @return Previously created \b {chat CENChat} instance or \c nil in case if it doesn't exists.
 */
- (nullable CENChat *)chatWithName:(NSString *)name private:(BOOL)isPrivate;


#pragma mark - Removal

/**
 * @brief Remove particular \b {chat CENChat} from local chat cache.
 *
 * @param chat \b {Chat CENChat} which should be removed from cache.
 */
- (void)removeChat:(CENChat *)chat;


#pragma mark - Handlers

/**
 * @brief Process message received for specific \b {chat CENChat}.
 *
 * @param chat \b {Chat CENChat} for which message has been received.
 * @param payload Message payload dictionary with information about it's sender and actual data.
 */
- (void)handleChat:(CENChat *)chat message:(NSDictionary *)payload;

/**
 * @brief Process changes in users presence for specific \b {chat CENChat}.
 *
 * @param chat \b {Chat CENChat} in which active users list did change.
 * @param information \b PubNub presence information data object.
 */
- (void)handleChat:(CENChat *)chat presenceEvent:(PNPresenceEventData *)information;


#pragma mark - Clean up

/**
 * @brief Clean up all used resources.
 *
 * @discussion Clean up all resources which has been provided to create and manage active chats.
 */
- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
