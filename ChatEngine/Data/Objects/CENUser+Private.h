/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENUser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENUser (CENUser)


#pragma mark - Information

/**
 * @brief Map of chat channel names to \a NSDictionary which represent user's state on that chat.
 */
@property (nonatomic, readonly, copy) NSDictionary<NSString *, NSDictionary *> *states;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure new \b {user CENUser}.
 *
 * @param uuid Unique user identifier.
 * @param state \a NSDictionary with state which should be bound to \b {CENChatEngine.global} chat
 *     if \b {CENConfiguration.enableGlobal} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration
 * @param chatEngine \b {ChatEngine CENChatEngine} client which is used to create this instance
 *     and maintain it.
 *
 * @return Configured and ready to use \b {user CENUser} or \c nil in case if malformed data
 *     passed during instantiation.
 */
+ (nullable instancetype)userWithUUID:(NSString *)uuid
                                state:(NSDictionary *)state
                           chatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Initialize \b {user CENUser}.
 *
 * @param uuid Unique user identifier.
 * @param state \a NSDictionary with state which should be bound to \b {CENChatEngine.global} chat
 *     if \b {CENConfiguration.enableGlobal} should be set to \c YES during
 *     \b {ChatEngine CENChatEngine} client configuration
 * @param chatEngine \b {ChatEngine CENChatEngine} client which is used to create this instance
 *     and maintain it.
 *
 * @return Initialized \b {user CENUser}.
 */
- (instancetype)initWithUUID:(NSString *)uuid
                       state:(NSDictionary *)state
                  chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - State

/**
 * @brief Assign user's state locally.
 *
 * @param state User's state which should be merged with existing state for \b {chat CENChat}.
 * @param chat \b {Chat CENChat} for which user's \c state should be assigned.
 *     \b Default: \b {CENChatEngine.global}
 */
- (void)assignState:(nullable NSDictionary *)state forChat:(nullable CENChat *)chat;

/**
 * @brief Assign user's state locally using resource access queue.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - passed and \b {CENChatEngine.global} chats are \c nil.
 *
 * @param state User's state which should be merged with existing state for \b {chat CENChat}.
 * @param chat \b {Chat CENChat} for which user's \c state should be assigned.
 *     \b Default: \b {CENChatEngine.global}
 * @param useAccessQueue Whether resource access queue should be used for changes synchronization or
 *     not.
 */
- (void)assignState:(nullable NSDictionary *)state
            forChat:(nullable CENChat *)chat
            onQueue:(BOOL)useAccessQueue;

/**
 * @brief Update user's state locally.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - passed and \b {CENChatEngine.global} chats are \c nil.
 *
 * @param state User's state which should be merged with existing state for \b {chat CENChat}.
 * @param chat \b {Chat CENChat} for which user's \c state should be assigned.
 *     \b Default: \b {CENChatEngine.global}
 */
- (void)updateState:(nullable NSDictionary *)state forChat:(nullable CENChat *)chat;

/**
 * @brief Try restore user's state on specific \b {chat CENChat}.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - passed and \b {CENChatEngine.global} chats are \c nil.
 *
 * @param chat \b {Chat CENChat} for which user's state should be fetched.
 * @param block State restore completion block / closure which pass state from persistent
 *     \b PubNub K/V storage.
 */
- (void)restoreStateForChat:(CENChat *)chat
             withCompletion:(nullable void(^)(NSDictionary * __nullable state))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
