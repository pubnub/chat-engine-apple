#import "CENChatEngine+Connection.h"


#pragma mark Class forward

@class CENUserConnectBuilderInterface;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine client interface for \c user's connection management.
 * @discussion This is extended Objective-C interface to provide builder pattern for methods invocation.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (ConnectionBuilderInterface)


#pragma mark - Connection

/**
 * @brief      Prepare and connect \b ChatEngine to real-time network on behalf of user identified by his UUID.
 * @discussion Builder block allow to specify \b required client's identifier which will be used to authenticate user with
 *             \b ChatEngine network.
 * @discussion Available builder parameters can be specified in different variations depending from needs.
 *
 * @discussion Connect to real-time network with user identifier:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.connect(@"ChatEngine").perform();
 * @endcode
 *
 * @discussion Connect to real-time network with user state:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * self.client.connect(@"ChatEngine").state(@{ @"name": @"PubNub" }).perform();
 * @endcode
 *
 * @discussion Connect to real-time network with user authorization key:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = CENChatEngine.Client(configuration);
 * self.client.connect(@"ChatEngine").state(@{ @"name": @"PubNub" }).authKey(@"secret").perform();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENUserConnectBuilderInterface * (^connect)(NSString *uuid);

/**
 * @brief Re-connect previously disconnected \b ChatEngine instance.
 *
 * @discussion Reconnect after client has been disconnected:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * // user requested to disconnect from ChatEngine real-time network or there was another issues which caused client
 * // disconnection.
 * // .....
 * // user requested to restore real-time data update.
 * self.client.reconnect();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^reconnect)(void);

/**
 * @brief  Disconnect \b ChatEngine from real-time network and stop any updates.
 *
 * @discussion Disconnect ChatEngine from real-time network:
 * @code
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * // .....
 * // user requested to disconnect from ChatEngine real-time network.
 * self.client.disconnect();
 * @endcode
 */
@property (nonatomic, readonly, strong) CENChatEngine * (^disconnect)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
