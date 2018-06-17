/**
 * @brief Global client constants declared here.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#ifndef CENConstants_h
#define CENConstants_h

#pragma mark General information constants

// Stores client library version number
static NSString * const kCELibraryVersion = @"0.9.0";

// Stores information about SDK codebase
static NSString * const kCECommit = @"initial";


#pragma mark - Service information

/**
 * @brief  Stores reference on \b PubNub Functions entry point.
 */
static NSString * const kCEPNFunctionsBaseURI = @"https://pubsub.pubnub.com/v1/blocks/sub-key";


#pragma mark - Default client configuration

static NSInteger const kCEDefaultPresenceHeartbeatValue = 150;
static NSInteger const kCEDefaultPresenceHeartbeatInterval = 120;
static NSString * const kCEDefaultGlobalChannel = @"chat-engine";
static BOOL const kCEDefaultShouldSynchronizeSession = NO;
static BOOL const kCEDefaultEnableMeta = NO;

static NSTimeInterval const kCERequestTimeout = 10.f;
static NSInteger const kCEMaximumConnectioncCount = 4;

/**
 * @brief  Temporary object will be stored maximum 10 minutes. If longer time required, caller code
 *         should store reference on it.
 */
static NSTimeInterval const kCEMaximumTemporaryStoreTime = 600.f;

/**
 * @brief  Temporary storage will be cleaned up every minute.
 */
static NSTimeInterval const kCETemporaryStoreCleanUpInterval = 60.f;

#endif // CENConstants_h
