/**
 * @brief Set of types and structures which is used by \b {CENChatEngine} plugins.
 *
 * @ref 3d3ce216-a8c9-4437-82aa-5dfe721b1848
 *
 * @author Serhii Mamontov
 * @version 0.9.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
#ifndef CEPStructures_h
#define CEPStructures_h


#pragma once

/**
 * @brief Structure which describe available middleware locations.
 *
 * @ref ac398582-9527-43dd-a482-73be611b5633
 */
typedef struct CEPMiddlewareLocations {
    /**
     * @brief Location which is triggered when \b {CENChatEngine} is about to send any
     * data to \b PubNub real-time network.
     *
     * @discussion When bound to this location, middleware will be able to modify payload before it
     * will be sent to \b PubNub real-time network.
     *
     * @ref 0f6e1435-191f-4992-b8e3-446985f2923b
     */
    __unsafe_unretained NSString *emit;
    
    /**
     * @brief Location which is triggered when \b {CENChatEngine} receive any data from
     * \b PubNub real-time network.
     *
     * @discussion When bound to this location, middleware will be able to modify payload before it
     * will be returned back to the \b {user CENUser}.
     *
     * @ref 31336787-a791-4c53-bf0d-5508d8424c7e
     */
    __unsafe_unretained NSString *on;
} CEPMiddlewareLocations;

extern CEPMiddlewareLocations CEPMiddlewareLocation;

#endif // CEPStructures_h
