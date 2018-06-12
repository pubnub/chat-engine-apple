/**
 * @brief Set of types and structures which is used by \b ChatEngine client internally.
 *
 * @author Serhii Mamontov
 * @version 0.9.13
 * @copyright © 2009-2018 PubNub, Inc.
 */
#ifndef CENPrivateStructures_h
#define CENPrivateStructures_h


#pragma once

/**
 * @brief  Structure wich describe available chat groups.
 */
typedef struct CENChatDataKeys {
    
    /**
     * @brief  Stores reference on name of chat(s) group which unify system (\b ChatEngine service)
     *         chats.
     */
    __unsafe_unretained NSString *channel;
    
    __unsafe_unretained NSString *group;
    
    /**
     * @brief  Stores reference on name of chat(s) group which unify chat(s) created by user(s).
     */
    __unsafe_unretained NSString *private;
    __unsafe_unretained NSString *meta;
} CENChatDataKeys;

extern CENChatDataKeys CENChatData;


/**
 * @brief  Structure which describe available chat groups.
 */
typedef struct CENObjectTypes {
    
    /**
     * @brief  Stores reference on name of object which represent remote user(s).
     */
    __unsafe_unretained NSString *user;
    
    /**
     * @brief  Stores reference on name of object which represent \c local user.
     */
    __unsafe_unretained NSString *me;
    
    /**
     * @brief  Stores reference on name of object which represent communication channel - chat.
     */
    __unsafe_unretained NSString *chat;
    
    /**
     * @brief  Stores reference on name of object which represent \c local user.
     */
    __unsafe_unretained NSString *search;
} CENObjectTypes;

extern CENObjectTypes CENObjectType;


/**
 * @brief  Structure which describe keys under which plugin's data is stored.
 */
typedef struct CEPluginDataKeys {
    
    /**
     * @brief  Stores reference on key name under which stored dictionary where keys are object
     *         types and values are arrays with \c plugin identifiers in order of registration.
     */
    __unsafe_unretained NSString *objects;
    
    /**
     * @brief  Stores reference on key name under which stored dictionary with \c plugin
     *         indentifiers linked to initialized instances.
     */
    __unsafe_unretained NSString *instances;
    
    /**
     * @brief  Stores reference on key name under which stored dictionary with \c plugin
     *         indentifiers linked to initialized instances.
     */
    __unsafe_unretained NSString *referencesCount;
    
    /**
     * @brief  Stores reference on key name under which stored dictionary where keys are object
     *         types and values are arrays with \c plugin identifiers in order of registration.
     */
    __unsafe_unretained NSString *extensions;
    
    /**
     * @brief  Stores reference on key name under which stored dictionary with \c plugin
     *         indentifiers linked to initialized instances.
     */
    __unsafe_unretained NSString *middlewares;
} CEPluginDataKeys;

extern CEPluginDataKeys CEPluginData;

/**
 * @brief  Structure wich describe available chat groups.
 */
typedef struct CEExceptionPropagationFlows {
    
    /**
     * @brief  Field represent flow which propagate exception only on behalf of specified object.
     */
    __unsafe_unretained NSString *direct;
    
    /**
     * @brief  Field represent flow which propagate exception on behalf of specified object and \b ChatEngine client itself.
     */
    __unsafe_unretained NSString *middleware;
} CEExceptionPropagationFlows;

extern CEExceptionPropagationFlows CEExceptionPropagationFlow;

#endif // CENPrivateStructures_h
