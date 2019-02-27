/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENChatEngine+Authorization.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface CENChatEngine (AuthorizationPrivate)

/**
 * @brief Complete \b {local user CENMe} authorization after \b [CENChatEngine connectUser:] or
 * \b [CENChatEngine connectUser:withAuthKey:globalChannel:] method call.
 *
 * @param block Authorization completion handler block.
 */
- (void)authorizeLocalUserWithCompletion:(dispatch_block_t)block;

/**
 * @brief Complete \b {local user CENMe} authorization with provided credentials.
 *
 * @param uuid Unique identifier of currently active user.
 * @param authKey Access key which will be used for \b {local user CENMe} authorization.
 * @param block Authorization completion handler block.
 */
- (void)authorizeLocalUserWithUUID:(NSString *)uuid
                  authorizationKey:(NSString *)authKey
                        completion:(dispatch_block_t)block;

/**
 * @brief Complete \b {chat CENChat} registration for \b {local user CENMe}.
 *
 * @discussion \b {Chat CENChat} will be added to \b {local user CENMe} custom \b {chats CENChat}
 * group and granted read / write access.
 *
 * @param chat \b {Chat CENChat} for which user should be granted access.
 * @param block Chat handshake completion handler block.
 */
- (void)handshakeChatAccess:(CENChat *)chat withCompletion:(dispatch_block_t)block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
