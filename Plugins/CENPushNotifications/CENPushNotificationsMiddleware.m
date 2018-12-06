/**
 * @author Serhii Mamontov
 * @version 1.1.0
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
 * @brief Create default notifications payload for known events (\c message and \c $.invite).
 *
 * @param chatEngineEvent Payload from \b {ChatEngine CENChatEngine} for which payload for push
 *     notification services should be created.
 *
 * @return Payload which contain data required by \b PubNub service to trigger push notifications.
 */
- (NSDictionary *)defaultPayloadFrom:(NSDictionary *)chatEngineEvent;

/**
 * @brief Create payload for notification \c ACK.
 *
 * @discussion Payload which will be silently delivered to other devices and hide 'seen'
 * notifications.
 *
 * @param chatEngineEvent Payload from \b {ChatEngine CENChatEngine} which contain information which
 *     should be used to create silent notification for 'seen' feature.
 *
 * @return Payload which contain data required by \b PubNub service to trigger push notifications.
 */
- (NSDictionary *)seenPayloadFrom:(NSDictionary *)chatEngineEvent;

/**
 * @brief Complete notification payload configuration.
 *
 * @param payload Reference on current message payload which may contain notification payloads.
 * @param chatEngineEvent Reference on name of event for which data has been emitted.
 *
 * @return \b {ChatEngine CENChatEngine} compatible payload which can be emitted to target
 * \b {chat CENChat}.
 */
- (NSDictionary *)normalizedPayloadFrom:(NSDictionary *)payload
                               forEvent:(NSDictionary *)chatEngineEvent;


#pragma mark - Misc

/**
 * @brief Compose name of notification category basing on ChatEngine event.
 *
 * @param event Name of event for which category should be created.
 *
 * @return Name of category which is unique for this plugin.
 */
- (NSString *)categoryFromEvent:(NSString *)event;

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

- (void)runForEvent:(NSString *)event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    NSDictionary * (^formatter)(NSDictionary *) = nil;
    NSDictionary *notificationsPayload = nil;
    
    if ([event isEqualToString:@"$notifications.seen"]) {
        notificationsPayload = [self seenPayloadFrom:data];
    } else {
        formatter = self.configuration[CENPushNotificationsConfiguration.formatter];
        
        if (formatter) {
            notificationsPayload = formatter(data);
        }
        
        if (!formatter || (formatter && !notificationsPayload)) {
            notificationsPayload = [self defaultPayloadFrom:data];
        }
    }
    
    [data addEntriesFromDictionary:[self normalizedPayloadFrom:notificationsPayload forEvent:data]];
    
    if (((NSNumber *)self.configuration[CENPushNotificationsConfiguration.debug]).boolValue) {
        data[@"pn_debug"] = @YES;
    }
    
    block(NO);
}


#pragma mark - Formatters

- (NSDictionary *)defaultPayloadFrom:(NSDictionary *)chatEngineEvent {
    
    NSString *chatName = ((CENChat *)chatEngineEvent[CENEventData.chat]).name;
    NSDictionary *eventData = chatEngineEvent[CENEventData.data];
    NSString *sender = chatEngineEvent[CENEventData.sender];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *title = nil;
    NSString *body = nil;
    NSString *ticker = nil;
    NSString *category = nil;
    
    if ([chatEngineEvent[CENEventData.event] isEqualToString:@"message"]) {
        title = [NSString stringWithFormat:@"%@ sent message in %@", sender, chatName];
        body = eventData[@"message"] ?: eventData[@"text"];
        ticker = @"New chat message";
        category = @"CATEGORY_MESSAGE";
    } else if ([chatEngineEvent[CENEventData.event] isEqualToString:@"$.invite"]) {
        NSString *channel = chatEngineEvent[CENEventData.data][@"channel"];
        chatName = [channel componentsSeparatedByString:@"#"].lastObject;

        title = [NSString stringWithFormat:@"Invitation from  %@", sender];
        body = [NSString stringWithFormat:@"%@ invited you to join '%@'", sender, chatName];
        ticker = @"New invitation to chat";
        category = @"CATEGORY_SOCIAL";
    }
    
    if (title && body) {
        for (NSString *service in self.configuration[CENPushNotificationsConfiguration.services]) {
            if ([service isEqualToString:CENPushNotificationsService.apns]) {
                payload[service] = @{ @"aps": @{ @"alert": @{ @"title": title, @"body": body} } };
            } else if ([service isEqualToString:CENPushNotificationsService.fcm]) {
                NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{
                    @"contentTitle": title,
                    @"contentText": body,
                    @"ticker": ticker,
                    @"category": category
                }];
                
                if ([chatEngineEvent[CENEventData.event] isEqualToString:@"$.invite"]) {
                    data[@"actions"] = @[@"Accept", @"Ignore"];
                }
                
                payload[service] = @{ @"data": data };
            }
        }
    }
    
    return payload;
}

