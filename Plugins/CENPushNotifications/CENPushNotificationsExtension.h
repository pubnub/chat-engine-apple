#import <CENChatEngine/CEPExtension.h>


#pragma mark Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      \b CENMe push notifications extension.
 * @discussion Plugin workhorse which track for changes in local user chats list and register plugin for them if required.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENPushNotificationsExtension : CEPExtension


#pragma mark - Information

/**
 * @brief  Stores reference on device push token which should be used by \b PubNub service to reach device remotely with message.
 */
@property (nonatomic, strong) NSData *pushToken;


#pragma mark - Management notifications state

/**
 * @brief      Enable/disable push notifications on specified list of chats.
 * @discussion \b ChatEngine will subscribe/unsubscribe for/from remote notifications from specified set of \c chats.
 *             If \c shouldEnabled is set to \c NO and \chats is empty or \c nil - client will unregister notifications from all chats.
 *
 * @param shouldEnabled Whether notifications should be enabled or disabled.
 * @param chats         Reference on list of chats for which \b ChatEngine service should start remote notification triggering.
 * @param token         Reference on device token which has been provided by APNS.
 * @param block         Reference on block which will be called at the end of registration process. Block pass only one argument - request
 *                      processing error (if any error happened during request).
 */
- (void)enablePushNotifications:(BOOL)shouldEnabled
                       forChats:(nullable NSArray<CENChat *> *)chats
                withDeviceToken:(NSData *)token
                     completion:(void(^ __nullable)(NSError * __nullable error))block;


#pragma mark - Notifications management

/**
 * @brief      Mark specific notification as seen on another devices.
 * @discussion Try hide notification from notification center on another devices.
 *
 * @param notification Reference on received remote notification which should be marked as seen.
 * @param block        Reference on block which will be called at the end of process. Block pass only one argument - request processing
 *                     error (if any error happened during request).
 */
- (void)markNotificationAsSeen:(NSNotification *)notification withCompletion:(void(^ __nullable)(NSError * __nullable error))block;

/**
 * @brief      Mark all notifications as seen on another devices.
 * @discussion Try hide all notifications from notification center on another devices.
 *
 * @param block Reference on block which will be called at the end of process. Block pass only one argument - request processing error (if any
 *              error happened during request).
 */
- (void)markAllNotificationAsSeenWithCompletion:(void(^ __nullable)(NSError * __nullable error))block;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
