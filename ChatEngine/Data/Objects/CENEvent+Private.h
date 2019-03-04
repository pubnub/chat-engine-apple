/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEvent.h"


#pragma mark Class forward

@class CENChatEngine, CENChat;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENEvent (Private)


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure event emitter.
 *
 * @param event Name of event which should be emitted.
 * @param chat \b {Chat CENChat} to which \c event should be emitted.
 * @param chatEngine \b {CENChatEngine} which manage \b {chat CENChat} to which event
 *     should be emitted.
 *
 * @return Configured and ready to use event emitter.
 */
+ (instancetype)eventWithName:(NSString *)event
                         chat:(CENChat *)chat
                   chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Publishing

/**
 * @brief Pre-process with middlewares and emit passed \c data.
 *
 * @param data \a NSMutableDictionary with default \b {CENChatEngine} event payload which
 *     will be passed through middlewares and emitted.
 */
- (void)publish:(NSMutableDictionary *)data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
