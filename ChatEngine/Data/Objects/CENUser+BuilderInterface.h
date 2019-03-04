/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEventEmitter+BuilderInterface.h"
#import "CENUser.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENUser (BuilderInterface)


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it with provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc c3ce7c1d-42f6-4364-aaef-d96e785d0718
 *
 * self.client.User(@"PubNub").create()
 *     .on(@"$.error.state.param", ^(CENEmittedEvent *event) {
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
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
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
 
 * @param handler Block / closure which will handle any events. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 263ba3a4-b0b8-4505-9fde-09a3291c93ee
 */
@property (nonatomic, readonly, strong) CENUser * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it once with provided event handler.
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
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref a8223078-2d92-4bd6-a230-d8970b0f7438
 */
@property (nonatomic, readonly, strong) CENUser * (^once)(NSString *event,
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
 * // objc fab24fcc-e9a7-46b3-b0d8-cb9d288598e8
 *
 * self.errorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle state restore error.
 * };
 *
 * self.user.off(@"$.error.state.param", self.errorHandlingBlock);
 * @endcode
 *
 * @discussion Stop multiple events handling
 * @code
 * // objc 4a1f90f5-0052-4efd-9830-3ea0dc6ed328
 *
 * self.errorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any emitted error.
 * };
 *
 * self.user.off(@"$.error.*", self.errorHandlingBlock);
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
 * @brief Unsubscribe all \c event or multiple (wildcard) \c events handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc b0ba935e-0d11-4deb-937d-4a4aa2ab2c22
 *
 * self.user.removeAll(@"$.error.state.param");
 * @endcode
 *
 * @discussion Remove multiple event handlers
 * @code
 * // objc 8c3784bf-1e92-439f-8989-54da92f16841
 *
 * self.user.removeAll(@"$.error.*");
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

