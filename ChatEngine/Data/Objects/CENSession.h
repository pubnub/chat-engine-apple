#import "CENObject.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} \b {chats CENChat} list synchronization session.
 *
 * @note Synchronization disabled by default and if required, can be enabled by setting
 * \b {CENConfiguration.synchronizeSession} to \b YES.
 *
 * @ref c865cb8d-ce71-4868-bdac-fe46e3727193
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENSession : CENObject


#pragma mark - Information

/**
 * @brief Map of synchronized chat channel names to \b {chats CENChat} which they represent.
 *
 * @ref abf41f0a-6393-4d5f-9777-9699ea4250fa
 */
@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, CENChat *> *chats;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
