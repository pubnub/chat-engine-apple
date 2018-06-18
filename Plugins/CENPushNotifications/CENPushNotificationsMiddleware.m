/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENPushNotificationsMiddleware.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENPushNotificationsPlugin.h"
#import <CENChatEngine/CENChat.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENPushNotificationsMiddleware ()


#pragma mark - Formatters

/**
 * @brief      Compose default notification payload for known events.
 * @discussion Format notifications for \c message and/or \c invite events.
 *
 * @param cePayload Reference on \b ChatEngine generate payload which should be used to compose notification payload.
 *
 * @return Push notification payload which should be merged with \c cePayload before sending.
 */
- (NSDictionary *)defaultNotificationPayloadFrom:(NSDictionary *)cePayload;

/**
 * @brief      Compose push notification ACK payload.
 * @discussion Compose notification payload which silently will be delivered to other devices and hide 'seen' notifications.
 *
 * @param cePayload Reference on \b ChatEngine generate payload which should be used to compose notification payload.
 *
 * @return Push notification payload which should be merged with \c cePayload before sending.
 */
- (NSDictionary *)seenNotificationPayloadFrom:(NSDictionary *)cePayload;

- (NSDictionary *)normalizedNotificationPayload:(NSDictionary *)payload forEvent:(NSDictionary *)ceEvent;


#pragma mark - Misc

- (NSString *)notificationCategoryFromEvent:(NSString *)event;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENPushNotificationsMiddleware


#pragma mark - Information

+ (NSArray<NSString *> *)events {
    
    return @[@"*"];
}

+ (NSString *)location {
    
    return CEPMiddlewareLocation.emit;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)event withData:(NSMutableDictionary *)data completion:(void (^)(BOOL rejected))block {
    
    NSDictionary *notificationsPayload = nil;
    
    if ([event isEqualToString:@"$notifications.seen"]) {
        notificationsPayload = [self normalizedNotificationPayload:[self seenNotificationPayloadFrom:data] forEvent:data];
    } else {
        NSDictionary * (^payloadFormatter)(NSDictionary *) = self.configuration[CENPushNotificationsConfiguration.formatter];
        
        if (payloadFormatter) {
            notificationsPayload = [self normalizedNotificationPayload:payloadFormatter(data) forEvent:data];
        }
        
        if (!payloadFormatter || (payloadFormatter && !notificationsPayload)) {
            notificationsPayload = [self normalizedNotificationPayload:[self defaultNotificationPayloadFrom:data] forEvent:data];
        }
    }
    
    [data addEntriesFromDictionary:notificationsPayload];
    block(NO);
}


#pragma mark - Formatters

- (NSDictionary *)defaultNotificationPayloadFrom:(NSDictionary *)cePayload {
    
    NSString *chatName = ((CENChat *)cePayload[CENEventData.chat]).name;
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *notificationTitle = nil;
    NSString *notificationBody = nil;
    NSString *notificationTicker = nil;
    NSString *notificationCategory = nil;
    
    if ([cePayload[CENEventData.event] isEqualToString:@"message"]) {
        notificationTitle = [NSString stringWithFormat:@"%@ sent message in %@", cePayload[CENEventData.sender], chatName];
        notificationBody = cePayload[CENEventData.data][@"message"] ?: cePayload[CENEventData.data][@"text"];
        notificationTicker = @"New chat message";
        notificationCategory = @"CATEGORY_MESSAGE";
    } else if ([cePayload[CENEventData.event] isEqualToString:@"$.invite"]) {
        notificationTitle = [NSString stringWithFormat:@"Invitation from  %@", cePayload[CENEventData.sender]];
        notificationBody = [NSString stringWithFormat:@"%@ invited you to join '%@'", cePayload[CENEventData.sender], chatName];
        notificationTicker = @"New invitation to chat";
        notificationCategory = @"CATEGORY_SOCIAL";
    }
    
    if (notificationTitle && notificationBody) {
        for (NSString *service in self.configuration[CENPushNotificationsConfiguration.services]) {
            if ([service isEqualToString:CENPushNotificationsService.apns]) {
                payload[service] = @{ @"aps": @{ @"alert": @{ @"title": notificationTitle, @"body": notificationBody} } };
            } else if ([service isEqualToString:CENPushNotificationsService.fcm]) {
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{
                    @"contentTitle": notificationTitle,
                    @"contentText": notificationBody,
                    @"ticker": notificationTicker,
                    @"category": notificationCategory
                }];
                
                if ([cePayload[CENEventData.event] isEqualToString:@"$.invite"]) {
                    data[@"actions"] = @[@"Accept", @"Ignore"];
                }
                
                payload[service] = @{ @"data": data };
            }
        }
    }
    
    return payload;
}

