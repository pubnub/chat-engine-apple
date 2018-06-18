#import "CENUser.h"


#pragma mark Class forward

@class CENSession;


/**
 * @brief      Local \b ChatEngine user representation model.
 * @discussion This model represent user for which \b ChatEngine has been configured.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENMe : CENUser


#pragma mark - Information

/**
 * @brief  Stores reference on object which allow track user's session synchronization.
 */
@property (nonatomic, nullable, readonly, strong) CENSession *session;

#pragma mark -


@end
