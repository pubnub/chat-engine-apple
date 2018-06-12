#import "CENChatEngine+Authorization.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user's authorization management.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (AuthorizationBuilderInterface)


#pragma mark - Configuration

/**
 * @brief      Re-authenticate local user with new authorization key.
 * @discussion Update \c local user authorization information and use it from now on for him.
 *
 * @discussion Change user's authorization key:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     self.client.reauthorize(@"super-secret");
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^reauthorize)(NSString *authKey);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
