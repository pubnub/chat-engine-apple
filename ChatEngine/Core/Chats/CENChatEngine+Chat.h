#import "CENChatEngine.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine client interface for \c chat instance management.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatEngine (Chat)


#pragma mark - Information

/**
 * @brief      Stores reference on list of known chats.
 * @discussion List contain chats created by user and \b ChatEngine client itself.
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENChat *> *chats;

/**
 * @brief      Stores reference on chat to which join all \b ChatEngine users.
 * @discussion This chat can be useful to send announCENMents, alerts, and global events.
 */
@property (nonatomic, readonly, strong) CENChat *global;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
