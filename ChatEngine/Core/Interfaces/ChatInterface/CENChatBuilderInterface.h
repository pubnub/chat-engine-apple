#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CENChat} instance creation / audition API access builder.
 *
 * @ref 4991561e-7420-46e8-a2b6-34dc84f94081
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief Unique \b {chat CENChat} name addition block.
 *
 * @param name Unique alphanumeric chat identifier with maximum 50 characters. Usually something
 *     like \c {The Watercooler}, \c Support, or \c {Off Topic}. See \b {PubNub Channels https://support.pubnub.com/support/solutions/articles/14000045182-what-is-a-channel-}.
 *     PubNub \c channel names are limited to \c 92 characters. If a user exceeds this limit while
 *     creating chat, an \c error will be thrown. The limit includes the prefixes and suffixes added
 *     by the chat engine as listed \b {here advanced-concepts-pubnub-channel-topology}.
 *     \b Default: \a [NSDate date]
 *
 * @return Builder instance which allow to complete chats management call configuration.
 *
 * @ref be936647-4ce6-49fe-9619-fdf88a1838c6
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^name)(NSString *name);

/**
 * @brief \b {Chat's CENChat} private flag addition block.
 *
 * @param isPrivate Whether \b {chat CENChat} access should be restricted only to invited
 *     \b {users CENUser} or not.
 *     \b Default: \c NO
 *
 * @return Builder instance which allow to complete chats management call configuration.
 *
 * @ref 5fb7e0a7-3444-41f0-9cda-6408a18ed07a
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^private)(BOOL isPrivate);

/**
 * @brief \b {Chat's CENChat} auto connection flag addition block.
 *
 * @param shouldAutoConnect Whether \b {local user CENMe} should be connected to this chat after
 *     creation or not. If set to \c NO, call \b {CENChat.connect} method to connect to this
 *     \b {chat CENChat}.
 *     \b Default: \c YES
 *
 * @return Builder instance which allow to complete chats management call configuration.
 *
 * @ref 5408e436-9109-46fe-b3e6-805040da4732
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^autoConnect)(BOOL shouldAutoConnect);

/**
 * @brief \b {Chat's CENChat} meta addition block.
 *
 * @param meta Information which should be persisted on server. To use this parameter
 *     \b {CENConfiguration.enableMeta} should be set to \c YES during \b {CENChatEngine}
 *     client configuration.
 *     \b Default: \c @{}
 *
 * @return Builder instance which allow to complete chats management call configuration.
 *
 * @ref a6be9696-ab35-47b3-ae70-43d24ea3c7f1
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^meta)(NSDictionary *meta);

/**
 * @brief \b {Chat's CENChat} group addition block.
 *
 * @param group Chats list group identifier. Available groups described in \b {CENChatGroup}
 *     structure.
 *     \b Default: \b {CENChatGroup.custom}
 *
 * @return Builder instance which allow to complete chats management call configuration.
 *
 * @deprecated 0.9.3
 *
 * @ref 9f3ede1b-fd55-4f35-88ae-7044f8df07a4
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^group)(NSString *group)
    DEPRECATED_MSG_ATTRIBUTE("This option deprecated since 0.9.3. All user-created chats belong "
                             "to 'custom' group");


#pragma mark - Call

/**
 * @brief Create and configure \b {chat CENChat} using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain name.private.autoConnect.meta.create
 *
 * @fires
 * - \b {$.created.chat CENChat}
 * - \b {$.error.auth CENChat}
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
 * @return Configured and ready to use \b {CENChat} instance.
 *
 * @ref 4dcb49b3-aa37-4bef-9c75-264e785dcd87
 */
@property (nonatomic, readonly, strong) CENChat * (^create)(void);

/**
 * @brief Search for \b {chat CENChat} using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain name!.private.get
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
 * @return Previously created \b {chat CENChat} instance or \c nil in case if it doesn't exists.
 *
 * @ref a492751c-b462-42f4-9221-ec13f92638ee
 */
@property (nonatomic, readonly, strong) CENChat * __nullable (^get)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
