/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENPushNotificationsExtension.h"
#if TARGET_OS_IOS || TARGET_OS_WATCH
#import <UserNotifications/UserNotifications.h>
#endif
#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENChat+Interface.h>
#import "CENPushNotificationsPlugin.h"
#import <CENChatEngine/CENEvent.h>
#import <CENChatEngine/CENMe.h>


#pragma mark Const

/**
 * @brief  Stores reference on value which represent event identifier for all received notifications.
 */
static NSString * const kCENPushNotificationAllNotificationsID = @"all";

/**
 * @brief  Stores maximum length of string which contain list of channels on which manipulation should be performed.
 */
static NSUInteger const kCENPushNotificationMaximumChannelsLength = 20000;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENPushNotificationsExtension ()


#pragma mark - Information

/**
 * @brief  Stores reference on chat creation block.
 * @note   Reference required to be able to unsubscribe from notifications.
 */
@property (nonatomic, strong) void(^chatCreateHandler)(CENChat *chat);


#pragma mark - Handlers

/**
 * @brief  Handler push notification state change request processing results.
 *
 * @param errors Reference on list of \a NSError instances which describe all issus which happened during request.
 * @param block  Reference on request process completion block. Block pass only one argument - reference on request processing error.
 */
- (void)handleStateChangeWithErrors:(NSArray<NSError *> *)errors completion:(void(^ __nullable)(NSError * __nullable error))block;


#pragma mark - Misc

/**
 * @brief      Split channels list on series of channels on which requests should be perfomred.
 * @discussion Each sequence will contain maximum number of channels which can be handled with single request.
 *
 * @param channels Reference on list of channels which should be splitted into sessions.
 *
 * @return Series of channel names.
 */
+ (NSArray<NSArray *> *)channelSeriesFromChannels:(NSArray<NSString *> *)channels;

/**
 * @brief  Compose error which emitted from \b PubNub for set of processed chats.
 *
 * @param chats Reference on list of \b CENChat instances which has been used during last state change operation.
 * @param status Reference on \b PubNub error status object which contain information about error.
 *
 * @return Reference on error based on \b PubNub error state and list of used \c chats.
 */
+ (NSError *)pushNotificationStateChangeErrorForChats:(NSArray<CENChat *> *)chats fromStatus:(PNErrorStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENPushNotificationsExtension


#pragma mark - Management notifications state

- (void)enablePushNotifications:(BOOL)shouldEnabled
                       forChats:(NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^)(NSError *error))block {
    
    NSArray<NSArray<NSString *> *> *channelSeries = [CENPushNotificationsExtension channelSeriesFromChannels:[chats valueForKey:@"channel"]];
    CENChatEngine *chatEngine = ((CENMe *)self.object).chatEngine;
    NSMutableArray<NSError *> *errors = [NSMutableArray new];
    dispatch_group_t group = dispatch_group_create();
    PubNub *pubNub = chatEngine.pubnub;

    if (shouldEnabled) {
        for (NSArray<NSString *> *channels in channelSeries) {
            dispatch_group_enter(group);
            [pubNub addPushNotificationsOnChannels:channels withDevicePushToken:token andCompletion:^(PNAcknowledgmentStatus *status) {
                if (status.isError) {
                    [errors addObject:[CENPushNotificationsExtension pushNotificationStateChangeErrorForChats:chats fromStatus:status]];
                }
        
                dispatch_group_leave(group);
            }];
        }
    } else {
        if (chats.count) {
            for (NSArray<NSString *> *channels in channelSeries) {
                dispatch_group_enter(group);
                [pubNub removePushNotificationsFromChannels:channels withDevicePushToken:token andCompletion:^(PNAcknowledgmentStatus *status) {
                    if (status.isError) {
                        [errors addObject:[CENPushNotificationsExtension pushNotificationStateChangeErrorForChats:chats fromStatus:status]];
                    }
                    
                    dispatch_group_leave(group);
                }];
            }
        } else {
            dispatch_group_enter(group);
            [pubNub removeAllPushNotificationsFromDeviceWithPushToken:token andCompletion:^(PNAcknowledgmentStatus *status) {
                if (status.isError) {
                    NSArray<CENChat *> *failedChats = [CENPushNotificationsExtension chatListByChannelNames:status.errorData.channels
                                                                                                    forUser:chatEngine.me];
                    [errors addObject:[CENPushNotificationsExtension pushNotificationStateChangeErrorForChats:failedChats fromStatus:status]];
                }
                
                dispatch_group_leave(group);
            }];
        }
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf handleStateChangeWithErrors:errors completion:block];
    });
}


