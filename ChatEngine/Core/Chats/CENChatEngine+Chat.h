#import "CENChatEngine.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {CENChatEngine} client interface for \b {chats CENChat} management.
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENChatEngine (Chat)


#pragma mark - Information

/**
 * @brief A map of all known \b {chats CENChat in this \b {CENChatEngine} client.
 *
 * @ref 383d09f5-6b39-464f-bb22-8061943555b1
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENChat *> *chats;

/**
 * @brief A global \b {chat CENChat} to which join all \b {users CENUser} when
 * \b {CENChatEngine} client connects.
 *
 * @ref f7b47331-33ee-437a-bc60-ec6770dccf47
 */
@property (nonatomic, readonly, strong) CENChat *global;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
