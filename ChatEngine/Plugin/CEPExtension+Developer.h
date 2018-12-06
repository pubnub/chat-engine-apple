/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CEPExtension.h"
#import <CENChatEngine/CENErrorCodes.h>
#import "CENObject+PluginsDeveloper.h"
#import "CENEventEmitter+Interface.h"
#import "CENStructures.h"
#import "CENError.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Developer's interface declaration

@interface CEPExtension (Developer)


#pragma mark - Information

/**
 * @brief \a NSDictionary which is passed during plugin registration and contain extension required
 * configuration information.
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *configuration;

/**
 * @brief \b {Object CENObject} for which extended interface has been provided.
 */
@property (nonatomic, nullable, readonly, weak) CENObject *object;

/**
 * @brief Unique identifier of plugin which instantiated this extension.
 */
@property (nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Handlers

/**
 * @brief Handle extension instantiation and registration completion for specific
 * \b {object CENObject}.
 */
- (void)onCreate;

/**
 * @brief Handle extension destruction and unregister from specific \b {object CENObject}.
 */
- (void)onDestruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
