/**
 *@author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENUser.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Private interface declaration

@interface CENUser (CENUser)


#pragma mark - Information

@property (nonatomic, readonly, copy) NSDictionary *userState;


#pragma mark - Initialization and Configuration

+ (nullable instancetype)userWithUUID:(NSString *)uuid state:(NSDictionary *)state chatEngine:(CENChatEngine *)chatEngine;
- (instancetype)initWithUUID:(NSString *)uuid state:(NSDictionary *)state chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - State

- (void)assignState:(nullable NSDictionary *)state;
- (void)updateState:(nullable NSDictionary *)state;
- (void)fetchStoredStateWithCompletion:(void(^)(NSDictionary * __nullable state))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
