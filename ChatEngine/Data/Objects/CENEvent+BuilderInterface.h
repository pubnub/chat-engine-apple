#import "CENEvent.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Builder interface declaration

@interface CENEvent (BuilderInterface)


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it with
 * provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc 4f3f3988-3ad3-4ffb-9637-54ccfca2f5dd
 
 * self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" }).perform()
 *     .on(@"$.emitted", ^(CENEmittedEvent *event) {
 *         // Handle event emit completion.
 *     });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc 68b9453c-6fcf-4cd4-9770-afe0bfedd303
 
 * self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" }).perform()
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
 * @ref ead126a1-1bf9-4642-97f1-a51e09425747
 */
@property (nonatomic, readonly, strong) CENEvent * (^on)(NSString *event,
                                                         CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc 0f2a267f-e28b-4e67-ad8c-0a6ca60be594
 *
 * self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" }).perform()
 *     .onAny(^(CENEmittedEvent *event) {
 *         // Handle any event emitted by object.
 *     });
 * @endcode
 
 * @param handler Block / closure which will handle any events.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 3ed464b2-582d-46a1-bc76-51316071360f
 */
@property (nonatomic, readonly, strong) CENEvent * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular \c event which will be emitted by receiver and handle it once with
 * provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc d6763664-f866-4c8d-81c4-32e54d2f9c78
 *
 * self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" }).perform()
 *     .once(@"$.emitted", ^(CENEmittedEvent *event) {
 *         // Handle emitted event.
 *     });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc 91a3a62e-8aaf-4b84-9279-bc448769374d
 *
 * self.chat.emit(@"test-event").data(@{ @"message": @"Hello world" }).perform()
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
 * @ref e584ad68-c719-4184-b384-232dbe356f44
 */
@property (nonatomic, readonly, strong) CENEvent * (^once)(NSString *event,
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
 * // objc 41724efa-ed81-498c-975d-36c98361cb40
 *
 * self.emitCompletionHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle successful event emit.
 * };
 *
 * self.event.off(@"$.emitted", self.emitCompletionHandlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 5970c5a3-2c7b-4290-9d08-5f92d58ba97c
 */
@property (nonatomic, readonly, strong) CENEvent * (^off)(NSString *event,
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
 * // objc eb43cc2f-71a2-4758-bcd7-9e28cbc3f4e3
 *
 * self.anyHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any event emitted by object.
 * };
 *
 * self.event.offAny(self.anyHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 7ae64ec2-2f3d-4fcf-9e56-c22059bbc6d7
 */
@property (nonatomic, readonly, strong) CENEvent * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event handling blocks from event processing.
 *
 * @discussion Remove all '$.emitted' event listeners:
 * @code
 * // objc e7d7a77b-5bba-4e72-a681-d5fe8cb874f3
 *
 * self.event.removeAll(@"$.emitted");
 * @endcode
 *
 * @param event Name of event for which has been used to register handler blocks.
 *
 * @return Receiver which can be used to chain other methods call.
 *
 * @ref 51190ade-5d29-41d5-8119-7396786a6e07
 */
@property (nonatomic, readonly, strong) CENEvent * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
