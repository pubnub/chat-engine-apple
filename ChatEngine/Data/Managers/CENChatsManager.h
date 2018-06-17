#import <Foundation/Foundation.h>


#pragma mark Class forward

@class PNPresenceEventData, CENChatEngine, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  \b ChatEngine chats manager.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENChatsManager : NSObject


#pragma mark - Information

@property (nonatomic, nullable, readonly, strong) NSDictionary<NSString *, CENChat *> *chats;
@property (nonatomic, nullable, readonly, strong) CENChat *global;


#pragma mark - Initialization and Configuration

+ (instancetype)managerForChatEngine:(CENChatEngine *)chatEngine;
- (instancetype) __unavailable init;


#pragma mark - Chat connection

- (void)connectChats;
- (void)disconnectChats;



#pragma mark - Creation

- (CENChat *)createChatWithName:(nullable NSString *)name
                         group:(nullable NSString *)group
                       private:(BOOL)isPrivate
                   autoConnect:(BOOL)shouldAutoConnect
                      metaData:(nullable NSDictionary *)meta;


#pragma mark - Audition

- (nullable CENChat *)chatWithName:(NSString *)name private:(BOOL)isPrivate;


#pragma mark - Removal

- (void)removeChat:(CENChat *)chat;


#pragma mark - Handlers

- (void)handleChat:(CENChat *)chat message:(NSDictionary *)payload;
- (void)handleChat:(CENChat *)chat presenceEvent:(PNPresenceEventData *)information;


#pragma mark - Clean up

- (void)destroy;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
