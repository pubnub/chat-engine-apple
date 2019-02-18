#import "CENUser.h"


#pragma mark Class forward

@class CENSession;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Special type of \b {user CENUser} which represent currently connected client with write
 * permissions and ability to update it's state.
 *
 * @ref 607f1564-8fbb-4dfd-aab7-b799ac431248
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENMe : CENUser


#pragma mark - Information

/**
 * @brief \b {Object CENSession} which allow to synchronize chats list change between
 * \b {local user CENMe} devices.
 *
 * @ref c0679c82-bff2-4dd9-8a4e-d5351a26418e
 */
@property (nonatomic, nullable, readonly, strong) CENSession *session;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
