#import <CENChatEngine/CEPPlugin.h>


#pragma mark Static

/**
 * @brief Key under which in error's \c userInfo stored list of \b {chats CENChat} for which plugin
 * wasn't able to change push notification state (enable / disable).
 */
extern NSString * const kCENNotificationsErrorChatsKey;


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 */
typedef struct CENPushNotificationsConfigurationKeys {
    /**
     * @brief Whether sent push notification should allow debugging with
     * \b {PubNub Console https://www.pubnub.com/docs/console} or not.
     *
     * \b Default: \c NO
     */
    __unsafe_unretained NSString *debug;
    
    /**
     * @brief List of event names which should trigger push notification payload composition before
     * sending event.
     *
     * \b Default: \c @[@"message", @"$.invite"]
     */
    __unsafe_unretained NSString *events;
    
    /**
     * @brief List of \b {service names \b CENPushNotificationsService} for which plugin should
     * generate notification payload (to mark as \c seen or if \c formatter missing).
     *
     * @note Not required, if custom \b {formatter} take care of all required \b {events}.
     *
     * \b Required: optional
     */
    __unsafe_unretained NSString *services;
    
    /**
     * @brief GCD block which should be used to provide custom payload format.
     *
     * \b Required: optional
     */
    __unsafe_unretained NSString *formatter;
} CENPushNotificationsConfigurationKeys;

extern CENPushNotificationsConfigurationKeys CENPushNotificationsConfiguration;

/**
 * @brief Structure which describe supported push notification services.
 */
typedef struct CENPushNotificationsServices {
    /**
     * @brief Apple Push Notification.
     */
    __unsafe_unretained NSString *apns;
    
    /**
     * @brief Google Cloud Messaging / Firebase Cloud Messaging.
     */
    __unsafe_unretained NSString *fcm;
} CENPushNotificationsServices;

extern CENPushNotificationsServices CENPushNotificationsService;


#pragma mark - Class forward

@class CENChat, CENMe;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} push notifications manage plugin.
 *
 * @discussion Plugin allow to enable / disable push notification sending for specific events
 * emitted to \b {chats CENChat}.
 *
 * @code
 * // objc
 * NSDictionary * (^formatter)(NSDictionary *payload) = ^NSDictionary * (NSDictionary *payload) {
 *     NSDictionary *payload = nil;
 *     if ([payload[CENEventData.event] isEqualToString:@"message"]) {
 *         NSString *chatName = ((CENChat *)payload[CENEventData.chat]).name;
 *         NSString *title = [NSString stringWithFormat:@"%@ sent message in %@",
 *                            payload[CENEventData.sender], chatName];
 *         NSString *body = (cePayload[CENEventData.data][@"message"] ?:
 *                           cePayload[CENEventData.data][@"text"]);
 *         payload = @{
 *             CENPushNotificationsService.apns: @{
 *                 @"aps": @{ @"alert": @{ @"title": title, @"body": body } }
 *             }
 *         };
 *     } else if ([payload[CENEventData.event] isEqualToString:@"ignoreMe"]) {
 *         // Create empty payload to ensure what push notification won't be triggered.
 *         payload = @{};
 *     }
 *
 *     return payload;
 * };
 *
 * self.client.proto(@"Chat", [CENPushNotificationsPlugin class]).configuration(@{
 *     CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns],
 *     CENPushNotificationsConfiguration.events: @[@"ping"],
 *     CENPushNotificationsConfiguration.formatter: formatter
 * }).store();
 * @endcode
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENPushNotificationsPlugin : CEPPlugin


#pragma mark - Management notifications state

/**
 * @brief Enable push notifications on specified list of \b {chats CENChat}.
 *
 * @note This method should be called at every application launch with received device push token.
 *
 * @code
 * // objc
 * [CENPushNotificationsPlugin enableForChats:@[chat1, chat2] withDeviceToken:self.token
 *                                completion:^(NSError *error) {
 *
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param chats List of \b {chats CENChat} for which remote notification should be triggered.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of registration process and pass
 *     error (if any).
 *
 * @since 1.1.0
 */
