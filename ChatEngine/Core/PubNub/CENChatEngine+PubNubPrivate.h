/**
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+PubNub.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CENChatEngine (PubNubPrivate)


#pragma mark - Information

@property (nonatomic, readonly, strong) dispatch_queue_t pubNubResourceAccessQueue;
@property (nonatomic, readonly, strong) dispatch_queue_t pubNubCallbackQueue;
@property (nonatomic, readonly, strong) NSString *pubNubUUID;
@property (nonatomic, readonly, strong) NSString *pubNubAuthKey;


#pragma mark - Configuration

- (void)setupPubNubForUserWithUUID:(NSString *)uuid authorizationKey:(NSString *)authorizationKey;
- (void)changePubNubAuthorizationKey:(NSString *)authorizationKey withCompletion:(dispatch_block_t)block;


#pragma mark - Connection

- (void)connectToPubNub;
- (void)disconnectFromPubNub;


#pragma mark - History

- (void)searchMessagesIn:(NSString *)channel withStart:(NSNumber *)date limit:(NSUInteger)limit completion:(PNHistoryCompletionBlock)block;


#pragma mark - Presence

- (void)fetchParticipantsForChannel:(NSString *)channel withState:(BOOL)fetchState completion:(PNHereNowCompletionBlock)block;
- (void)setClientState:(NSDictionary *)state forChannel:(NSString *)channel withCompletion:(nullable PNSetStateCompletionBlock)block;


#pragma mark - Subscription

- (void)unsubscribeFromChannels:(NSArray<NSString *> *)channels;


#pragma mark - Publishing

- (void)publishStorable:(BOOL)shouldStoreInHisotry
                   data:(NSDictionary *)data
              toChannel:(NSString *)channel
         withCompletion:(PNPublishCompletionBlock)block;


#pragma mark - Stream controller

- (void)channelsForGroup:(NSString *)group
          withCompletion:(void(^)(NSArray<NSString *> * __nullable chats, PNErrorData * __nullable errorData))block;


#pragma mark - Clean up

- (void)destroyPubNub;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
