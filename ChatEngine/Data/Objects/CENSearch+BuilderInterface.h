#import "CENSearch.h"
#import "CENEventEmitter+BuilderInterface.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Chat room history search.
 * @discussion This instance can be used to fetch older events for \c chat for which it has been created.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENSearch (BuilderInterface)


#pragma mark - Searching

/**
 * @brief  Perform initial search.
 */
@property (nonatomic, readonly, strong) CENSearch * (^search)(void);

/**
 * @brief  Search for older events (if possible).
 */
@property (nonatomic, readonly, strong) CENSearch * (^next)(void);


#pragma mark - Handlers addition

/**
 * @brief      Subscribe on particular \c event which will be emitted by receiver and handle with provided event handling
 *             \b handlerBlock.
 * @discussion Builder block allow to specify \b required fields: \c event - name of event on which handler should be called;
 *             \c handlerBlock - reference on event handling block.
 *
 * @discussion Handle client initialization complection:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.on(@"$.ready", ^(CENMe *me) {
 *     // Handle client connection complete.
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @return Refererence on \b CENChat subclass which can be used to chain other methods call.
 */
@property (nonatomic, readonly, strong) CENSearch * (^on)(NSString *event, id handlerBlock);

/**
 * @brief      Subscribe on any events which will be emitted by receiver and handle with provided event handling
 *             \b handlerBlock.
 * @discussion Builder block allow to specify \b required field - reference on event handling block.
 *
 * @discussion Handle any events emitted by client:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.onAny(^(NSString *event, CENObject *sender, id data) {
 *     // Handle event.
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @return Refererence on \b CENChat subclass which can be used to chain other methods call.
 */
@property (nonatomic, readonly, strong) CENSearch * (^onAny)(id handlerBlock);

/**
 * @brief      Subscribe on particular \c event which will be emitted by receiver and handle once with provided event
 *             handling \b handlerBlock.
 * @discussion Builder block allow to specify \b required fields: \c event - name of event on which handler should be called;
 *             \c handlerBlock - reference on event handling block.
 *
 * @discussion Handle user invitation once:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.on(@"$.ready", ^(CENMe *me) {
 *     me.direct.once(@"$.invite", ^(NSDictionary *invitationData) {
 *         // Handle invitation from invitationData.sender to join invitationData.channel.
 *     });
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @return Refererence on \b CENChat subclass which can be used to chain other methods call.
 */
@property (nonatomic, readonly, strong) CENSearch * (^once)(NSString *event, id handlerBlock);


#pragma mark - Handlers removal

/**
 * @brief      Unsubscribe from particular \c event by removing \c handlerBlock from notifiers list.
 * @discussion \b Important: to be able to remove handling block, it is required to store reference on it in class which
 *             listens for updates. Newly created block won't remove previously registered \c handler.
 * @discussion Builder block allow to specify \b required fields: \c event - name of event from which event handler should
 *             removed; \c handlerBlock - reference on event handling block which previously has been used to handle this
 *             event.
 *
 * @discussion Remove user's invitation event handler:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.invitationHandlingBlock = ^(NSDictionary *invitationData) {
 *     // Handle invitation from invitationData.sender to join invitationData.channel.
 * };
 *
 * self.client.on(@"$.ready", ^(CENMe *me) {
 *     me.direct.once(@"$.invite", self.invitationHandlingBlock);
 * });
 * self.client.connect(@"ChatEngine").perform();
 * ...
 * self.client.me.off(@"$.invite", self.invitationHandlingBlock);
 * @endcode
 *
 * @return Refererence on \b CENChat subclass which can be used to chain other methods call.
 */
@property (nonatomic, readonly, strong) CENSearch * (^off)(NSString *event, id handlerBlock);

/**
 * @brief      Unsubscribe from any events emitted by receiver by removing \c handlerBlock from notifiers list.
 * @discussion \b Important: to be able to remove handling block, it is required to store reference on it in class which
 *             listens for updates. Newly created block won't remove previously registered \c handler.
 * @discussion Builder block allow to specify \b required field - reference on event handling block which previously has been
 *             used to handle all events.
 *
 * @discussion Remove handler for any events emitted by client:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.anyHandlingBlock = ^(NSString *event, CENObject *sender, id data) {
 *     // Handle event.
 * };
 *
 * self.client.onAny(self.anyHandlingBlock);
 * self.client.connect(@"ChatEngine").perform();
 * ...
 * self.client.offAny(self.invitationHandlingBlock);
 * @endcode
 *
 * @return Refererence on \b CENChat subclass which can be used to chain other methods call.
 */
@property (nonatomic, readonly, strong) CENSearch * (^offAny)(id handlerBlock);

/**
 * @brief      Unsubscribe all \c event handling blocks from event processing.
 * @discussion Builder block allow to specify \b required field - name of event from which event handlers should removed.
 *
 * @discussion Remove all '$.invite' event listeners:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.on(@"$.ready", ^(CENMe *me) {
 *     me.direct.on(@"$.invite", ^(NSDictionary *invitationData) {
 *         // Do something with sender.
 *     });
 *     me.direct.on(@"$.invite", ^(NSDictionary *invitationData) {
 *         // Do something with channel data.
 *     });
 * }];
 * self.client.connect(@"ChatEngine").perform();
 * ...
 * self.client.me.removeAll(@"$.invite");
 * @endcode
 *
 * @return Refererence on \b CENChat subclass which can be used to chain other methods call.
 */
@property (nonatomic, readonly, strong) CENSearch * (^removeAll)(NSString *event);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
