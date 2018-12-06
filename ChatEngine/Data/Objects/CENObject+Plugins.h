#import "CENObject.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Plugins interface declaration

@interface CENObject (Plugins)


#pragma mark - Plugins

/**
 * @brief Check whether plugin with specified class already registered for receiver or not.
 *
 * @discussion Check whether plugin registered using it's class or not
 * @code
 * // objc 5a79f0b7-b8bf-44c6-9ec1-344947934d44
 *
 * if (![self.object hasPlugin:[AwesomeChatPlugin class]) {
 *     // Looks like object doesn't have plugin from AwesomeChatPlugin.
 * }
 * @endcode
 *
 * @param cls Class (subclass of \b {CEPPlugin}) which should be used for check.
 *
 * @return Whether plugin with specified class currently registered for receiver or not.
 *
 * @ref 0548677f-7eac-4670-9af2-54c0d118d313
 */
- (BOOL)hasPlugin:(Class)cls;

/**
 * @brief Check whether plugin with specified identifier already registered for receiver or not.
 *
 * @discussion Check whether proto plugin registered using it's identifier or not
 * @code
 * // objc e232ad0c-3f2f-48c0-8dc8-ad0b45caf8b0
 *
 * if (![self.object hasPluginWithIdentifier:@"com.chatengine.emoji") {
 *     // Looks like object doesn't have plugin with 'com.chatengine.emoji' identifier.
 * }
 * @endcode
 *
 * @param identifier Unique plugin identifier.
 *
 * @return Whether plugin with specified identifier currently registered for receiver or not.
 *
 * @ref 83033313-8a03-490e-8e87-622438b85111
 */
- (BOOL)hasPluginWithIdentifier:(NSString *)identifier;

/**
 * @brief Register plugin for receiver.
 *
 * @discussion Register plugin class w/o \c configuration
 * @code
 * // objc 89073a82-ff7a-4765-a6c4-e778e775775d
 *
 * [self.object registerPlugin:[AwesomeChatPlugin class] withConfiguration:nil];
 * @endcode
 *
 * @param cls Class of plugin which will provide extension and middleware for receiver.
 * @param configuration Configuration object with data which will be passed to plugin instance.
 *     \b Default: \c @{}
 *
 * @ref d2e396e7-d9f2-4762-a822-619d0819e9a8
 */
- (void)registerPlugin:(Class)cls withConfiguration:(nullable NSDictionary *)configuration;

/**
 * @brief Register plugin with custom identifier for receiver.
 *
 * @discussion Register plugin with custom \c identifier with \c configuration
 * @code
 * // objc 6b181727-6701-4f26-a404-f491a9be5e8a
 *
 * [self.object registerPlugin:[AwesomeChatPlugin class] withIdentifier:@"com.awesome.plugin"
 *               configuration:@{ @"api-key": @"secret" }];
 * @endcode
 *
 * @param cls Class of plugin which will provide extension and middleware for receiver.
 * @param identifier Unique plugin identifier under which it should be registered.
 * @param configuration Configuration object with data which will be passed to plugin instance.
 *     \b Default: @{}
 *
 * @ref 4b1033e0-2398-4706-9bfd-7a91e68c1ef8
 */
- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration;

/**
 * @brief Unregister plugin from specified receiver.
 *
 * @discussion Unregister proto plugin using it's class
 * @code
 * // objc e88fe74c-516e-45b1-ae58-12dd34efb34f
 *
 * [self.object unregisterPlugin:[AwesomeChatPlugin class]];
 * @endcode
 *
 * @param cls Class of plugin (subclass of \b {CEPPlugin}) which should be unregistered.
 *
 * @ref e9ca8ed1-9851-4853-af27-c14848295793
 */
- (void)unregisterPlugin:(Class)cls;

/**
 * @brief Unregister plugin with custom identifier from specified receiver.
 *
 * @code
 * // objc 2b753421-8463-4d69-92eb-da1dba1e45d9
 *
 * [self.object unregisterPluginWithIdentifier:@"com.awesome.plugin"];
 * @endcode
 *
 * @param identifier Unique plugin identifier which has been used during registration.
 *
 * @ref cd21bcb8-369a-4b1d-bfa9-c6c00cb471ff
 */
- (void)unregisterPluginWithIdentifier:(NSString *)identifier;


#pragma mark - Extension

/**
 * @brief Find receiver's extension by class.
 *
 * @discussion Find extension by plugin's class
 * @code
 * // objc 7c2a6fcf-3e36-4e66-b80e-3c09b5a46c8d
 *
 * [self.object extension:[AwesomeChatPlugin class]
 *            withContext:^(AwesomeChatExtension *extension) {
 *
 *     // Use extension's methods within provided execution context.
 * }];
 * @endcode
 *
 * @param cls Class of plugin (subclass of \b {CEPPlugin}) which provides requested extension.
 * @param block Extension execution context block / closure which pass reference on extension
 *     instance which can be used.
 *
 * @ref 831bbbae-50fe-441c-a564-34373ca54ca1
 */
- (void)extension:(Class)cls withContext:(void(^)(id __nullable extension))block;

/**
 * @brief Find receiver's extension by identifier.
 *
 * @discussion Find extension by custom identifier
 * @code
 * // objc 32c5ec2c-2b11-40d8-99c5-a848985de453
 *
 * [self.object extensionWithIdentifier:@"com.awesome.plugin"
 *                          withContext:^(AwesomeChatExtension *extension) {
 *
 *     // Use extension's methods within provided execution context.
 * }];
 * @endcode
 *
 * @param identifier Unique plugin identifier which used during registration.
 * @param block Extension execution context block / closure which pass reference on extension
 *     instance which can be used.
 *
 * @ref 0c24d012-571f-4829-94bb-e3f3261ad54a
 */
- (void)extensionWithIdentifier:(NSString *)identifier
                        context:(void(^)(id __nullable extension))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
