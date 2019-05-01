#import <CENChatEngine/CEPPlugin.h>
#import "CENPushNotificationsExtension.h"


#pragma mark Static

/**
 * @brief Key under which in error's \c userInfo stored list of \b {chats CENChat} for which plugin
 * wasn't able to change push notification state (enable / disable).
 *
 * @ref c7c8c759-c2cc-4cd3-8241-426dfdbc7294
 */
extern NSString * const kCENNotificationsErrorChatsKey;


#pragma mark - Types & Structures

/**
 * @brief Block / closure which should be passed for 'CENPushNotificationsConfiguration.formatter'
 * if custom should be used.
 *
 * @param event \a NSDictionary with \b {CENChatEngine} event payload which contain
 *     information about sender, where and what has been sent.
 *
 * @return \a NSDictionary where under \b {service names \b CENPushNotificationsService} stored data
 * which should be sent to corresponding service.
 * Remote notification won't be created if empty dictionary returned.
 * Default formatter (only for \c message and \c $.invite) events will be used if \c nil returned
 * from custom formatter.
 */
typedef NSDictionary *(^CENPushNotificationFormatterCallback)(NSDictionary *event);

/**
 * @brief Plugin methods call handler block / closure.
 *
 * @param error \a NSError instance will be passed in case if any errors happened during method
 *     call.
 */
typedef void(^CENPushNotificationCallback)(NSError * __nullable error);

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 4066c35e-3b1a-4108-9a16-bc20a8552db6
 */
typedef struct CENPushNotificationsConfigurationKeys {
    /**
     * @brief Boolean which specify whether sent push notification should allow debugging with
     * \b {PubNub Console https://www.pubnub.com/docs/console} or not.
     *
     * \b Default: \c NO
     *
     * @ref 723c7dee-7903-4eba-9feb-d4c231ce311b
     */
    __unsafe_unretained NSString *debug;
    
    /**
     * @brief List of event names which should trigger push notification payload composition before
     * sending event.
     *
     * \b Default: \c @[@"message", @"$.invite"]
     *
     * @ref b776a5d3-84b5-4f65-8232-70bb22f14b81
     */
    __unsafe_unretained NSString *events;
    
    /**
     * @brief List of \b {service names \b CENPushNotificationsService} for which plugin should
     * generate notification payload (to mark as \c seen or if \c formatter missing).
     *
     * @note Not required, if custom \b {formatter} take care of all required \b {events}.
     *
     * \b Required: optional
     *
     * @ref 6bf83c67-08f7-4bce-a100-6646d445d31c
     */
    __unsafe_unretained NSString *services;
    
    /**
     * @brief Block / closure which should be used to provide custom payload format.
     *
     * \b Required: optional
     *
     * @ref 4613270d-daa7-4f41-b371-99780ce1b932
     */
    __unsafe_unretained NSString *formatter;
} CENPushNotificationsConfigurationKeys;

extern CENPushNotificationsConfigurationKeys CENPushNotificationsConfiguration;

/**
 * @brief Structure which describe supported push notification services.
 *
 * @ref b5f6103b-bd3b-4dff-a757-ee4a86170ba5
 */
