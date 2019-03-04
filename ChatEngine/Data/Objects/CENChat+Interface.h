/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChat.h"
#import "CENEventEmitter+Interface.h"


#pragma mark Class forward

@class CENSearch, CENEvent, CENUser;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Standard interface declaration

@interface CENChat (Interface)


#pragma mark - Connection

/**
 * @brief Connect \b {local user CENMe} to \b PubNub real-time network to receive updates from other
 * \b {chat CENChat} participants.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - if chat already connected.
 *
 * @discussion Authenticate \b {local user CENMe} for \b {chat CENChat} and subscribe with \b PubNub
 * @code
 * // objc f3f3b69d-25ec-493b-87ee-512ad2027a46
 *
 * // Create new chat room, but don't connect to it automatically.
 * CENChat *chat = [self.client createChatWithName:@"some-chat" private:NO autoConnect:NO
 *                                        metaData:nil];
 *
 * // Connect to the chat when we feel like it.
 * [chat connectChat];
 * @endcode
 *
 * @ref e5bf86e5-f05f-4ed1-8303-37a82479f28c
 */
- (void)connectChat;


#pragma mark - Meta

/**
 * @brief Update \b {chat CENChat} meta information on server.
 *
 * @discussion Update \b {chat's CENChat} metadata
 * @code
 * // objc e4a1350a-80bf-4e03-abda-0aec62655f15
 *
 * // Create new chat room, with initial meta information.
 * CENChat *chat = [self.client createChatWithName:nil private:NO autoConnect:YES
 *                                        metaData:@{ @"title": @"Test" }];
 *
 * // Change chat's meta when it will be required.
 * [chat updateMeta:@{ @"title": @"Updated Test" }];
 * @endcode
 *
 * @param meta \a NSDictionary with metadata which should be bound to \b {chat CENChat}.
 *
 * @ref e8edd46b-1d65-462b-8ce8-b0bd4676e816
 */
- (void)updateMeta:(nullable NSDictionary *)meta;


#pragma mark - Participating

/**
 * @brief Invite a \b {user CENUser} to this \b {chat CENChat}.
 *
 * @discussion Authorizes the invited user in the \b {chat CENChat} and sends them an invite via
 * \b {CENUser.direct} chat.
 *
 * @discussion Invite another user to \b {chat CENChat}
 * @code
 * // objc 9124b306-3108-4c5a-a2ce-e2dd3aca2a50
 *
 * // One of user running ChatEngine.
 * CENChat *secretChat = [self.client createChatWithName:@"secret-chat" private:YES autoConnect:YES
 *                                              metaData:nil];
 * [chat inviteUser:anotherUser];
 *
 * // Another user listens for invitations.
 * [self.client handleEvent:@"$.invite" withHandlerBlock:^(CENEmittedEvent *event) {
 *     NSDictionary *payload = ((NSDictionary *)event.data)[CENEventData.data];
 *
 *     CENChat *secretChat = [self.client createChatWithName:payload[@"channel"] private:YES
 *                                               autoConnect:YES metaData:nil];
 * }];
 * @endcode
 *
 * @param user \b {User CENUser} which should be invited.
 *
 * @ref c3608222-f64b-4598-90b9-ec1d4fe65efd
 */
- (void)inviteUser:(CENUser *)user;

/**
 * @brief Leave from the \b {chat CENChat} on behalf of \b {local user CENMe} and stop receiving
 * events.
 *
 * @discussion Leave specific chat
 * @code
 * // objc 56aac5cd-e129-4241-8e6e-3a18c9035cc3
 *
 * // Create new chat for local user to participate in.
 * CENChat *chat = [self.client createChatWithName:@"test-chat" private:NO autoConnect:YES
 *                                        metaData:nil];
 *
 * // Leave chat when there is no more any need to be participant of it.
 * [chat leave];
 * @endcode
 *
 * @ref 48a1986e-9f54-4e83-a392-b9a21000f516
 */
- (void)leaveChat;


#pragma mark - Events emitting

