/**
 * @brief Set of types and structures which is used by \b {ChatEngine CENChatEngine} plugins.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#ifndef CEPStructures_h
#define CEPStructures_h


#pragma once

/**
 * @brief Structure wich describe available middleware locations.
 */
typedef struct CEPMiddlewareLocations {
    /**
     * @brief Location which is triggered when \b {ChatEngine CENChatEngine} is about to send any
     * data to \b PubNub real-time network.
     *
     * @discussion When bound to this location, middleware will be able to modify payload before it
     * will be sent to \b PubNub real-time network.
     */
    __unsafe_unretained NSString *emit;
    
    /**
     * @brief Location which is triggered when \b {ChatEngine CENChatEngine} receive any data from
     * \b PubNub real-time network.
     *
     * @discussion When bound to this location, middleware will be able to modify payload before it
     * will be returned back to the \b {user CENUser}.
     */
    __unsafe_unretained NSString *on;
} CEPMiddlewareLocations;

extern CEPMiddlewareLocations CEPMiddlewareLocation;

#endif // CEPStructures_h
