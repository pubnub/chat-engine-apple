/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+Authorization.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CENChatEngine (AuthorizationPrivate)


#pragma mark - Access management

- (void)authorizeLocalUserWithCompletion:(dispatch_block_t)block;
- (void)authorizeLocalUserWithUUID:(NSString *)uuid authorizationKey:(NSString *)authorizationKey completion:(dispatch_block_t)block;
- (void)handshakeChatAccess:(CENChat *)chat withCompletion:(void (^)(BOOL error, NSDictionary *meta))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
