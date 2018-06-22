#import <CENChatEngine/CEPPlugin.h>


#pragma mark Static

/**
 * @brief  Name of key for \a NSError userInfo where stored list of chats for which error has been created.
 */
extern NSString * const kCENNotificationsErrorChatsKey;


#pragma mark Structures

/**
 * @brief  Structure wich describe available configuration option key names.
 */
typedef struct CENPushNotificationsConfigurationKeys {
    
    /**
     * @brief  Stores reference on name of key under which stored list of event names for which plugin should be used.
     */
    __unsafe_unretained NSString *events;
    
    /**
     * @brief  Stores reference on name of key under which stored list of service names (from \b CENPushNotificationsService fields) for which
     *         plugin should generate notification payload (to mark as \c seen or if \c formatter missing).
     */
    __unsafe_unretained NSString *services;
    
    /**
     * @brief      Stores reference on name of key under which stored GCD block which should be used to provide custom payload format.
     * @discussion In case if \c services specified, plugin should be able to generate minimum push notification for each of specified services.
     *             If custom payload required, formatter can be used to override notification payload.
     */
    __unsafe_unretained NSString *formatter;
} CENPushNotificationsConfigurationKeys;

extern CENPushNotificationsConfigurationKeys CENPushNotificationsConfiguration;

/**
 * @brief  Structure wich describe available OS platforms.
 */
typedef struct CENPushNotificationsServices {
    
    /**
     * @brief      Apple Push Notification service representation key.
     * @discussion If used with client configuration and set to \c YES plugin will try to generate push notification payload which can be sent
     *             with APNS provide.
     *             Key also can be used from within \c formatter method to specify service for which payload stored as value.
     */
    __unsafe_unretained NSString *apns;
    
    /**
     * @brief      Google Cloud Messaging/Firebase Cloud Messaging services representation key.
     * @discussion If used with client configuration and set to \c YES plugin will try to generate push notification payload which can be sent
     *             with GCM/FCM provide.
     *             Key also can be used from within \c formatter method to specify service for which payload stored as value.
     */
    __unsafe_unretained NSString *fcm;
} CENPushNotificationsServices;

extern CENPushNotificationsServices CENPushNotificationsService;


#pragma mark - Class forward

@class CENChat, CENMe;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b CENMe plugin's extension provide functionality to work with push notifications.
 * @discussion Plugin extend \b ChatEngine functionality by adding local user extensions and events emitting middlewares which allow to modify
 *             payload to add notifications body there.
 */
@interface CENPushNotificationsPlugin : CEPPlugin


#pragma mark - Management notifications state

/**
 * @brief      Enable push notifications on specified list of chats.
 * @discussion \b ChatEngine will subscribe for remote notifications from specified set of \c chats.
 * @note       It is required to call this method each time when application launch and receive device push token.
 *
 * @param chats Reference on list of chats for which \b ChatEngine service should start remote notification triggering.
 * @param token Reference on device token which has been provided by APNS.
 * @param block Reference on block which will be called at the end of registration process. Block pass only one argument - request processing
 *              error (if any error happened during request).
 */
+ (void)enablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                        withDeviceToken:(NSData *)token
                             completion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief      Disable push notifications on specified list of chats.
 * @discussion \b ChatEngine will unsubscribe from remote notifications from specified set of \c chats.
 *
 * @param chats Reference on list of chats for which \b ChatEngine service should stop remote notification triggering.
 * @param token Reference on device token which has been provided by APNS.
 * @param block Reference on block which will be called at the end of unregister process. Block pass only one argument - request processing
 *              error (if any error happened during request).
 */
+ (void)disablePushNotificationsForChats:(NSArray<CENChat *> *)chats
                         withDeviceToken:(NSData *)token
                              completion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief      Disable all push notifications for specified user.
 * @discussion \b ChatEngine will unsubscribe from all notifications for chats which has been used by \c user.
 * @note       It is good idea to call this method when application signout user
 *
 * @param user  Reference on local \b ChatEngine user for which notifications should be disabled.
 * @param token Reference on device token which has been provided by APNS.
 * @param block Reference on block which will be called at the end of unregister process. Block pass only one argument - request processing
 *              error (if any error happened during request).
 */
+ (void)disableAllPushNotificationsForUser:(CENMe *)user
                           withDeviceToken:(NSData *)token
                                completion:(void(^ __nullable)(NSError * __nullable error))block;


#pragma mark - Notifications management

/**
 * @brief      Mark specific notification as seen on another devices.
 * @discussion Try hide notification from notification center on another devices.
 *
 * @param notification Reference on received remote notification which should be marked as seen.
 * @param user         Reference on user which is used on another devices for which notification should be hidden.
 * @param block        Reference on block which will be called at the end of process. Block pass only one argument - request processing
 *                     error (if any error happened during request).
 */
+ (void)markNotificationAsSeen:(NSNotification *)notification
                       forUser:(CENMe *)user
                withCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief      Mark all notifications as seen on another devices.
 * @discussion Try hide all notifications from notification center on another devices.
 *
 * @param user  Reference on user which is used on another devices for which notifications should be hidden.
 * @param block Reference on block which will be called at the end of process. Block pass only one argument - request processing error (if any
 *              error happened during request).
 */
+ (void)markAllNotificationAsSeenForUser:(CENMe *)user withCompletion:(void(^ __nullable)(NSError * __nullable error))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
