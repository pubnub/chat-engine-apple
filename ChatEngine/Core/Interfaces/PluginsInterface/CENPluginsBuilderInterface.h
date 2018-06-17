#import "CENInterfaceBuilder.h"
#import "CEPPlugin.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine plugins management API interface builder.
 * @discussion Depending on object from which builder has been invoked, it can manage proto plugins (if called from
 *             \b ChatEngine client) or object's plugins.
 *             Proto plugins automatically attached to each instance (of specific object \c type) during instantiation.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2017 PubNub, Inc.
 */
@interface CENPluginsBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief      Specify proto plugin identifier.
 * @discussion Specify identifier under which initialized plugin will be stored and can be retrieved.
 *             If value not specified during registration process, \b ChatEngine will use \b CEPPlugin class' \c identifier
 *             property (getter should be replaced by subclass) to get value for this parameter.
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^identifier)(NSString * __nullable identifier);

/**
 * @brief      Specify proto plugin initialization configuration.
 * @discussion If plugin require configuration during creation, this parameter allow to specify it.
 */
@property (nonatomic, readonly, strong) CENPluginsBuilderInterface * (^configuration)(NSDictionary * __nullable configuration);


#pragma mark - Call

/**
 * @brief  Store proto plugin for further instantiation using passed parameters.
 */
@property (nonatomic, readonly, strong) void(^store)(void);

/**
 * @brief      Remove proto plugin using passed parameters.
 * @discussion Remove proto plugin class and all instantiated instances (including instances attached to target \c objects).
 */
@property (nonatomic, readonly, strong) void(^remove)(void);

/**
 * @brief  Check whether proto plugin exists basing on passed parameters.
 */
@property (nonatomic, readonly, strong) BOOL (^exists)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
