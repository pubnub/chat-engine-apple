/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENObject+Plugins.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENObject (PluginsPrivate)


#pragma mark - Plugins

/**
 * @brief Register plugin with custom identifier for receiver.
 *
 * @param cls Class of plugin which will provide extension and middleware for receiver.
 * @param identifier Unique plugin identifier under which it should be registered.
 * @param configuration Configuration object with data which will be passed to plugin instance.
 *     \b Default: @{}
 * @param shouldBeFirstInList Whether plugin should be pushed first in receiver's plugins list.
 */
- (void)registerPlugin:(Class)cls
        withIdentifier:(NSString *)identifier
         configuration:(nullable NSDictionary *)configuration
           firstInList:(BOOL)shouldBeFirstInList;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