#pragma mark - Handlers

- (void)onCreate {
    
    CENMe *me = (CENMe *)self.object;
    NSDictionary *configuration = self.configuration;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![me.direct hasPluginWithIdentifier:self.identifier]) {
            [me.direct registerPlugin:[CENPushNotificationsPlugin class] withConfiguration:configuration];
        }
    });
    
    self.chatCreateHandler = ^(CENChat *chat) {
        [chat registerPlugin:[CENPushNotificationsPlugin class] withConfiguration:configuration];
    };
    
    [me.chatEngine handleEvent:@"$.created.chat" withHandlerBlock:self.chatCreateHandler];
}

- (void)onDestruct {
    
    CENMe *me = (CENMe *)self.object;
    [me.chatEngine removeHandler:self.chatCreateHandler forEvent:@"$.created.chat"];
}

- (void)handleStateChangeWithErrors:(NSArray<NSError *> *)errors completion:(void(^)(NSError *error))block {
    
    if (!block) {
        return;
    }
    
    NSError *error = errors.count == 1 ? errors.firstObject : nil;
    
    if (errors.count > 1) {
        NSMutableArray<CENChat *> *failedChats = [NSMutableArray new];
        
        for (error in errors) {
            if (((NSArray *)error.userInfo[kCENNotificationsErrorChatsKey]).count) {
                [failedChats addObjectsFromArray:error.userInfo[kCENNotificationsErrorChatsKey]];
            } else {
                break;
            }
        }
        
        if (failedChats.count) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
            userInfo[kCENNotificationsErrorChatsKey] = failedChats;
            
            error = [NSError errorWithDomain:errors.lastObject.domain code:errors.lastObject.code userInfo:userInfo];
        }
    }
    
    block(error);
}


#pragma mark - Notifications management

- (void)markNotificationAsSeen:(NSNotification *)notification withCompletion:(void(^)(NSError *error))block {

    NSString *eventName = notification.userInfo[@"cepayload"][CENEventData.event];
    NSString *eventID = notification.userInfo[@"cepayload"][CENEventData.eventID];
    CENChatEngine *chatEngine = ((CENMe *)self.object).chatEngine;
    CENEvent *event = nil;
    
    if (eventName) {
        if (![eventName isEqualToString:@"$notifications.seen"] && eventID.length) {
            // Emit 'seen' event internally will be pre-formatted with push notifications payload.
            event = [chatEngine.me.direct emitEvent:@"$notifications.seen" withData:@{ CENEventData.eventID: eventID }];
            
            if (block) {
                [event handleEventOnce:@"$.emitted" withHandlerBlock:^(NSDictionary *__unused payload) {
                    block(nil);
                }];
                
                [event handleEventOnce:@"$.error.emitter" withHandlerBlock:^(NSError *error) {
                    block(error);
                }];
            }
            
            [self hideNotificationWithEventID:eventID];
        }
    } else if (block) {
        block(nil);
    }
}

- (void)markAllNotificationAsSeenWithCompletion:(void(^)(NSError *error))block {

    CENChatEngine *chatEngine = ((CENMe *)self.object).chatEngine;
    // Emit 'seen' event internally will be pre-formatted with push notifications payload.
    CENEvent *event = [chatEngine.me.direct emitEvent:@"$notifications.seen"
                                             withData:@{ CENEventData.eventID: kCENPushNotificationAllNotificationsID }];
    
    if (block) {
        [event handleEvent:@"$.emitted" withHandlerBlock:^(NSDictionary *__unused payload) {
            block(nil);
        }];
    }
    
    [self hideNotificationWithEventID:kCENPushNotificationAllNotificationsID];
}

