/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENObject.h"


#pragma mark Class forward

@class CENChatEngine, CEPExtension, CEPMiddleware;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Private interface declaration

@interface CENObject (Private)


#pragma mark - Information

@property (nonatomic, readonly, strong) dispatch_queue_t resourceAccessQueue;
@property (nonatomic, readonly, weak) CENChatEngine *chatEngine;
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * @brief      Retrieve type of data object.
 * @discussion Supported data object types described in \c CENObjectType structure. Object types used to construct
 *             notification event identifiers.
 *
 * @return One of supported object types.
 */
+ (NSString *)objectType;


#pragma mark - Initialization and Configuration

- (instancetype)initWithChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief      Called by \b ChatEngine upon object removal from it.
 * @discussion This is good place to ensure what object removed from any persistent storage and all listeners removed as well.
 */
- (void)destruct;


#pragma mark - Handlers

/**
 * @brief  Handle \b ChatEngine object creation.
 */
- (void)onCreate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
