#import "CENChatEngine.h"


#pragma mark Class forward

@class CENEvent, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine client interface for event publishing.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (Publish)

/**
 * @brief  Create and configure event emitting instance.
 * @discussion Instance responsible for event delivery and progress updates notifications.
 *
 * @param chat      Reference on chat to which \c event should emit \c data.
 * @param eventName Reference on name of event which will allow to identify it on another side (participants of
 *                  chat).
 * @param data      Reference on object which should be sent along with event.
 *
 * @return Configured and ready to use event emittin instance.
 */
- (CENEvent *)publishToChat:(CENChat *)chat eventWithName:(NSString *)eventName data:(NSDictionary *)data;

/**
 * @brief  Perform actual data push using underlying \b PubNub client.
 *
 * @param shouldStoreInHistory Whether pushed data should be stored and available with history API.
 * @param event                Reference on name of event which will allow to identify it on another side
 *                             (participants of chat).
 * @param channel              Reference on channel (unique chat channel) to which data should be pushed.
 * @param data                 Reference on object which should be sent along with event.
 * @param block                Reference on block which should be called at the end of data push process. Block
 *                             pass only one argument - timestamp of time when \c data reached \b PubNub service.
 */
- (void)publishStorable:(BOOL)shouldStoreInHistory
                  event:(CENEvent *)event
              toChannel:(NSString *)channel
               withData:(NSDictionary *)data
             completion:(void(^)(NSNumber *))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
