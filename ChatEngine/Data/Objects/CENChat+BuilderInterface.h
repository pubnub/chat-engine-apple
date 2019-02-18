/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChat.h"


#pragma mark Class forward

@class CENChatSearchBuilderInterface, CENChatEmitBuilderInterface, CENUser;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Builder interface declaration

@interface CENChat (BuilderInterface)


#pragma mark - Connection

/**
 * @brief Connect \b {local user CENMe} to \b PubNub real-time network to receive updates from other
 * \b {chat CENChat} participants.
 *
 * @fires
 * - \b {$.connected}
 * - \b {$.error.auth}
 * - \b {$.error.connection.duplicate}
 *
 * @discussion Authenticate \b {local user CENMe} for \b {chat CENChat} and subscribe with \b PubNub
 * @code
 * // objc f3f3b69d-25ec-493b-87ee-512ad2027a46
 *
 * // Create new chat room, but don't connect to it automatically.
 * CENChat *chat = self.client.Chat().name(@"some-chat").autoConnect(NO).create();
 *
 * // Connect to the chat when we feel like it.
 * chat.connect();
 * @endcode
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref e5bf86e5-f05f-4ed1-8303-37a82479f28c
 */
@property (nonatomic, readonly, strong) CENChat * (^connect)(void);


#pragma mark - Meta

/**
 * @brief Update \b {chat CENChat} meta information on server.
 *
 * @fires
 * - \b {$.error.chat}
 *
 * @discussion Update \b {chat's CENChat} metadata
 * @code
 * // objc e4a1350a-80bf-4e03-abda-0aec62655f15
 *
 * // Create new chat room, with initial meta information.
 * CENChat *chat = self.client.Chat().meta(@{ @"title": @"Test" }).create();
 *
 * // Change chat's meta when it will be required.
 * chat.update(@{ @"title": @"Updated Test" });
 * @endcode
 *
 * @param meta \a NSDictionary with metadata which should be bound to \b {chat CENChat}.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref e8edd46b-1d65-462b-8ce8-b0bd4676e816
 */
@property (nonatomic, readonly, strong) CENChat * (^update)(NSDictionary * __nullable meta);


#pragma mark - Participating

/**
 * @brief Invite a \b {user CENUser} to this \b {chat CENChat}.
 *
 * @discussion Authorizes the invited user in the \b {chat CENChat} and sends them an invite via
 * \b {CENUser.direct} chat.
 *
 * @fires
 * - \b {$.error.auth}
 * - \b {$.invite CENMe}
 *
 * @discussion Invite another user to \b {chat CENChat}
 * @code
 * // objc 9124b306-3108-4c5a-a2ce-e2dd3aca2a50
 *
 * // One of user running ChatEngine.
 * CENChat *secretChat = self.client.Chat().name(@"secret-chat").create();
 * secretChat.invite(anotherUser);
 *
 * // Another user listens for invitations.
 * self.client.me.direct.on(@"$.invite", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = ((NSDictionary *)event.data)[CENEventData.data];
 *
 *     CENChat *secretChat = self.client.Chat().name(payload[@"channel"]).create();
 * });
 * @endcode
 *
 * @param user \b {User CENUser} which should be invited.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref c3608222-f64b-4598-90b9-ec1d4fe65efd
 */
@property (nonatomic, readonly, strong) CENChat * (^invite)(CENUser *user);

/**
 * @brief Leave from the \b {chat CENChat} on behalf of \b {local user CENMe} and stop receiving
 * events.
 *
 * @fires
 * - \b {$.disconnected}
 * - \b {$.error.leave}
 * - \b {$.left}
 *
 * @discussion Leave specific chat
 * @code
 * // objc 56aac5cd-e129-4241-8e6e-3a18c9035cc3
 *
 * // Create new chat for local user to participate in.
 * CENChat *chat = self.client.Chat().name(@"test-chat").create();
 *
 * // Leave chat when there is no more any need to be participant of it.
 * chat.leave();
 * @endcode
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref 48a1986e-9f54-4e83-a392-b9a21000f516
 */
@property (nonatomic, readonly, strong) CENChat * (^leave)(void);

