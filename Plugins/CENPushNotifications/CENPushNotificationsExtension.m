/**
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENPushNotificationsExtension.h"

#if (TARGET_OS_IOS && __IPHONE_OS_VERSION_MIN_REQUIRED >= 100000 && \
     __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000) || \
    (TARGET_OS_WATCH && __WATCH_OS_VERSION_MIN_REQUIRED >= 30000 && \
     __WATCH_OS_VERSION_MAX_ALLOWED >= 30000) || \
    (TARGET_OS_TV && __TV_OS_VERSION_MIN_REQUIRED >= 100000 && \
     __TV_OS_VERSION_MAX_ALLOWED >= 100000) || \
    (TARGET_OS_OSX && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101200 && \
     __MAC_OS_X_VERSION_MAX_ALLOWED >= 101400)
#define CEN_NOTIFICATION_PLUGIN_NOTIFICATION_CENTER_AVAILABLE 1
#import <UserNotifications/UserNotifications.h>
#else
#define CEN_NOTIFICATION_PLUGIN_NOTIFICATION_CENTER_AVAILABLE 0
#endif

#import <CENChatEngine/CENEventEmitter+Interface.h>
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENChat+Interface.h>
#import "CENPushNotificationsPlugin.h"
#import <CENChatEngine/ChatEngine.h>
#import <CENChatEngine/CENEvent.h>
#import <CENChatEngine/CENMe.h>





#pragma mark Const

/**
 * @brief Identifier of event which mean: all received notifications.
 */
static NSString * const kCENPushNotificationAllNotificationsID = @"all";

/**
 * @brief Maximum length of string with channel names which can be sent with PubNub API at once.
 */
static NSUInteger const kCENPushNotificationMaximumChannelsLength = 20000;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface declaration

@interface CENPushNotificationsExtension ()


#pragma mark - Handlers

/**
 * @brief Push notification state change request results handler.
 *
 * @param errors List of \a NSError instances which describe issues which happened during request.
 * @param block Request process completion block which pass reference on error (if any).
 */
- (void)handleStateChange:(BOOL)enable
                 forChats:(NSArray<CENChat *> *)chats
               withErrors:(NSArray<NSError *> *)errors
               completion:(void(^ __nullable)(NSError * __nullable error))block;


#pragma mark - Misc

/**
 * @brief Try to hide from notification center the one, which represent event with specific
 * identifier.
 *
 * @param seenEventID Unique event identifier or \c all in case if all notifications should be
 *     hidden.
 */
- (void)hideNotificationWithEventID:(NSString *)seenEventID;

/**
 * @brief Get list of channel name series on which push notification state change should be done.
 *
 * @discussion Because there is limit on URI string length, huge list of names should be splitted
 * into series of names.
 *
 * @param channels List of channels which should be splitted into sessions.
 *
 * @return Series of channel names.
 */
- (NSArray<NSArray *> *)channelSeriesFromChannels:(NSArray<NSString *> *)channels;

/**
 * @brief Compose error using \b PubNub error status.
 *
 * @param chats List of \b {Chat CENChat} instances which has been used during last state change
 *     operation.
 * @param status \b PubNub error status object which contain information about error.
 *
 * @return Error based on \b PubNub error state and list of used \c chats.
 */
- (NSError *)updateErrorForChats:(NSArray<CENChat *> *)chats fromStatus:(PNErrorStatus *)status;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENPushNotificationsExtension


#pragma mark - Management notifications state

