/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENMe (BuilderInterface)


#pragma mark - State

/**
 * @brief Update \b {local user CENMe} state in a \b {CENChatEngine.global} chat.
 *
 * @discussion All other \b {users CENUser} will be notified of this change via \b {$.state}.
 * Retrieve state at any time with \b {CENUser.state}.
 *
 * @fires
 * - \b {$.error.auth CENChat}
 *
 * @discussion Update state
 * @code
 * // objc a78cd174-e6cc-4b02-bc81-3b6177c82b27
 *
 * self.client.me.update(@{ @"state": @"working" });
 * @endcode
 *
 * @param state \a NSDictionary which contain updated state for \b {local user CENMe}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref fd42194b-4626-452d-8393-a9602283947b
 */
@property (nonatomic, readonly, strong) CENMe * (^update)(NSDictionary *state);


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it with provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc b735d5e6-c3e6-486d-aa90-cdb7873e23de
 *
 * self.client.me.on(@"$.error.state.param", ^(CENEmittedEvent *event) {
 *     // Handler state update error.
 * });
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc ddc46914-0707-44d6-8795-138a059a4517
 *
 * self.client.me.on(@"$.error.*", ^(CENEmittedEvent *event) {
 *     // Handle any emitted error.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref de099a87-474b-4394-829f-be0d27c10e3f
 */
@property (nonatomic, readonly, strong) CENMe * (^on)(NSString *event,
                                                      CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc 07c858e4-5f99-4d26-8466-2b5c92d44545
 *
 * self.client.me.onAny(^(CENEmittedEvent *event) {
 *     // Handle any emitted events.
 * });
 * @endcode
 
 * @param handler Block / closure which will handle any events. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 98994633-76c8-4af7-8bad-4834c301bffd
 */
@property (nonatomic, readonly, strong) CENMe * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it once with provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc 26bd33e1-1bc3-4a33-9383-9c226f2b060b
 *
 * self.client.me.once(@"$.error.state.param", ^(CENEmittedEvent *event) {
 *     // Handler state update error once.
 * });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc 66631f72-abd2-41e2-b03e-417f392b8e52
 *
 * self.client.me.once(@"$.error.*", ^(CENEmittedEvent *event) {
 *     // Handle any first emitted error.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 33fe49da-fa8d-484f-a750-3bd2695db603
 */
@property (nonatomic, readonly, strong) CENMe * (^once)(NSString *event,
                                                        CENEventHandlerBlock handler);


#pragma mark - Handlers removal

/**
 * @brief Unsubscribe from particular or multiple (wildcard) \c events by removing \c handler from
 * listeners list.
 *
 * @note To be able to remove handler block / closure, it is required to store reference on it in
 * class which listens for updates.
 *
 * @discussion Stop specific event handling
 * @code
 * // objc f67bc12b-909a-4a70-9455-5e2fb171b69c
 *
 * self.errorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle state update error.
 * };
 *
 * self.client.me.off(@"$.error.state.param", self.errorHandlingBlock);
 * @endcode
 *
 * @discussion Stop multiple events handling
 * @code
 * // objc e437ea39-b211-4ebe-bfbe-6d8298e3d394
 *
 * self.errorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any first emitted error.
 * };
 *
 * self.client.me.off(@"$.error.*", self.errorHandlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 0dff154c-d7f4-4d16-bc0e-2c88928fd436
 */
@property (nonatomic, readonly, strong) CENMe * (^off)(NSString *event,
                                                       CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe from any events emitted by receiver by removing \c handler from
 * listeners list.
 *
 * @note To be able to remove handler block / closure, it is required to store reference on it in
 * class which listens for updates.
 *
 * @discussion Stop any events handling
 * @code
 * // objc 4ba12b0c-959c-4db0-97fd-768b92ee32ab
 *
 * self.anyErrorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any emitted events.
 * };
 *
 * self.client.me.offAny(self.anyErrorHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 0d93ac03-2ec8-4aae-bd92-a22a4e0f1fd5
 */
@property (nonatomic, readonly, strong) CENMe * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event or multiple (wildcard) \c events handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc 06d87227-59a1-4ea6-ad47-10afe8619920
 *
 * self.client.me.removeAll(@"$.error.state.param");
 * @endcode
 *
 * @discussion Remove multiple event handlers
 * @code
 * // objc c77b3222-ac17-45e2-8866-fc46032c3985
 *
 * self.client.me.removeAll(@"$.error.*");
 * @endcode
 *
 * @param event Name of event for which has been used to register handler blocks.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref e453c765-c186-43a7-b2a4-ceecc48807dd
 */
@property (nonatomic, readonly, strong) CENMe * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
