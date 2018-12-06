#import "CENObject.h"


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} \b {chats CENChat} list synchronization session.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
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
