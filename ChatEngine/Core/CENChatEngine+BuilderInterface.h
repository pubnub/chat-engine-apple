/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENChatEngine (BuilderInterface)


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it with provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc 90d83c8b-1308-4d4a-9b95-56c8c27a0597
 *
 * self.client.on(@"$.created.chat", ^(CENEmittedEvent *event) {
 *     // Handle chat instance creation.
 * });
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc 5c04e7ce-fe29-4739-b65a-d79203e439ed
 *
 * self.client.on(@"$.created.*", ^(CENEmittedEvent *event) {
 *     // Handle object creation events: $.created.chat, $.created.user,
 *     // $.created.me, $.created.search and other.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref d30303c3-b285-4d32-bbcc-eaffafce66e0
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^on)(NSString *event,
                                                              CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc 95b4f6ae-1b4e-45ee-91e1-33b0dad53a1a
 *
 * self.client.onAny(^(CENEmittedEvent *event) {
 *     // Handle any client event.
 * });
 * @endcode

 * @param handler Block / closure which will handle any events. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 8a039941-155b-45d5-9bf1-aae48e7076ed
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it once with provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc f10bf2f1-fbab-4219-8b40-c025093c74ea
 *
 * self.client.once(@"$.created.chat", ^(CENEmittedEvent *event) {
 *     // Handle chat instance creation once.
 * });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc f1a91aba-7e29-44fa-b74b-aab07454a1e7
 *
 * self.client.once(@"$.created.*", ^(CENEmittedEvent *event) {
 *     // Handle any object creation event once: $.created.chat, $.created.user,
 *     // $.created.me, $.created.search and other.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 1dc639e8-4b13-49da-bc50-8b549b4fa614
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^once)(NSString *event,
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
 * // objc a5283e6b-3f14-4bd3-bb02-c44f762181d9
 *
 * self.createHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle chat instance creation.
 * };
 *
 * self.client.off(@"$.created.chat", self.createHandlingBlock);
 * @endcode
 *
 * @discussion Stop multiple event handling
 * @code
 * // objc 16a79f03-be2e-43c2-ba38-23f3e55a47e7
 *
 * self.createHandlingBlock = ^(id emitter, NSDictionary *payload) {
 *     // Handle object creation events: $.created.chat, $.created.user,
 *     // $.created.me, $.created.search and other.
 * };
 *
 * self.client.off(@"$.created.*", self.createHandlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 625ef297-fd7c-456f-9e8a-5d148470059e
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^off)(NSString *event,
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
 * // objc 02b724a9-d216-4707-8d09-62e60f9f01c2
 *
 * self.anyHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any client event.
 * };
 *
 * self.client.offAny(self.anyHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref aa600067-c18c-4216-a726-189cdfe41236
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event or multiple (wildcard) \c events handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc 13b5524a-f52e-48ad-a435-63e844e3b565
 *
 * self.client.removeAll(@"$.created.chat");
 * @endcode
 *
 * @discussion Remove multiple event handlers
 * @code
 * // objc c8d9595a-6e68-4d05-a717-b8f1e0b33d16
 *
 * self.client.removeAll(@"$.created.*");
 * @endcode
 *
 * @param event Reference on event which has been used to register handler blocks.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 724bc0df-9b74-4538-ab0c-3b5f8fcb06de
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END