- (void)hideNotificationWithEventID:(NSString *)seenEventID {
    
#if TARGET_OS_IOS || TARGET_OS_WATCH
    if (@available(iOS 10.0, watchOS 3.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        NSMutableArray<NSString *> *notificationIdentifiers = [NSMutableArray array];
        dispatch_async(dispatch_get_main_queue(), ^{
#if !TARGET_OS_WATCH
            UIBackgroundTaskIdentifier backgroundTaskIdentifier = 0;
            
            if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
                }];
            }
#endif
            
            [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> *notifications) {
                [notifications enumerateObjectsUsingBlock:^(UNNotification *notification, __unused NSUInteger objectIdx, BOOL *enumeratorStop) {
                    NSString *eventID = ((UNNotificationContent *)notification.request.content).userInfo[@"cepayload"][CENEventData.eventID];
                    
                    if (eventID && ([eventID isEqualToString:seenEventID] || [seenEventID isEqualToString:kCENPushNotificationAllNotificationsID])) {
                        [notificationIdentifiers addObject:notification.request.identifier];
                        *enumeratorStop = [eventID isEqualToString:seenEventID];
                    }
                }];
                
                if (notificationIdentifiers.count) {
                    [center removeDeliveredNotificationsWithIdentifiers:notificationIdentifiers];
                }
                
#if !TARGET_OS_WATCH
                if (backgroundTaskIdentifier) {
                    [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
                }
#endif
            }];
        });
    }
#endif
}


#pragma mark - Misc

+ (NSArray<NSArray *> *)channelSeriesFromChannels:(NSArray<NSString *> *)channels {
    
    NSCharacterSet *allowedCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSUInteger length = [[channels componentsJoinedByString:@","] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters].length;

    if (length < kCENPushNotificationMaximumChannelsLength) {
        return length == 0 ? @[] : @[channels];
    }
    
    NSMutableArray<NSArray *> *series = [NSMutableArray new];
    NSMutableArray<NSString *> *currentSequence = [NSMutableArray new];
    NSMutableString *queryString = [NSMutableString new];
    for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
        NSString *channel = channels[channelIdx];
        NSString *percentEncodedChannel = [channel stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        if (!queryString.length) {
            [queryString setString:percentEncodedChannel];
        } else {
            [queryString appendString:[@"," stringByAppendingString:percentEncodedChannel]];
        }
        
        if (queryString.length < kCENPushNotificationMaximumChannelsLength) {
            [currentSequence addObject:channel];
        } else {
            if (currentSequence.count) {
                [series addObject:currentSequence];
                currentSequence = [NSMutableArray new];
            }
            
            [queryString setString:@""];
            channelIdx--;
        }
    }
    
    if (currentSequence.count) {
        [series addObject:currentSequence];
    }
    
    return series;
}

+ (NSError *)pushNotificationStateChangeErrorForChats:(NSArray<CENChat *> *)chats fromStatus:(PNErrorStatus *)status {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    
    if (status.errorData.channels.count) {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"channel IN %@", status.errorData.channels];
        NSArray<CENChat *> *failedChats = [chats filteredArrayUsingPredicate:filterPredicate];
        if (failedChats.count) {
            userInfo[kCENNotificationsErrorChatsKey] = failedChats;
        }
    }
    
    return [CENError errorFromPubNubStatus:status withUserInfo:userInfo];
}

+ (NSArray<CENChat *> *)chatListByChannelNames:(NSArray<NSString *> *)channels forUser:(CENMe *)user {
    
    NSMutableArray<CENChat *> *chats = [NSMutableArray new];
    CENChatEngine *chatEngine = user.chatEngine;
    NSDictionary<NSString *,CENChat *> *knownChats = chatEngine.chats;
    
    for (NSString *channel in channels) {
        if (knownChats[channel]) {
            [chats addObject:knownChats[channel]];
        }
    }
    
    return chats;
}

#pragma mark -


@end
