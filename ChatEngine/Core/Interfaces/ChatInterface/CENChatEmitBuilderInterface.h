#import "CENInterfaceBuilder.h"


#pragma mark Class forward

@class CENEvent, CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat's CENChat} events sending API access builder.
 *
 * @ref 03571450-341c-42f4-8f72-731a6b8ea91c
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
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
 *
 * @ref caf79187-f7d0-48c6-83e3-3e7171354ab3
 */
@property (nonatomic, readonly, strong) CENChatEmitBuilderInterface * (^data)(NSDictionary * __nullable data);


#pragma mark - Call

/**
 * @brief Emit \c event using specified parameters.
 *
 * @discussion Events are triggered over the network and all events are made on behalf of
 * \b {local user CENMe}.
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
