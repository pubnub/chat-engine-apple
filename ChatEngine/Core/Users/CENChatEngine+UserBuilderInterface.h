#import "CENChatEngine+User.h"


#pragma mark Class forward

@class CENUserBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user instance management.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (UserBuilderInterface)


#pragma mark - User

/**
 * @brief      Create/check existence of user (depending from used builder commiting function).
 * @discussion Builder block allow to specify \b required field - user unique identifier which later can be used to get
 *             instance on this user back.
 * @discussion Available builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Rreate user w/o state information:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     CENUser *user = self.client.User(@"ChatEngineUser").create();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Rreate user w/ state information:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     CENUser *user = self.client.User(@"ChatEngineUser").state(@{ @"name": @"PubNub" }).create();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Retrieve previously created/noticed user:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * CENUser *user = self.client.User(@"ChatEngineUser").get();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENUserBuilderInterface * (^User)(NSString *uuid);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
