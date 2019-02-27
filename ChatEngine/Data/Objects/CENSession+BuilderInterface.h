/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSession.h"
#import "CENEventEmitter+BuilderInterface.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENSession (BuilderInterface)


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it with provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc 710e4292-bdde-4d11-90fe-83efc906b13c
 *
 * self.client.me.session.on(@"$.group.restored", ^(CENEmittedEvent *event) {
 *     // Handle user's chats group restore completion.
 * });
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc afb46b80-488f-47e1-ae90-a372a36bdf4e
 *
 * self.client.me.session.on(@"$.chat.*", ^(CENEmittedEvent *event) {
 *     // Handle '$.chat.join' and / or '$.chat.leave' chats synchronization events.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 695850ab-e1da-4b69-aed3-288b5a1d7e77
 */
@property (nonatomic, readonly, strong) CENSession * (^on)(NSString *event,
                                                           CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc ca86bfcf-2513-4022-a940-2434491c7a0c
 *
 * self.client.me.session.onAny(^(CENEmittedEvent *event) {
 *     // Handle emitted event.
 * });
 * @endcode

 * @param handler Block / closure which will handle any events. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref bd5e41d1-0384-4e35-8129-0ca54bfb3b2c
 */
@property (nonatomic, readonly, strong) CENSession * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it once with provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc 9f8f77a4-ee7c-45d4-b2f8-103825edf69f
 *
 * self.client.me.session.once(@"$.group.restored", ^(CENEmittedEvent *event) {
 *     // Handle user's chats group restore completion once.
 * });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc c1880e2b-dc08-4ddd-bbdc-c9815f6453a1
 *
 * self.client.me.session.once(@"$.chat.*", ^(CENEmittedEvent *event) {
 *     // Handle any chats synchronization event.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref cba87f90-355d-418c-928c-e03595440fb0
 */
@property (nonatomic, readonly, strong) CENSession * (^once)(NSString *event,
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
 * // objc e6aadc52-3ab4-4e7c-a6d3-83c9d96064f4
 *
 * self.restoreHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle user's chats group restore completion.
 * };
 *
 * self.client.me.session.off(@"$.group.restored", self.restoreHandlingBlock);
 * @endcode
 *
 * @discussion Stop multiple event handling
 * @code
 * // objc 8bc2a4c6-e106-46b0-a3a3-d8953d394ed1
 *
 * self.syncHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any chats synchronization event.
 * };
 *
 * self.client.me.session.off(@"$.chat.*", self.syncHandlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 2546f764-34b0-407b-808a-c45e1b114b43
 */
@property (nonatomic, readonly, strong) CENSession * (^off)(NSString *event,
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
 * // objc 9f72f722-7342-4979-88d1-fba1fa73e12d
 *
 * self.anyHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle event.
 * };
 *
 * self.client.me.session.offAny(self.anyHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 7631115b-4c71-489c-b781-9adba011f995
 */
@property (nonatomic, readonly, strong) CENSession * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event or multiple (wildcard) \c events handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc d890f3d9-5911-4189-8cc7-21b1e10d7bf9
 *
 * self.client.me.session.removeAll(@"$.chat.join");
 * @endcode
 *
 * @discussion Remove multiple event handlers
 * @code
 * // objc 4eecf7d5-6ca7-40b6-ac3f-c76edb47b8fc
 *
 * self.client.me.session.removeAll(@"$.chat.*");
 * @endcode
 *
 * @param event Reference on event which has been used to register handler blocks.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 73d0f679-0838-4723-8ac5-9b2deb3c13f0
 */
@property (nonatomic, readonly, strong) CENSession * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END