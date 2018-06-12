#import <CENChatEngine/CEPPlugin.h>
#import "CEDummyEmitMiddleware.h"
#import "CEDummyOnMiddleware.h"
#import "CEDummyExtension.h"


#pragma mark Interface declaration

@interface CEDummyPlugin : CEPPlugin


#pragma mark - Information

/**
 * @brief  Stores reference on list of classes for which plugin should provide interface extension.
 */
@property (class, nonatomic, strong) NSArray<Class> *classesWithExtensions;

/**
 * @brief  Stores reference on map of middleware locations to list of classes for which plugin
 *         provide middleware.
 */
@property (class, nonatomic, strong) NSDictionary<NSString *, NSArray<Class> *> *middlewareLocationClasses;

/**
 * @brief  Stores reference on map of middleware locations to list of event names which should be
 *         handled by them.
 */
@property (class, nonatomic, strong) NSDictionary<NSString *, NSArray<NSString *> *> *middlewareLocationEvents;

#pragma mark -


@end
