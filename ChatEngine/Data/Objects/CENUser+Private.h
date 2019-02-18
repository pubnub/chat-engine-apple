/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENUser.h"


#pragma mark Class forward

@class CENChatEngine;


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
 * @param state \a NSDictionary with state which should be bound to \b {CENChatEngine.global} chat.
 * @param chatEngine \b {CENChatEngine} client which is used to create this instance
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
 * @param state \a NSDictionary with state which should be bound to \b {CENChatEngine.global} chat.
 * @param chatEngine \b {CENChatEngine} client which is used to create this instance
 *     and maintain it.
 *
 * @return Initialized \b {user CENUser}.
 */
- (instancetype)initWithUUID:(NSString *)uuid
                       state:(NSDictionary *)state
                  chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - State

/**
 * @brief Get cached state for user on specified \b {chat CENChat}.
 *
 * @discussion State populated and maintained by network updates.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
 *
 * @param chat \b {Chat CENChat} for which \b {user's CENUser} state should be retrieved.
 *     Pass \c nil to use \b {CENChatEngine.global} chat.
 *
 * @return \a NSDictionary with \b {user's CENUser} state which has been set for \c chat earlier or
 * \c nil in case if not set.
 *
 * @since 0.9.3
 *
 * @ref 590b7902-9f8e-4ee1-b48d-d45f96916c70
 */
- (nullable NSDictionary *)stateForChat:(nullable CENChat *)chat;

/**
 * @brief Assign user's state locally for specific \b {chat CENChat}.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
 *
 * @param state User's state which should be merged with existing state for \b {chat CENChat}.
 * @param chat \b {Chat CENChat} for which user's \c state should be assigned.
 *     \b Default: \b {CENChatEngine.global}
 */
- (void)assignState:(nullable NSDictionary *)state forChat:(nullable CENChat *)chat;

/**
 * @brief Assign user's state locally for specific \b {chat CENChat} using resource access queue.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
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
 * @brief Update user's state locally for specific \b {chat CENChat}.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
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
 * @brief Restore \b {user's CENUser} state for specific \b {chat CENChat}.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
 *
 * @param chat \b {Chat CENChat} from which state should be restored.
 *     Pass \c nil to use \b {CENChatEngine.global} chat.
 *
 * @since 0.9.3
 *
 * @ref ca77541f-c3f9-456f-8de4-ed8f3169853c
 */
- (void)restoreStateForChat:(nullable CENChat *)chat;

/**
 * @brief Try restore user's state on specific \b {chat CENChat}.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
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
