#import "CENMe.h"


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Local \b ChatEngine user representation model.
 * @discussion This model represent user for which \b ChatEngine has been configured.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENMe (Interface)


#pragma mark - State

/**
 * @brief      Update local user state.
 * @discussion Changes will be propagated to \b ChatEngine and \b PubNub network.
 *
 * @discussion Update local user information:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * [self.client handleEventOnce:@"$.ready" withHandlerBlock:^(CENMe *me) {
 *     [me updateState:@{ @"state": @"working" }];
 * }];
 * [self.client connectUser:@"ChatEngine"];
 * @endcode
 *
 * @param state Reference on dictionary which contain target local user state.
 */
- (void)updateState:(nullable NSDictionary *)state;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