+ (void)enableForChats:(NSArray<CENChat *> *)chats
       withDeviceToken:(NSData *)token
            completion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Enable push notifications on specified list of \b {chats CENChat}.
 *
 * @note This method should be called at every application launch with received device push token.
 *
 * @param chats List of \b {chats CENChat} for which remote notification should be triggered.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of registration process and pass
 *     error (if any).
 */
+ (void)enablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                        withDeviceToken:(NSData *)token
                             completion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-enableForChats:withDeviceToken:completion: method instead.");

/**
 * @brief Disable push notifications on specified list of \b {chats CENChat}.
 *
 * @code
 * // objc
 * [CENPushNotificationsPlugin disableForChats:@[chat1, chat2] withDeviceToken:self.token
 *                                  completion:^(NSError *error) {
 *
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param chats List of \b {chats CENChat} for which remote notifications shouldn't be triggered.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of un-registration process and pass
 *     error (if any).
 *
 * @since 1.1.0
 */
+ (void)disableForChats:(NSArray<CENChat *> *)chats
        withDeviceToken:(NSData *)token
             completion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Disable push notifications on specified list of \b {chats CENChat}.
 *
 * @param chats List of \b {chats CENChat} for which remote notifications shouldn't be triggered.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of un-registration process and pass
 *     error (if any).
 */
+ (void)disablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                         withDeviceToken:(NSData *)token
                              completion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-disableForChats:withDeviceToken:completion: method instead.");

/**
 * @brief Disable all push notifications for \b {local user CENMe}.
 *
 * @note It is good idea to call this method when user signs off.
 *
 * @code
 * // objc
 * [CENPushNotificationsPlugin disableAllForUser:self.client.me withDeviceToken:self.token
 *                                    completion:^(NSError *error) {
 *
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param user \b {Local user CENMe} for which notifications should be disabled.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of un-registration process and pass
 *     error (if any).
 *
 * @since 1.1.0
 */
+ (void)disableAllForUser:(CENMe *)user
          withDeviceToken:(NSData *)token
               completion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Disable all push notifications for \b {local user CENMe}.
 *
 * @note It is good idea to call this method when application sign out user
 *
 * @param user \b {Local user CENMe} for which notifications should be disabled.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of un-registration process and pass
 *     error (if any).
 */
+ (void)disableAllPushNotificationsForUser:(CENMe *)user
                           withDeviceToken:(NSData *)token
                                completion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-disableAllForUser:withDeviceToken:completion: method instead.");


#pragma mark - Notifications management

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @code
 * // objc
 * [[CENPushNotificationsPlugin markAsSeen:pushNotification forUser:self.client.me
 *                          withCompletion:^(NSError *error) {
 
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param notification Received remote notification which should be hidden.
 * @param user \b {Local user CENMe} for which \c notification should be hidden on another devices.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @since 1.1.0
 */
+ (void)markAsSeen:(NSNotification *)notification
           forUser:(CENMe *)user
    withCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param notification Received remote notification which should be hidden.
 * @param user \b {Local user CENMe} for which \c notification should be hidden on another devices.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 */
+ (void)markNotificationAsSeen:(NSNotification *)notification
                       forUser:(CENMe *)user
                withCompletion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-markAsSeen:withCompletion: method instead.");

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @code
 * // objc
 * [[CENPushNotificationsPlugin markAllAsSeenForUser:self.client.me
 *                                    withCompletion:^(NSError *error) {
 
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param user \b {Local user CENMe} for which all \c notification should be hidden another devices.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @since 1.1.0
 */
+ (void)markAllAsSeenForUser:(CENMe *)user
              withCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param user \b {Local user CENMe} for which all \c notification should be hidden another devices.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 */
+ (void)markAllNotificationAsSeenForUser:(CENMe *)user
                          withCompletion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-markAllAsSeenWithCompletion: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
