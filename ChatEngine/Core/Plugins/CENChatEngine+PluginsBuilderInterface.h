#import "CENChatEngine.h"


#pragma mark Class forward

@class CENPluginsBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \c plugins management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (PluginsBuilderInterface)

/**
 * @brief \b {CENChatEngine} proto plugins manage / audit API builder.
 *
 * @discussion Registered proto plugins will be applied to objects of specified type when they will
 * be created.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Check proto plugin registered using it's class for \c Chat or not
 * @code
 * // objc fccb32cf-dd1c-4f6f-a5ce-47f0eb35a817
 *
 * if (!self.client.proto(@"Chat", [AwesomeChatPlugin class]).exists()) {
 *     // Looks like 'Chat' objects doesn't have proto plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @discussion Check proto plugin registered using it's identifier for \c Chat or not
 * @code
 * // objc 2c947a51-1963-4a1f-9527-bb2d81c5e113
 *
 * if (!self.client.proto(@"Chat", @"chatengine.emoji").exists()) {
 *     // Looks like 'Chat' objects doesn't have proto plugin with 'chatengine.emoji' identifier.
 * }
 * @endcode
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
 * @param object Object's type for which proto plugins should be accessed: \c Chat, \c User, \c Me
 *     or \c Search.
 * @param plugin Unique plugin identifier or class of plugin (subclass of \b {CEPPlugin}).
 *
 * @return Builder instance which allow to complete proto plugins management call configuration.
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^proto)(NSString *object,
                                                                              id plugin);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
