/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <Foundation/Foundation.h>
#import "CENObject.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Remote user representation model which allow to get information about user itself and
 * interact with him using \b {direct} chat.
 *
 * @ref a4bf46b0-25d1-4e6a-9cfc-6fbd7e390be1
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENUser : CENObject


#pragma mark - Information

/**
 * @brief \a NSDictionary which represent user's state bound to \b {CENChatEngine.global} chat.
 *
 * @discussion See \b {CENMe.update} for how to assign state values.
 */
@property (nonatomic, readonly, copy) NSDictionary *state;

/**
 * @brief \b {Chat CENChat} which can be used to send direct (private) messages which right to
 * this user.
 *
 * @ref d11cc0e8-3295-43f1-9210-d28fd6b7682c
 */
@property (nonatomic, readonly, strong) CENChat *direct;

/**
 * @brief Unique user identifier which has been passed during instance initialization.
 *
 * @ref 2094781a-00e5-4bb1-a2ec-c6333618d534
 */
@property (nonatomic, readonly, copy) NSString *uuid;

/**
 * @brief \b {Chat CENChat} which is used by \b {user CENUser} to publish updates (public) which
 * can be observed by anyone.
 *
 * @ref e8b1e8fe-8213-41f0-9fbf-0572ca09a47d
 */
@property (nonatomic, readonly, strong) CENChat *feed;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
