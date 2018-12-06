#import "CENInterfaceBuilder.h"
#import "CEPPlugin.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} plugins management API access builder.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
@interface CENPluginsBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief Plugin identifier addition block.
 *
 * @param identifier Proto plugin identifier under which initialized plugin will be stored and can
 *     be retrieved.
 *     \b Default: \c {Plugin's identifier}
 *
 * @return Builder instance which allow to complete plugins / proto plugins management call
 * configuration.
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^identifier)(NSString *identifier);

/**
 * @brief Plugin configuration addition block.
 *
 * @param configuration Dictionary with configuration for plugin.
 *     \b Default: \c @{}
 *
 * @return Builder instance which allow to complete plugins / proto plugins management call
 * configuration.
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^configuration)(NSDictionary *configuration);


#pragma mark - Call

/**
 * @brief Create plugin / proto plugin using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain identifier.configuration.store
 *
 * @discussion Register proto plugin class w/o \c configuration for \c Chat
 * @code
 * // objc a9b4d909-f198-4ff6-b125-49bbaa2b4637
 *
 * self.client.proto(@"Chat", [AwesomeChatPlugin class]).store();
 * @endcode
 *
 * @discussion Register proto plugin with custom \c identifier with \c configuration for \c Chat
 * @code
 * // objc f3f5c385-7d01-4a32-aca5-dfca10d01fd0
 *
 * self.client.proto(@"Chat", [AwesomeChatPlugin class])
 *     .identifier(@"com.awesome.plugin")
 *     .configuration(@{ @"api-key": @"secret" })
 *     .store();
 * @endcode
 *
 * @discussion Register plugin class w/o \c configuration
 * @code
 * // objc 89073a82-ff7a-4765-a6c4-e778e775775d
 *
 * self.object.plugin([AwesomeChatPlugin class]).store();
 * @endcode
 *
 * @discussion Register plugin with custom \c identifier with \c configuration
 * @code
 * // objc 6b181727-6701-4f26-a404-f491a9be5e8a
 *
 * self.object.plugin([AwesomeChatPlugin class])
 *     .identifier(@"com.awesome.plugin")
 *     .configuration(@{ @"api-key": @"secret" })
 *     .store();
 * @endcode
 *
 * @ref 41e188a3-f2dc-4f17-a11a-e12ac0a99b8f
 * @ref 691b3c6f-ff89-4c39-9bd2-d9b493a36dac
 * @ref d2e396e7-d9f2-4762-a822-619d0819e9a8
 * @ref 4b1033e0-2398-4706-9bfd-7a91e68c1ef8
 */
@property (nonatomic, readonly, strong) void(^store)(void);

/**
 * @brief Remove plugin using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain remove
 *
 * @discussion Unregister proto plugin using it's class from \c Chat
 * @code
 * // objc 59bea506-4ef8-4384-94e8-bf4b68c8b82b
 *
 * self.client.proto(@"Chat", [AwesomeChatPlugin class]).remove();
 * @endcode
 *
 * @discussion Unregister proto plugin using it's identifier from \c Chat
 * @code
 * // objc ae5dbd06-9843-4ca7-a810-a6fc3a5e8d57
 *
 * self.client.proto(@"Chat", @"com.awesome.plugin").remove();
 * @endcode
 *
 * @discussion Unregister plugin using it's class
 * @code
 * // objc e88fe74c-516e-45b1-ae58-12dd34efb34f
 *
 * self.object.plugin([AwesomeChatPlugin class]).remove();
 * @endcode
 *
 * @discussion Unregister plugin using it's identifier
 * @code
 * // objc 2b753421-8463-4d69-92eb-da1dba1e45d9
 *
 * self.object.plugin(@"com.awesome.plugin").remove();
 * @endcode
 *
 * @ref 77a3d358-3582-477b-918f-84221d7735f7
 * @ref e9347636-fb97-475b-a3f2-4591aa9367e3
 * @ref e9ca8ed1-9851-4853-af27-c14848295793
 * @ref cd21bcb8-369a-4b1d-bfa9-c6c00cb471ff
 */
@property (nonatomic, readonly, strong) void(^remove)(void);

/**
 * @brief Check whether plugin / proto plugin exists using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain exists
 *
 * @discussion Check whether proto plugin registered using it's class for \c Chat or not
 * @code
 * // objc fccb32cf-dd1c-4f6f-a5ce-47f0eb35a817
 *
 * if (!self.client.proto(@"Chat", [AwesomeChatPlugin class]).exists()) {
 *     // Looks like 'Chat' objects doesn't have proto plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @discussion Check whether proto plugin registered using it's identifier for \c Chat or not
 * @code
 * // objc 2c947a51-1963-4a1f-9527-bb2d81c5e113
 *
 * if (!self.client.proto(@"Chat", @"chatengine.emoji").exists()) {
 *     // Looks like 'Chat' objects doesn't have proto plugin with 'chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @discussion Check whether plugin registered using it's class
 * @code
 * // objc 5a79f0b7-b8bf-44c6-9ec1-344947934d44
 *
 * if (!self.object.plugin([AwesomeChatPlugin class]).exists()) {
 *     // Looks like object doesn't have plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @discussion Check whether plugin registered using it's identifier
 * @code
 * // objc e232ad0c-3f2f-48c0-8dc8-ad0b45caf8b0
 *
 * if (!self.object.plugin(@"chatengine.emoji").exists()) {
 *     // Looks like object doesn't have plugin with 'chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @return Whether plugin / proto plugin exists or not.
 *
 * @ref df0791d4-92ea-48ad-8ad3-c89f0b1cc179
 * @ref 0d0e3dd9-c636-4272-a243-f7e51708f486
 * @ref 0548677f-7eac-4670-9af2-54c0d118d313
 * @ref 83033313-8a03-490e-8e87-622438b85111
 */
@property (nonatomic, readonly, strong) BOOL (^exists)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
