/**
 * @brief Global client constants declared here.
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#ifndef CENConstants_h
#define CENConstants_h

#pragma mark General information constants

/**
 * @brief Stores client library version number
 */
static NSString * const kCENLibraryVersion = @"0.9.2";

/**
 * @brief Stores information about SDK codebase
 */
static NSString * const kCENCommit = @"cb41650117d0e95023aa0fccb7f220b709932a22";


#pragma mark - Service information

/**
 * @brief Stores reference on \b PubNub Functions entry point.
 */
static NSString * const kCENPNFunctionsBaseURI = @"https://pubsub.pubnub.com/v1/blocks/sub-key";


#pragma mark - Default client configuration

/**
 * @brief Maximum time after which server will treat \b {local user CENMe} as inactive in case if it
 * won't notify about it's state.
 */
static NSInteger const kCENDefaultPresenceHeartbeatValue = 300;

/**
 * @brief Interval which is used by \b PubNub client to notify server what \b {local user CENMe}
 * still active.
 */
static NSInteger const kCENDefaultPresenceHeartbeatInterval = 0;

/**
 * @brief Default namespace to which belongs all \b {chats CENChat}.
 */
static NSString * const kCENDefaultNamespace = @"chat-engine";

/**
 * @brief Whether \b {ChatEngine CENChatEngine} should synchronize changes of \b {chats CENChat}
 * list between \b {local user CENMe} devices or not.
 */
static BOOL const kCENDefaultShouldSynchronizeSession = NO;

/**
 * @brief Whether \b {ChatEngine CENChatEngine} should create and throw exceptions when any error
 * emitted.
 */
#if DEBUG
static BOOL const kCENDefaultThrowsExceptions = YES;
#else
static BOOL const kCENDefaultThrowsExceptions = NO;
#endif // DEBUG

/**
 * @brief Whether \b {ChatEngine CENChatEngine} should create \b {CENChatEngine.global} chat on
 * \b {local user CENMe} connection or not.
 */
static BOOL const kCENDefaultEnableGlobal = YES;

/**
 * @brief Whether \b {ChatEngine CENChatEngine} should synchronize meta information for new chats or
 * not.
 */
static BOOL const kCENDefaultEnableMeta = NO;

/**
 * @brief Maximum \b PubNub Functions response wait time.
 */
static NSTimeInterval const kCENRequestTimeout = 10.f;

/**
 * @brief Maximum number of simultaneous connections to \b PubNub Functions.
 */
static NSInteger const kCENMaximumConnectionCount = 4;

/**
 * @brief Temporary object will be stored maximum 10 minutes. If longer time required, caller code
 * should store reference on it.
 */
static NSTimeInterval const kCENMaximumTemporaryStoreTime = 600.f;

/**
 * @brief Temporary storage will be cleaned up every minute.
 */
static NSTimeInterval const kCENTemporaryStoreCleanUpInterval = 60.f;

#endif // CENConstants_h
