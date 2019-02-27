#import "CENChatEngine+Chat.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \b {chat CENChat} management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (ChatInterface)

/**
 * @brief Create and configure new \b {chat CENChat} instance.
 *
 * @discussion Create public \b {chat CENChat}
 * @code
 * // objc 9056a4bb-4b12-4fd3-8e80-a3a2fffef9b3
 *
 * CENChat *chat = [self.client createChatWithName:@"public-chat" private:NO autoConnect:YES
 *                                        metaData:nil];
 * @endcode
 *
 * @discussion Create private \b {chat CENChat}
 * @code
 * // objc f524ff9f-2e3c-45fd-9aeb-7bffcc47cc0d
 *
 * CENChat *chat = [self.client createChatWithName:@"private-chat" private:YES autoConnect:YES
 *                                        metaData:nil];
 * @endcode
 *
 * @discussion Create \b {chat CENChat} with meta
 * @code
 * // objc 0d99b93d-95cf-471c-9f85-92835c994655
 *
 * CENChat *chat = [self.client createChatWithName:@"test-chat" private:YES autoConnect:YES
 *                                        metaData:@{ @"interesting": @"data" }];
 * @endcode
 *
 * @param name Unique alphanumeric chat identifier with maximum 50 characters. Usually something
 *     like \c {The Watercooler}, \c {Support}, or \c {Off Topic}. See \b {PubNub Channels https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-}.
 *     PubNub \c channel names are limited to \c 92 characters. If a user exceeds this limit while
 *     creating chat, an \c error will be thrown. The limit includes the prefixes and suffixes added
 *     by the chat engine as listed \b {here pubnub-channel-topology}.
 *     \b Default: \a [NSDate date]
 * @param isPrivate Whether \b {chat CENChat} access should be restricted only to invited
 *     \b {users CENUser} or not.
 * @param autoConnect Whether \b {local user CENMe} should be connected to this chat after creation
 *     or not. If set to \c NO, call \b [CENChat connectChat] method to connect to this
 *     \b {chat CENChat}.
 * @param meta Chat metadata that will be persisted on the server and populated on creation.
 *     To use this parameter \b {CENConfiguration.enableMeta} should be set to \c YES during
 *     \b {CENChatEngine} client configuration.
 *     \b Default: \c @{}
 *
 * @return Configured and ready to use \b {CENChat} instance.
 *
 * @ref 4dcb49b3-aa37-4bef-9c75-264e785dcd87
 */
- (CENChat *)createChatWithName:(nullable NSString *)name
                        private:(BOOL)isPrivate
                    autoConnect:(BOOL)autoConnect
                       metaData:(nullable NSDictionary *)meta;

/**
 * @brief Try to find and return previously created \b {chat CENChat} instance.
 *
 * @discussion Retrieve previously created \b {chat CENChat}
 * @code
 * // objc de4a3ab4-66c7-4e23-ac6e-c4ddcd152a1f
 *
 * if ([self.client chatWithName:@"test-chat" private:NO] != nil) {
 *     // Provide chat interface.
 * }
 * @endcode
 *
 * @param name Name of chat which has been created before.
 * @param isPrivate Whether previously created chat is private or not.
 *
 * @return Previously created \b {chat CENChat} instance or \c nil in case if it doesn't exists.
 *
 * @ref a492751c-b462-42f4-9221-ec13f92638ee
 */
- (nullable CENChat *)chatWithName:(NSString *)name private:(BOOL)isPrivate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
