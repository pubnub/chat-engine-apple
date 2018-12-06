/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
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
 * @brief \b {ChatEngine CENChatEngine} instance which manage instantiated subclass.
 */
@property (nonatomic, readonly, weak) CENChatEngine *chatEngine;

/**
 * @brief Unique object identifier.
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief \b {ChatEngine CENChatEngine} object type (one of \b {CENObjectType} enum fields).
 */
+ (NSString *)objectType;


#pragma mark - Initialization and Configuration

/**
 * @brief Initialize \b {ChatEngine CENChatEngine} object.
 *
 * @param chatEngine \b {ChatEngine CENChatEngine} instance which will maintain created instance.
 *
 * @return Initialized and ready to use instance.
 */
- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine;


#pragma mark - State

/**
 * @brief Restore receivers state or managed objects using specified \b {chat CENChat}.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - passed and \b {CENChatEngine.global} chats are \c nil.
 *
 * @param chat \b {Chat CENChat} which should be used as source of state.
 *     Pass \c nil to use \b {CENChatEngine.global} chat (possible only if
 *     \b {CENConfiguration.enableGlobal} is set to \c YES during \b {ChatEngine CENChatEngine}
 *     client configuration).
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
