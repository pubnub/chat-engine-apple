/**
 * @brief Set of types and structures which is used as part of API calls in \b ChatEngine client.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#ifndef CENStructures_h
#define CENStructures_h


/**
 * @brief  \b ChatEngine client logging levels available for manipulations.
 */
typedef NS_OPTIONS(NSUInteger, CELogLevel) {
    
    /**
     * @brief      \b CELog level which allow to disable all active logging levels.
     * @discussion This log level can be set with \b PNLLogger instance method \c -setLogLevel:
     */
    CENSilentLogLevel = 0,
    
    /**
     * @brief  \b CELog level which allow to print out client information data.
     */
    CENInfoLogLevel = (1 << 1),
    
    /**
     * @brief  \b CELog level which allow to print out all API call request URI which has been passed to communicate with \b PubNub Function.
     *
     * @since 0.9.2
     */
    CENRequestLogLevel = (1 << 2),
    
    /**
     * @brief  \b CELog level which allow to print out request processing errors.
     *
     * @since 0.9.2
     */
    CENRequestErrorLogLevel = (1 << 3),
    
    /**
     * @brief  \b CELog level which allow to print out API execution results.
     *
     * @since 0.9.2
     */
    CENResponseLogLevel = (1 << 4),
    
    /**
     * @brief  \b CELog level which allow to print out all service exception messages (before they will raise).
     */
    CENExceptionsLogLevel = (1 << 5),
    
    /**
     * @brief  \b CELog level which allow to print out data which is emitted by \b CENEvent to remote chat's participants.
     */
    CENEventEmitLogLevel = (1 << 6),
    
    /**
     * @brief      \b CELog level which allow to print out resources allocation/deallocation information.
     * @discussion This is developer debug logger level to profile client behavior and resources release (no leaks).
     */
    CENResourcesAllocationLogLevel = (1 << 7),
    
    /**
     * @brief      \b CELog level which allow to print out all API calls with passed parameters.
     * @discussion This log level allow with debug to find out when API has been called and what parameters should be passed.
     *
     * @since 0.9.2
     */
    CENAPICallLogLevel = (1 << 8),
    
    /**
     * @brief  Log every message from \b PubNub client.
     */
    CENVerboseLogLevel = (CENInfoLogLevel | CENRequestLogLevel | CENRequestErrorLogLevel | CENResponseLogLevel | CENExceptionsLogLevel |
                          CENEventEmitLogLevel | CENAPICallLogLevel)
};


/**
 * @brief  Structure wich describe available chat groups.
 */
typedef struct CENChatGroups {
    
    /**
     * @brief  Stores reference on name of chat(s) group which unify system (\b ChatEngine service)
     *         chats.
     */
    __unsafe_unretained NSString *system;
    
    /**
     * @brief  Stores reference on name of chat(s) group which unify chat(s) created by user(s).
     */
    __unsafe_unretained NSString *custom;
} CENChatGroups;

extern CENChatGroups CENChatGroup;


/**
 * @brief  Structure which describe keys under which stored \b ChatEngine data passed with emitted
 *         event.
 */
typedef struct CENEventDataKeys {
    
    /**
     * @brief  Stores reference on name of key under which stored data emitted by \c sender.
     */
    __unsafe_unretained NSString *data;
    
    /**
     * @brief  Stores reference on name of key under which stored \c CENUser instance which represent
     *         user which sent this event.
     */
    __unsafe_unretained NSString *sender;
    
    /**
     * @brief  Stores reference on name of key under which stored \c CENChat instance which received
     *         \c event.
     */
    __unsafe_unretained NSString *chat;
    
    /**
     * @brief  Stores reference on name of key under which stored name of emitted event.
     */
    __unsafe_unretained NSString *event;
    
    /**
     * @brief  Stores reference on name of key under which stored unique event identifier.
     */
    __unsafe_unretained NSString *eventID;
    
    /**
     * @brief  Stores reference on name of key under which stored timetoken representing date when
     *         event has been emitted.
     */
    __unsafe_unretained NSString *timetoken;
    
    /**
     * @brief  Stores reference on name of key under which stored version of \b ChatEngine SDK which
     *         emitted this \c event.
     */
    __unsafe_unretained NSString *sdk;
} CENEventDataKeys;

extern CENEventDataKeys CENEventData;

#endif // CENStructures_h
