#import "CENChatEngine.h"


#pragma mark Class forward

@class CENPluginsBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c plugins management.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods
 *             invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (PluginsBuilderInterface)


#pragma mark - Plugins

/**
 * @brief      Create/remove or check existence of proto plugin for specified \b ChatEngine object type (depending from used
 *             builder commiting function).
 * @discussion Registered proto plugins will be applied to objects of specified type when they will be created.
 * @discussion Builder block allow to specify \b required fields for proto plugin registration: \c object - type of
 *             \b ChatEngine object (currently supported: Chat, User, Me and Search) for which proto plugin will be
 *             registered/removed/checked; \c plugin - reference on class (during registration/removal/check) or identifier
 *             (during removal or check).
 * @discussion Available builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Chek proto plugin registered using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * if (!self.client.proto(@"Chat", [AwesomeChatPlugin class]).exists()) {
 *     // Looks like 'Chat' objects doesn't have proto plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @discussion Chek proto plugin registered using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * if (!self.client.proto(@"Chat", @"com.chatengine.emoji").exists()) {
 *     // Looks like 'Chat' objects doesn't have proto plugin with 'com.chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @discussion Register proto plugin w/o initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [AwesomeChatPlugin class]).store();
 * @endcode
 *
 * @discussion Register proto plugin with initialization configuration:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.proto(@"Chat", [AwesomeChatPlugin class])
 *     .identifier(@"com.awesome.plugin")
 *     .configuration(@{ @"api-key": @"secret" })
 *     .store();
 * @endcode
 *
 * @discussion Unregister proto plugin using it's class:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * self.client.proto(@"Chat", [AwesomeChatPlugin class]).remove();
 * @endcode
 *
 * @discussion Unregister proto plugin using it's identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * self.client.proto(@"Chat", @"com.awesome.plugin").remove();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^proto)(NSString *object, id plugin);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
