#import <XCTest/XCTest.h>
#import <CENChatEngine/ChatEngine.h>
#import "NSInvocation+CENTest.h"
#import <YAHTTPVCR/YAHTTPVCR.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Base class for all test cases which provide initial setup.
 *
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENTestCase : YHVTestCase


#pragma mark Information

/**
 * @brief Reference on currently used ChatEngine instance.
 *
 * @discussion Instance created lazily and take into account whether mocking enabled at this moment
 * or not.
 * As configuration instance will use \c defaultConfiguration and options provided by available
 * configuration callbacks.
 *
 * @note This client should be used only for unit tests, because they don't need to use multi-user
 * environment.
 */
@property (nonatomic, readonly, nullable, strong) CENChatEngine *client;

/**
 * @brief Path at which integration fixtures will be stored or already exists for playback.
 */
@property (nonatomic, readonly, strong) NSString *fixturesLocation;

/**
 * @brief Currently used global chat / channel name.
 *
 * @discussion Channel name generated randomly and persist during same test case.
 */
@property (nonatomic, readonly, strong) NSString *globalChannel;

/**
 * @brief Whether current test case uses mocked objects or not.
 *
 * @discussion Value of this property affects ChatEngine instance on-demand creation by storing
 * original instance or mocked object.
 */
@property (nonatomic, assign) BOOL usesMockedObjects;

/**
 * @brief Whether during test expected some errors or not.
 */
@property (nonatomic, assign) BOOL expectedError;

/**
 * @brief Stores number of seconds which should be waited before performing in-test verifications.
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


#pragma mark - Test configuration

/**
 * @brief Check whether exception should be thrown if ChatEngine stumbles on error in specified
 * test.
 *
 * @param name Name of current test case.
 *
 * @return Whether any errors should throw exceptions or not.
 *     \b Default: \c NO
 */
- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name;

/**
 * @brief Check whether ChatEngine instance should create global chat during configuration or not.
 *
 * @param name Name of current test case.
 *
 * @return Whether any errors should throw exceptions or not.
 *     \b Default: \c YES
 */
- (BOOL)shouldEnableGlobalChatForTestCaseWithName:(NSString *)name;

/**
 * @brief Check whether ChatEngine instance should sync chat's meta during configuration or not.
 *
 * @param name Name of current test case.
 *
 * @return Whether meta information should be synchronized or not.
 *     \b Default: \c NO
 */
- (BOOL)shouldEnableMetaForTestCaseWithName:(NSString *)name;

/**
 * @brief Check whether ChatEngine instance should synchronize user's session or not.
 *
 * @param name Name of current test case.
 *
 * @return Whether session should be synchronized or not.
 *     \b Default: \c NO
 */
- (BOOL)shouldSynchronizeSessionForTestCaseWithName:(NSString *)name;

/**
 * @brief Whether created \b ChatEngine instance should be connected automatically or not.
 *
 * @discussion If \c YES returned, then client will complete connection (and \c state assignment if
 * configured) before test continuation.
 *
 * @param name Name of current test case.
 *
 * @return Whether client should connect after creation or not.
 *     \b Default: \c NO
 */
- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name;

/**
 * @brief Whether created \b ChatEngine instance should wait for own local user presence events
 * before continuation or not.
 *
 * @return Whether client should wait presence events or not.
 *     \b Default: \c YES
 */
- (BOOL)shouldWaitOwnOnlineStatusForTestCaseWithName:(NSString *)name;

/**
 * @brief Whether running test case has any \b ChatEngine objects or not.
 *
 * @return Whether test case stub / mock any data or not.
 *     \b Default: \c NO
 */
- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name;

/**
 * @brief Get name of channel for global chat (if should be created).
 *
 * @param name Name of current test case.
 *
 * @return Name of channel which should be used for global chat.
 *     \b Default: random
 */
- (nullable NSString *)globalChatChannelForTestCaseWithName:(NSString *)name;

/**
 * @brief Assign local \c user state upon connection to \b PubNub real-time network.
 *
 * @param user Name of user for which \b ChatEngine instance would like to know state for \c global
 *     chat.
 * @param name Name of current test case.
 *
 * @return State which should be assigned to the user on \c global chat.
 *     \b Default: \c nil
 */