/**
 * @brief Send events to other clients in this \c {chat CENChat}.
 *
 * @discussion Events are trigger over the network and all events are made on behalf of
 * \b {local user CENMe}.
 *
 * @discussion Emit event with data
 * @code
 * // objc 26856530-b1e4-453d-8a8d-ab9b2627e890
 *
 * // Emit event by one user.
 * [chat emitEvent:@"custom-event" withData:@{ @"value": @YES }];
 *
 * // Handle event on another side.
 * [chat handleEventOnce:@"custom-event" withHandlerBlock:^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *     CENUser *sender = payload[CENEventData.sender];
 *
 *     NSLog(@"%@ emitted the value: %@", sender.uuid, payload[CENEventData.data][@"message"]);
 * }];
 * @endcode
 *
 * @param event Name of emitted event.
 * @param data \a NSDictionary with data which should be sent along with event.
 *
 * @return \b {Event CENEvent} which allow to track emitting progress.
 *
 * @ref 01b1735e-06a5-4c11-9510-cccaded934fd
 */
- (CENEvent *)emitEvent:(NSString *)event withData:(nullable NSDictionary *)data;


#pragma mark - Events search

/**
 * @brief Search through previously emitted events.
 *
 * @throws \b CENErrorDomain exception in following cases:
 * - if chat not connected yet.
 *
 * @discussion Search for specific event from \b {local user CENMe}
 * @code
 * // objc 643490dc-1019-4830-bf87-950e46493f9f
 *
 * CENSearch *search = [chat searchEvent:@"my-custom-event" fromUser:self.client.me withLimit:20
 *                                 pages:0 count:100 start:nil end:nil];
 *
 * [search handleEvent:@"my-custom-event" withHandlerBlock:^(CENEmittedEvent *event) {
 *     NSDictionary *eventData = event.data;
 *
 *     NSLog(@"This is an old event!: %@", eventData);
 * }];
 *
 * [search handleEvent:@"$.search.finish" withHandlerBlock:^(CENEmittedEvent *event) {
 *     NSLog(@"We have all our results!");
 * }];
 *
 * [search searchEvents];
 * @endcode
 *
 * @discussion Search for all events
 * @code
 * // objc eba2b098-1b22-450f-951f-f7869ab32137
 *
 * CENSearch *search = [chat searchEvent:nil fromUser:nil withLimit:0 pages:0 count:100 start:nil
 *                                   end:nil];
 *
 * [search handleEvent:@"my-custom-event" withHandlerBlock:^(CENEmittedEvent *event) {
 *     NSDictionary *eventData = event.data;
 *
 *     NSLog(@"This is an old event!: %@", eventData);
 * }];
 *
 * [search handleEvent:@"$.search.finish" withHandlerBlock:^(CENEmittedEvent *event) {
 *     NSLog(@"We have all our results!");
 * }];
 *
 * [search searchEvents];
 * @endcode
 *
 * @param event Name of event to search for.
 * @param sender \b {User CENUser} who sent the message.
 * @param limit The maximum number of results to return that match search criteria. Search will
 *     continue operating until it returns this number of results or it reached the end of history.
 *     Limit will be ignored in case if both 'start' and 'end' timetokens has been passed in search
 *     configuration.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 20
 * @param pages The maximum number of history requests which \b {CENChatEngine} will do
 *     automatically to fulfill \c limit requirement.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 10
 * @param count The maximum number of messages which can be fetched with single history request.
 *     Pass \c 0 or below to use default value.
 *     \b Default: \c 100
 * @param start The timetoken to begin searching between.
 * @param end The timetoken to end searching between.
 *
 * @return \b {Chat CENChat} events \b {searcher CENSearch}.
 *
 * @ref 8638be94-e114-4beb-9eb8-1b25c80d8c42
 */
- (CENSearch *)searchEvent:(nullable NSString *)event
                  fromUser:(nullable CENUser *)sender
                 withLimit:(NSInteger)limit
                     pages:(NSInteger)pages
                     count:(NSInteger)count
                     start:(nullable NSNumber *)start
                       end:(nullable NSNumber *)end;


#pragma mark - Misc

/**
 * @brief Serialize \c chat instance into dictionary.
 *
 * @discussion Serialize \b {chat CENChat} information into dictionary
 * @code
 * // objc 23b3c6dd-5ed1-46dc-a45e-4bca9fffa154
 *
 * CENChat *secretChat = [self.client createChatWithName:@"secret-chat" private:YES autoConnect:NO
 *                                              metaData:nil];
 *
 * NSLog(@"Chat dictionary representation: %@", [chat dictionaryRepresentation]);
 * @endcode
 *
 * @return \a NSDictionary with publicly visible chat data.
 *
 * @ref 84bf40d4-6226-45e2-b3c0-cad9fedc1c62
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
