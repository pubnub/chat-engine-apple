#import "CENUser.h"
#import "CENEventEmitter+BuilderInterface.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENUser (BuilderInterface)


#pragma mark - State

/**
 * @brief Get cached state for user on specified \b {chat CENChat}.
 *
 * @discussion State populated and maintained by network updates.
 *
 * @discussion Get cached \b {user's CENUser} state for \b {CENChatEngine.global} chat
 * @code
 * // objc 1a6586b2-ba57-430b-b2d6-265dd891a0a5
 *
 * CENUser *user = self.client.User(@"PubNub").get();
 *
 * NSLog(@"State for '%@' previously set on global chat: %@", user.uuid, user.state(nil));
 * @endcode
 *
 * @discussion Get cached \b {user's CENUser} state for custom chat chat
 * @code
 * // objc 002ff26c-6835-442a-830f-dff739f20d65
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").create();
 * CENUser *user = self.client.User(@"PubNub").get();
 *
 * NSLog(@"State for '%@' previously set on '%@' chat: %@", user.uuid, chat.name,
 *       user.state(chat));
 * @endcode
 *
 * @param chat \b {Chat CENChat} for which \b {user's CENUser} state should be retrieved.
 *     Pass \c nil to use \b {CENChatEngine.global} chat (possible only if
 *     \b {CENConfiguration.enableGlobal} is set to \c YES during \b {ChatEngine CENChatEngine}
 *     client configuration).
 *
 * @return \a NSDictionary with \b {user's CENUser} state which has been set for \c chat earlier or
 * \c nil in case if not set.
 *
 * @since 0.10.0
 *
 * @ref 590b7902-9f8e-4ee1-b48d-d45f96916c70
 */
@property (nonatomic, readonly, strong) NSDictionary * __nullable (^state)(CENChat * __nullable chat);

/**
 * @brief Restore \b {user's CENUser} state for specific \b {chat CENChat}.
 *
 *
 * @discussion Restore users' state from \b {CENChatEngine.global} chat
 * @code
 * // objc 74685ac2-2135-4b02-867e-285d27ce2494
 *
 * self.client.User(@"PubNub").create().restoreState(nil);
 * @endcode
 *
 *
 * @discussion Restore users' state from custom chat
 * @code
 * // objc 28792db0-81bf-400e-adac-cc65b5e844b6
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").create();
 *
 * self.client.User(@"PubNub").create().restoreState(chat);
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
 * @ref ca77541f-c3f9-456f-8de4-ed8f3169853c
 */
@property (nonatomic, readonly, strong) CENUser * (^restoreState)(CENChat * __nullable chat);


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it with
 * provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc c3ce7c1d-42f6-4364-aaef-d96e785d0718
 *
 * self.client.User(@"PubNub").create()
 *     .on(@"$.error.restoreState.param", ^(CENEmittedEvent *event) {
 *         // Handler state restore error.
 *     });
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc dea66c89-9189-4f1b-b9ee-b3a4f2aa1369
 *
 * self.client.User(@"PubNub").create()
 *     .on(@"$.error.*", ^(CENEmittedEvent *event) {
 *         // Handle any emitted error.
 *     });
 * @endcode
 *
 * @param event Name of event which should be handled by \c block.
 * @param handler Block / closure which will handle specified \c event.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 3b1d52ed-9b19-4027-b50d-af043437db8e
 */
@property (nonatomic, readonly, strong) CENUser * (^on)(NSString *event,
                                                        CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc 4d882513-589e-443b-a553-6a00aa6d1557
 *
 * self.client.User(@"PubNub").create()
 *     .onAny(^(CENEmittedEvent *event) {
 *         // Handle any event emitted by object.
 *     });
 * @endcode
 
 * @param handler Block / closure which will handle any events.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 263ba3a4-b0b8-4505-9fde-09a3291c93ee
 */
@property (nonatomic, readonly, strong) CENUser * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it once with
 * provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc 5b76d7d0-30ed-4977-8b81-fcdd4d4cad06
 *
 * self.client.User(@"PubNub").create()
 *     .once(@"$.error.state.param", ^(CENEmittedEvent *event) {
 *         // Handler state fetch error once.
 *     });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc 34f5bc93-d7f5-40a9-b5f7-2a13b336a4a6
 *
 * self.client.User(@"PubNub").create()
 *     .once(@"$.error.*", ^(CENEmittedEvent *event) {
 *         // Handle any first emitted error.
 *     });
 * @endcode
 *
 * @param event Name of event which should be handled by \c block.
 * @param handler Block / closure which will handle specified \c event.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref a8223078-2d92-4bd6-a230-d8970b0f7438
 */
@property (nonatomic, readonly, strong) CENUser * (^once)(NSString *event,
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
 * // objc fab24fcc-e9a7-46b3-b0d8-cb9d288598e8
 *
 * self.errorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle state restore error.
 * };
 *
 * self.client.me.off(@"$.error.restoreState.param", self.errorHandlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 2b7a9854-03fb-4a6e-a358-433b22d33b84
 */
@property (nonatomic, readonly, strong) CENUser * (^off)(NSString *event,
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
 * // objc 7aa9de79-9a66-49fd-bf2d-999572930142
 *
 * self.anyErrorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any event emitted by object.
 * };
 *
 * self.user.offAny(self.anyErrorHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 40ebd53f-c8ac-4b22-9313-8a3942d8e8ef
 */
@property (nonatomic, readonly, strong) CENUser * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc b0ba935e-0d11-4deb-937d-4a4aa2ab2c22
 *
 * self.user.removeAll(@"$.error.restoreState.param");
 * @endcode
 *
 * @param event Name of event for which has been used to register handler blocks.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 8bd1125a-52ed-4570-972b-52eafdcbc4d4
 */
@property (nonatomic, readonly, strong) CENUser * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END

