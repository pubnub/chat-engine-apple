#import "CENChat.h"
#import "CENEventEmitter+Interface.h"


#pragma mark Class forward

@class CENSearch, CENEvent, CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine chat room representation model.
 * @discussion This instance can be used to invite new user(s), send messages and receive updates.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChat (Interface)


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
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     // .....
 *     // at moment when chat created, ChatEngine client should be connected (at least once).
 *     // .....
 *     CENChat *chat = [self.client createChatWithName:nil group:nil private:NO autoConnect:NO metaData:nil];
 *     [chat connectChat];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 */
- (void)connectChat;


#pragma mark - Meta

/**
 * @brief Update \c chat meta information in \b ChatEngine network.
 *
 * @discussion Change chat title on connection:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     // .....
 *     // at moment when chat created, ChatEngine client should be connected (at least once).
 *     // .....
 *     CENChat *chat = [self.client createChatWithName:nil group:nil private:NO autoConnect:YES metaData:@{ @"title": @"Test" }];
 *
 *     [chat handleEvent:@"$.connected" withHandlerBlock:^{
 *         [chat updateMeta:@{ @"title": @"Updated test" }];
 *     }];
 *     [chat connectChat];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param meta Reference on metadata which should be bound to chat.
 */
- (void)updateMeta:(nullable NSDictionary *)meta;


#pragma mark - Participating

/**
 * @brief      Invite remote \c user to join conversation.
 * @discussion Remote \c user will be granted with required rights to read and write messages to
 *             \c chat.
 *
 * @discussion Inivte user to chat with name:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEvent:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     // .....
 *     // at moment when chat created, ChatEngine client should be connected (at least once).
 *     // .....
 *     CENChat *chat = [self.client chatWithName:@"test-chat" private:NO];
 *
 *     [chat inviteUser:[self.client createUserWithUUID:@"PubNub" state:nil]];
 * };
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param user Reference on \b CENUser instante which represent remote user.
 */
- (void)inviteUser:(CENUser *)user;

/**
 * @brief      Leave \c chat on \c local user behalf.
 * @discussion After user will leave, he won't receive any real-time updates anymore.
 *
 * @discussion Leave previously connected chat:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * CENChat *chat = [self.client chatWithName:@"test-chat" private:NO];
 * [chat leave];
 * @endcode
 */
- (void)leaveChat;


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
 * [self.client handleEvent:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [self.client.global emitEvent:@"$.test-event" withData:@{ @"message": @"Hello world" }];
 * }];
 * [self.client.global handleEventOnce:@"$.test-event" withHandlerBlock:^(NSDictionary *payload) {
 *     NSLog("Pyaload: %@", payload); // Payload: { "message": "Hello world" }
 * }];
 * [self.client connect:@"ChatEngine"];
 * @endcode
 *
 * @param event Reference on name of emitted event.
 * @param data  Reference on data which should be sent along with event.
 *
 * @return Reference on object which allow to track emitting progress (it is possible to subscribe on events for it with
 *         '-[CENEvent handleEvent:withHandlerBlock:]' and '-[CENEvent handleEventOnce:withHandlerBlock:]' methods).
 */
- (CENEvent *)emitEvent:(NSString *)event withData:(nullable NSDictionary *)data;


#pragma mark - Events search

/**
 * @brief      Search through previously emitted events.
 * @discussion Created \b CENSearch instance will allow to iterate through history of found \c events. Depending from
 *             configuration, search instance can search for particular event type and/or sent from specific \c user. It is
 *             possible to limit in time and count of sent events.
 * @note       If returned \b CENSearch instance will be user longer than 10 minutes, make sure to save reference on it or it
 *             will be deallocated.
 *
 * @discussion Search for 10 'ping' events sent by 'PubNub':
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEvent:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     CENUser *user = [self.client userWithUUID:@"PubNub"];
 *     CENSearch *search = [self.client.global searchEvent:@"ping"
 *                                               fromUser:user
 *                                              withLimit:10
 *                                                  pages:0
 *                                                  count:100
 *                                                  start:nil
 *                                                    end:nil];
 *
 *     [search handleEvent:@"ping" withHandlerBlock:^(NSDictionary *eventData) {
 *         // Handle 'ping' event from chat's history.
 *     }];
 *
 *     [search searchEvents];
 * }];
 * [self.client connect:@"ChatEngine"];
 * @endcode
 *
 * @param event  Reference on name of event to search for. All events will be returned in case if \c nil has been passed.
 * @param sender Reference on \b CENUser instance who sent the message. Events from any sender will be returned in case if
 *               \c nil has been passed.
 * @param limit  Reference on maximum number of results to return that match search criteria.
 *               Search will continue operating until it returns this number of results or it reached the end of history.
 *               Specify \b 0 or below to search all events.
 *               Limit will be ignored in case if both \c start and \c end timetokens has been passed to search configuration.
 *               By default set to: \b 20.
 * @param pages  Reference on maximum number of search request which can be performed to reach specified search end
 *               criteria: limit.
 *               By default set to: \b 10.
 * @param count  Reference on maximum number of events which can be fetched with single search request.
 *               By default set to: maximum \b 100.
 * @param start  Reference on timetoken to begin searching between.
 * @param end    Reference on timetoken to end searching between.
 */
- (CENSearch *)searchEvent:(nullable NSString *)event
                 fromUser:(nullable CENUser *)sender
                withLimit:(NSInteger)limit
                    pages:(NSInteger)pages
                    count:(NSInteger)count
                    start:(nullable NSNumber *)start
                      end:(nullable NSNumber *)end;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