typedef struct CENPushNotificationsServices {
    /**
     * @brief Apple Push Notification.
     *
     * @ref 2c1f50ac-4a4e-4da5-bfb3-6e16dafd81d4
     */
    __unsafe_unretained NSString *apns;
    
    /**
     * @brief Google Cloud Messaging / Firebase Cloud Messaging.
     *
     * @ref 068a2668-2c2a-43e2-b3d3-118a06c347d4
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
 * @discussion Setup with custom push notifications payload formatter
 * @code
 * // objc 1f354c6b-5db3-4f29-ba8b-9b8aa6712fd5
 *
 * CENPushNotificationFormatterCallback formatter = ^NSDictionary * (NSDictionary *payload) {
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
 * self.client.proto(@"Me", [CENPushNotificationsPlugin class]).configuration(@{
 *     CENPushNotificationsConfiguration.services: @[CENPushNotificationsService.apns],
 *     CENPushNotificationsConfiguration.events: @[@"ping"],
 *     CENPushNotificationsConfiguration.formatter: formatter
 * }).store();
 * @endcode
 *
 * @ref 709ee690-d7d3-4ebe-9ed9-58ed0e4f7f01
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENPushNotificationsPlugin : CEPPlugin


#pragma mark - Management notifications state

/**
 * @brief Enable push notifications on specified list of \b {chats CENChat}.
 *
 * @note This method should be called at every application launch with received device push token.
 *
 * @discussion Enable push notifications on set of \b {chats CENChat} on device
 * @code
 * // objc 9efd8b53-5be1-4860-b29f-70199d4f6f21
 *
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
 * @since 0.0.2
 *
 * @ref ec289e00-6df9-4dcf-b3ce-cfa488f62edb
 */
+ (void)enableForChats:(NSArray<CENChat *> *)chats
       withDeviceToken:(NSData *)token
            completion:(nullable CENPushNotificationCallback)block;

/**
 * @brief Enable push notifications on specified list of \b {chats CENChat}.
 *
 * @note This method should be called at every application launch with received device push token.
 *
 * @param chats List of \b {chats CENChat} for which remote notification should be triggered.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of registration process and pass
 *     error (if any).
 *
 * @deprecated 0.0.2
 *
 * @ref d3b882de-e438-4a01-a121-e6fa6326ae29
 */
+ (void)enablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                        withDeviceToken:(NSData *)token
                             completion:(nullable CENPushNotificationCallback)block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-enableForChats:withDeviceToken:completion: method instead.");

/**
 * @brief Disable push notifications on specified list of \b {chats CENChat}.
 *
 * @discussion Disable push notifications on set of \b {chats CENChat} on device
 * @code
 * // objc eff43218-5605-426a-96e0-ebfe41c738eb
 *
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
 * @since 0.0.2
 *
 * @ref 8a0df0d2-2975-47f5-9224-3dade6552243
 */
+ (void)disableForChats:(NSArray<CENChat *> *)chats
        withDeviceToken:(NSData *)token
             completion:(nullable CENPushNotificationCallback)block;

/**
 * @brief Disable push notifications on specified list of \b {chats CENChat}.
 *
 * @param chats List of \b {chats CENChat} for which remote notifications shouldn't be triggered.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of un-registration process and pass
 *     error (if any).
 *
 * @deprecated 0.0.2
 *
 * @ref 3cf8ae10-d8d8-4781-bcf5-56dc96e662de
 */
+ (void)disablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                         withDeviceToken:(NSData *)token
                              completion:(nullable CENPushNotificationCallback)block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-disableForChats:withDeviceToken:completion: method instead.");

/**
 * @brief Disable all push notifications for \b {local user CENMe}.
 *
 * @note It is good idea to call this method when user signs off.
 *
 * @discussion Disable push notifications on all \b {chats CENChat} on device
 * @code
 * // objc a06ac2d2-97fe-4f06-84fb-50bb96790918
 *
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
 * @since 0.0.2
 *
 * @ref c307fee7-4e41-4c9a-9d4f-cc319518e6c0
 */
+ (void)disableAllForUser:(CENMe *)user
          withDeviceToken:(NSData *)token
               completion:(nullable CENPushNotificationCallback)block;

/**
 * @brief Disable all push notifications for \b {local user CENMe}.
 *
 * @note It is good idea to call this method when application sign out user
 *
 * @param user \b {Local user CENMe} for which notifications should be disabled.
 * @param token Device token which has been provided by APNS.
 * @param block Block / closure which will be called at the end of un-registration process and pass
 *     error (if any).
 *
 * @deprecated 0.0.2
 *
 * @ref f811e420-78fd-4041-b948-06023c6f6109
 */
+ (void)disableAllPushNotificationsForUser:(CENMe *)user
                           withDeviceToken:(NSData *)token
                                completion:(nullable CENPushNotificationCallback)block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-disableAllForUser:withDeviceToken:completion: method instead.");


#pragma mark - Notifications management

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @discussion Hide specific \c notification on other devices where same user has been authorized
 * @code
 * // objc dd68aad3-24e9-4696-8aef-37a88f7f819b
 *
 * [CENPushNotificationsPlugin markAsSeen:pushNotification forUser:self.client.me
 *                         withCompletion:^(NSError *error) {
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
 * @since 0.0.2
 *
 * @ref 574cc8a3-566e-4337-b316-f7635e0cb157
 */
+ (void)markAsSeen:(NSNotification *)notification
           forUser:(CENMe *)user
    withCompletion:(nullable CENPushNotificationCallback)block;

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param notification Received remote notification which should be hidden.
 * @param user \b {Local user CENMe} for which \c notification should be hidden on another devices.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @ref 30828dfd-8289-47c1-bd15-33f9747870e8
 *
 * @deprecated 0.0.2
 */
+ (void)markNotificationAsSeen:(NSNotification *)notification
                       forUser:(CENMe *)user
                withCompletion:(nullable CENPushNotificationCallback)block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-markAsSeen:forUser:withCompletion: method instead.");

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @discussion Hide all \c notifications on other devices where same user has been authorized
 * @code
 * // objc 0e2d8dff-ff81-47d1-8728-b0a895a2722b
 *
 * [CENPushNotificationsPlugin markAllAsSeenForUser:self.client.me
 *                                   withCompletion:^(NSError *error) {
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
 * @since 0.0.2
 *
 * @ref d0e7d8d0-1b0a-4b4f-aceb-6ca50b10e10f
 */
+ (void)markAllAsSeenForUser:(CENMe *)user
              withCompletion:(nullable CENPushNotificationCallback)block;

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param user \b {Local user CENMe} for which all \c notification should be hidden another devices.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @deprecated 0.0.2
 *
 * @ref c3a02900-7eb1-46aa-adbb-499c62c84a4a
 */
+ (void)markAllNotificationAsSeenForUser:(CENMe *)user
                          withCompletion:(nullable CENPushNotificationCallback)block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-markAllAsSeenForUser:withCompletion: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
