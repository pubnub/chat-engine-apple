/**
 * @brief Set of types and structures which is used by \b ChatEngine plugins.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#ifndef CEPStructures_h
#define CEPStructures_h


#pragma once

/**
 * @brief  Structure wich describe available middleware locations.
 */
typedef struct CEPMiddlewareLocations {
    
    /**
     * @brief  Stores reference on name of location which is triggered when \b ChatEngine is about to send any data to
     *         \b PubNub real-time network.
     *         When bound to this location, middleware will be able to modify payload before it will be sent to \b PubNub
     *         real-time network.
     */
    __unsafe_unretained NSString *emit;
    
    /**
     * @brief  Stores reference on name of location which is triggered when \b ChatEngine receive any data from \b PubNub
     *         real-time network.
     *         When bound to this location, middleware will be able to modify payload before it will be returned back to the
     *         user.
     */
    __unsafe_unretained NSString *on;
} CEPMiddlewareLocations;

extern CEPMiddlewareLocations CEPMiddlewareLocation;

#endif // CEPStructures_h
