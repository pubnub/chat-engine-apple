#import "CENChatEngine.h"


#pragma mark Class forward

@class CENEvent, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for event publishing.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (Publish)

/**
 * @brief Create and configure event \b {emitter CENEvent} instance.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - data is not \a NSDictionary.
 *
 * @param chat \b {Chat CENChat} to which \c event should emit \c data.
 * @param eventName Name of event which will allow to identify it on another side (participants of
 *     chat).
 * @param data Dictionary with data which should be sent along with event.
 *
 * @return Configured and ready to use event \b {emitter CENEvent} instance or \c nil in case if
 *     critical internal data missing.
 */
- (nullable CENEvent *)publishToChat:(CENChat *)chat
                       eventWithName:(NSString *)eventName
                                data:(NSDictionary *)data;

/**
 * @brief Perform actual data push using underlying \b PubNub client.
 *
 * @param shouldStoreInHistory Whether pushed data should be stored and available with history API
 *     or not.
 * @param event Event \b {emitter CENEvent} instance.
 * @param channel Channel (unique chat channel) to which data should be pushed.
 * @param data Object which should be sent along with event.
 * @param block Event emitting completion handler which pass date when payload has been delivered to
 *     \b PubNub service.
 */
- (void)publishStorable:(BOOL)shouldStoreInHistory
                  event:(CENEvent *)event
              toChannel:(NSString *)channel
               withData:(NSDictionary *)data
             completion:(void(^)(NSNumber *))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
