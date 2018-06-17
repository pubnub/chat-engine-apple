#import "CENChatEngine.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user's authorization management.
 * @discussion This interface used when builder interface usage not configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (Authorization)


#pragma mark - Configuration

/**
 * @brief  Re-authorize \c local user with new \c authorization key.
 *
 * @discussion Change user's authorization key:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [self.client reauthorizeUserWithKey:@"super-secret"];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param authKey Reference on key which should be used for \c local user from now on.
 */
- (void)reauthorizeUserWithKey:(NSString *)authKey;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
