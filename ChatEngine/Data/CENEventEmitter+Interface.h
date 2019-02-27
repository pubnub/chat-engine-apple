/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEventEmitter.h"
#import "CENStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Default interface declaration

@interface CENEventEmitter (Interface)


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it with
 * provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc 65b6554d-9cf1-4c3c-9dd9-a51958cbc588
 *
 * [self.object handleEvent:@"event" withHandlerBlock:^(CENEmittedEvent *event) {
 *     // Handle 'event' emitted by object.
 * }];
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc 8fa074e0-b569-463e-8562-fb18d2e2ac2d
 *
 * [self.object handleEvent:@"event.*" withHandlerBlock:^(CENEmittedEvent *event) {
 *     // Handle 'event.a' and / 'event.b' or emitted by object.
 * }];
 * @endcode
 *
 * @discussion Handle any event using wildcard
 * @code
 * // objc 1ccd9e96-6a2d-4beb-8bb2-1b88309bef4e
 *
 * [self.client handleEvent:@"*" withHandlerBlock:^(CENEmittedEvent *event) {
 *     // Handle any event emitted by object.
 * }];
 * @endcode
 *
 * @param event Name of event which should be handled by \c block.
 * @param handler Block / closure which will handle specified \c event.
 *
 * @ref b64e680a-9ea2-4b24-820a-1908878ce2ac
 * @ref 135a906c-49e7-46ed-a835-311940b5a1e1
 */
- (void)handleEvent:(NSString *)event withHandlerBlock:(CENEventHandlerBlock)handler;

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it once with
 * provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc 9e735acd-b4f3-4698-8561-128383d0c946
 *
 * [self.object handleEventOnce:@"event" withHandlerBlock:^(CENEmittedEvent *event) {
 *     // Handle 'event' emitted by object.
 * }];
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc c3e1cea0-ce2a-4797-b91b-6c0befecd7b9
 *
 * [self.object handleEventOnce:@"event.*" withHandlerBlock:^(CENEmittedEvent *event) {
 *     // Handle 'event.a' and / 'event.b' or emitted by object.
 * }];
 * @endcode
 *
 * @param event Name of event which should be handled by \c block.
 * @param handler Block / closure which will handle specified \c event.
 *
 * @ref 7c771fc2-89ac-461f-864d-5d4b8ec646b2
 */
- (void)handleEventOnce:(NSString *)event withHandlerBlock:(CENEventHandlerBlock)handler;


#pragma mark - Handlers removal

/**
 * @brief Unsubscribe from particular \c event by removing \c handler from listeners list.
 *
 * @note To be able to remove handler block / closure, it is required to store reference on it in
 * class which listens for updates.
 *
 * @discussion Stop specific event handling
 * @code
 * // objc 6d9101fc-3a2b-4e32-96a1-74e3ace1a209
 *
 * self.handlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle 'event' emitted by object.
 * };
 *
 * // Later, when event handling not required anymore.
 * [self.object removeHandler:self.handlingBlock forEvent:@"event"];
 * @endcode
 *
 * @discussion Stop any events handling
 * @code
 * // objc 07226174-098b-46dc-873c-2724a011c797
 *
 * self.handlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any event emitted by object.
 * };
 *
 * // Later, when event handling not required anymore.
 * [self.object removeHandler:self.handlingBlock forEvent:@"*"];
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 * @param event Name of event for which handler should be removed.
 *
 * @ref 6aa74473-f670-4c36-b2a3-54ce4b2be023
 * @ref 8534c8c0-0271-437f-8c5c-24a27773253c
 */
- (void)removeHandler:(CENEventHandlerBlock)handler forEvent:(NSString *)event;

/**
 * @brief Unsubscribe all \c event handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc 34a4f615-4479-4c80-a39d-e87443da5d06
 *
 * [self.object removeAllHandlersForEvent:@"event"];
 * @endcode
 *
 * @param event Name of event for which has been used to register handler blocks.
 *
 * @ref d598b01c-8e8e-42c4-8a21-74b0531a8a82
 */
- (void)removeAllHandlersForEvent:(NSString *)event;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
