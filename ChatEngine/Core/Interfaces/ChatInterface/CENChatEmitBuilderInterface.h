#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENEvent, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief      Chat's events emitting API interface builder.
 * @discussion Class describe interface which allow user to publish events which will be delivered to remote \c chat
 *             participnats.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2017 PubNub, Inc.
 */
@interface CENChatEmitBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief      Specify dictionary which should be sent along with event.
 * @discussion Limit search to specific event type. All event(s) will be returned in case if this parameter is not part of
 *             \b CENSearch build call or set to \c nil.
 */
@property (nonatomic, readonly, strong) CENChatEmitBuilderInterface * (^data)(NSDictionary * __nullable data);


#pragma mark - Call

/**
 * @brief  Emit \c event using provided information.
 */
@property (nonatomic, readonly, strong) CENEvent * (^perform)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