- (nullable NSDictionary *)stateForUser:(NSString *)user inTestCaseWithName:(NSString *)name;

/**
 * @brief \b Chat which will hold user's state information for test.
 *
 * @param user Name of user for which \b ChatEngine instance would like to know state for \c global
 *     chat.
 * @param name Name of current test case.
 *
 * @return Chat which will be used to store state.
 *     \b Default: \c nil
 */
- (nullable CENChat *)stateChatForUser:(NSString *)user inTestCaseWithName:(NSString *)name;

/**
 * @brief \b Chat which should be used to track when current \b ChatEngine client user will be
 * online.
 *
 * @return \b Chat on which user's presence will be tracked.
 *     \b Default: \c nil
 */
- (nullable CENChat *)chatToTrackOnlineStatusForTestCaseWithName:(NSString *)name;

/**
 * @brief ChatEngine instance configuration for specific test case.
 *
 * @discussion If method return valid object, then rest callbacks won't be used (whether exceptions
 * should be thrown, whether global should be created, name of global).
 *
 * @param name Name of current test case.
 *
 * @return ChatEngine configuration model instance.
 *     \b Default: default configuration partly configured by values from callbacks.
 */
- (nullable CENConfiguration *)configurationForTestCaseWithName:(NSString *)name;


#pragma mark - VCR filter

/**
 * @brief Filter sensitive data from published payload.
 *
 * @param message Reference on payload which is about to be stored.
 *
 * @return Reference on filtered PubNub message payload.
 */
- (NSString *)filteredPublishMessageFrom:(NSString *)message;


#pragma mark - Client configuration

/**
 * @brief Retrieve reference on default configuration which applied by helper to all created
 * instances.
 */
- (CENConfiguration *)defaultConfiguration;

/**
 * @brief Configure \b ChatEngine instance with data required for test case.
 *
 * @param configuration Reference on \b ChatEngine configuration object.
 *
 * @return Configured and ready to use \b ChatEngine instance.
 */
- (CENChatEngine *)createChatEngineWithConfiguration:(CENConfiguration *)configuration;

/**
 * @brief Configure \b ChatEngine instance for specific user using default configuration with values
 * returned by configuration callbacks.
 *
 * @param user Reference on unique user identifier for which \b ChatEngine instance should be
 *     created and connected.
 *
 * @return Configured and ready to use \b ChatEngine instance.
 */
- (CENChatEngine *)createChatEngineForUser:(NSString *)user;

/**
 * @brief Configure \b ChatEngine instance with data required for test case.
 *
 * @param user Reference on unique user identifier for which \b ChatEngine instance should be
 *     created and connected.
 * @param configuration Reference on \b ChatEngine configuration object.
 *
 * @return Configured and ready to use \b ChatEngine instance.
 */
- (CENChatEngine *)createChatEngineForUser:(NSString *)user withConfiguration:(CENConfiguration *)configuration;

/**
 * @brief Configure \b ChatEngine instance with data required for test case.
 *
 * @discussion It is possible to configure multiple \b ChatEngine instances per single test case.
 * If another setup request for \b ChatEngine for same user will be sent, clone will be created in
 * separate storage and can be retrieved with special method: \c -chatEngineCloneForUser:.
 *
 * @param user Unique user identifier for which \b ChatEngine instance should be created and
 *     connected (if callback request it).
 */
- (void)setupChatEngineForUser:(NSString *)user;

/**
 * @brief Ensure what \b ChatEngine is ready for test case run.
 *
 * @param chatEngine \b ChatEngine instance for which setup process should be finalyzed.
 */
- (void)completeChatEngineConfiguration:(CENChatEngine *)chatEngine;

/**
 * @brief Retrieve reference on \b ChatEngine which has been created on \c -setUp state for
 * specified \c user.
 *
 * @param user Unique identifier for which separate \b ChatEngine instance has been created before.
 *
 * @return Reference on previously configured \b ChatEngine instance.
 */
- (CENChatEngine *)chatEngineForUser:(NSString *)user;

/**
 * @brief Retrieve reference on \b ChatEngine duplicate which has been created on \c -setUp state
 * for specified \c user for which one instance already exists.
 *
 * @param user Unique identifier for which separate \b ChatEngine instance has been created before.
 *
 * @return Reference on clone of previously configured \b ChatEngine instance.
 */