- (void)enable:(BOOL)enable
           forChats:(NSArray<CENChat *> *)chats
    withDeviceToken:(NSData *)token
         completion:(void(^)(NSError * error))block {
    
    NSArray *chatChannels = [chats valueForKey:NSStringFromSelector(@selector(channel))];
    NSArray<NSArray<NSString *> *> *channelSeries = [self channelSeriesFromChannels:chatChannels];
    NSMutableArray<NSError *> *errors = [NSMutableArray new];
    dispatch_group_t group = dispatch_group_create();
    BOOL disableAll = !enable && !chats;
    CENMe *me = (CENMe *)self.object;
    PubNub *pubNub = me.chatEngine.pubnub;
    
    void(^handlerBlock)(PNAcknowledgmentStatus *) = ^(PNAcknowledgmentStatus *status) {
        if (status.isError) {
            NSArray<CENChat *> *failedChats = !disableAll ? chats : @[];
            
            if(disableAll && status.errorData.channels) {
                failedChats = [self chatListByChannelNames:status.errorData.channels forUser:me];
            }
            
            [errors addObject:[self updateErrorForChats:failedChats fromStatus:status]];
        }
        
        dispatch_group_leave(group);
    };
    
    if (disableAll) {
        dispatch_group_enter(group);
        [pubNub removeAllPushNotificationsFromDeviceWithPushToken:token andCompletion:handlerBlock];
    } else {
        for (NSArray<NSString *> *channels in channelSeries) {
            dispatch_group_enter(group);
            
            if (enable) {
                [pubNub addPushNotificationsOnChannels:channels
                                   withDevicePushToken:token
                                         andCompletion:handlerBlock];
            } else {
                [pubNub removePushNotificationsFromChannels:channels
                                        withDevicePushToken:token
                                              andCompletion:handlerBlock];
            }
        }
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf handleStateChange:enable forChats:chats withErrors:errors completion:block];
    });
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"
- (void)enablePushNotifications:(BOOL)enable
                       forChats:(NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^)(NSError *error))block {
    
    [self enable:enable forChats:chats withDeviceToken:token completion:block];
}
#pragma GCC diagnostic pop


#pragma mark - Notifications management

- (void)markAsSeen:(NSNotification *)notification withCompletion:(void (^)(NSError *error))block {
    
    NSString *eventName = notification.userInfo[@"cepayload"][CENEventData.event];
    NSString *eventID = notification.userInfo[@"cepayload"][CENEventData.eventID];
    CENChat *directChat = ((CENMe *)self.object).direct;
    CENEvent *event = nil;
    
    if (eventName) {
        if (![eventName isEqualToString:@"$notifications.seen"] && eventID.length) {
            NSDictionary *eventPayload = @{ CENEventData.eventID: eventID };
            
            // Emit 'seen' event internally will be pre-formatted with push notifications payload.
            event = [directChat emitEvent:@"$notifications.seen" withData:eventPayload];
            
            if (block) {
                [event handleEventOnce:@"$.emitted"
                      withHandlerBlock:^(CENEmittedEvent * __unused localEvent) {
                          
                    block(nil);
                }];
                
                [event handleEventOnce:@"$.error.emitter"
                      withHandlerBlock:^(CENEmittedEvent *localEvent) {
                          
                    block(localEvent.data);
                }];
            }
            
            [self hideNotificationWithEventID:eventID];
        }
    } else if (block) {
        block(nil);
    }
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"
- (void)markNotificationAsSeen:(NSNotification *)notification
                withCompletion:(void(^)(NSError *error))block {
    
    [self markAsSeen:notification withCompletion:block];
}
#pragma GCC diagnostic pop

- (void)markAllAsSeenWithCompletion:(void(^)(NSError *error))block {
    
    NSDictionary *eventPayload = @{ CENEventData.eventID: kCENPushNotificationAllNotificationsID };
    CENChat *directChat = ((CENMe *)self.object).direct;
    
    // Emit 'seen' event internally will be pre-formatted with push notifications payload.
    CENEvent *event = [directChat emitEvent:@"$notifications.seen" withData:eventPayload];
    
    if (block) {
        [event handleEventOnce:@"$.emitted"
              withHandlerBlock:^(CENEmittedEvent *__unused localEvent) {
                  
            block(nil);
        }];
        
        [event handleEventOnce:@"$.error.emitter" withHandlerBlock:^(CENEmittedEvent *localEvent) {
            block(localEvent.data);
        }];
    }
    
    [self hideNotificationWithEventID:kCENPushNotificationAllNotificationsID];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"
- (void)markAllNotificationAsSeenWithCompletion:(void(^)(NSError *error))block {
    
    [self markAllAsSeenWithCompletion:block];
}
#pragma GCC diagnostic pop


#pragma mark - Handlers

- (void)handleStateChange:(BOOL)enable
                 forChats:(NSArray<CENChat *> *)chats
               withErrors:(NSArray<NSError *> *)errors
               completion:(void(^)(NSError *error))block {
    
    chats = chats.count ? chats : ((CENMe *)self.object).chatEngine.chats.allValues;
    NSError *error = errors.count == 1 ? errors.firstObject : nil;
    NSString *identifier = self.identifier;
    
    if (errors.count > 1) {
        NSMutableArray<CENChat *> *failedChats = [NSMutableArray new];
        
        for (error in errors) {
            if ((NSArray *)error.userInfo[kCENNotificationsErrorChatsKey]) {
                [failedChats addObjectsFromArray:error.userInfo[kCENNotificationsErrorChatsKey]];
            }
        }
        
        if (failedChats.count) {
            NSError *anyError = errors.lastObject;
            NSMutableDictionary *userInfo = [(error.userInfo ?: @{}) mutableCopy];
            userInfo[kCENNotificationsErrorChatsKey] = failedChats;
            
            error = [NSError errorWithDomain:anyError.domain code:anyError.code userInfo:userInfo];
        }
    }
    
    for (CENChat *chat in chats) {
        if (enable) {
            if (error == nil && ![chat hasPluginWithIdentifier:identifier]) {
                [chat registerPlugin:[CENPushNotificationsPlugin class]
                      withIdentifier:identifier
                       configuration:self.configuration];
            }
        } else {
            [chat unregisterPluginWithIdentifier:identifier];
        }
    }
    
    if (block) {
        block(error);
    }
}


#pragma mark - Misc

#if CEN_NOTIFICATION_PLUGIN_NOTIFICATION_CENTER_AVAILABLE
- (void)hideNotificationWithEventID:(NSString *)seenEventID {
    
    if (@available(iOS 10.0, watchOS 3.0, tvOS 10.0, macOS 10.14, *)) {
        BOOL isAllEvents = [seenEventID isEqualToString:kCENPushNotificationAllNotificationsID];
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        NSMutableArray<NSString *> *identifiers = [NSMutableArray array];
        
#if TARGET_OS_IOS || TARGET_OS_TV
        UIApplication *application = [UIApplication sharedApplication];
        __block UIBackgroundTaskIdentifier taskIdentifier = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (application.applicationState != UIApplicationStateActive) {
                taskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
                    [application endBackgroundTask:taskIdentifier];
                }];
            }
        });
