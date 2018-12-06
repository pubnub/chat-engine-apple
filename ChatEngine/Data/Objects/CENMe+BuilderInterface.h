#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENMe (BuilderInterface)


#pragma mark - State

/**
 * @brief Update \b {local user CENMe} state in a \b {chat CENChat}.
 *
 * @discussion All other \b {users CENUser} will be notified of this change via \b {$.state}.
 * Retrieve state at any time with \b {CENUser.state}.
 *
 * @discussion Update state in a \b {CENChatEngine.global} chat
 * @code
 * // objc a78cd174-e6cc-4b02-bc81-3b6177c82b27
 *
 * // Update local user state when it will be required.
 * self.client.me.update(@{ @"state": @"working" }, nil);
 * @endcode
 *
 * @discussion Update state in a custom chat
 * @code
 * // objc 33b242f0-6909-497a-9e9c-fd0c06d923cc
 *
 * // Create chat which will be used by application to store users' state in it.
 * CENChat *stateChat = self.client.Chat().name(@"users-state").create();
 *
 * // Update local user state when it will be required.
 * self.client.me.update(@{ @"state": @"working" }, stateChat);
 * @endcode
 *
 * @param state \a NSDictionary which contain updated state for \b {local user CENMe}.
 * @param chat \b {Chat CENChat} where state will be updated.
 *     Pass \c nil to use \b {CENChatEngine.global} chat (possible only if
 *     \b {CENConfiguration.enableGlobal} is set to \c YES during \b {ChatEngine CENChatEngine}
 *     client configuration).
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @since 0.10.0
 *
 * @ref fd42194b-4626-452d-8393-a9602283947b
 */
@property (nonatomic, readonly, strong) CENMe * (^update)(NSDictionary * __nullable state,
                                                          CENChat * __nullable chat);

/**
 * @brief Restore \b {local user CENMe} state from specific \b {chat CENChat}.
 *
 * @discussion Restore users' state from \b {CENChatEngine.global} chat
 * @code
 * // objc dfd2d1f6-f4a5-440c-b7e2-1ad9b1fcedf7
 *
 * // Create chat which will be used by application to store users' state in it.
 * CENChat *stateChat = self.client.Chat().name(@"users-state").create();
 *
 * // Fetch local user state from global chat.
 * self.client.me.restoreState(nil);
 * @endcode
 *
 * @discussion Restore users' state from custom chat
 * @code
 * // objc a593ca83-c54e-4b44-bc68-1a31de671b22
 *
 * // Create chat which will be used by application to store users' state in it.
 * CENChat *stateChat = self.client.Chat().name(@"users-state").create();
 *
 * // Fetch local user state from specific chat.
 * self.client.me.restoreState(stateChat);
 * @endcode
 *
 * @param chat \b {Chat CENChat} from which state should be restored.
 *     Pass \c nil to use \b {CENChatEngine.global} chat (possible only if
 *     \b {CENConfiguration.enableGlobal} is set to \c YES during \b {ChatEngine CENChatEngine}
 *     client configuration).
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @since 0.10.0
 *
 * @ref 11d57605-6d4d-437d-8f64-1dd83b088aa8
 */
@property (nonatomic, readonly, strong) CENMe * (^restoreState)(CENChat * __nullable chat);


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it with
 * provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc b735d5e6-c3e6-486d-aa90-cdb7873e23de
 *
 * self.client.me.on(@"$.error.updateParam", ^(CENEmittedEvent *event) {
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
 * @param event Name of event which should be handled by \c block.
 * @param handler Block / closure which will handle specified \c event.
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
 
 * @param handler Block / closure which will handle any events.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 98994633-76c8-4af7-8bad-4834c301bffd
 */
@property (nonatomic, readonly, strong) CENMe * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it once with
 * provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc 26bd33e1-1bc3-4a33-9383-9c226f2b060b
 *
 * self.client.me.once(@"$.error.updateParam", ^(CENEmittedEvent *event) {
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
 * @param event Name of event which should be handled by \c block.
 * @param handler Block / closure which will handle specified \c event.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 33fe49da-fa8d-484f-a750-3bd2695db603
 */
@property (nonatomic, readonly, strong) CENMe * (^once)(NSString *event,
                                                        CENEventHandlerBlock handler);


#pragma mark - Handlers removal

/**
 * @brief Unsubscribe from particular \c event by removing \c handler from listeners list.
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
 * self.client.me.off(@"$.error.updateParam", self.errorHandlingBlock);
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
 * @brief Unsubscribe all \c event handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc 06d87227-59a1-4ea6-ad47-10afe8619920
 *
 * self.client.me.removeAll(@"$.error.restoreState.param");
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
