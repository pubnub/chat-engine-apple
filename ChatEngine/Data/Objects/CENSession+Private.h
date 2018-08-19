/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENSession.h"


NS_ASSUME_NONNULL_BEGIN


#pragma mark Private interface declaration

@interface CENSession (Private)


#pragma mark - Initialization and Configuration

+ (instancetype)sessionWithChatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Synchronization

- (void)listenEvents;
- (void)restore;
- (void)joinChat:(CENChat *)chat;
- (void)leaveChat:(CENChat *)chat;


#pragma mark - Misc

- (BOOL)isSynchronizationChat:(CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