#endif
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [center getDeliveredNotificationsWithCompletionHandler:^(NSArray *notifications) {
                for (UNNotification *notification in notifications) {
                    UNNotificationContent *content = notification.request.content;
                    NSString *eventID = content.userInfo[@"cepayload"][CENEventData.eventID];
                    
                    if (eventID && (isAllEvents || [eventID isEqualToString:seenEventID])) {
                        [identifiers addObject:notification.request.identifier];
                    }
                }
                
                [center removeDeliveredNotificationsWithIdentifiers:identifiers];
                
#if TARGET_OS_IOS || TARGET_OS_TV
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (taskIdentifier) {
                        [application endBackgroundTask:taskIdentifier];
                    }
                });
#endif
            }];
        });
    }
}
#else
- (void)hideNotificationWithEventID:(NSString *)__unused seenEventID {
    // Do nothing, because UNUserNotificationCenter not available for target platform.
}
#endif // CEN_NOTIFICATION_PLUGIN_NOTIFICATION_CENTER_AVAILABLE

- (NSArray<NSArray *> *)channelSeriesFromChannels:(NSArray<NSString *> *)channels {
    
    NSCharacterSet *allowedCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *channelsList = [channels componentsJoinedByString:@","];
    NSString *encodedChannelsList = [channelsList stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    NSUInteger length = encodedChannelsList.length;

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

- (NSError *)updateErrorForChats:(NSArray<CENChat *> *)chats fromStatus:(PNErrorStatus *)status {
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    NSArray<CENChat *> *failedChats = chats;
    
    if (status.errorData.channels.count) {
        NSArray *channels = status.errorData.channels;
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"channel IN %@", channels];

        failedChats = [chats filteredArrayUsingPredicate:filterPredicate];
    }
    
    if (failedChats.count) {
        userInfo[kCENNotificationsErrorChatsKey] = failedChats;
    }
    
    return [CENError errorFromPubNubStatus:status withUserInfo:userInfo];
}

- (NSArray<CENChat *> *)chatListByChannelNames:(NSArray *)channels forUser:(CENMe *)user {
    
    NSDictionary<NSString *,CENChat *> *knownChats = user.chatEngine.chats;
    NSMutableArray<CENChat *> *chats = [NSMutableArray new];
    
    for (NSString *channel in channels) {
        if (knownChats[channel]) {
            [chats addObject:knownChats[channel]];
        }
    }
    
    return chats;
}

#pragma mark -


@end
