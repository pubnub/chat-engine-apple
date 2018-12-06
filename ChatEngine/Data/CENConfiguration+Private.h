/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENConfiguration.h"
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENConfiguration (Private)


#pragma mark - PubNub helper methods

/**
 * @brief Get configuration object for \b PubNub client.
 *
 * @return \b PNConfiguration with data required by \b PubNub client to work.
 */
- (PNConfiguration *)pubNubConfiguration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
