#import "CENChatEngine.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {ChatEngine CENChatEngine} client interface for \b {chats CENChat} management.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENChatEngine (Chat)


#pragma mark - Information

/**
 * @brief A map of all known \b {chats CENChat in this \b {ChatEngine CENChatEngine} client.
 *
 * @ref 383d09f5-6b39-464f-bb22-8061943555b1
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENChat *> *chats;

/**
 * @brief A global \b {chat CENChat} to which join all \b {users CENUser} when
 * \b {ChatEngine CENChatEngine} client connects.
 *
 * @note This \b {chat CENChat} will be created only if \b {CENConfiguration.enableGlobal} is set to
 * \c YES during \b {ChatEngine CENChatEngine} client configuration.
 *
 * @ref f7b47331-33ee-437a-bc60-ec6770dccf47
 */
@property (nonatomic, readonly, nullable, strong) CENChat *global;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
