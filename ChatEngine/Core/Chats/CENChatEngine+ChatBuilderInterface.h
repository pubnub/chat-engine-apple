#import "CENChatEngine+Chat.h"


#pragma mark Class forward

@class CENChatBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c chat instance management.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (ChatBuilderInterface)


#pragma mark - Chat

/**
 * @brief      Create or retrieve reference on previously created chat instance (depending from used builder commiting
 *             function).
 * @discussion Available builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Create public chat with random name:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     CENChat *chat = self.client.Chat().create();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Create public chat with name:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     CENChat *chat = self.client.Chat().name(@"test-chat").create();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Create public chat with meta information:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.once(@"$.ready", ^(CENMe *me) {
 *     CENChat *chat = self.client.Chat().name(@"test-chat").meta(@{ @"interesting": @"data" }).create();
 * });
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Retrieve previously created chat:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.connect(@"ChatEngine").perform();
 * // .....
 * // show interface for conversation creation, but ensure, what there is no such conversation yet.
 * CENChat *chat = self.client.Chat().name(@"test-chat").get();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChatBuilderInterface * (^Chat)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
