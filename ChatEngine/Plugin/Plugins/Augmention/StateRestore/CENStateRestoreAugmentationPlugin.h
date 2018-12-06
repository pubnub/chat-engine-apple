#import "CEPPlugin.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 */
typedef struct CENStateRestoreAugmentationConfigurationKeys {
    /**
     * @brief \b {Chat CENChat} for which plugin's middleware created.
     */
    __unsafe_unretained NSString *chat;
} CENStateRestoreAugmentationConfigurationKeys;

extern CENStateRestoreAugmentationConfigurationKeys CENStateRestoreAugmentationConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Object CENObject} local emitter plugin.
 *
 * @discussion Plugin allows temporally postpone local events emitting till it's sender state will
 * be fetched.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENStateRestoreAugmentationPlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
