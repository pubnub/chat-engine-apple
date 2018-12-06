#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENEvent, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat's CENChat} events sending API access builder.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2017 PubNub, Inc.
 */
@interface CENChatEmitBuilderInterface : CENInterfaceBuilder


#pragma mark - Configuration

/**
 * @brief Emitted event data addition block.
 *
 * @param data \a NSDictionary with data which should be sent along with event.
 *     \b Default: \c @{}
 *
 * @return Builder instance which allow to complete event emit call configuration.
 */
@property (nonatomic, readonly, strong) CENChatEmitBuilderInterface * (^data)(NSDictionary * __nullable data);


#pragma mark - Call

/**
 * @brief Emit \c event using specified parameters.
 *
 * @note Builder parameters can be specified in different variations depending from needs.
 *
 * @chain data.perform
 *
 * @discussion Emit event with data
 * @code
 * // objc 26856530-b1e4-453d-8a8d-ab9b2627e890
 *
 * // Emit event by one user.
 * self.chat.emit(@"custom-event").data(@{ @"value": @YES }).perform();
 *
 * // Handle event on another side.
 * self.chat.on(@"custom-event", ^(CENEmittedEvent *event) {
 *     NSDictionary *payload = event.data;
 *     CENUser *sender = payload[CENEventData.sender];
 *
 *     NSLog(@"%@ emitted the value: %@", sender.uuid, payload[CENEventData.data][@"message"]);
 * });
 * @endcode
 *
 * @return \b {Event CENEvent} which allow to track emitting progress.
 *
 * @ref 01b1735e-06a5-4c11-9510-cccaded934fd
 */
@property (nonatomic, readonly, strong) CENEvent * (^perform)(void);

#pragma mark -


@end

NS_ASSUME_NONNULL_END