- (CENChatEngine *)chatEngineCloneForUser:(NSString *)user;


#pragma mark - Connection

/**
 * @brief Connect \c user to ChatEngine network using provided \c client.
 *
 * @discussion Method can be used to wait for connection completion in tests.
 *
 * @note This method will use \c user to generate random \c uuid which will be used as user and
 * authorization key and with state provided through callback (will be used only if configured to
 * use \c global chat).
 *
 * @param user Reference on unique user identifier for which \b ChatEngine instance should be
 *     created and connected.
 * @param client Reference on \b ChatEngine instance which should be used to connect \c user to
 *     real-time network.
 */
- (void)connectUser:(NSString *)user usingClient:(CENChatEngine *)client;

/**
 * @brief Disconnect currently connected user from real-time network.
 *
 * @param client Reference on \b ChatEngine instance which should disconnect user.
 */
- (void)disconnectUserUsingClient:(CENChatEngine *)client;

/**
 * @brief Connect disconnected user back to real-time network.
 *
 * @param client Reference on \b ChatEngine instance which should reconnect user.
 */
- (void)reconnectUserUsingClient:(CENChatEngine *)client;


#pragma mark - State

/**
 * @brief Update local user \c state and wait till operation completion.
 *
 * @param me Reference on local user instance for which state should be changed.
 * @param state Reference on new set of data which should be associated with local user.
 */
- (void)updateState:(NSDictionary *)state forUser:(CENMe *)me;


#pragma mark - Mocking

/**
 * @brief Check whether passed \c object has been mocked before or not.
 *
 * @param object Object which should be checked on whether it has been mocked or not.
 *
 * @return Whether mocked \c object passed or not.
 */
- (BOOL)isObjectMocked:(id)object;

/**
 * @brief Create mock object for class.
 *
 * @param object Reference on object for which mock should be created (class or it's instance).
 *
 * @return Object mock.
 */
- (id)mockForObject:(id)object;


#pragma mark - Chat mocking

/**
 * @brief Stub current \b CENChatEngine instance to call complete user authorization call w/o
 * request to network.
 */
- (void)stubUserAuthorization;

/**
 * @brief Stub current \b CENChatEngine instance to call chat connection callback w/o request to
 * network.
 */
- (void)stubChatConnection;

/**
 * @brief Stub current \b CENChatEngine instance to call chat handshake callback w/o request to
 * network.
 */
- (void)stubChatHandshake;

/**
 * @brief Stub current \b CENChatEngine instance to call PubNub subscription callback w/o request to
 * network.
 */
- (void)stubPubNubSubscribe;

/**
 * @brief Create and configure user feed chat.
 *
 * @param uuid Unique identifier of user for which feed created.
 * @param ableToConnect Whether chat should be able to connect (whether 'connect' method will do
 *     anything) or not.
 * @param chatEngine Reference on \b ChatEngine client instance with which chat should be created.
 *
 * @return Configured and ready to use user feed chat instance.
 */
- (CENChat *)feedChatForUser:(NSString *)uuid
                 connectable:(BOOL)ableToConnect
              withChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure user direct chat.
 *
 * @param uuid Unique identifier of user for which direct created.
 * @param ableToConnect Whether chat should be able to connect (whether 'connect' method will do
 *     anything) or not.
 * @param chatEngine Reference on \b ChatEngine client instance with which chat should be created.
 *
 * @return Configured and ready to use user direct chat instance.
 */
- (CENChat *)directChatForUser:(NSString *)uuid
                   connectable:(BOOL)ableToConnect
                withChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)privateChatWithChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param meta Dictionary with information which should be bound to chat instance.
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)privateChatWithMeta:(nullable NSDictionary *)meta
                      chatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param group One of \b CENChatGroup enum fields which describe scope to which chat belongs.
 *     \b Default: \c CENChatGroup.custom
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)privateChatFromGroup:(nullable NSString *)group
                   withChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 
 * @param group One of \b CENChatGroup enum fields which describe scope to which chat belongs.
 *     \b Default: \c CENChatGroup.custom
 * @param meta Dictionary with information which should be bound to chat instance.
 *     \b Default: @{}
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use private chat representing model.
 */
