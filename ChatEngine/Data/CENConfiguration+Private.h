/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENConfiguration.h"
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CENConfiguration (Private)


#pragma mark - PubNub helper methods

/**
 * @brief  Contruct configuration instance for \b PubNub client which is responsible for data transfer between users
 *         connected to chat(s).
 *
 * @return Configured and ready to use \b PubNub client configuration instance.
 */
- (PNConfiguration *)pubNubConfiguration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
