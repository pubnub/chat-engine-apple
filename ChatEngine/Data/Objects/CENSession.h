#import "CENObject.h"


#pragma mark Class forward

@class CENChatEngine, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \c Local user session.
 * @discussion Session allow to synchronize user's subscriptions and events between different devices from which he has been
 *             authorized and active at this moment.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENSession : CENObject


#pragma mark - Information

/**
 * @brief Stores reference on dictionary where key represent chats group and value represent key/value pairs of chat's channel
 *        to their \b CENChat instances.
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, NSDictionary<NSString *, CENChat *> *> *chats;


#pragma mark -


@end

NS_ASSUME_NONNULL_END
