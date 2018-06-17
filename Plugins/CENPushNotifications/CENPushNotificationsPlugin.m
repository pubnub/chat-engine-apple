/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENPushNotificationsPlugin.h"
#import <CENChatEngine/CENObject+PluginsDeveloper.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import "CENPushNotificationsMiddleware.h"
#import "CENPushNotificationsExtension.h"
#import <CENChatEngine/CENChat.h>
#import <CENChatEngine/CENMe.h>


#pragma mark Externs

NSString * const kCENNotificationsErrorChatsKey = @"CENNotificationsErrorChatsKey";

CENPushNotificationsConfigurationKeys CENPushNotificationsConfiguration = { .events = @"e", .services = @"s", .ignoredChats = @"i",
                                                                            .formatter = @"f" };

CENPushNotificationsServices CENPushNotificationsService = { .apns = @"apns", .fcm = @"gcm" };


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface

@interface CENPushNotificationsPlugin ()


#pragma mark - Management notifications state

/**
 * @brief      Enable/disable push notifications on specified list of chats.
 * @discussion \b ChatEngine will subscribe for remote notifications from specified set of \c chats.
 * @note       It is required to call this method each time when application launch and receive device push token.
 *
 * @param shouldEnabled Whether notifications should be enabled or disabled.
 * @param chats         Reference on list of chats for which \b ChatEngine service should start remote notification triggering.
 * @param token         Reference on device token which has been provided by APNS.
 * @param block         Reference on block which will be called at the end of registration process. Block pass only one argument - request
 *                      processing error (if any error happened during request).
 */
+ (void)enablePushNotifications:(BOOL)shouldEnabled
                       forChats:(NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^)(NSError * __nullable error))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENPushNotificationsPlugin


#pragma mark - Information

+ (NSString *)identifier {
    
    return @"com.chatengine.plugin.push-notifications";
}


#pragma mark - Extension

- (Class)extensionClassFor:(CENObject *)object {
    
    Class extensionClass = nil;
    
    if ([object isKindOfClass:[CENMe class]]) {
        extensionClass = [CENPushNotificationsExtension class];
    }
    
    return extensionClass;
}


#pragma mark - Management notifications state

+ (void)enablePushNotificationsForChats:(NSArray<CENChat *> *)chats withDeviceToken:(NSData *)token completion:(void(^)(NSError *error))block {
    
    [self enablePushNotifications:YES forChats:chats withDeviceToken:token completion:block];
}

+ (void)disablePushNotificationsForChats:(NSArray<CENChat *> *)chats withDeviceToken:(NSData *)token completion:(void(^)(NSError *error))block {
    
    [self enablePushNotifications:NO forChats:chats withDeviceToken:token completion:block];
}

+ (void)enablePushNotifications:(BOOL)shouldEnabled
                       forChats:(NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^)(NSError *error))block {
    
    if (!chats.count || !token.length) {
        return;
    }
    
    CENMe *me = chats.firstObject.chatEngine.me;
    
    [me extensionWithIdentifier:self.identifier context:^(CENPushNotificationsExtension *extension) {
        [extension enablePushNotifications:shouldEnabled forChats:chats withDeviceToken:token completion:block];
    }];
}

+ (void)disableAllPushNotificationsForUser:(CENMe *)user withDeviceToken:(NSData *)token completion:(void(^)(NSError *error))block {
    
    if (!token.length) {
        return;
    }
    
    [user extensionWithIdentifier:self.identifier context:^(CENPushNotificationsExtension *extension) {
        [extension enablePushNotifications:NO forChats:nil withDeviceToken:token completion:block];
    }];
}


#pragma mark - Notifications management

+ (void)markNotificationAsSeen:(NSNotification *)notification forUser:(CENMe *)user withCompletion:(void (^)(NSError *error))block {
    
    [user extensionWithIdentifier:self.identifier context:^(CENPushNotificationsExtension *extension) {
        [extension markNotificationAsSeen:notification withCompletion:block];
    }];
}

+ (void)markAllNotificationAsSeenForUser:(CENMe *)user withCompletion:(void (^)(NSError *error))block {
    
    [user extensionWithIdentifier:self.identifier context:^(CENPushNotificationsExtension *extension) {
        [extension markAllNotificationAsSeenWithCompletion:block];
    }];
}


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object {
    
    Class middleware = nil;
    
    if ([location isEqualToString:CEPMiddlewareLocation.emit] && [object isKindOfClass:[CENChat class]]) {
        middleware = [CENPushNotificationsMiddleware class];
    }
    
    return middleware;
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [NSMutableDictionary dictionaryWithDictionary:self.configuration];
    NSMutableArray<NSString *> *ignoredChats = [NSMutableArray arrayWithArray:configuration[CENPushNotificationsConfiguration.ignoredChats]];
    NSMutableArray<NSString *> *events = [NSMutableArray arrayWithArray:configuration[CENPushNotificationsConfiguration.events]];
    
    if (![events containsObject:@"$notifications.seen"]) {
        [events addObject:@"$notifications.seen"];
    }
    
    if (![ignoredChats containsObject:@"feed"]) {
        [ignoredChats addObject:@"feed"];
    }
    
    configuration[CENPushNotificationsConfiguration.ignoredChats] = ignoredChats;
    configuration[CENPushNotificationsConfiguration.events] = events;
    
    self.configuration = configuration;
    
    // Override events list with user-provided values.
    [CENPushNotificationsMiddleware replaceEventsWith:self.configuration[CENPushNotificationsConfiguration.events]];
}

#pragma mark -


@end
