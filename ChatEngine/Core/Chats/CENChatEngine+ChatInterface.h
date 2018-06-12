#import "CENChatEngine+Chat.h"

#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c chat instance management.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (ChatInterface)


#pragma mark - Chat

/**
 * @brief  Create and configure new \b CENChat instance.
 *
 * @discussion Create public chat with random name:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     CENChat *chat = [self.client createChatWithName:nil group:nil private:NO autoConnect:YES metaData:nil];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @discussion Create public chat with name:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     CENChat *chat = [self.client createChatWithName:@"test-chat" group:nil private:NO autoConnect:YES metaData:nil];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @discussion Create public chat with meta information:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     CENChat *chat = [self.client createChatWithName:@"test-chat"
 *                                              group:nil
 *                                            private:NO
 *                                        autoConnect:YES
 *                                           metaData:@{ @"interesting": @"data" }];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param name      Reference on name of chat which shoud be created.
 * @param group     Chat(s) aggregation group name. \b ChatEngine aggregate list of chats into group to help \b PubNub client
 *                  to subscribe to them. Available values descrived by \c CENChatGroup structure.
 * @param isPrivate Whether chat is private for other user(s) which not invited to it or not.
 * @param meta      Reference on meta data which should be appended to this chat. This option require to set
 *                  \a enableMeta to \c YES in \b CENConfiguration which used for \b ChatEngine configuration.
 *
 * @return Configured and ready to use \b CENChat instance.
 */
- (CENChat *)createChatWithName:(nullable NSString *)name
                         group:(nullable NSString *)group
                       private:(BOOL)isPrivate
                   autoConnect:(BOOL)autoConnect
                      metaData:(nullable NSDictionary *)meta;

/**
 * @brief  Try to find and return previously created \b CENChat instance.
 *
 * @discussion Retrieve previously created chat:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client connectUser:@"ChatEngine"];
 * // .....
 * // show interface for conversation creation, but ensure, what there is no such conversation yet.
 * CENChat *chat = [self.client chatWithName:@"test-chat" private:NO];
 * @endcode
 *
 * @param name      Reference on name of chat which has been created before.
 * @param isPrivate Whether previously created chat is private or not.
 *
 * @return Previously created \b CENChat instance or \c nil in case if it doesn't exists.
 */
- (nullable CENChat *)chatWithName:(NSString *)name private:(BOOL)isPrivate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
