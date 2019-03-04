/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSearch.h"
#import "CENEventEmitter+BuilderInterface.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENSearch (BuilderInterface)


#pragma mark - Searching

/**
 * @brief Search through previously emitted events.
 *
 * @discussion Make initial search call
 * @code
 * // objc ce884f00-c7ff-40dd-87ea-7f73df6f0202
 *
 * self.chat.search().event(@"announcement").create().search();
 * @endcode
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 5f5c8359-31f3-410a-9265-b326314dbe5e
 */
@property (nonatomic, readonly, strong) CENSearch * (^search)(void);

/**
 * @brief Search for older events (if possible).
 *
 * @discussion Make initial search call
 * @code
 * // objc ddd1467e-7d7b-4c05-8e7b-f17e0e99c641
 *
 * CENSearch *search = self.chat.search().event(@"announcement").create();
 *
 * search.search().once(@"$.search.pause", ^(CENEmittedEvent *event) {
 *     // Handle search pause because any of specified limits has been reached.
 *     search.next();
 * });
 * @endcode
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 773459ef-4c30-46b2-9324-c5f34ae9f3a3
 */
@property (nonatomic, readonly, strong) CENSearch * (^next)(void);


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it with provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc f3744a36-d0c9-460d-aee7-0800181c0ec1
 *
 * self.search.on(@"ping", ^(CENEmittedEvent *event) {
 *     // Handle 'ping' event from chat's history.
 * });
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc c8e64544-fe56-4cbe-becc-22940181af38
 *
 * self.search.on(@"$typingIndicator.*", ^(CENEmittedEvent *event) {
 *     // Handle '$typingIndicator.startTyping' and / or '$typingIndicator.stopTyping' event from
 *     // chat's history.
 * });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 2cfdd8b4-f4d2-4c1b-b007-e8cdee660b5b
 */
@property (nonatomic, readonly, strong) CENSearch * (^on)(NSString *event,
                                                          CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc c0f46b2f-48d2-434e-ae78-d2984d7b399b
 *
 * self.search.onAny(^(CENEmittedEvent *event) {
 *     // Handle emitted event.
 * });
 * @endcode
 
 * @param handler Block / closure which will handle any events. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 3494aa7c-31d5-49ae-a593-fe81d5d49e16
 */
@property (nonatomic, readonly, strong) CENSearch * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it once with provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc 9e813a82-7e2f-459d-9576-490419bce590
 *
 * self.search.once(@"ping", ^(CENEmittedEvent *event) {
 *     // Handle 'ping' event from chat's history once.
 * });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc 53ced580-202c-4bae-b24a-03f7f6421be0
 *
 * self.search.once(@"$.error.*", ^(CENEmittedEvent *event) {
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
 * @ref 1d02e259-b247-4780-989e-55c9bf0877db
 */
@property (nonatomic, readonly, strong) CENSearch * (^once)(NSString *event,
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
 * // objc 25706655-a444-4880-805b-011d8f617e4d
 *
 * self.pingHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle 'ping' event from chat's history.
 * };
 *
 * self.search.off(@"ping", self.pingHandlingBlock);
 * @endcode
 *
 * @discussion Stop multiple event handling
 * @code
 * // objc 096edf61-4294-466a-9e53-f0615afc969e
 *
 * self.errorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any first emitted error.
 * };
 *
 * self.search.off(@"$.error.*", self.errorHandlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 076dc372-d31d-4026-ae8b-87dd3385fc8a
 */
@property (nonatomic, readonly, strong) CENSearch * (^off)(NSString *event,
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
 * // objc 474f43af-db04-4b37-aa8b-8a12fe584182
 *
 * self.anyHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle event.
 * };
 *
 * self.search.offAny(self.anyHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 5521a02a-7faa-4a57-9612-2808ef9200de
 */
@property (nonatomic, readonly, strong) CENSearch * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event or multiple (wildcard) \c events handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc af0c82a0-e5f9-48cf-b17f-3e51ef23050b
 *
 * self.search.removeAll(@"ping");
 * @endcode
 *
 * @discussion Remove multiple event handlers
 * @code
 * // objc 8674dcb5-df94-4464-94d3-37970ca8a6a1
 *
 * self.search.removeAll(@"$.error.*");
 * @endcode
 *
 * @param event Reference on event which has been used to register handler blocks.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 45c7928b-020b-4ee9-8b13-c21b7079a3e0
 */
@property (nonatomic, readonly, strong) CENSearch * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
