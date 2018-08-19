#import <XCTest/XCTest.h>
#import <CENChatEngine/ChatEngine.h>
#import <YAHTTPVCR/YAHTTPVCR.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  Base class for all test cases which provide initial setup.
 *
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENTestCase : YHVTestCase


#pragma mark Information

/**
 * @brief      Stores number of seconds which test should wait till async operation completion.
 * @discussion Used for tests which contain handlers with nested semaphores.
 */
@property (nonatomic, readonly, assign) NSTimeInterval testCompletionDelayWithNestedSemaphores;

/**
 * @brief  Stores number of seconds which should be waited before performing next action.
 */
@property (nonatomic, readonly, assign) NSTimeInterval delayBetweenActions;

/**
 * @brief  Stores number of seconds which should be waited before performing in-test verifications.
 */
@property (nonatomic, readonly, assign) NSTimeInterval delayedCheck;

/**
 * @brief Stores number of seconds which positive test should wait till async operation completion.
 */
@property (nonatomic, readonly, assign) NSTimeInterval testCompletionDelay;

/**
 * @brief Stores number of seconds which negative test should wait till async operation completion.
 */
@property (nonatomic, readonly, assign) NSTimeInterval falseTestCompletionDelay;


#pragma mark - VCR filter

/**
 * @brief  Filter sensitive data from published payload.
 *
 * @param message Reference on payload which is about to be stored.
 *
 * @return Reference on filtered PubNub message payload.
 */
- (NSString *)filteredPublishMessageFrom:(NSString *)message;


#pragma mark - Client configuration

/**
 * @brief  Retrieve reference on default configuration which applied by helper to all created instances.
 */
- (CENConfiguration *)defaultConfiguration;

/**
 * @brief      Configure \b ChatEngine instance with data required for test case.
 *
 * @param configuration Reference on \b ChatEngine configuration object.
 *
 * @return Configured and ready to use \b ChatEngine instane.
 */
- (CENChatEngine *)chatEngineWithConfiguration:(CENConfiguration *)configuration;

/**
 * @brief      Configure \b ChatEngine instance with data required for test case.
 * @discussion It is possible to configure multiple \b ChatEngine instances per single test case. If another setup request for \b ChatEngine for
 *             same user will be sent, clone will be created in separate storage and can be retrieved with special method:
 *             \c -chatEngineCloneForUser:.
 *
 * @param configuration Reference on \b ChatEngine configuration object.
 * @param user          Reference on unique user identifier for which \b ChatEngine instance should be created and connected.
 * @param state         Reference on dictionary with information which should be bound to \c user.
 */
- (void)setupChatEngineWithConfiguration:(CENConfiguration *)configuration forUser:(NSString *)user withState:(NSDictionary *)state;

/**
 * @brief      Configure \b ChatEngine instance with data required for test case.
 * @discussion It is possible to configure multiple \b ChatEngine instances per single test case. If another setup request for \b ChatEngine for
 *             same user will be sent, clone will be created in separate storage and can be retrieved with special method:
 *             \c -chatEngineCloneForUser:.
 *
 * @param user               Reference on unique user identifier for which \b ChatEngine instance should be created and connected.
 * @param synchronizeSession Whether synchronization session should be enabled or not.
 * @param synchronizeMeta    Whether chat information should be synchronized on connection or not.
 * @param state              Reference on dictionary with information which should be bound to \c user.
 */
- (void)setupChatEngineForUser:(NSString *)user withSynchronization:(BOOL)synchronizeSession meta:(BOOL)synchronizeMeta state:(NSDictionary *)state;

/**
 * @brief      Configure \b ChatEngine instance with data required for test case.
 * @discussion It is possible to configure multiple \b ChatEngine instances per single test case. If another setup request for \b ChatEngine for
 *             same user will be sent, clone will be created in separate storage and can be retrieved with special method:
 *             \c -chatEngineCloneForUser:.
 *
 * @param globalChannel      Reference on name of global chat (namespace).
 * @param user               Reference on unique user identifier for which \b ChatEngine instance should be created and connected.
 * @param synchronizeSession Whether synchronization session should be enabled or not.
 * @param synchronizeMeta    Whether chat information should be synchronized on connection or not.
 * @param state              Reference on dictionary with information which should be bound to \c user.
 */