/**
 * @brief Retrieve list of \b {users CENUser} in \b {chat CENChat}.
 *
 * @fires
 * - \b {$.error.presence}
 * - \b {$.online.here}
 * - \b {$.online.join}
 *
 * @discussion Retrieve list of \b {users CENUser}:
 * @code
 * // objc 48b10920-d623-40ed-aa61-aca7856db3f6
 *
 * self.chat.fetchUserUpdates();
 * @endcode
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref 6a0ea863-00a1-4e36-bf33-196b37ab0e6a
 */
@property (nonatomic, readonly, strong) CENChat * (^fetchUserUpdates)(void);


#pragma mark - Events emitting

/**
 * @brief Event creation and configuration API builder.
 *
 * @discussion Emit event with data
 * @code
 * // objc 26856530-b1e4-453d-8a8d-ab9b2627e890
 *
 * // Emit event by one user.
 * self.chat.emit(@"custom-event").data(@{ @"value": @YES }).perform();
 *
 * // Handle event on another side.
 * self.chat.on(@"custom-event", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *     CENUser *sender = payload[CENEventData.sender];
 *
 *     NSLog(@"%@ emitted the value: %@", sender.uuid, payload[CENEventData.data][@"message"]);
 * });
 * @endcode
 *
 * @param event Name of emitted event.
 *
 * @return Builder instance which allow to complete event emit call configuration.
 *
 * @ref e3caa6f5-c6c7-4d51-9e8e-f2272f5d226a
 */
@property (nonatomic, readonly, strong) CENChatEmitBuilderInterface * (^emit)(NSString *event);


#pragma mark - Events search

/**
 * @brief Emitted events searcher creation and configuration API builder.
 *
 * @fires
 * - \b {$.error.search}
 *
 * @discussion Search for specific event from \b {local user CENMe}
 * @code
 * // objc 643490dc-1019-4830-bf87-950e46493f9f
 *
 * self.chat.search().event(@"my-custom-event").sender(self.client.me).limit(20).create()
 *     .on(@"my-custom-event", ^(CENEmittedEvent *event) {
 *         NSLog(@"This is an old event!: %@", event.data);
 *     })
 *     .on(@"$.search.finish", ^(CENEmittedEvent *event) {
 *         NSLog(@"We have all our results!");
 *     }).search();
 * @endcode
 *
 * @discussion Search for all events
 * @code
 * // objc eba2b098-1b22-450f-951f-f7869ab32137
 *
 * self.chat.search().create()
 *     .search()
 *     .on(@"my-custom-event", ^(CENEmittedEvent *event) {
 *         NSLog(@"This is an old event!: %@", event.data);
 *     })
 *     .on(@"$.search.finish", ^(CENEmittedEvent *event) {
 *         NSLog(@"We have all our results!");
 *     });
 * @endcode
 *
 * @return Builder instance which allow to complete events searching call configuration.
 * If builder call completed with `create` method call, then it will return \b {CENSearch}
 * instance.
 *
 * @ref cd4c3648-6119-4bd0-bfa6-5d4d4b18c60f
 */
@property (nonatomic, readonly, strong) CENChatSearchBuilderInterface * (^search)(void);


#pragma mark - Handlers addition

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it with provided event handler.
 *
 * @discussion Handle specific event
 * @code
 * // objc 5029a4eb-b20d-406d-b263-a4b0047ec088
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").create()
 *     .on(@"$.connected", ^(CENEmittedEvent *event) {
 *         // Handle connection to chat real-time channel.
 *     });
 * @endcode
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc 1a66ce8d-910b-4023-af5d-f0d8d6fa92d0
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").create()
 *     .on(@"$.error.*", ^(CENEmittedEvent *event) {
 *         // Handle any emitted error.
 *     });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref d1ff2b7b-6cb7-4301-996a-a597210f907a
 */
@property (nonatomic, readonly, strong) CENChat * (^on)(NSString *event,
                                                        CENEventHandlerBlock handler);

/**
 * @brief Subscribe on any events which will be emitted by receiver and handle them with provided
 * event handler.
 *
 * @discussion Handle any event
 * @code
 * // objc 373b6ae0-0e0b-4dbc-8751-6b089ea15a1d
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").create()
 *     .onAny(^(CENEmittedEvent *event) {
 *         // Handle any event emitted by object.
 *     });
 * @endcode
 
 * @param handler Block / closure which will handle any events. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref 141023e7-25c8-419c-889b-6aac928bf959
 */
