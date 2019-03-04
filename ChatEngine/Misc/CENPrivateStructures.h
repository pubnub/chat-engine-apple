/**
 * @brief Set of types and structures which is used by \b {CENChatEngine} client
 * internally.
 *
 * @author Serhii Mamontov
 * @since 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#ifndef CENPrivateStructures_h
#define CENPrivateStructures_h


#pragma once

/**
 * @brief Structure which provides keys for \b {CENChat} object dictionary representation.
 */
typedef struct CENChatDataKeys {
    /**
     * @brief Name of PubNub channel which is used to deliver real-time updates for \b {CENChat}.
     */
    __unsafe_unretained NSString *channel;
    
    /**
     * @brief Name of group to which chat belongs.
     */
    __unsafe_unretained NSString *group;
    
    /**
     * @brief Whether chat is private or not.
     */
    __unsafe_unretained NSString *private;
    
    /**
     * @brief Chat meta information, which is available for all participants.
     */
    __unsafe_unretained NSString *meta;
} CENChatDataKeys;

extern CENChatDataKeys CENChatData;


/**
 * @brief Structure which provides available chat groups.
 */
typedef struct CENChatGroups {
    /**
     * @brief Stores reference on name of chat(s) group which unify system
     * (\b {CENChatEngine} service) chats.
     */
    __unsafe_unretained NSString *system;
    
    /**
     * @brief Stores reference on name of chat(s) group which unify chat(s) created by user(s).
     */
    __unsafe_unretained NSString *custom;
} CENChatGroups;

extern CENChatGroups CENChatGroup;


/**
 * @brief Structure which provides information about available \b {CENObject} types.
 */
typedef struct CENObjectTypes {
    /**
     * @brief \b {Remote user CENUser} data object.
     */
    __unsafe_unretained NSString *user;
    
    /**
     * @brief \b {Local user CENMe} data object.
     */
    __unsafe_unretained NSString *me;
    
    /**
     * @brief \b {Chat CENChat} data object.
     */
    __unsafe_unretained NSString *chat;
    
    /**
     * @brief Chat events \b {search CENSearch} object.
     */
    __unsafe_unretained NSString *search;
    
    /**
     * @brief Chat event \b {publish CENEvent} object.
     */
    __unsafe_unretained NSString *event;
    
    /**
     * @brief Local user chats synchronization \b {session CENSession} object.
     */
    __unsafe_unretained NSString *session;
} CENObjectTypes;

extern CENObjectTypes CENObjectType;


/**
 * @brief Structure which provides keys to store plugin's data.
 */
typedef struct CEPluginDataKeys {
    /**
     * @brief Dictionary of object identifiers / types mapped to list of plugin / components
     * identifiers in order of registration.
     */
    __unsafe_unretained NSString *objects;
    
    /**
     * @brief Dictionary with plugin / components identifiers mapped to initialized instances.
     */
    __unsafe_unretained NSString *instances;
} CEPluginDataKeys;

extern CEPluginDataKeys CEPluginData;


/**
 * @brief Structure which provides available middleware location.
 */
typedef struct CEExceptionPropagationFlows {
    /**
     * @brief Field represent flow which propagate exception only on behalf of specified object.
     */
    __unsafe_unretained NSString *direct;
    
    /**
     * @brief Field represent flow which propagate exception on behalf of specified object and
     * \b {CENChatEngine} client itself.
     */
    __unsafe_unretained NSString *middleware;
} CEExceptionPropagationFlows;

extern CEExceptionPropagationFlows CEExceptionPropagationFlow;

#endif // CENPrivateStructures_h
