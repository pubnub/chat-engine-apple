#import "CENEventEmitter.h"
#import <PubNub/PubNub.h>


#pragma mark Class forward

@class CENConfiguration;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client which is responsible for organization of
 * \b {users CENUser} interaction through \b {chats CENChat} and provide responses back to
 * completion block / closure / delegate.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine : CENEventEmitter


#pragma mark - Information

/**
 * @brief Current \b {ChatEngine CENChatEngine} configuration.
 *
 * @ref 13e9732b-1efc-4236-b9fa-154e9af2578b
 */
@property (nonatomic, readonly, copy) CENConfiguration *currentConfiguration;

/**
 * @brief \b {ChatEngine CENChatEngine} SDK version.
 *
 * @ref 9ae8cb0a-b677-4353-b79d-1797ca49c31d
 */
@property (class, nonatomic, readonly, strong) NSString *sdkVersion;

/**
 * @brief \b {ChatEngine CENChatEngine} logger which can be used to insert additional logs to
 * console (if enabled) and file (if enabled).
 *
 * @ref b91d4811-bd79-4590-930c-cd656fd50dbd
 */
@property (nonatomic, readonly, strong) PNLLogger *logger;


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure new \b {ChatEngine CENChatEngine} client instance.
 *
 * @discussion Create \b {ChatEngine CENChatEngine} client instance
 * @code
 * // objc 9a490db3-fccc-4e9b-9147-361b774f08dd
 *
 * CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"demo-36"
 *                                                                    subscribeKey:@"demo-36"];
 * self.client = [CENChatEngine clientWithConfiguration:configuration];
 * @endcode

 * @param configuration User-provided information about how client should operate and handle events.
 *
 * @return Configured and ready to use \b {ChatEngine CENChatEngine} client.
 *
 * @ref 595db2ef-9b6a-43dc-9069-f69cd328ce7c
 */
+ (instancetype)clientWithConfiguration:(CENConfiguration *)configuration
    NS_SWIFT_NAME(clientWithConfiguration(_:));


#pragma mark - Clean up

/**
 * @brief Completely terminate \b {ChatEngine  CENChatEngine}.
 *
 * @discussion Call this method when there is no more need in \b {ChatEngine CENChatEngine}. It
 * ensure, what all accrued resources will be released.
 *
 * @ref b73f8803-db74-4bdc-a62b-5de0c2f7d838
 */
- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
