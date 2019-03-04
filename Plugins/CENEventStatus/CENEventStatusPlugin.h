#import <CENChatEngine/CEPPlugin.h>
#import "CENEventStatusExtension.h"


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref 8164a777-a95a-489b-bcc4-cbf9334a7767
 */
typedef struct CENEventStatusConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * \b Default: \c @[@"message"]
     *
     * @ref 4352f207-9fdc-428f-ae98-b3385628b02a
     */
    __unsafe_unretained NSString *events;
} CENEventStatusConfigurationKeys;

extern CENEventStatusConfigurationKeys CENEventStatusConfiguration;

/**
 * @brief Structure which provides available status event data keys.
 *
 * @ref 9df3fbe2-99bc-421e-8ae4-6ddc7381874e
 */
typedef struct CENEventStatusDataKeys {
    /**
     * @brief Event status information.
     *
     * @ref 8e0ea1cc-4d4c-4327-84a0-0397fa83de76
     */
    __unsafe_unretained NSString *data;
    /**
     * @brief Event unique identifier.
     *
     * @ref a8c8f3be-e33d-4c60-a41f-470469d0667b
     */
    __unsafe_unretained NSString *identifier;
} CENEventStatusDataKeys;

extern CENEventStatusDataKeys CENEventStatusData;


#pragma mark - Class forward

@class CENChat;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CEChat} emitted event status tracking.
 *
 * @discussion This plugin allow automatically track \c delivery state and by user request notify
 * about event \c read.
 *
 * @discussion Setup with default configuration
 * @code
 * // objc 566ae131-5d26-43db-a183-924ca3e7c0cf
 *
 * // Register plugin for every created chat.
 * self.client.proto(@"Chat", [CENEventStatusPlugin class]).store();
 *
 * // or register plugin for particular chat (global), when CENChatEngine will be ready.
 * self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
 *     self.client.global.plugin([CENEventStatusPlugin class])
 *         .configuration(configuration).store();
 * });
 * @endcode
 *
 * @discussion Setup with custom events
 * @code
 * // objc aa9696a6-2bb0-4378-a3be-cd7f5952e034
 *
 * NSDictionary *configuration = @{
 *     CENEventStatusConfiguration.events: @[@"ping", @"pong", @"message"]
 * };
 *
 * // Register plugin for every created chat.
 * self.client.proto(@"Chat", [CENEventStatusPlugin class])
 *     .configuration(configuration).store();
 *
 * // or register plugin for particular chat (global), when ChatEngine will be ready.
 * self.client.once(@"$.ready", ^(CENEmittedEvent *event) {
 *     self.client.global.plugin([CENEventStatusPlugin class])
 *         .configuration(configuration).store();
 * });
 * @endcode
 *
 * @ref 07c4dcb9-8084-4a3b-8cab-562efcfc44da
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENEventStatusPlugin : CEPPlugin


#pragma mark - Extension

/**
 * @brief Mark particular event as \c read and notify other \b {chat CENChat} participants.
 *
 * @discussion Mark event as seen
 * @code
 * // objc a0ed93b5-c48a-40db-b49c-568c82d633b0
 *
 * self.chat.on(@"message", ^(CENEmittedEvent *event) {
 *     [CENEventStatusPlugin readEvent:event.data inChat:self.chat];
 * });
 * @endcode
 *
 * @param event \a NSDictionary with event data which has been received from \b {chat CENChat}.
 * @param chat \b {Chat CENChat} to which \c read acknowledgment should be sent.
 *
 * @ref e6d16920-bbb5-4eff-9436-27936a25b768
 */
+ (void)readEvent:(NSDictionary *)event inChat:(CENChat *)chat;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