- (void)setupChatEngineWithGlobal:(nullable NSString *)globalChannel
                          forUser:(NSString *)user
                  synchronization:(BOOL)synchronizeSession
                             meta:(BOOL)synchronizeMeta
                            state:(NSDictionary *)state;

/**
 * @brief Retrieve reference on \b ChatEngine which has been created on \c -setUp stae for specified
 *        \c user.
 *
 * @param user Unique identifier for which separate \b ChatEngine instance has been created before.
 *
 * @return Reference on previously configured \b ChatEngine instance.
 */
- (CENChatEngine *)chatEngineForUser:(NSString *)user;

/**
 * @brief Retrieve reference on \b ChatEngine duplicate which has been created on \c -setUp stae for
 *        specified \c user for which one instance already exists.
 *
 * @param user Unique identifier for which separate \b ChatEngine instance has been created before.
 *
 * @return Reference on clone of previously configured \b ChatEngine instance.
 */
- (CENChatEngine *)chatEngineCloneForUser:(NSString *)user;


#pragma mark - Connection

/**
 * @brief      Connect \c user to ChatEngine network using provided \c client.
 * @discussion Method can be used to wait for connection completion in tests.
 *
 * @param uuid    Reference on unique user identifier for which \b ChatEngine instance should be created and connected.
 * @param authKey Reference on user's secret combination (password).
 * @param state   Reference on dictionary with information which should be bound to \c user.
 * @param client  Reference on \b ChatEngine instance which should be used to connect \c user to real-time network.
 */
- (void)connectUser:(NSString *)uuid withAuthKey:(NSString *)authKey state:(NSDictionary *)state usingClient:(CENChatEngine *)client;

/**
 * @brief  Disconnect currently connected user from real-time network.
 *
 * @param client Reference on \b ChatEngine instance which should disconnect user.
 */
- (void)disconnectUserUsingClient:(CENChatEngine *)client;

/**
 * @brief  Connect disconnected user back to real-time network.
 *
 * @param client Reference on \b ChatEngine instance which should reconnect user.
 */
- (void)reconnectUserUsingClient:(CENChatEngine *)client;


#pragma mark - State

/**
 * @brief  Update local user \c state and wait till operation completion.
 *
 * @param me    Reference on local user instance for which state should be changed.
 * @param state Reference on new set of data which should be associated with local user.
 */
- (void)updateState:(NSDictionary *)state forUser:(CENMe *)me;


#pragma mark - Mocking

/**
 * @brief      Create mock object for class.
 * @discussion Object prepared for automated clean up.
 *
 * @param cls Reference on class for which mocking shopuld be enabled.
 *
 * @return Class mocking object.
 */
- (id)mockForClass:(Class)cls;

/**
 * @brief      Create partial mock of existing object.
 * @discussion Object prepared for automated clean up.
 *
 * @param object Reference on object for which partial mocking shopuld be enabled.
 *
 * @return Class mocking object.
 */
- (id)partialMockForObject:(id)object;


#pragma mark - Chat mocking

/**
 * @brief  Create and configure \c chat instance with random parameters, which can be used for real
 *         chats mocking.
 *
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)privateChatForMockingWithChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief  Create and configure \c chat instance with random parameters, which can be used for real
 *         chats mocking.
 *
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use public chat representing model.
 */
- (CENChat *)publicChatForMockingWithChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief  Comnpose invocation for Chat class constructor.
 *
 * @param isPrivate Reference on flag which specify whether configured for private chat creation or
 *                  not.
 * @param mock Reference on mocked chat class object.
 *
 * @return Configured and ready to use invocation object.
 */
- (id)createPrivateChat:(BOOL)isPrivate invocationForClassMock:(id)mock;


#pragma mark - Handlers

/**
 * @brief      Pause test execution to wait for asynchronous task to complete.
 * @discussion Useful in case of asynchronous block execution and timer based events. This method
 *             allow to pause test and wait for specified number of \c seconds.
 *
 * @param taskName Name of task for which we are waiting to complete.
 * @param seconds  Number of seconds for which test execution will be postponed to give tested code
 *                 time to perform asynchronous actions.
 *
 * @return Reference on expectation object which can be used for fullfilment.
 */
- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
