#import "CENEventEmitter.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Events signalling.
 * @discussion This class provide interface to subscribe and emit events for it's subclasses.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENEventEmitter (Interface)


#pragma mark - Handlers addition

/**
 * @brief      Subscribe on particular \c event which will be emitted by receiver and handle with provided event handling
 *             \b handlerBlock.
 * @discussion It is possible to specify specific event to be handler or use wildcard specified (*) to route all events
 *             emitted by \b ChatEngine and it's comonents.
 *
 * @discussion Handle client initialization complection:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEvent:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     // Handle client connection complete.
 * }];
 * [self.client connect:@"ChatEngine"];
 * @endcode
 *
 * @param event Reference on event name which should be handled by \c block.
 * @param block Reference on GCD block which will handle specified \c event.
 */
- (void)handleEvent:(NSString *)event withHandlerBlock:(id)block;

/**
 * @brief      Subscribe on particular \c event which will be emitted by receiver and handle once with provided event 
 *             handling \b handlerBlock.
 * @discussion It is possible to specify specific event to be handler or use wildcard specified (*) to route all events
 *             emitted by \b ChatEngine and it's comonents.
 *
 * @discussion Handle user invitation once:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me.direct handleEventOnce:@"$.invite" withHandlerBlock:^(NSDictionary *invitationData){
 *         // Handle invitation from invitationData.sender to join invitationData.channel.
 *     }];
 * }];
 * [self.client connect:@"ChatEngine"];
 * @endcode
 *
 * @param event Reference on event name which should be handled by \c block.
 * @param block Reference on GCD block which will handle specified \c event.
 */
- (void)handleEventOnce:(NSString *)event withHandlerBlock:(id)block;


#pragma mark - Handlers removal

/**
 * @brief      Unsubscribe from particular \c event by removing \c handlerBlock from notifiers list.
 * @discussion \b Important: to be able to remove handling block, it is required to store reference on it in class which
 *             listens for updates. Newly created block won't remove previously registered \c handler.
 *
 * @discussion Remove user's invitation event handler:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.invitationHandlingBlock = ^(NSDictionary *invitationData) {
 *     // Handle invitation from invitationData.sender to join invitationData.channel.
 * };
 *
 * [self.client handleEvent:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me.direct handleEvent:@"$.invite" withHandlerBlock:self.invitationHandlingBlock];
 * }];
 * [self.client connect:@"ChatEngine"];
 * ...
 * [self.client.me removeHandler:self.invitationHandlingBlock forEvent:@"$.invite"];
 * @endcode
 *
 * @param block Reference on GCD block which previously has been used to register for event for specified \c event.
 * @param event Reference on name of event for which handling \c block should be removed.
 */
- (void)removeHandler:(id)block forEvent:(NSString *)event;

/**
 * @brief  Remove all handler blocks for specified \c event.
 *
 * @discussion Remove all '$.invite' event listeners:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEvent:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me.direct handleEvent:@"$.invite" withHandlerBlock:^(NSDictionary *invitationData) {
 *         // Do something with sender.
 *     }];
 *     [me.direct handleEvent:@"$.invite" withHandlerBlock:^(NSDictionary *invitationData) {
 *         // Do something with channel data.
 *     }];
 * }];
 * [self.client connect:@"ChatEngine"];
 * ...
 * [self.client.me removeAllHandlersForEvent:@"$.invite"];
 * @endcode
 *
 * @param event Reference on name of event for which \c handlerBlock should be removed.
 */
- (void)removeAllHandlersForEvent:(NSString *)event;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
