#import "CENObject.h"


#pragma mark Class forward

@class CENUser;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b ChatEngine chat room representation model.
 * @discussion This instance can be used to invite new user(s), send messages and receive updates.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChat : CENObject


#pragma mark - Information

/**
 * @brief  Stores whether chat publicly available or require owner's authoriztion to join to it.
 */
@property (nonatomic, readonly, assign, getter=isPrivate) BOOL private NS_SWIFT_NAME(private);

/**
 * @brief  Reference on map of active user(s) stored under their unique identifiers.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENUser *> *users;

/**
 * @brief  Stores whether client was able to connect to chat at least once.
 */
@property (nonatomic, readonly, assign) BOOL hasConnected;

/**
 * @brief  Stores reference on \c meta chat information which has been set earlier.
 */
@property (nonatomic, readonly, copy) NSDictionary *meta;

/**
 * @brief      Stores reference on name of channel which is used internally by \b ChatEngine itself.
 * @discussion This name used to store reference on \b CENChat instance inside of \b ChatEngine client and used by \b PubNub
 *             Function to store/remove it in user's session when he join/levae it.
 */
@property (nonatomic, readonly, copy) NSString *channel;

/**
 * @brief  Stores whether \b ChatEngine and \c local user currently connected to this chat or not.
 */
@property (nonatomic, readonly, assign) BOOL connected;

/**
 * @brief  Stores reference on name of channel which has been passed during instance initialization.
 */
@property (nonatomic, readonly, copy) NSString *name;

/**
 * @brief  Stores whether chat has been manually disconnected or not.
 */
@property (nonatomic, readonly, assign) BOOL asleep;


#pragma mark - Helpers

/**
 * @brief  Check whether passed \c chat name represent \c private \c chat or not.
 *
 * @param chatName Reference on name of channel for which verification should be done.
 */
+ (BOOL)isPrivate:(NSString *)chatName;

/**
 * @brief      Serialize \c chat instance into dictionary.
 * @discussion Serialized model used by \b PubNub function to manage access rights to it.
 *
 * @return Serialized \c chat instance.
 */
- (NSDictionary *)dictionaryRepresentation;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