- (NSDictionary *)seenNotificationPayloadFrom:(NSDictionary *)cePayload {
    
    BOOL servicesSpecified = ((NSArray *)self.configuration[CENPushNotificationsConfiguration.services]).count > 0;
    NSDictionary *eventData = @{ @"data": (cePayload[CENEventData.data] ?: @{}) };
    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    for (NSString *service in self.configuration[CENPushNotificationsConfiguration.services]) {
        if ([service isEqualToString:CENPushNotificationsService.apns]) {
            payload[service] = @{ @"aps": @{ @"content-available": @1, @"sound": @"" }, @"cepayload": eventData };
        } else if ([service isEqualToString:CENPushNotificationsService.fcm]) {
            payload[service] = @{ @"data": @{ @"cepayload": eventData } };
        }
    }
    
    return servicesSpecified ? payload : @{};
}

- (NSDictionary *)normalizedNotificationPayload:(NSDictionary *)payload forEvent:(NSDictionary *)ceEvent {
    
    // Normalize ChatEngine payload, so it can be included into notification payload and available for user when it will arrive.
    NSMutableDictionary *normalizedChatEngineEvent = [ceEvent mutableCopy];
    normalizedChatEngineEvent[CENEventData.chat] = ((CENChat *)ceEvent[CENEventData.chat]).channel;
    normalizedChatEngineEvent[@"category"] = [self notificationCategoryFromEvent:ceEvent[CENEventData.event]];
    NSMutableDictionary *normalizedNotificationPayload = [NSMutableDictionary new];
    
    for (NSString *service in self.configuration[CENPushNotificationsConfiguration.services]) {
        NSMutableDictionary *servicePayload = [NSMutableDictionary dictionaryWithDictionary:payload[service]];
        NSDictionary *notificationCEPayload = servicePayload[@"cepayload"] ?: servicePayload[@"data"][@"cepayload"];
        
        if (!servicePayload.count) {
            continue;
        }
        
        NSMutableDictionary *cePayload = [NSMutableDictionary dictionaryWithDictionary:normalizedChatEngineEvent];
        cePayload[@"data"] = [NSMutableDictionary dictionaryWithDictionary:normalizedChatEngineEvent[@"data"]];
        [(NSMutableDictionary *)cePayload[@"data"] addEntriesFromDictionary:notificationCEPayload[@"data"]];
        cePayload[@"category"] = notificationCEPayload[@"category"] ?: cePayload[@"category"];
        
        if ([service isEqualToString:CENPushNotificationsService.apns]) {
            if (servicePayload[@"aps"][@"category"]) {
                cePayload[@"category"] = servicePayload[@"aps"][@"category"];
            }
            
            NSMutableDictionary *aps = [NSMutableDictionary dictionaryWithDictionary:servicePayload[@"aps"]];
            aps[@"category"] = cePayload[@"category"];
            
            servicePayload[@"aps"] = aps;
            servicePayload[@"cepayload"] = cePayload;
        } else if ([service isEqualToString:CENPushNotificationsService.fcm]) {
            servicePayload[@"data"] = [NSMutableDictionary dictionaryWithDictionary:servicePayload[@"data"]];
            
            if (servicePayload[@"data"][@"category"]) {
                cePayload[@"category"] = servicePayload[@"data"][@"category"];
            }
            
            servicePayload[@"data"][@"category"] = cePayload[@"category"];
            servicePayload[@"data"][@"cepayload"] = cePayload;
        }
        
        normalizedNotificationPayload[[@"pn_" stringByAppendingString:service]] = servicePayload;
    }
    
    return normalizedNotificationPayload;
}


#pragma mark - Misc

- (NSString *)notificationCategoryFromEvent:(NSString *)event {
    
    if ([event hasPrefix:@"$."]) {
        event = [event substringFromIndex:2];
    } else if ([event hasPrefix:@"$"]) {
        event = [event substringFromIndex:1];
    }
    
    return [@"com.pubnub.chat-engine." stringByAppendingString:event];
}

#pragma mark -


@end
