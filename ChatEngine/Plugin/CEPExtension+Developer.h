/**
 * @ref 7b59c3ae-e6da-488d-91e9-7d8e46802aa8
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+PluginsDeveloper.h>
#import <CENChatEngine/CENErrorCodes.h>
#import "CENObject+PluginsDeveloper.h"
#import "CENEventEmitter+Interface.h"
#import "CENStructures.h"
#import "CEPExtension.h"
#import "CENError.h"


#pragma mark Class forward

@class CENObject;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Developer's interface declaration

@interface CEPExtension (Developer)


#pragma mark - Information

/**
 * @brief \a NSDictionary which is passed during plugin registration and contain extension required
 * configuration information.
 *
 * @ref b2b42c48-4e63-4779-b487-8b4cfc721893
 */
@property (nonatomic, nullable, readonly, copy) NSDictionary *configuration;

/**
 * @brief \b {Object CENObject} subclass instance for which extended interface has been provided.
 *
 * @ref aaa65bf8-3403-4180-9238-3a4a742eb7d4
 */
@property (nonatomic, nullable, readonly, weak) CENObject *object;

/**
 * @brief Unique identifier of plugin which instantiated this extension.
 *
 * @ref 6d5b0836-1150-4461-b7a9-5c4ad5a69e41
 */
@property (nonatomic, readonly, copy) NSString *identifier;


#pragma mark - Handlers

/**
 * @brief Handle extension instantiation and registration completion for specific \b {object}.
 *
 * @discussion Handle extension instantiation and registration completion
 * @code
 * // objc 3b1c920c-87a9-405f-9763-a96251eb3863
 *
 * - (void)onCreate {
 *
 *     __weak __typeof(self) weakSelf = self;
 *     self.eventHandlerBlock = ^(CENEmittedEvent *localEvent) {
 *         __strong __typeof(weakSelf) strongSelf = weakSelf;
 *         NSDictionary *event = localEvent.data;
 *
 *         [strongSelf handleEvent:event];
 *     };
 *
 *     for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
 *         [self.object handleEvent:event withHandlerBlock:self.eventHandlerBlock];
 *     }
 * }
 * @endcode
 *
 * @ref 3430a537-c00b-469f-a8bc-c1c47ffd020e
 */
- (void)onCreate;

/**3
 * @brief Handle extension destruction and unregister from specific \b {object}.
 *
 * @discussion Handle extension instantiation and registration completion
 * @code
 * // objc 426139c5-1476-4a7f-a449-b6fce3706be1
 *
 * - (void)onDestruct {
 *
 *     for (NSString *event in self.configuration[CENUnreadMessagesConfiguration.events]) {
 *         [self.object removeHandler:self.eventHandlerBlock forEvent:event];
 *     }
 * }
 * @endcode
 *
 * @ref f6d5c5e1-946c-4432-8802-7ffc9a68089b
 */
- (void)onDestruct;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
