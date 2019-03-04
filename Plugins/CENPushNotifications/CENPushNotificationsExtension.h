#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Local user CENMe} interface extension to enable push notifications management.
 *
 * @ref db20a794-884e-4f9b-90cc-b80813e4f8d9
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENPushNotificationsExtension : CEPExtension


#pragma mark - Information

/**
 * @brief Device push token which should be used to manage notifications for specific device and
 * trigger notifications for it.
 *
 * @ref cb66d035-0f55-4e83-9272-6d550328ca6a
 */
@property (nonatomic, strong) NSData *pushToken;


#pragma mark - Management notifications state

/**
 * @brief Enable / disable push notifications on specified list of chats.
 *
 * @discussion Enable push notifications on set of \b {chats CENChat} on device
 * @code
 * // objc c2f8f12d-bc9e-4f5a-99ba-49aeead07685
 *
 * CENPushNotificationsExtension *extension = nil;
 * extension = self.client.me.extension([CENPushNotificationsPlugin class]);
 *
 * [extension enable:YES forChats:@[chat1, chat2] withDeviceToken:self.token
 *        completion:^(NSError *error) {
 *
 *     if (error) {
 *         NSLog(@"Request did fail with error: %@", error);
 *     }
 * }];
 * @endcode
 *
 * @discussion Disable push notifications on set of \b {chats CENChat} on device
 * @code
 * // objc 253700d0-aef7-44c0-a14f-03a7c2055bab
 *
 * CENPushNotificationsExtension *extension = nil;
 * extension = self.client.me.extension([CENPushNotificationsPlugin class]);
 *
 * [extension enable:NO forChats:@[chat1, chat2] withDeviceToken:self.token
 *        completion:^(NSError *error) {
 *
 *     if (error) {
 *         NSLog(@"Request did fail with error: %@", error);
 *     }
 * }];
 * @endcode
 *
 * @discussion Disable push notifications on all \b {chats CENChat} on device
 * @code
 * // objc 18ae102a-1c9e-4e0f-bdc0-6b39f50a0d57
 *
 * CENPushNotificationsExtension *extension = nil;
 * extension = self.client.me.extension([CENPushNotificationsPlugin class]);
 *
 * [extension enable:NO forChats:nil withDeviceToken:self.token completion:^(NSError *error) {
 *     if (error) {
 *         NSLog(@"Request did fail with error: %@", error);
 *     }
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
 * @ref c0ee14e8-e9e1-4087-8481-c47e464994ef
 *
 * @since 0.0.2
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
 *
 * @deprecated 0.0.2
 *
 * @ref 07ad3402-f9e6-4bf3-ac1b-366e918c1a4b
 */
- (void)enablePushNotifications:(BOOL)enable
                       forChats:(nullable NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-enable:forChats:withDeviceToken:completion: method instead.");


#pragma mark - Notifications management

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @discussion Mark specific remote push notification as \c seen
 * @code
 * // objc b996fea2-a92b-4fdd-8945-42257d36e258
 *
 * CENPushNotificationsExtension *extension = nil;
 * extension = self.client.me.extension([CENPushNotificationsPlugin class]);
 *
 * [extension markAsSeen:pushNotification withCompletion:^(NSError *error) {
 *     if (error) {
 *         NSLog(@"Request did fail with error: %@", error);
 *     }
 * }];
 * @endcode
 *
 * @param notification Received remote notification which should be hidden.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @since 0.0.2
 *
 * @ref edebf9f2-3194-4f4b-92c0-dfd5c4073b9a
 */
- (void)markAsSeen:(NSNotification *)notification
    withCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Try to hide notification from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param notification Received remote notification which should be hidden.
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @deprecated 0.0.2
 *
 * @ref e965c7bc-5644-4880-bfc5-e845aad31a7a
 */
- (void)markNotificationAsSeen:(NSNotification *)notification
                withCompletion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-markAsSeen:withCompletion: method instead.");

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @discussion Mark all received remote notifications as \c seen
 * @code
 * // objc 9c3d838d-8584-4820-a21c-29dea90e0bd0
 *
 * CENPushNotificationsExtension *extension = nil;
 * extension = self.client.me.extension([CENPushNotificationsPlugin class]);
 *
 * [extension markAllAsSeenWithCompletion:^(NSError *error) {
 *     if (error) {
 *         NSLog(@"Request did fail with error: %@", error);
 *     }
 * }];
 * @endcode
 *
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @since 0.0.2
 *
 * @ref b21371ae-1c6e-4b53-a7ac-2c9572001b5a
 */
- (void)markAllAsSeenWithCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief Try hide all notifications from notification centers on another \b {local user CENMe}
 * devices.
 *
 * @param block Block / closure which will be called at the end of process and pass error (if any).
 *
 * @deprecated 0.0.2
 *
 * @ref 43c405b1-6ddd-4880-962a-1d910889afc1
 */
- (void)markAllNotificationAsSeenWithCompletion:(void(^ __nullable)(NSError * __nullable error))block
    DEPRECATED_MSG_ATTRIBUTE("This method deprecated since 0.0.2. Please use "
                             "-markAllAsSeenWithCompletion: method instead.");

#pragma mark -


@end

NS_ASSUME_NONNULL_END