@property (nonatomic, readonly, strong) CENChat * (^onAny)(CENEventHandlerBlock handler);

/**
 * @brief Subscribe on particular or multiple (wildcard) \c events which will be emitted by receiver
 * and handle it once with provided event handler.
 *
 * @discussion Handle specific event once
 * @code
 * // objc b995473a-0d1d-4a7f-a85b-888fb1015619
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").create()
 *     .once(@"$.state", ^(CENEmittedEvent *event) {
 *         // Handle once user's state change for chat.
 *     });
 * @endcode
 *
 * @discussion Handle one of multiple events once using wildcard
 * @code
 * // objc 0f8e5012-6155-4e19-a671-46a02ab8e972
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").create()
 *     .once(@"$.online.*", ^(CENEmittedEvent *event) {
 *         // Handle once remote user join or list refresh.
 *     })
 *     .once(@"$.offline.*", ^(CENEmittedEvent *event) {
 *         // Handle once remote user leave or offline events.
 *     });
 * @endcode
 *
 * @param event Name of event which should be handled by \c handler.
 * @param handler Block / closure which will handle specified \c event. Block / closure pass only
 *     one argument - locally emitted event \b {representation object CENEmittedEvent}.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref 7c3091a6-4bea-4f32-bdae-90dfa0b8d5b2
 */
@property (nonatomic, readonly, strong) CENChat * (^once)(NSString *event,
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
 * // objc d9ef9d87-934d-4843-8c1d-b3d5d6b25f06
 *
 * self.messageHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle remote user emitted event payload.
 * };
 *
 * self.chat.off(@"message", self.messageHandlingBlock);
 * @endcode
 *
 * @discussion Stop multiple events handling
 * @code
 * // objc 17ca3708-c128-40fc-94b0-94a1a1314d65
 *
 * self.errorHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any emitted error.
 * };
 *
 * self.chat.off(@"$.error.*", self.errorHandlingBlock);
 * @endcode
 *
 * @param event Name of event for which handler should be removed.
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref 23b56479-17a0-479b-9b18-ce93983b5221
 */
@property (nonatomic, readonly, strong) CENChat * (^off)(NSString *event,
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
 * // objc 156cd8c4-9e24-4eb9-b419-00852b818a80
 *
 * self.anyEventHandlingBlock = ^(CENEmittedEvent *event) {
 *     // Handle any event emitted by object.
 * };
 *
 * self.chat.offAny(self.anyEventHandlingBlock);
 * @endcode
 *
 * @param handler Block / closure which has been used during event handler registration.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref 1614fc4b-a395-4b8c-894e-7e2c4ac7451c
 */
@property (nonatomic, readonly, strong) CENChat * (^offAny)(CENEventHandlerBlock handler);

/**
 * @brief Unsubscribe all \c event or multiple (wildcard) \c events handlers.
 *
 * @discussion Remove specific event handlers
 * @code
 * // objc 72d3ec39-2941-4b55-b50f-65ee95a27aab
 *
 * self.chat.removeAll(@"message");
 * @endcode
 *
 * @discussion Remove multiple event handlers
 * @code
 * // objc 316b5b47-cebb-42ff-8785-6b976806765e
 *
 * self.chat.removeAll(@"$.error.*");
 * @endcode
 *
 * @param event Name of event for which has been used to register handler blocks.
 *
 * @return \b {Receiver CENChat} which can be used to chain other methods call.
 *
 * @ref d3497eaf-63c4-4a13-950d-c62a8aa35614
 */
@property (nonatomic, readonly, strong) CENChat * (^removeAll)(NSString *event);


#pragma mark - Misc

/**
 * @brief Serialize \c chat instance into dictionary.
 *
 * @discussion Serialize \b {chat CENChat} information into dictionary
 * @code
 * // objc 23b3c6dd-5ed1-46dc-a45e-4bca9fffa154
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat").get();
 *
 * NSLog(@"Chat dictionary representation: %@", chat.objectify());
 * @endcode
 *
 * @return \a NSDictionary with publicly visible chat data.
 *
 * @ref 84bf40d4-6226-45e2-b3c0-cad9fedc1c62
 */
@property (nonatomic, readonly, strong) NSDictionary * (^objectify)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
