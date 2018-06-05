/**
 *@author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChat.h"
#import "CENObject+Private.h"


#pragma mark Class forward

@class PNPresenceEventData, CENChatEngine;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Private interface declaration

@interface CENChat (Private)


#pragma mark - Information

@property (nonatomic, readonly, copy) NSString *group;


#pragma mark - Initialization and Configuration

+ (nullable instancetype)chatWithName:(NSString *)name
                            namespace:(NSString *)nspace
                                group:(NSString *)group
                              private:(BOOL)isPrivate
                             metaData:(NSDictionary *)meta
                           chatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Activity

- (void)sleep;
- (void)wake;


#pragma mark - Participants

- (void)fetchParticipants;


#pragma mark - State

- (void)setState:(NSDictionary *)state withCompletion:(nullable dispatch_block_t)block;
- (void)updateMetaWithFetchedData:(nullable NSDictionary *)meta;


#pragma mark - Handlers

- (void)handleLeave;
- (void)handleRemoteUsersJoin:(NSArray<CENUser *> *)users;
- (void)handleRemoteUsersLeave:(NSArray<CENUser *> *)users;
- (void)handleRemoteUsersDisconnect:(NSArray<CENUser *> *)users;
- (void)handleRemoteUsersStateChange:(NSArray<CENUser *> *)users;


#pragma mark - Misc

+ (NSString *)internalNameFor:(NSString *)channelName inNamespace:(NSString *)nspace private:(BOOL)isPrivate;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
