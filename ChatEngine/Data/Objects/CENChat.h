#import "CENObject.h"


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} chat room representation.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChat : CENObject


#pragma mark - Information

/**
 * @brief Whether chat publicly available or require owner's authorization to join to it.
 *
 * @ref f39e3edd-4083-4370-82ca-379bc5a7e8c7
 */
@property (nonatomic, readonly, assign, getter=isPrivate) BOOL private NS_SWIFT_NAME(private);

/**
 * @brief List of users in this chat.
 *
 * @discussion Automatically kept in sync as users join and leave the chat. Use \b {$.online.join}
 * and related events to get notified when this changes.
 *
 * @ref 2aca1ec9-4c73-40a9-a67b-438a0e55eeeb
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENUser *> *users;

/**
 * @brief Whether client was able to connect to chat at least once.
 *
 * @ref 5a386b00-6089-4a4c-a70a-346831edb042
 */
@property (nonatomic, readonly, assign) BOOL hasConnected;

/**
 * @brief Name of channel which is used internally by \b {ChatEngine CENChatEngine} itself.
 *
 * @ref b5fe612d-8577-4902-a4d2-bbffe29cb711
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief Whether chat currently connected to the network.
 *
 * @ref f0abe73e-a6cf-40dc-b6e9-b813c697e835
 */
@property (nonatomic, readonly, assign) BOOL connected;

/**
 * @brief Name of channel which has been passed during instance initialization.
 *
 * @ref 26cc8da0-1a96-4fd4-8714-700521402413
 */
@property (nonatomic, readonly, copy) NSString *name;


#pragma mark - Helpers

/**
 * @brief Check whether passed name represent private chat or not.
 *
 * @param chatName Name of channel for which verification should be done.
 *
 * @return Whether passed chat name from private chat or not.
 *
 * @ref 645ec82f-2843-4792-8650-b72d5ba55b04
 */
+ (BOOL)isPrivate:(NSString *)chatName;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
