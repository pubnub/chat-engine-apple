/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPExtension.h"
#import "CENObject+PluginsDeveloper.h"
#import "CENObject+PluginsDeveloper.h"
#import "CENEventEmitter+Interface.h"
#import "CENStructures.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Developer's interface declaration

@interface CEPExtension (Developer)


#pragma mark - Information

/**
 * @brief  Stores reference on dictionary which is passed during plugin registration and may contain extension configuration
 *         information.
 */
@property (nonatomic, nullable, readonly, weak) NSDictionary *configuration;

/**
 * @brief Stores reference on object for which extended interface has been provided.
 */
@property (nonatomic, nullable, readonly, weak) CENObject *object;

/**
 * @brief  Stores reference on unique identifier of plugin which instantiated this extension.
 */
@property (nonatomic, readonly, strong) NSString *identifier;


#pragma mark - Handlers

/**
 * @brief      Handle extension instantiation and registration completion for specific \b CENObject.
 * @discussion Method will be called on plugin within it's execution context (all state information can be used right in this
 *             method w/o starting new context).
 */
- (void)onCreate;

/**
 * @brief      Handle extension destruction and unregister from specific \b CENObject.
 * @discussion Method will be called on plugin within it's execution context (all state information can be used right in this
 *             method w/o starting new context).
 */
- (void)onDestruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
