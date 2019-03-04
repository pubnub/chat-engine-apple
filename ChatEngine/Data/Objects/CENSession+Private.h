/**
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENSession.h"


#pragma mark Class forward

@class CENChatEngine;


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENSession (Private)


#pragma mark - Initialization and Configuration

/**
 * @brief Create and configure session synchronizer.
 *
 * @param chatEngine \b {CENChatEngine} client which represent local user for which
 *     session will be synchronized.
 *
 * @return Configured and ready to use session synchronizer.
 */
+ (instancetype)sessionWithChatEngine:(CENChatEngine *)chatEngine;


#pragma mark - Synchronization

/**
 * @brief Create synchronization chat and start listening \b {chats CENChat} list change.
 */
- (void)listenEvents;

/**
 * @brief Retrieve list of \b {chats CENChat} from \c custom group.
 */
- (void)restore;

/**
 * @brief Synchronize join to \b {chat CENChat}.
 *
 * @param \b {Chat CENChat} to which \b {local user CENMe} joined or created.
 */
- (void)joinChat:(CENChat *)chat;

/**
 * @brief Synchronize leave from \b {chat CENChat}.
 *
 * @param \b {Chat CENChat} which \b {local user CENMe} decided to leave.
 */
- (void)leaveChat:(CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
