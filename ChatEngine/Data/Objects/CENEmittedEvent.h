#import <Foundation/Foundation.h>


#pragma mark Class forward

@class CENEventEmitter;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Local \b {CENChatEngine} emitted events representation.
 *
 * @since 0.9.3
 *
 * @ref 9df126d7-6bdd-4572-9c3c-48645dd94a82
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENEmittedEvent : NSObject


#pragma mark - Information

/**
 * @brief Object which emitted \b {event} locally.
 *
 * @ref fb7de903-cff2-4ad5-a308-365ef3f28106
 */
@property (nonatomic, readonly, strong) id emitter;

/**
 * @brief Full name of emitted event.
 *
 * @ref f68e4cbe-2692-49db-ae69-3eaa34545531
 */
@property (nonatomic, readonly, copy) NSString *event;

/**
 * @brief Object which has been sent along with local \b {event} for handlers consumption.
 *
 * @discussuion There is events like \b {$.connected CENChat} which doesn't set this property, so it
 * will be \c nil.
 *
 * @discussion When handler user to receive remote events
 * (\b {custom events advanced-concepts-namespaces#custom-events}), this property will store
 * dictionary with following keys (each key is _field_ inside of \c CENEventData _typedef struct_)
 * in it:
 * - \c event - name of emitted event,
 * - \c chat - \b {chat CENChat} on which `event` has been received,
 * - \c sender - \b {user CENUser} which represent event sender,
 * - \c timetoken - timetoken representing date when event has been emitted,
 * - \c data - \a NSDictionary with data emitted by \c sender,
 * - \c eventID - unique event identifier.
 *
 * @discussion Handle multiple events using wildcard
 * @code
 * // objc f970e00f-e8e9-4a3d-aab4-0ff93b69ac4e
 *
 * self.chat.on(@"$.online.*", ^(CENEmittedEvent *event) {
 *     // In this case information about user's presence change will be logged out.
 *     CENUser *user = event.data;
 *
 *     NSLog(@"User '%@' %@'ed", user.uuid, event.event);
 * });
 * @endcode
 *
 * @ref 56b44eb1-13b8-47d7-9aac-ce920551d865
 */
@property (nonatomic, nullable, readonly, strong) id data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
