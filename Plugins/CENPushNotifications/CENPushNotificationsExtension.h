#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} interface extension to enable push notifications management.
 *
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENPushNotificationsExtension : CEPExtension


#pragma mark - Information

/**
 * @brief Device push token which should be used to manage notifications for specific device and
 * trigger notifications for it.
 */
@property (nonatomic, strong) NSData *pushToken;


#pragma mark - Management notifications state

/**
 * @brief Enable / disable push notifications on specified list of chats.
 *
 * @discussion Enable notifications on set of \b {chats CENChat}:
 * @code
 * // objc
 * self.client.me.extension([CENPushNotificationsPlugin class],
 *                          ^(CENPushNotificationsExtension *extension) {
 *
 *     [extension enable:YES forChats:@[chat1, chat2] withDeviceToken:self.token
 *            completion:^(NSError *error) {
 *
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @discussion Disable notifications from set of \b {chats CENChat}:
 * @code
 * // objc
 * self.client.me.extension([CENPushNotificationsPlugin class],
 *                          ^(CENPushNotificationsExtension *extension) {
 *
 *     [extension enable:NO forChats:@[chat1, chat2] withDeviceToken:self.token
 *            completion:^(NSError *error) {
 *
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @discussion Disable notifications from all \b {chats CENChat} associated with specified token:
 * @code
 * // objc
 * self.client.me.extension([CENPushNotificationsPlugin class],
 *                          ^(CENPushNotificationsExtension *extension) {
 *
 *     [extension enable:NO forChats:nil withDeviceToken:self.token completion:^(NSError *error) {
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param enable Whether notifications should be enabled or disabled.
 * @param chats List of \b {chats CENChat} for which remote notification \c enable state should be
 *     changed.
 * @param token Device token which has been provided by APNS.
 * @param block Block which will be called at the end of state change process and pass
 *     error (if any).
 *
 * @since 1.1.0
 */
- (void)enable:(BOOL)enable
           forChats:(nullable NSArray<CENChat *> *)chats
    withDeviceToken:(NSData *)token
         completion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Enable / disable push notifications on specified list of chats.
 *
 * @param enable Whether notifications should be enabled or disabled.
 * @param chats List of \b {chats CENChat} for which remote notification \c enable state should be
 *     changed. \c nil can be used with \c enable set to \c NO to disable notifications for all
 *     chats.
 * @param token Device token which has been provided by APNS.
 * @param block Block which will be called at the end of state change process and pass
 *     error (if any).
 */
- (void)enablePushNotifications:(BOOL)enable
                       forChats:(nullable NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-enable:forChats:withDeviceToken:completion: method instead.");


#pragma mark - Notifications management

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @code
 * // objc
 * self.client.me.extension([CENPushNotificationsPlugin class],
 *                          ^(CENPushNotificationsExtension *extension) {
 *
 *     [extension markAsSeen:pushNotification withCompletion:^(NSError *error) {
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param notification Received remote notification which should be hidden.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 */
- (void)markAsSeen:(NSNotification *)notification
    withCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param notification Received remote notification which should be hidden.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 */
- (void)markNotificationAsSeen:(NSNotification *)notification
                withCompletion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-markAsSeen:withCompletion: method instead.");

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @code
 * // objc
 * self.client.me.extension([CENPushNotificationsPlugin class],
 *                          ^(CENPushNotificationsExtension *extension) {
 *
 *     [extension markAllAsSeenWithCompletion:^(NSError *error) {
 *         if (error) {
 *             NSLog(@"Request did fail with error: %@", error);
 *         }
 *     }];
 * }];
 * @endcode
 *
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 */
- (void)markAllAsSeenWithCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 */
- (void)markAllNotificationAsSeenWithCompletion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 1.1.0. Please use "
                             "-markAllAsSeenWithCompletion: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
