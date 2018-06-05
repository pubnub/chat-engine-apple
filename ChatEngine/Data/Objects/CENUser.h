#import <Foundation/Foundation.h>
#import "CENObject.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Remote \b ChatEngine user representation model.
 * @discussion This instance can be used to reach remote user by sending him direct message or subscribe on his private feed.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENUser : CENObject


#pragma mark - Information

/**
 * @brief  Stores reference on publicly available user's information.
 */
@property (nonatomic, readonly, copy) NSDictionary *state;

/**
 * @brief  Reference on chat which can be used to send direct messages which is accessible only to this user.
 */
@property (nonatomic, readonly, strong) CENChat *direct;

/**
 * @brief  Stores reference on unique user identifier which has been passed during instance initialization.
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 * @brief  Reference on chat which is used by user to publish updates to which anyone has access.
 */
@property (nonatomic, readonly, strong) CENChat *feed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
