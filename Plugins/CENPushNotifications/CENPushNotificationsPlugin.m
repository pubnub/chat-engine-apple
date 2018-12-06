/**
 * @author Serhii Mamontov
 * @version 1.1.0
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

/**
 * @brief Key under which in error's \c userInfo stored list of \b {chats CENChat} for which plugin
 * wasn't able to change push notification state (enable / disable).
 */
NSString * const kCENNotificationsErrorChatsKey = @"CENNotificationsErrorChatsKey";

/**
 * @brief Configuration keys structure values assignment.
 */
CENPushNotificationsConfigurationKeys CENPushNotificationsConfiguration = {
    .debug = @"d",
    .events = @"e",
    .services = @"s",
    .formatter = @"f"
};

/**
 * @brief Notification services structure values assignment.
 */
CENPushNotificationsServices CENPushNotificationsService = {
    .apns = @"apns",
    .fcm = @"gcm"
};


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Protected interface

@interface CENPushNotificationsPlugin ()


#pragma mark - Management notifications state

/**
 * @brief Enable / disable push notifications on specified list of \b {chats CENChat}.
 *
 * @param enable Whether notifications should be enabled or disabled.
 * @param chats List of \b {chats CENChat} for which remote notification \c enable state should be
 *     changed.
 * @param token Device token which has been provided by APNS.
 * @param block Block which will be called at the end of state change process and pass
 *     error (if any).
 */
+ (void)enablePushNotifications:(BOOL)enable
                       forChats:(NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^ __nullable)(NSError * __nullable error))block;

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


#pragma mark - Middleware

- (Class)middlewareClassForLocation:(NSString *)location object:(CENObject *)object {
    
    BOOL isEmitLocation = [location isEqualToString:CEPMiddlewareLocation.emit];
    Class middleware = nil;
    
    if (isEmitLocation && [object isKindOfClass:[CENChat class]]) {
        middleware = [CENPushNotificationsMiddleware class];
    }
    
    return middleware;
}


#pragma mark - Management notifications state

+ (void)enableForChats:(NSArray<CENChat *> *)chats
       withDeviceToken:(NSData *)token
            completion:(void(^)(NSError *error))block {
    
    [self enablePushNotifications:YES forChats:chats withDeviceToken:token completion:block];
}

+ (void)enablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                        withDeviceToken:(NSData *)token
                             completion:(void(^)(NSError *error))block {
    
    [self enableForChats:chats withDeviceToken:token completion:block];
}

+ (void)disableForChats:(NSArray<CENChat *> *)chats
        withDeviceToken:(NSData *)token
             completion:(void(^ __nullable)(NSError * __nullable error))block {
    
    [self enablePushNotifications:NO forChats:chats withDeviceToken:token completion:block];
}

+ (void)disablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                         withDeviceToken:(NSData *)token
                              completion:(void(^)(NSError *error))block {
    
    [self disableForChats:chats withDeviceToken:token completion:block];
}

+ (void)enablePushNotifications:(BOOL)enable
                       forChats:(NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^)(NSError *error))block {
    
    if (!chats.count || !token.length) {
        return;
    }
    
    CENMe *me = chats.firstObject.chatEngine.me;
    NSString *identifier = self.identifier;
    
    [me extensionWithIdentifier:identifier context:^(CENPushNotificationsExtension *extension) {
        [extension enable:enable forChats:chats withDeviceToken:token completion:block];
    }];
}

+ (void)disableAllForUser:(CENMe *)user
          withDeviceToken:(NSData *)token
               completion:(void(^)(NSError *error))block {
    
    NSString *identifier = self.identifier;
    
    if (!token.length || ![user isKindOfClass:[CENMe class]]) {
        return;
    }
    
    [user extensionWithIdentifier:identifier context:^(CENPushNotificationsExtension *extension) {
        [extension enable:NO forChats:nil withDeviceToken:token completion:block];
    }];
}

+ (void)disableAllPushNotificationsForUser:(CENMe *)user
                           withDeviceToken:(NSData *)token
                                completion:(void(^)(NSError *error))block {
    
    [self disableAllForUser:user withDeviceToken:token completion:block];
}


#pragma mark - Notifications management

+ (void)markAsSeen:(NSNotification *)notification
           forUser:(CENMe *)user
    withCompletion:(void(^)(NSError *error))block {
    
    NSString *identifier = self.identifier;
    
    if (![user isKindOfClass:[CENMe class]]) {
        return;
    }
    
    [user extensionWithIdentifier:identifier context:^(CENPushNotificationsExtension *extension) {
        [extension markAsSeen:notification withCompletion:block];
    }];
}

+ (void)markNotificationAsSeen:(NSNotification *)notification
                       forUser:(CENMe *)user
                withCompletion:(void (^)(NSError *error))block {
    
    [self markAsSeen:notification forUser:user withCompletion:block];
}

+ (void)markAllAsSeenForUser:(CENMe *)user withCompletion:(void (^)(NSError *error))block {
    
    NSString *identifier = self.identifier;
    
    if (![user isKindOfClass:[CENMe class]]) {
        return;
    }
    
    [user extensionWithIdentifier:identifier context:^(CENPushNotificationsExtension *extension) {
        [extension markAllAsSeenWithCompletion:block];
    }];
}

+ (void)markAllNotificationAsSeenForUser:(CENMe *)user
                          withCompletion:(void (^)(NSError *error))block {
    
    [self markAllAsSeenForUser:user withCompletion:block];
}


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *configuration = [(self.configuration ?: @{}) mutableCopy];
    NSArray *userEvents = configuration[CENPushNotificationsConfiguration.events];
    NSMutableArray<NSString *> *events = [(userEvents ?: @[]) mutableCopy];
    
    if (![events containsObject:@"$notifications.seen"]) {
        [events addObject:@"$notifications.seen"];
    }
    
    configuration[CENPushNotificationsConfiguration.events] = events;
    
    self.configuration = configuration;
    
    // Override events list with user-provided values.
    [CENPushNotificationsMiddleware replaceEventsWith:events];
}

#pragma mark -


@end
