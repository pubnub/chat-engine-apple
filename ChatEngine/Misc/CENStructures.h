/**
 * @brief Set of types and structures which is used as part of API calls in
 * \b {CENChatEngine} client.
 *
 * @ref c0f7c125-ef34-44c9-9b50-b18a4dc8ab33
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#ifndef CENStructures_h
#define CENStructures_h

/**
 * @brief Enum which provides levels for \b {CENChatEngine} logging verbosity
 * configuration.
 *
 * @ref fb07a5a3-9e5f-47de-b540-9fe6099476ed
 */
typedef NS_OPTIONS(NSUInteger, CENLogLevel) {
    /**
     * @brief \b CENLog level which allow to disable all active logging levels.
     *
     * @ref 82d92dcb-38d7-4a5f-9481-ce200011c029
     */
    CENSilentLogLevel = 0,
    
    /**
     * @brief \b CENLog level which allow to print out client information data.
     *
     * @ref 3443873c-1eb8-4423-aa10-da563da99129
     */
    CENInfoLogLevel = (1 << 1),
    
    /**
     * @brief \b CENLog level which allow to print out all API call request URI which has been
     * passed to communicate with \b PubNub Function.
     *
     * @since 0.9.2
     *
     * @ref 9cd43cc0-ba85-41bc-9ea9-2a88321544df
     */
    CENRequestLogLevel = (1 << 2),
    
    /**
     * @brief \b CENLog level which allow to print out request processing errors.
     *
     * @since 0.9.2
     *
     * @ref a00e413c-4c67-49a0-aac8-2790d82b9ec1
     */
    CENRequestErrorLogLevel = (1 << 3),
    
    /**
     * @brief \b CENLog level which allow to print out API execution results.
     *
     * @since 0.9.2
     *
     * @ref 242f3c23-5a0e-4d69-8a37-e8acddace982
     */
    CENResponseLogLevel = (1 << 4),
    
    /**
     * @brief \b CENLog level which allow to print out all service exception messages (before they
     * will raise).
     *
     * @ref 6a76ae0a-fdaf-426c-9a5d-0b7631dd9c1e
     */
    CENExceptionsLogLevel = (1 << 5),
    
    /**
     * @brief \b CENLog level which allow to print out data which is emitted by \b {CENEvent} to
     * remote chat's participants.
     *
     * @ref 1123ef5e-8d3a-47b5-82a5-68fd88e3c67d
     */
    CENEventEmitLogLevel = (1 << 6),
    
    /**
     * @brief \b CENLog level which allow to print out resources allocation / deallocation
     * information.
     *
     * @discussion This is debug logger level to profile client behavior and resources release
     * (no leaks).
     *
     * @ref 65553c81-c1a6-4fce-83f1-4fe3a66465c0
     */
    CENResourcesAllocationLogLevel = (1 << 7),
    
    /**
     * @brief \b CENLog level which allow to print out all API calls with passed parameters.
     *
     * @discussion This log level allow to find out when API has been called and what parameters
     * has been passed.
     *
     * @since 0.9.2
     *
     * @ref 97d6968f-b0f7-4d71-a815-6c13b27245f2
     */
    CENAPICallLogLevel = (1 << 8),
    
    /**
     * @brief Log every message from \b {CENChatEngine} client.
     *
     * @ref c1114084-9d9c-455f-bf56-8fda8d38d1a4
     */
    CENVerboseLogLevel = (CENInfoLogLevel | CENRequestLogLevel | CENRequestErrorLogLevel |
                          CENResponseLogLevel | CENExceptionsLogLevel | CENEventEmitLogLevel |
                          CENAPICallLogLevel)
};


/**
 * @brief Structure which provides keys under which stored \b {CENChatEngine} data passed
 * with emitted event.
 *
 *  @ref 84ee23a8-e218-4a82-ab5d-6010c55a0c52
 */
typedef struct CENEventDataKeys {
    /**
     * @brief \a NSDictionary with data emitted by \b {sender}.
     *
     * @ref d1521c25-0b4d-4466-a532-7d1dde39576c
     */
    __unsafe_unretained NSString *data;
    
    /**
     * @brief \b {User CENUser} which represent event sender.
     *
     * @ref 7940dbc5-e18a-40b6-8bcc-8873da7947fb
     */
    __unsafe_unretained NSString *sender;
    
    /**
     * @brief \b {Chat CENChat} on which \c event has been received.
     *
     * @ref 5db9cfe5-cb55-4705-aec3-12f33cd70220
     */
    __unsafe_unretained NSString *chat;
    
    /**
     * @brief Name of emitted event.
     *
     * @ref 1d3a46fd-14e3-444f-9128-6dc084fe0601
     */
    __unsafe_unretained NSString *event;
    
    /**
     * @brief Unique event identifier.
     *
     * @ref 2ae9f748-a865-468e-b125-5035d390ff22
     */
    __unsafe_unretained NSString *eventID;
    
    /**
     * @brief Timetoken representing date when event has been emitted.
     *
     * @ref 4140970e-0e86-4320-824d-37fd945b1288
     */
    __unsafe_unretained NSString *timetoken;
    
    /**
     * @brief Version of \b {CENChatEngine} SDK which emitted this \c event.
     *
     * @ref b2e97146-63dd-4654-a867-58dd88dfb38c
     */
    __unsafe_unretained NSString *sdk;
} CENEventDataKeys;

extern CENEventDataKeys CENEventData;


#pragma mark Class forward

@class CENEmittedEvent;


#pragma mark - Block / Closures

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Emitted events handling block / closure.
 *
 * @param event Object which hold information about actual event name, data and it's emitted
 *     information.
 *
 * @since 0.9.3
 *
 * @ref 67c888c6-215a-43a7-8f44-43de37a19a68
 */
typedef void(^CENEventHandlerBlock)(CENEmittedEvent *event);

NS_ASSUME_NONNULL_END

#endif // CENStructures_h