- (CENChat *)privateChatFromGroup:(nullable NSString *)group
                         withMeta:(nullable NSDictionary *)meta
                       chatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use public chat representing model.
 */
- (CENChat *)publicChatWithChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param meta Dictionary with information which should be bound to chat instance.
 *     \b Default: @{}
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use public chat representing model.
 */
- (CENChat *)publicChatWithMeta:(nullable NSDictionary *)meta
                     chatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param group One of \b CENChatGroup enum fields which describe scope to which chat belongs.
 *     \b Default: \c CENChatGroup.custom
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use public chat representing model.
 */
- (CENChat *)publicChatFromGroup:(nullable NSString *)group
                  withChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Create and configure \c chat instance with random parameters, which can be used for real
 * chats mocking.
 *
 * @param group One of \b CENChatGroup enum fields which describe scope to which chat belongs.
 *     \b Default: \c CENChatGroup.custom
 * @param meta Dictionary with information which should be bound to chat instance.
 *     \b Default: @{}
 * @param chatEngine Reference on \b ChatEngine client instance for which mocking has been done.
 *
 * @return Configured and ready to use public chat representing model.
 */
- (CENChat *)publicChatFromGroup:(nullable NSString *)group
                        withMeta:(nullable NSDictionary *)meta
                  cithChatEngine:(CENChatEngine *)chatEngine;

/**
 * @brief Compose invocation for Chat class constructor.
 *
 * @param isPrivate Reference on flag which specify whether configured for private chat creation or
 *     not.
 * @param mock Reference on mocked chat class object.
 *
 * @return Configured and ready to use invocation object.
 */
- (id)createPrivateChat:(BOOL)isPrivate invocationForClassMock:(id)mock;


#pragma mark - Handlers

/**
 * @brief Wait for recorded (OCMExpect) stub to be called within specified interval. Default
 * interval for success test operation will be used.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 * code.
 */
- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
                afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for recorded (OCMExpect) stub to be called within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 * code.
 */
- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
            withinInterval:(NSTimeInterval)interval
                afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param label Label for executed code which will allow to identify it later in case of failure.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(nullable NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param label Label for executed code which will allow to identify it later in case of failure.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToCompleteIn:(NSTimeInterval)interval
           codeTaskLabel:(nullable NSString *)label
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Listen for event which should be emitted by \c object.
 *
 * @param object Object on which \c event will be listened.
 * @param event Name of event which is expected to be emitted by \c object.
 * @param initialBlock GCD block which contain initialization of code which passed in \c handler.
 */
- (void)object:(CENEventEmitter *)object
    shouldHandleEvent:(NSString *)event
           afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Listen for event which should be emitted by \c object.
 *
 * @param object Object on which \c event will be listened.
 * @param event Name of event which is expected to be emitted by \c object.
 * @param handler GCD block which will be called by test case to get handler for \c event and
 *     provide GCD handler completion block which should be called by handler's code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c handler.
 */
- (void)object:(CENEventEmitter *)object
    shouldHandleEvent:(NSString *)event
          withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
           afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Listen for event which should be emitted by \c object within specified interval.
 *
 * @param object Object on which \c event will be listened.
 * @param event Name of event which is expected to be emitted by \c object.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param handler GCD block which will be called by test case to get handler for \c event and
 *     provide GCD handler completion block which should be called by handler's code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c handler.
 */
- (void)object:(CENEventEmitter *)object
    shouldHandleEvent:(NSString *)event
       withinInterval:(NSTimeInterval)interval
          withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
           afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Listen for set of events which should be emitted by \c object within specified interval.
 *
 * @param object Object on which \c event will be listened.
 * @param events List of event names which is expected to be emitted by \c object.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param handlers List of GCD blocks which will be called by test case to get handler for \c event
 *     and provide GCD handler completion block which should be called by handler's code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c handler.
 */
- (void)object:(CENEventEmitter *)object
    shouldHandleEvents:(NSArray<NSString *> *)events
        withinInterval:(NSTimeInterval)interval
          withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
            afterBlock:(void(^)(void))initialBlock;

/**
 * @brief Expect recorded (OCMExpect) stub not to be called within specified interval. Default
 * interval for failed test operation will be used.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
                   afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Expect recorded (OCMExpect) stub not to be called within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
               withinInterval:(NSTimeInterval)interval
                   afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Wait for code from \c codeBlock to not call completion handler in specified amount of
 * time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 */
- (void)waitToNotCompleteIn:(NSTimeInterval)interval
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock;

/**
 * @brief Wait for code from \c codeBlock to not call completion handler in specified amount of time.
 *
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param codeBlock GCD block which contain tested async code. Block pass completion handler which
 *     should be called by tested code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c codeBlock.
 */
- (void)waitToNotCompleteIn:(NSTimeInterval)interval
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock
                 afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Listen for event which shouldn't be emitted by \c object.
 *
 * @param object Object on which \c event will be listened.
 * @param event Name of event which is not expected to be emitted by \c object.
 * @param handler GCD block which will be called by test case to get handler for \c event and
 *     provide GCD handler completion block which should be called by handler's code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c handler.
 */
- (void)object:(CENEventEmitter *)object
    shouldNotHandleEvent:(NSString *)event
             withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
              afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Listen for event which shouldn't be emitted by \c object within specified interval.
 *
 * @param object Object on which \c event will be listened.
 * @param event Name of event which is not expected to be emitted by \c object.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param handler GCD block which will be called by test case to get handler for \c event and
 *     provide GCD handler completion block which should be called by handler's code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c handler.
 */
- (void)object:(CENEventEmitter *)object
    shouldNotHandleEvent:(NSString *)event
          withinInterval:(NSTimeInterval)interval
             withHandler:(CENEventHandlerBlock (^)(dispatch_block_t handler))handler
              afterBlock:(nullable void(^)(void))initialBlock;

/**
 * @brief Listen for set of events which shouldn't be emitted by \c object within specified
 * interval.
 *
 * @param object Object on which \c event will be listened.
 * @param events List of event names which is not expected to be emitted by \c object.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param handlers List of GCD blocks which will be called by test case to get handler for \c event
 *     and provide GCD handler completion block which should be called by handler's code.
 * @param initialBlock GCD block which contain initialization of code which passed in \c handler.
 */
- (void)object:(CENEventEmitter *)object
  shouldNotHandleEvents:(NSArray<NSString *> *)events
         withinInterval:(NSTimeInterval)interval
           withHandlers:(NSArray<CENEventHandlerBlock (^)(dispatch_block_t handler)> *)handlers
             afterBlock:(void(^)(void))initialBlock;

/**
 * @brief Pause test execution to wait for asynchronous task to complete.
 *
 * @discussion Useful in case of asynchronous block execution and timer based events. This method
 * allow to pause test and wait for specified number of \c seconds.
 *
 * @param taskName Name of task for which we are waiting to complete.
 * @param seconds Number of seconds for which test execution will be postponed to give tested code
 *   time to perform asynchronous actions.
 *
 * @return Reference on expectation object which can be used for fulfillment.
 */
- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds;

/**
 * @brief Wait when global chat of \c client will have expected number of users.
 *
 * @param count How many users expected to get online before test continuation.
 * @param client Reference on \b ChatEngine instance for which test should wait for all users.
 */
- (void)waitForOtherUsers:(NSUInteger)count withClient:(CENChatEngine *)client;

/**
 * @brief Instruct test case to wait for chat \c connection.
 *
 * @discussion Because \c $.connected emitted as soon as communication with PubNub Functions
 * completes, there is a chance to miss events. It is better to wait configuration from PubNub
 * client what local user joined target \c chat.
 */
- (void)waitForOwnOnlineOnChat:(CENChat *)chat;


#pragma mark - Helpers

/**
 * @brief Retrieve object from invocation at specified index and store it till test case completion.
 *
 * @param invocation Invocation which passed by OCMock from which object should be retrieved.
 * @param index Index of parameter in method signature from which value should be retrieved (offset
 *     for self and selector applied internally).
 *
 * @return Object instance passed to method under specified index.
 */
- (id)objectForInvocation:(NSInvocation *)invocation argumentAtIndex:(NSUInteger)index;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
