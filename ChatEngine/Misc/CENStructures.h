/**
 * @brief Set of types and structures which is used as part of API calls in
 * \b {ChatEngine CENChatEngine} client.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#ifndef CENStructures_h
#define CENStructures_h

/**
 * @brief Enum which provides levels for \b {ChatEngine CENChatEngine} logging verbosity
 * configuration.
 */
typedef NS_OPTIONS(NSUInteger, CENLogLevel) {
    /**
     * @brief \b CENLog level which allow to disable all active logging levels.
     */
    CENSilentLogLevel = 0,
    
    /**
     * @brief \b CENLog level which allow to print out client information data.
     */
    CENInfoLogLevel = (1 << 1),
    
    /**
     * @brief \b CENLog level which allow to print out all API call request URI which has been
     * passed to communicate with \b PubNub Function.
     *
     * @since 0.9.2
     */
    CENRequestLogLevel = (1 << 2),
    
    /**
     * @brief \b CENLog level which allow to print out request processing errors.
     *
     * @since 0.9.2
     */
    CENRequestErrorLogLevel = (1 << 3),
    
    /**
     * @brief \b CENLog level which allow to print out API execution results.
     *
     * @since 0.9.2
     */
    CENResponseLogLevel = (1 << 4),
    
    /**
     * @brief \b CENLog level which allow to print out all service exception messages (before they
     * will raise).
     */
    CENExceptionsLogLevel = (1 << 5),
    
    /**
     * @brief \b CENLog level which allow to print out data which is emitted by \b {CENEvent} to
     * remote chat's participants.
     */
    CENEventEmitLogLevel = (1 << 6),
    
    /**
     * @brief \b CENLog level which allow to print out resources allocation / deallocation
     * information.
     *
     * @discussion This is debug logger level to profile client behavior and resources release
     * (no leaks).
     */
    CENResourcesAllocationLogLevel = (1 << 7),
    
    /**
     * @brief \b CENLog level which allow to print out all API calls with passed parameters.
     *
     * @discussion This log level allow to find out when API has been called and what parameters
     * has been passed.
     *
     * @since 0.9.2
     */
    CENAPICallLogLevel = (1 << 8),
    
    /**
     * @brief Log every message from \b {ChatEngine CENChatEngine} client.
     */
    CENVerboseLogLevel = (CENInfoLogLevel | CENRequestLogLevel | CENRequestErrorLogLevel |
                          CENResponseLogLevel | CENExceptionsLogLevel | CENEventEmitLogLevel |
                          CENAPICallLogLevel)
};


/**
 * @brief Structure which provides keys under which stored \b {ChatEngine CENChatEngine} data passed
*  with emitted event.
 */
typedef struct CENEventDataKeys {
    /**
     * @brief \a NSDictionary with data emitted by \c sender.
     */
    __unsafe_unretained NSString *data;
    
    /**
     * @brief \b {CENUser} which represent event sender.
     */
    __unsafe_unretained NSString *sender;
    
    /**
     * @brief \b {CENChat} on which \c event has been received.
     */
    __unsafe_unretained NSString *chat;
    
    /**
     * @brief Name of emitted event.
     */
    __unsafe_unretained NSString *event;
    
    /**
     * @brief Unique event identifier.
     */
    __unsafe_unretained NSString *eventID;
    
    /**
     * @briefTimetoken representing date when event has been emitted.
     */
    __unsafe_unretained NSString *timetoken;
    
    /**
     * @brief Version of \b {ChatEngine CENChatEngine} SDK which emitted this \c event.
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
 * @since 0.10.0
 */
typedef void(^CENEventHandlerBlock)(CENEmittedEvent *event);

NS_ASSUME_NONNULL_END

#endif // CENStructures_h
