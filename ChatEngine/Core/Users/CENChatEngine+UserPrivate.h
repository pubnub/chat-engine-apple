/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+User.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CENChatEngine (UserPrivate)


#pragma mark - State

- (void)updateLocalUserState:(nullable NSDictionary *)state withCompletion:(nullable dispatch_block_t)block;
- (void)propagateLocalUserStateRefreshWithCompletion:(nullable dispatch_block_t)block;
- (void)fetchUserState:(CENUser *)user withCompletion:(void(^)(NSDictionary *state))block;


#pragma mark - Clean up

- (void)destroyUsers;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
