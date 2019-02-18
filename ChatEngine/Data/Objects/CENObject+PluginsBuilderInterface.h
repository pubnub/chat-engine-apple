/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENObject.h"


#pragma mark Class forward

@class CENPluginsBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Builder interface declaration

@interface CENObject (PluginsBuilderInterface)


#pragma mark - Plugins

/**
 * @brief Receiver's plugins management.
 *
 * @tutorial \b {Plugins}

 * @note Builder parameters can be specified in different variations depending from needs.
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
 * if (!self.object.plugin(@"com.chatengine.emoji").exists()) {
 *     // Looks like object doesn't have plugin with 'com.chatengine.emoji' identifier.
 * }
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
 * @discussion Unregister plugin using it's class
 * @code
 * // objc e88fe74c-516e-45b1-ae58-12dd34efb34f
 *
 * self.client.me.plugin([AwesomeChatPlugin class]).remove();
 * @endcode
 *
 * @discussion Unregister plugin using it's identifier
 * @code
 * // objc 2b753421-8463-4d69-92eb-da1dba1e45d9
 *
 * self.client.me.plugin(@"com.awesome.plugin").remove();
 * @endcode
 *
 * @param plugin Subclass of \b {CEPPlugin} or plugin's unique identifier.
 *
 * @return Builder instance which allow to complete plugins manipulation call configuration.
 * If builder call completed with `exists` method call, then it will return `BOOL` value.
 *
 * @ref 0548677f-7eac-4670-9af2-54c0d118d313
 * @ref 83033313-8a03-490e-8e87-622438b85111
 * @ref d2e396e7-d9f2-4762-a822-619d0819e9a8
 * @ref 4b1033e0-2398-4706-9bfd-7a91e68c1ef8
 * @ref e9ca8ed1-9851-4853-af27-c14848295793
 * @ref cd21bcb8-369a-4b1d-bfa9-c6c00cb471ff
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^plugin)(id plugin);


#pragma mark - Extension

/**
 * @brief Access receiver's interface extensions.
 *
 * @tutorial \b {Plugins Plugins#extension}
 *
 * @discussion Find extension by plugin's class
 * @code
 * // objc 7c2a6fcf-3e36-4e66-b80e-3c09b5a46c8d
 *
 * AwesomeChatExtension *extension = self.object.extension([AwesomeChatPlugin class]);
 * @endcode
 *
 * @discussion Find extension by identifier:
 * @code
 * // objc 32c5ec2c-2b11-40d8-99c5-a848985de453
 *
 * AwesomeChatExtension *extension = self.object.extension(@"com.awesome.plugin");
 * @endcode
 *
 * @param plugin Class of plugin (subclass of \b {CEPPlugin}) or unique plugin identifier which
 *     used during registration.
 *
 * @return Extension instance which can be used or \c nil if there is no extension for specified
 * class or \c identifier.
 *
 * @since 0.9.3
 *
 * @ref 831bbbae-50fe-441c-a564-34373ca54ca1
 * @ref 0c24d012-571f-4829-94bb-e3f3261ad54a
 */
@property (nonatomic, readonly, strong) id __nullable (^extension)(id plugin);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
