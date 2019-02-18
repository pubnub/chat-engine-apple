/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEventEmitter.h"
#import "CENStructures.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENEventEmitter (BuilderInterface)


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it with provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc 65b6554d-9cf1-4c3c-9dd9-a51958cbc588
 *
 * self.object.on(@"event", ^(CENEmittedEvent *event) {
 *     // Handle 'event' emitted by object.
 * });
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc 8fa074e0-b569-463e-8562-fb18d2e2ac2d
 *
 * self.object.on(@"event.*", ^(CENEmittedEvent *event) {
 *     // Handle 'event.a' and / or 'event.b' or emitted by object.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref b64e680a-9ea2-4b24-820a-1908878ce2ac
 */
@property (nonatomic, readonly, strong) CENEventEmitter * (^on)(NSString *event,
                                                                CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc 1ccd9e96-6a2d-4beb-8bb2-1b88309bef4e
 *
 * self.object.onAny(^(CENEmittedEvent *event) {
 *     // Handle any event emitted by object.
 * });
 * @endcode
 
 * @param handler Block / closure which will handle any events. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 135a906c-49e7-46ed-a835-311940b5a1e1
 */
@property (nonatomic, readonly, strong) CENEventEmitter * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it once with provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc 9e735acd-b4f3-4698-8561-128383d0c946
 *
 * self.object.once(@"event", ^(CENEmittedEvent *event) {
 *     // Handle 'event' emitted by object once.
 * });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc c3e1cea0-ce2a-4797-b91b-6c0befecd7b9
 *
 * self.object.once(@"event.*", ^(CENEmittedEvent *event) {
 *     // Handle 'event.a' and / or 'event.b' or emitted by object once.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 7c771fc2-89ac-461f-864d-5d4b8ec646b2
 */
@property (nonatomic, readonly, strong) CENEventEmitter * (^once)(NSString *event,
                                                                  CENEventHandlerBlock handler);


#pragma mark - Handlers removal

/**
 * @brief Unsubscribe from particular or multiple (wildcard) \c events by removing \c handler from
 * listeners list.
 *
 * @note To be able to remove handler block / closure, it is required to store reference on it in
 * instance which listens for updates.
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
 * self.object.off(@"event", self.handlingBlock);
 * @endcode
 *
 * @discussion Stop multiple events handling
 * @code
 * // objc 97cf3c3c-ab0b-49cf-b376-48b3b3e5b896
 *
 * self.handlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle 'event.a' and / or 'event.b' or emitted by object.
 * };
 *
 * // Later, when event handling not required anymore.
 * self.object.off(@"event.*", self.handlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 6aa74473-f670-4c36-b2a3-54ce4b2be023
 */
@property (nonatomic, readonly, strong) CENEventEmitter * (^off)(NSString *event,
                                                                 CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe from any events emitted by receiver by removing \c handler from
 * listeners list.
 *
 * @note To be able to remove handler block / closure, it is required to store reference on it in
 * instance which listens for updates.
 *
 * @discussion Stop any events handling
 * @code
 * // objc 07226174-098b-46dc-873c-2724a011c797
 *
 * self.anyHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any event emitted by object.
 * };
 *
 * // Later, when event handling not required anymore.
 * self.client.offAny(self.invitationHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 8534c8c0-0271-437f-8c5c-24a27773253c
 */
@property (nonatomic, readonly, strong) CENEventEmitter * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event or multiple (wildcard) \c events handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc 34a4f615-4479-4c80-a39d-e87443da5d06
 *
 * self.object.removeAll(@"event");
 * @endcode
 *
 * @discussion Remove multiple event handlers
 * @code
 * // objc 39843055-33af-478e-9986-4d1f09b2821f
 *
 * self.object.removeAll(@"event.*");
 * @endcode
 *
 * @param event Name of event for which has been used to register handler blocks.
 *
 * @return Receiver which can be used to chain other methods call.
 */
@property (nonatomic, readonly, strong) CENEventEmitter * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
