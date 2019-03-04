#import <CENChatEngine/CEPPlugin.h>


#pragma mark Structures

/**
 * @brief Structure which provides available configuration option keys.
 *
 * @ref be2ac85b-f3f3-449b-bb46-67e177ac758c
 */
typedef struct CENOpenGraphConfigurationKeys {
    /**
     * @brief List of event names for which plugin should be used.
     *
     * \b Default: \c @[@"message"]
     *
     * @ref 54c060ce-c4e8-413b-883d-cfc67f5f70ba
     */
    __unsafe_unretained NSString *events;

    /**
     * @brief Unique application ID provided by \b {Open Graph https://www.opengraph.io} after
     * registration and used with Open Graph data processing API.
     *
     * @ref 24f9c2ed-e73f-42f4-bfcd-4359fac4e146
     */
    __unsafe_unretained NSString *appID;
    
    /**
     * @brief Key or key-path in \c data payload where string which should be pre-processed.
     *
     * \b Default: \c text
     *
     * @ref 1c71c605-04d9-422d-8c04-1b79869ac6c3
     */
    __unsafe_unretained NSString *messageKey;
    
    /**
     * @brief Key or key-path in \c data payload where received OpenGraph data will be stored.
     *
     * \b Default: \c openGraph
     *
     * @ref 374033dc-c4ab-47a3-a196-5e689914f8e0
     */
    __unsafe_unretained NSString *openGraphKey;
} CENOpenGraphConfigurationKeys;

extern CENOpenGraphConfigurationKeys CENOpenGraphConfiguration;

/**
 * @brief Structure which provides available OpenGraph data keys.
 *
 * @ref d934fcee-0ee4-4d85-93de-92cf5b19ef0d
 */
typedef struct CENOpenGraphDataKeys {
    /**
     * @brief URL string from which requested URL OpenGraph representation image can be downloaded.
     *
     * @ref 1c4b5967-bb9d-42bb-8245-746822e466c3
     */
    __unsafe_unretained NSString *image;
    /**
     * @brief URL string for which OpenGraph data has been retrieved.
     *
     * @ref 6740520c-f127-4e99-9bd1-920016e3201f
     */
    __unsafe_unretained NSString *url;
    /**
     * @brief Short string which represent object from requested URL.
     *
     * @ref 3d9f604f-3440-439e-b5dc-3d555a0e0453
     */
    __unsafe_unretained NSString *title;
    /**
     * @brief Body which represent object from requested URL.
     *
     * @ref 4f4bb3f5-35c2-4204-bdd1-b79dd2b690ce
     */
    __unsafe_unretained NSString *description;
} CENOpenGraphDataKeys;

extern CENOpenGraphDataKeys CENOpenGraphData;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \b {Chat CEChat} received data pre-processor to fetch OpenGraph data for link in event.
 *
 * @discussion Plugin allow to scan received event and fetch OpenGraph data about object referenced
 * by link in event payload.
 *
 * @discussion Setup with default configuration and application ID
 * @code
 * // objc 94d2a382-56f8-4eb9-b9c6-80b195986b6a
 *
 * self.chat.plugin([CENOpenGraphPlugin class]).configuration(@{
 *     CENOpenGraphConfiguration.appID: @"xxxxxxxxxxxxxxxxx"
 * }).store();
 *
 * self.chat.on(@"message", ^(CENEmittedEvent *event) {
 *     NSDictionary *eventPayload = ((NSDictionary *)event.data)[CENEventData.data];
 *     NSDictionary *openGraphPayload = eventPayload[@"openGraph"];
 *
 *     if (openGraphPayload) {
 *         NSLog(@"Received OpenGraph object for %@\n\tTitle: %@\n\tDescription: %@\ntImage: %@",
 *               openGraphPayload[CENOpenGraphData.url],
 *               openGraphPayload[CENOpenGraphData.title],
 *               openGraphPayload[CENOpenGraphData.description],
 *               openGraphPayload[CENOpenGraphData.image]);
 *     }
 * });
 * @endcode
 *
 * @discussion Setup with custom event text location, OpenGraph store location and events
 * @code
 * // objc 7cc53e56-7b37-4588-97ff-811a20c2f1f1
 *
 * self.chat.plugin([CENOpenGraphPlugin class]).configuration(@{
 *     CENOpenGraphConfiguration.appID: @"xxxxxxxxxxxxxxxxx",
 *     CENOpenGraphConfiguration.events: @[@"ping", @"pong"],
 *     CENRandomUsernameConfiguration.messageKey: @"attachment.link",
 *     CENRandomUsernameConfiguration.openGraphKey: @"attachment.openGraph"
 * }).store();
 *
 * self.chat.on(@"pong", ^(CENEmittedEvent *event) {
 *     NSDictionary *eventPayload = ((NSDictionary *)event.data)[CENEventData.data];
 *     NSDictionary *openGraphPayload = [eventPayload valueForKeyPath:@"attachment.openGraph"];
 *
 *     if (openGraphPayload) {
 *         NSLog(@"Received OpenGraph object for %@\n\tTitle: %@\n\tDescription: %@\ntImage: %@",
 *               openGraphPayload[CENOpenGraphData.url],
 *               openGraphPayload[CENOpenGraphData.title],
 *               openGraphPayload[CENOpenGraphData.description],
 *               openGraphPayload[CENOpenGraphData.image]);
 *     }
 * });
 * @endcode
 *
 * @ref 3843f963-c016-401f-9ede-f1fdf2b4e4fc
 *
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENOpenGraphPlugin : CEPPlugin


#pragma mark -


@end

NS_ASSUME_NONNULL_END
