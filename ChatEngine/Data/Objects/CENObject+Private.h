/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENObject.h"


#pragma mark Class forward

@class CENChatEngine, CENChat;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENObject (Private)


#pragma mark - Information

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, readonly, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief \b {Chat CENChat} which should be used by state restore augmentation plugin to get
 * participants state.
 */
@property (nonatomic, readonly, weak) CENChat *defaultStateChat;

/**
 * @brief \b {CENChatEngine} instance which manage instantiated subclass.
 */
@property (nonatomic, readonly, weak) CENChatEngine *chatEngine;

/**
 * @brief Unique object identifier.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief Whether object still valid or has been prepared for clean-up.
 */
@property (nonatomic, readonly, getter = isValid, assign) BOOL valid;

/**
 * @brief \b {CENChatEngine} object type (one of \b {CENObjectType} enum fields).
 */
+ (NSString *)objectType;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize \b {CENChatEngine} object.
 *
 * @param chatEngine \b {CENChatEngine} instance which will maintain created instance.
 *
 * @return Initialized and ready to use instance.
 */
- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine;


#pragma mark - State

/**
 * @brief Restore receivers state or managed objects using specified \b {chat CENChat}.
 *
 * @note This is part of 0.10.0 version functionality, but should be used with
 * \b {CENChatEngine.global} chat or \c nil till 0.10.0 release.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - passed and \b {CENChatEngine.global} chats are \c nil.
 *
 * @param chat \b {Chat CENChat} which should be used as source of state.
 *     Pass \c nil to use \b {CENChatEngine.global} chat.
 */
- (void)restoreStateForChat:(nullable CENChat *)chat;


#pragma mark - Handlers

/**
 * @brief Object creation handler.
 */
- (void)onCreate;


#pragma mark - Clean up

/**
 * @brief Clean up any resources allocated for events and plugins support.
 */
- (void)destruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
