/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENChatEngine+Chat.h"


#pragma mark Class forward

@class CENChat, CENUser;


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Private interface declaration

@interface CENChatEngine (ChatPrivate)


#pragma mark - Chats management

- (void)createGlobalChat;
- (CENChat *)createDirectChatForUser:(CENUser *)user;
- (CENChat *)createFeedChatForUser:(CENUser *)user;
- (void)removeChat:(CENChat *)chat;


#pragma mark - Chats state

- (void)fetchRemoteStateForChat:(CENChat *)chat withCompletion:(void(^)(BOOL success, NSDictionary *meta))block;
- (void)handleFetchedMeta:(NSDictionary *)meta forChat:(CENChat *)chat;
- (void)updateChatState:(CENChat *)chat withData:(NSDictionary *)data completion:(nullable dispatch_block_t)block;
- (void)pushUpdatedChatMeta:(CENChat *)chat withRepresentation:(NSDictionary *)representation;


#pragma mark - Chat connection

- (void)connectToChat:(CENChat *)chat withCompletion:(void(^)(NSDictionary * __nullable meta))block;
- (void)connectChats;
- (void)disconnectChats;


#pragma mark - Participation

- (void)inviteToChat:(CENChat *)chat user:(CENUser *)user;
- (void)leaveChat:(CENChat *)chat;
- (void)fetchParticipantsForChat:(CENChat *)chat;

#pragma mark - Clean up

- (void)destroyChats;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