- (NSDictionary *)seenPayloadFrom:(NSDictionary *)chatEngineEvent {
 
    NSDictionary *eventData = @{ @"data": (chatEngineEvent[CENEventData.data] ?: @{}) };
    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    for (NSString *service in self.configuration[CENPushNotificationsConfiguration.services]) {
        if ([service isEqualToString:CENPushNotificationsService.apns]) {
            payload[service] = @{
                @"aps": @{ @"content-available": @1, @"sound": @"" },
                @"cepayload": eventData
            };
        } else if ([service isEqualToString:CENPushNotificationsService.fcm]) {
            payload[service] = @{ @"data": @{ @"cepayload": eventData } };
        }
    }
    
    return payload;
}

- (NSDictionary *)normalizedPayloadFrom:(NSDictionary *)payload
                               forEvent:(NSDictionary *)chatEngineEvent {
    
    NSMutableDictionary *eventPayload = [chatEngineEvent mutableCopy];
    eventPayload[CENEventData.chat] = ((CENChat *)chatEngineEvent[CENEventData.chat]).channel;
    eventPayload[@"category"] = [self categoryFromEvent:chatEngineEvent[CENEventData.event]];
    NSMutableDictionary *payloads = [NSMutableDictionary new];
    
    for (NSString *service in self.configuration[CENPushNotificationsConfiguration.services]) {
        NSMutableDictionary *servicePayload = [(payload[service] ?: @{}) mutableCopy];
        NSDictionary *notificationCEPayload = (servicePayload[@"cepayload"] ?:
                                               servicePayload[@"data"][@"cepayload"]);
        
        if (!servicePayload.count) {
            continue;
        }
        
        NSMutableDictionary *cePayload = [(eventPayload ?: (id)@{}) mutableCopy];
        cePayload[@"data"] = [(eventPayload[@"data"] ?: @{}) mutableCopy];
        [cePayload[@"data"] addEntriesFromDictionary:notificationCEPayload[@"data"]];
        cePayload[@"category"] = notificationCEPayload[@"category"] ?: cePayload[@"category"];
        
        if ([service isEqualToString:CENPushNotificationsService.apns]) {
            if (servicePayload[@"aps"][@"category"]) {
                cePayload[@"category"] = servicePayload[@"aps"][@"category"];
            }
            
            NSMutableDictionary *aps = [(servicePayload[@"aps"] ?: @{}) mutableCopy];
            aps[@"category"] = cePayload[@"category"];
            
            servicePayload[@"aps"] = aps;
            servicePayload[@"cepayload"] = cePayload;
        } else if ([service isEqualToString:CENPushNotificationsService.fcm]) {
            servicePayload[@"data"] = [(servicePayload[@"data"] ?: @{}) mutableCopy];
            
            if (servicePayload[@"data"][@"category"]) {
                cePayload[@"category"] = servicePayload[@"data"][@"category"];
            }
            
            servicePayload[@"data"][@"category"] = cePayload[@"category"];
            servicePayload[@"data"][@"cepayload"] = cePayload;
        }
        
        payloads[[@"pn_" stringByAppendingString:service]] = servicePayload;
    }
    
    return payloads;
}


#pragma mark - Misc

- (NSString *)categoryFromEvent:(NSString *)event {
    
    if ([event hasPrefix:@"$."]) {
        event = [event substringFromIndex:2];
    } else if ([event hasPrefix:@"$"]) {
        event = [event substringFromIndex:1];
    }
    
    return [@"com.pubnub.chat-engine." stringByAppendingString:event];
}

#pragma mark -


@end
