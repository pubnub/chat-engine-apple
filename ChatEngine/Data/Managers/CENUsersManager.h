#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CENChatEngine, CENUser, CENMe;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine users manager.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENUsersManager : NSObject


#pragma mark - Information

@property (nonatomic, readonly, strong) NSDictionary<NSString *, CENUser *> *users;
@property (nonatomic, nullable, readonly, strong) CENMe *me;


#pragma mark - Initialization and Configuration

+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine;
- (instancetype) __unavailable init;


#pragma mark - Creation

- (CENUser *)createUserWithUUID:(NSString *)uuid state:(nullable NSDictionary *)state;
- (NSArray<CENUser *> *)createUsersWithUUID:(NSArray<NSString *> *)uuids;


#pragma mark - Audition

- (nullable CENUser *)userWithUUID:(NSString *)uuid;


#pragma mark - Clean up

- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
