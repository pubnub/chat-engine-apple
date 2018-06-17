#import "CENChat.h"


#pragma mark Class forward

@class CENChatSearchBuilderInterface, CENChatEmitBuilderInterface, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine chat room representation model.
 * @discussion This instance can be used to invite new user(s), send messages and receive updates.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChat (BuilderInterface)


#pragma mark - Connection

/**
 * @brief      Connect \c local user to \b PubNub real-time network to receive updates from other \c chat users.
 * @discussion During connection process, \b ChatEngine will perform handshake to get recent user's metadata for \c chat and
 *             ensure what there is no issues with access rights.
 *
 * @discussion Connect to chat with random name:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     // .....
 *     // at moment when chat created, ChatEngine client should be connected (at least once).
 *     // .....
 *     CENChat *chat = self.client.Chat().autoConnect(NO).create();
 *
 *     chat.connect();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChat * (^connect)(void);


#pragma mark - Meta

/**
 * @brief Update \c chat meta information in \b ChatEngine network.
 *
 * @discussion Change chat title on connection:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     // .....
 *     // at moment when chat created, ChatEngine client should be connected (at least once).
 *     // .....
 *     CENChat *chat = self.client.Chat().meta(@{ @"title": @"Test" }).create();
 *
 *     chat.on(@"$.connected", ^{
 *         chat.update(@{ @"title": @"Updated test" });
 *     });
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @param meta Reference on metadata which should be bound to chat.
 */
@property (nonatomic, readonly, strong) CENChat * (^update)(NSDictionary * __nullable meta);


#pragma mark - Participating

/**
 * @brief      Invite remote \c user to join conversation.
 * @discussion Remote \c user will be granted with required rights to read and write messages to \c chat.
 *
 * @discussion Inivte user to chat with name:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     // .....
 *     // at moment when chat created, ChatEngine client should be connected (at least once).
 *     // .....
 *     CENChat *chat = self.client.Chat().name(@"test-chat").create();
 *
 *     chat.invite(self.client.User(@"PubNub").create());
 * };
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @param user Reference on \b CENUser instante which represent remote user.
 */
@property (nonatomic, readonly, strong) CENChat * (^invite)(CENUser *user);

/**
 * @brief      Leave \c chat on \c local user behalf.
 * @discussion After user will leave, he won't receive any real-time updates anymore.
 *
 * @discussion Leave previously connected chat:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * CENChat *chat = self.client.Chat().name(@"test-chat").get();
 * chat.leave();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChat * (^leave)(void);

/**
 * @brief  Retrieve list of \c users in \c chat.
 *
 * @discussion \b Example:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * CENChat *chat = self.client.Chat().name(@"test-chat").get();
 * chat.getUserUpdates();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChat * (^fetchUserUpdates)(void);


#pragma mark - Events emitting

/**
 * @brief      Emit event for remote chat listeners.
 * @discussion Emit named event for all remote users connected to this chat.
 * @note       If returned \b CENEvent instance will be user longer than 10 minutes, make sure to save reference on it or it
 *             will be deallocated.
 *
 * @discussion Emit simple event to 'global' chat:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.on(@"$.ready", ^(CENMe *me) {
 *     self.client.global.emit(@"$.test-event").data(@{ @"message": @"Hello world" }).perform()
 *         .once(@"$.emitted", ^(NSDictionary *payload) {
 *             // Handle event emit completion at payload.timetoken.
 *         });
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @param event Reference on name of emitted event.
 * @param data  Reference on data which should be sent along with event.
 *
 * @return Reference on object which allow to track emitting progress (it is possible to subscribe on events for it with
 *         '-CENEvent.on()' and '-CENEvent.once()' methods.
 */
@property (nonatomic, readonly, strong) CENChatEmitBuilderInterface * (^emit)(NSString *event);


#pragma mark - Events search

/**
 * @brief      Search through previously emitted events.
 * @discussion Created \b CENSearch instance will allow to iterate through history of found \c events. Depending from
 *             configuration, search instance can search for particular event type and/or sent from specific \c user. It is
 *             possible to limit in time and count of sent events.
 * @note       If returned \b CENSearch instance will be user longer than 10 minutes, make sure to
 *             save reference on it or it will be deallocated.
 *
 * @discussion Search for 10 'ping' events sent by 'PubNub':
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.on(@"$.ready", ^(CENMe *me) {
 *     CENUser *user = self.client.User(@"PubNub").get();
 *     self.client.global.search().event(@"ping").sender(user).limit(10).create()
 *         .search()
 *         .on(@"ping", ^(NSDictionary *eventData) {
 *             // Handle 'ping' event from chat's history.
 *         });
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^search)(void);


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
@property (nonatomic, readonly, strong) CENChat * (^on)(NSString *event, id handlerBlock);

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
@property (nonatomic, readonly, strong) CENChat * (^onAny)(id handlerBlock);

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
@property (nonatomic, readonly, strong) CENChat * (^once)(NSString *event, id handlerBlock);


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
@property (nonatomic, readonly, strong) CENChat * (^off)(NSString *event, id handlerBlock);

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
@property (nonatomic, readonly, strong) CENChat * (^offAny)(id handlerBlock);

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
@property (nonatomic, readonly, strong) CENChat * (^removeAll)(NSString *event);


#pragma mark - Misc

/**
 * @brief  Serialize \c chat instance into dictionary.
 *
 * @discussion \b Example:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * CENChat *chat = self.client.Chat().name(@"test-chat").get();
 * NSLog(@"Chat dictionary representation: %@", chat.objectify());
 * @endcode
 *
 * @return Chat's dictionary representation.
 */
@property (nonatomic, readonly, strong) NSDictionary * (^objectify)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
