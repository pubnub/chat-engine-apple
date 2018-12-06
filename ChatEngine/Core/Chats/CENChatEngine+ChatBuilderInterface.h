#import "CENChatEngine+Chat.h"


#pragma mark Class forward

@class CENChatBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for \b {chats CENChat} management.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (ChatBuilderInterface)

/**
 * @brief \b {Chats CENChat} management API builder.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Create public \b {chat CENChat}
 * @code
 * // objc 9056a4bb-4b12-4fd3-8e80-a3a2fffef9b3
 *
 * CENChat *chat = self.client.Chat().name(@"public-chat" ).create();
 * @endcode
 *
 * @discussion Create private \b {chat CENChat}
 * @code
 * // objc f524ff9f-2e3c-45fd-9aeb-7bffcc47cc0d
 *
 * CENChat *chat = self.client.Chat().name(@"private-chat").private(YES).create();
 * @endcode
 *
 * @discussion Create \b {chat CENChat} with meta
 * @code
 * // objc 0d99b93d-95cf-471c-9f85-92835c994655
 *
 * CENChat *chat = self.client.Chat().name(@"test-chat")
 *     .meta(@{ @"interesting": @"data" }).create();
 * @endcode
 *
 * @discussion Retrieve previously created \b {chat CENChat}
 * @code
 * // objc de4a3ab4-66c7-4e23-ac6e-c4ddcd152a1f
 *
 * if (self.client.Chat().name(@"test-chat").get() != nil) {
 *     // Provide chat interface.
 * }
 * @endcode
 *
 * @return Builder instance which allow to complete chats management call configuration.
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^Chat)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
