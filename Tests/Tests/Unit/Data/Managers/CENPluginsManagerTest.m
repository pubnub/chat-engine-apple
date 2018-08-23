/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENObject+PluginsPrivate.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CENPluginsManager.h>
#import <CENChatEngine/CENChat+Private.h>
#import <CENChatEngine/CENUser+Private.h>
#import <CENChatEngine/ChatEngine.h>
#import "CEDummyPlugin.h"
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


#pragma mark Extension for test

@interface CENPluginsManager (TestExtension)


#pragma mark - Information

/**
 * @brief  Stores reference on registered proto plugin(s).
 */
@property (nonatomic, readonly, strong) NSDictionary<NSString *, NSMutableDictionary *> *protoPlugins;

/**
 * @brief  Stores reference on queue which is used to serialize access to shared object information.
 */
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Extension

/**
 * @brief  Retrieve reference on extension by it's plugin identifier for object.
 *
 * @param identifier Unique identifier which has been passed during plugin registration.
 * @param type       Reference on one of supported \b ChatEngine object types which is described in
 *                   \b CENObjectType structure.
 *
 * @return Reference on previously registered \c extension or \c nil in case if it not exists or
 *         invalid data (identifier or unknown object \c type) has been passed.
 */
- (nullable CEPExtension *)extensionWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;

/**
 * @brief      Re-use previously registered extensions for object type.
 * @discussion It it possible repeatedly use same extension instance for different \c object
 *             instances. This method allow to link object with existing \c extension instance.
 *
 * @param extension Reference on previously created extension which should be registered within
 *                  \c object.
 * @param object    Reference on object for which \c extension should be registered.
 * @param group     Plugin registration notification group. Used to notify plugin registration
 *                  completion.
 */
- (void)reuseExtension:(CEPExtension *)extension forObject:(CENObject *)object withRegistrationGroup:(dispatch_group_t)group;


#pragma mark - Middleware

/**
 * @brief  Retrieve reference on middlewares by their plugin identifier for object.
 *
 * @param identifier Unique identifier which has been passed during plugin registration.
 * @param type       Reference on one of supported \b ChatEngine object types which is described in
 *                   \b CENObjectType structure.
 *
 * @return Reference on previously registered \c middlewares or \c nil in case if they don't exists
 *         or invalid data (identifier or unknown object \c type) has been passed.
 */
- (nullable NSArray<CEPMiddleware *> *)middlewaresWithIdentifier:(NSString *)identifier forObjectType:(NSString *)type;

/**
 * @brief      Re-use previously registered middlewares for object type.
 * @discussion It it possible repeatedly use same middleware instances for different \c object
 *             instances. This method allow to link object with existing \c middleware instances.
 *
 * @param middlewares         Reference on previously created middlewares which should be registered within \c object.
 * @param object              Reference on object for which \c middlewares should be registered.
 * @param shouldBeFirstInList Whether middleware should be placed first in list of middlewares (processed first) or not.
 * @param group               Plugin registration notification group. Used to notify plugin registration completion.
 */
- (void)reuseMiddlewares:(NSArray<CEPMiddleware *> *)middlewares
               forObject:(CENObject *)object
             firstInList:(BOOL)shouldBeFirstInList
   withRegistrationGroup:(dispatch_group_t)group;

/**
 * @brief      Provide context for \c middleware so it can be used for \c object.
 * @discussion Because \c middleware properties storage separated from it (so \c middleware itself
 *             can be used for many different \c objects) it require storage configuration before it
 *             can be used with target \c object.
 *
 * @param middleware Reference on \c middleware for which excution context should be provided.
 * @param object     Reference on object for which \c middleware will be called and execution context
 *                   provided.
 * @param block      Reference on block which will be called when execution context will be ready.
 *                   Block pass only one argument - reference on \c middleware which can be used.
 */
- (void)useMiddleware:(CEPMiddleware *)middleware withObject:(CENObject *)object context:(void(^)(CEPMiddleware *middleware))block;


#pragma mark - Plugins management

/**
 * @brief      Register \b ChatEngine plugin for \c object.
 * @discussion Retrieve middlewares list and extension to register them for \c object.
 *
 * @param plugin              Reference on \b ChatEngine plugin which may contain \c object extension and middlewares.
 * @param object              Reference on object for which plugin should be registered.
 * @param shouldBeFirstInList Whether plugin's middlewares should be placed first in list of middlewares (processed first) or not.
 * @param group               Plugin registration notification group. Used to notify plugin registration completion.
 *
 * @return \c YES in case if plugin can be registered and \c NO in case if plugin with same
 *         identifier but different configuration already registred (in this case it can be
 *         registered with different \c identifier passed to plugin constructor).
 */
- (BOOL)registerProto:(BOOL)isProto
               plugin:(CEPPlugin *)plugin
            forObject:(CENObject *)object
          firstInList:(BOOL)shouldBeFirstInList
withRegistrationGroup:(dispatch_group_t)group;


#pragma mark - Proto plugins management

/**
 * @brief  Check whether there is proto plugin registered with specified \c identifier and
 *         \c configuration.
 *
 * @param identifier    Reference on unique plugin identifier which should be used for search in
 *                      \c type proto plugins list.
 * @param configuration Reference on plugin's configuration which has been passed during
 *                      registration.
 *
 * @return \c YES in case if plugin with specified \c identifier and \c configuration already
 *         registered or \c NO in case if unknown data type has been passed.
 */
- (BOOL)hasProtoPluginWithIdentifier:(NSString *)identifier configuration:(NSDictionary *)configuration;

#pragma mark -


@end


@interface CENPluginsManagerTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, weak) CENChatEngine *client;
@property (nonatomic, nullable, weak) CENChatEngine *clientMock;
@property (nonatomic, nullable, strong) CENPluginsManager *manager;


#pragma mark - Misc

/**
 * @brief      Access manager's data in thread-safe way.
 * @discussion This is small 'hack' by use of private queue to get access to resources.
 *
 * @param block Reference on block which should be executed while on private queue.
 */
- (void)threadSafeManagerDataAccessWith:(dispatch_block_t)block;

#pragma mark -


@end



@implementation CENPluginsManagerTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    CENConfiguration *configuration = [CENConfiguration configurationWithPublishKey:@"test-36" subscribeKey:@"test-36"];
    configuration.throwExceptions = YES;
    self.client = [self chatEngineWithConfiguration:configuration];
    self.clientMock = [self partialMockForObject:self.client];
    
    self.manager = [CENPluginsManager managerForChatEngine:self.client];
    
    OCMStub([self.clientMock fetchParticipantsForChat:[OCMArg any]]).andDo(nil);
}

- (void)tearDown {
    
    CEDummyPlugin.middlewareLocationClasses = nil;
    CEDummyPlugin.classesWithExtensions = nil;
    
    [self.manager destroy];
    self.manager = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShoulThrowException_WhenInstanceCreatedWithNew {
    
    XCTAssertThrowsSpecificNamed([CENPluginsManager new], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: registerProtoPlugin

- (void)testRegisterProtoPlugin_ShouldRegister {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL checkHasBeenDone = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    
    [self threadSafeManagerDataAccessWith:^{
        checkHasBeenDone = YES;
        
        XCTAssertTrue([self.manager hasProtoPluginWithIdentifier:identifier configuration:nil]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    
    XCTAssertTrue(checkHasBeenDone, @"It took too long to access manager's data and proper check not completed.");
}

- (void)testRegisterProtoPlugin_ShouldThrowException_WhenNonPluginSubclassPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[NSArray class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrowException_WhenUnknownObjectTypePassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"PubNub"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrowException_WhenNonNSStringIdentifierPassed {
    
    NSString *identifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrowException_WhenNilIdentifierPassed {
    
    NSString *identifier = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrowException_WhenEmptyIdentifierPassed {
    
    NSString *identifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldReturnFalse_WhenNonNSDictionaryConfigurationPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:(id)[NSArray class] forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: hasProtoPluginWithIdentifier

- (void)testHasProtoPluginWithIdentifier_ShouldReturnTrue_WhenProtoWithSpecifiedIdentifierRegistered {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    
    XCTAssertTrue([self.manager hasProtoPluginWithIdentifier:identifier forObjectType:@"Chat"]);
}

- (void)testHasProtoPluginWithIdentifier_ShouldReturnFalse_WhenProtoWithSpecifiedIdentifierNotRegistered {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    
    XCTAssertFalse([self.manager hasProtoPluginWithIdentifier:[identifier stringByAppendingString:@"2"] forObjectType:@"Chat"]);
}

- (void)testHasProtoPluginWithIdentifier_ShouldThrowException_WhenNonNSStringNilIdentifierPassed {
    
    NSString *searchIdentifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:searchIdentifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasProtoPluginWithIdentifier_ShouldReturnFalse_WhenNilIdentifierPassed {
    
    NSString *searchIdentifier = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:searchIdentifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasProtoPluginWithIdentifier_ShouldReturnFalse_WhenEmptyIdentifierPassed {
    
    NSString *searchIdentifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:searchIdentifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasProtoPluginWithIdentifier_ShouldReturnFalse_WhenUnknownObjectTypePassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:identifier forObjectType:@"PubNub"],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: setupProtoPluginsForObject

- (void)testSetupProtoPluginsForObject_ShouldCreateExtension_WhenProtoPluginRegisteredForSameObjectType {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL extensionRequested = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    
    [self.manager setupProtoPluginsForObject:chat withCompletion:^{
        [self threadSafeManagerDataAccessWith:^{
            extensionRequested = YES;
            
            XCTAssertNotNil([self.manager extensionWithIdentifier:identifier forObjectType:@"Chat"]);
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(extensionRequested, @"It took too long to get execution context for extension.");
}

- (void)testSetupProtoPluginsForObject_ShouldNotCreateExtension_WhenProtoPluginRegisteredForDifferentObjectType {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL extensionRequested = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"User"];
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    
    [self.manager setupProtoPluginsForObject:chat withCompletion:^{
        [self threadSafeManagerDataAccessWith:^{
            extensionRequested = YES;
            
            XCTAssertNil([self.manager extensionWithIdentifier:identifier forObjectType:@"Chat"]);
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(extensionRequested, @"It took too long to get execution context for extension.");
}

- (void)testSetupProtoPluginsForObject_ShouldNotSetupPlugin_WhenUknownObjectPassed {
    
    XCTAssertThrowsSpecificNamed([self.manager setupProtoPluginsForObject:(id)@2010 withCompletion:^{}], NSException,
                                 NSInvalidArgumentException);
}

- (void)testSetupProtoPluginsForObject_ShouldCreateMiddleware_WhenProtoPluginRegisteredForRegisteredMiddlewareLocation {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL middlewareRequested = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    
    [self.manager setupProtoPluginsForObject:chat withCompletion:^{
        [self threadSafeManagerDataAccessWith:^{
            middlewareRequested = YES;
            
            XCTAssertNotNil([self.manager middlewaresWithIdentifier:identifier forObjectType:@"Chat"]);
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(middlewareRequested, @"It took too long to get execution context for extension.");
}

- (void)testSetupProtoPluginsForObject_ShouldNotCreateMiddleware_WhenProtoPluginRegisteredForDifferentMiddlewareLocation {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL middlewareRequested = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"User"];
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    
    [self.manager setupProtoPluginsForObject:chat withCompletion:^{
        [self threadSafeManagerDataAccessWith:^{
            middlewareRequested = YES;
            
            XCTAssertNil([self.manager middlewaresWithIdentifier:identifier forObjectType:@"Chat"]);
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(middlewareRequested, @"It took too long to get execution context for extension.");
}


#pragma mark - Tests :: unregisterProtoPluginWithIdentifier

- (void)testUnregisterProtoPluginWithIdentifier_ShouldRemoveProtoPlugin_WhenNotAppliedToAnyObjects {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL unregisterRequest = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];

    [self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"];
    [self threadSafeManagerDataAccessWith:^{
        unregisterRequest = YES;
        
        XCTAssertFalse([self.manager hasProtoPluginWithIdentifier:identifier configuration:nil]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(unregisterRequest, @"It took too long to unregister proto plugin.");
}

- (void)testUnregisterProtoPluginWithIdentifier_ShouldRemoveProtoPlugin_WhenThereIsObjectsWhichUseIt {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL unregisterRequest = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    
    [self.manager setupProtoPluginsForObject:chat withCompletion:^{
        [self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"];
        
        [self threadSafeManagerDataAccessWith:^{
            unregisterRequest = YES;
            
            XCTAssertFalse([self.manager hasProtoPluginWithIdentifier:identifier configuration:nil]);
            dispatch_semaphore_signal(semaphore);
        }];
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(unregisterRequest, @"It took too long to unregister proto plugin.");
}

- (void)testUnregisterProtoPluginWithIdentifier_ShouldThrowExpection_WhenNilIdentifierPassed {
    
    NSString *identifier = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testUnregisterProtoPluginWithIdentifier_ShouldThrowExpection_WhenNotNSStringIdentifierPassed {
    
    NSString *identifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testUnregisterProtoPluginWithIdentifier_ShouldThrowExpection_WhenEmptyIdentifierPassed {
    
    NSString *identifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testUnregisterProtoPluginWithIdentifier_ShouldThrowExpection_WhenUnknownObjectTypePassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"PubNub"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testUnregisterProtoPluginWithIdentifier_ShouldNotRemoveProtoPlugin_WhenThereIsAnotherObjectsWhichUseIt {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL unregisterRequest = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"User"];
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CENUser *user = [CENUser userWithUUID:@"test" state:@{} chatEngine:self.client];
    
    [self.manager setupProtoPluginsForObject:chat withCompletion:^{
        [self.manager setupProtoPluginsForObject:user withCompletion:^{
            [self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"];
            
            [self threadSafeManagerDataAccessWith:^{
                unregisterRequest = YES;
                
                XCTAssertTrue([self.manager hasProtoPluginWithIdentifier:identifier configuration:nil]);
                dispatch_semaphore_signal(semaphore);
            }];
        }];
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(unregisterRequest, @"It took too long to unregister proto plugin.");
}

#pragma mark - Tests :: registerPlugin

- (void)testRegisterPlugin_ShouldRegisterPlugin_WhenNoProtoPluginAvailable {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;
    
    id managerPartialMock = [self partialMockForObject:self.manager];
    OCMExpect([managerPartialMock registerProto:NO plugin:[OCMArg any] forObject:chat firstInList:NO withRegistrationGroup:[OCMArg any]])
        .andForwardToRealObject();
    
    BOOL registered = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                                       firstInList:NO completion:^{
                                           
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(registered);
    OCMVerifyAll(managerPartialMock);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldRegisterUsingProtoPlugin_WhenProtoPluginAvailable {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    
    id managerPartialMock = [self partialMockForObject:self.manager];
    OCMExpect([managerPartialMock registerProto:YES plugin:[OCMArg any] forObject:chat firstInList:NO withRegistrationGroup:[OCMArg any]])
        .andForwardToRealObject();
    
    BOOL registered = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                                       firstInList:NO completion:^{
                                           
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(registered);
    OCMVerifyAll(managerPartialMock);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldRegisterPlugin_WhenProtoPluginHasDifferentConfiguration {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:@{ @"proto": @"configuration" } forObjectType:@"Chat"];
    
    id managerPartialMock = [self partialMockForObject:self.manager];
    OCMExpect([managerPartialMock registerProto:NO plugin:[OCMArg any] forObject:chat firstInList:NO withRegistrationGroup:[OCMArg any]])
        .andForwardToRealObject();
    
    BOOL registered = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                     configuration:@{ @"instance": @"configuration" } forObject:chat firstInList:NO completion:^{
                                         
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(registered);
    OCMVerifyAll(managerPartialMock);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldRegisterExtensionForAnotherObject_WhenPluginHasBeenRegisteredWithObject {
    
    CENChat *chat1 = [CENChat chatWithName:@"test1" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CENChat *chat2 = [CENChat chatWithName:@"test2" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSDictionary *configuration = @{ @"instance": @"configuration" };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:configuration forObject:chat1 firstInList:NO
                      completion:nil];
    
    id managerPartialMock = [self partialMockForObject:self.manager];
    OCMExpect([managerPartialMock reuseExtension:[OCMArg any] forObject:chat2 withRegistrationGroup:[OCMArg any]]).andForwardToRealObject();
    
    BOOL registered = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:configuration forObject:chat2
                                       firstInList:NO completion:^{
                                           
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(registered);
    OCMVerifyAll(managerPartialMock);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldRegisterMiddlewaresForAnotherObject_WhenPluginHasBeenRegisteredWithObject {
    
    CENChat *chat1 = [CENChat chatWithName:@"test1" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CENChat *chat2 = [CENChat chatWithName:@"test2" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;
    NSDictionary *configuration = nil;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:configuration forObject:chat1 firstInList:NO
                      completion:nil];
    
    id managerPartialMock = [self partialMockForObject:self.manager];
    OCMExpect([managerPartialMock reuseExtension:[OCMArg any] forObject:chat2 withRegistrationGroup:[OCMArg any]]).andForwardToRealObject();
    
    BOOL registered = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:configuration forObject:chat2
                                       firstInList:NO completion:^{
                                             
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(registered);
    OCMVerifyAll(managerPartialMock);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldNotRegisterExstencions_WhenObjectAlreadyHasSamePluginWithDifferentConfiguration {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;
    
    BOOL registeredFirstTime = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                              configuration:@{ @"instance1": @"configuration" } forObject:chat firstInList:NO completion:nil];
    BOOL registeredSecondTime = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                               configuration:@{ @"instance2": @"configuration" } forObject:chat firstInList:NO completion:^{
                                                   
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(registeredFirstTime);
    XCTAssertFalse(registeredSecondTime);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldNotRegisterMiddlewares_WhenObjectAlreadyHasSamePluginWithSameConfiguration {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    NSDictionary *configuration = @{ @"instance": @"configuration" };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;

    BOOL registeredFirstTime = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:configuration
                                                  forObject:chat firstInList:NO completion:nil];
    BOOL registeredSecondTime = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:configuration
                                                   forObject:chat firstInList:NO completion:^{
                                                       
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(registeredFirstTime);
    XCTAssertFalse(registeredSecondTime);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldNotRegisterMiddlewares_WhenObjectAlreadyHasSamePluginWithDifferentConfiguration {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL registerRequested = NO;
    
    BOOL registeredFirstTime = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                              configuration:@{ @"instance1": @"configuration" } forObject:chat firstInList:NO completion:nil];
    BOOL registeredSecondTime = [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                               configuration:@{ @"instance2": @"configuration" } forObject:chat firstInList:NO completion:^{
                                                   
        registerRequested = YES;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    
    XCTAssertTrue(registeredFirstTime);
    XCTAssertFalse(registeredSecondTime);
    XCTAssertTrue(registerRequested, @"It took too long to register plugin for object.");
}

- (void)testRegisterPlugin_ShouldThrowException_WhenNonPluginSubclassPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[NSArray class] withIdentifier:identifier configuration:nil forObject:chat
                                                  firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}
- (void)testRegisterPlugin_ShouldThrowException_WhenUnknownObjectPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil
                                                    forObject:(id)[NSArray new] firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrowException_WhenNonNSStringIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                                                  firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrowException_WhenNilIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                                                  firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrowException_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                                                  firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrowException_WhenNonNSdictionaryConfigurationPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:(id)[NSNumber class]
                                                  forObject:chat firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: hasPluginWithIdentifier

- (void)testHasPluginWithIdentifier_ShouldReturnTrue_WhenProtoWithSpecifiedIdentifierRegistered {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    NSString *identifier = CEDummyPlugin.identifier;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO completion:nil];
    
    XCTAssertTrue([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
}

- (void)testHasPluginWithIdentifier_ShouldReturnFalse_WhenProtoWithSpecifiedIdentifierNotRegistered {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    NSString *identifier = CEDummyPlugin.identifier;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO completion:nil];
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:[identifier stringByAppendingString:@"2"] forObject:chat]);
}

- (void)testHasPluginWithIdentifier_ShouldThrowException_WhenNonNSStringNilIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *searchIdentifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:chat],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasPluginWithIdentifier_ShouldReturnFalse_WhenNilIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *searchIdentifier = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:chat],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasPluginWithIdentifier_ShouldReturnFalse_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *searchIdentifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:chat],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasPluginWithIdentifier_ShouldReturnFalse_WhenUnknownObjectPassed {
    
    NSString *searchIdentifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:(id)[NSArray new]],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: unregisterObjects

- (void)testUnregisterObjects_ShouldRemovedPlugin_WhenPluginWithIdentifierRegistered {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    NSString *identifier = CEDummyPlugin.identifier;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO completion:nil];
    
    [self.manager unregisterObjects:chat pluginWithIdentifier:identifier];
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
}

- (void)testUnregisterObjects_ShouldRemovedPlugin_WhenProvidedByProtoPlugin {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier = CEDummyPlugin.identifier;
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    [self.manager setupProtoPluginsForObject:chat withCompletion:^{
        [self.manager unregisterObjects:chat pluginWithIdentifier:identifier];
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
    XCTAssertTrue([self.manager hasProtoPluginWithIdentifier:identifier configuration:nil]);
}

- (void)testUnregisterObjects_ShouldNotRemovedPlugin_WhenRegisteredWithDifferentIdentifiers {
    
    CENChat *chat1 = [CENChat chatWithName:@"test1" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CENChat *chat2 = [CENChat chatWithName:@"test2" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier1 = CEDummyPlugin.identifier;
    NSString *identifier2 = [identifier1 stringByAppendingString:@"2"];
    __block BOOL storageResetCalled = NO;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObject:chat1 firstInList:NO
                      completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier2 configuration:nil forObject:chat1 firstInList:NO
                      completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObject:chat2 firstInList:NO
                      completion:nil];
    
    id partialChatMock = [self partialMockForObject:chat2];
    OCMStub([partialChatMock invalidateMiddlewareProperties:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        storageResetCalled = YES;
    });
    
    [self.manager unregisterObjects:chat2 pluginWithIdentifier:identifier2];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25f * NSEC_PER_SEC)));
    
    XCTAssertTrue([self.manager hasPluginWithIdentifier:identifier1 forObject:chat1]);
    XCTAssertTrue([self.manager hasPluginWithIdentifier:identifier2 forObject:chat1]);
    XCTAssertFalse(storageResetCalled);
}

- (void)testUnregisterObjects_ShouldThrowException_WhenNonNSStringIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *searchIdentifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:chat pluginWithIdentifier:searchIdentifier],
                                 NSException, NSInvalidArgumentException);
}

- (void)testUnregisterObjects_ShouldReturnFalse_WhenNilIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *searchIdentifier = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:chat pluginWithIdentifier:searchIdentifier],
                                 NSException, NSInvalidArgumentException);
}

- (void)testUnregisterObjects_ShouldReturnFalse_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *searchIdentifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:chat pluginWithIdentifier:searchIdentifier],
                                 NSException, NSInvalidArgumentException);
}

- (void)testUnregisterObjects_ShouldReturnFalse_WhenUnknownObjectPassed {
    
    NSString *searchIdentifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:(id)[NSArray new] pluginWithIdentifier:searchIdentifier],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: unregisterAllFromObjects

- (void)testUnregisterAllFromObjects_ShouldRemovedPlugin_WhenPluginWithIdentifierRegistered {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO completion:nil];
    
    [self.manager unregisterAllFromObjects:chat];
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
}

- (void)testUnregisterAllFromObjects_ShouldThrowException_WhenUnknownObjectPassed {
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterAllFromObjects:(id)[NSArray new]], NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: extensionForObject

- (void)testExtensionForObject_ShouldReceiveExtensionExecutionContext_WhenPluginRegisteredForObject {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL extensionRequest = NO;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO completion:nil];
    [self.manager extensionForObject:chat withIdentifier:identifier context:^(CEPExtension *extension) {
        extensionRequest = YES;
        
        XCTAssertNotNil(extension);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(extensionRequest, @"It took too long to get execution context for extension.");
}

- (void)testExtensionForObject_ShouldNotReceiveExtensionExecutionContext_WhenUsedNotRegisteredPluginIdentifier {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL extensionRequest = NO;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO completion:nil];
    [self.manager extensionForObject:chat withIdentifier:[identifier stringByAppendingString:@"2"] context:^(CEPExtension *extension) {
        extensionRequest = YES;
        
        XCTAssertNil(extension);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(extensionRequest, @"It took too long to get execution context for extension.");
}

- (void)testExtensionForObject_ShouldContextPreserveData_WhenPluginRegisteredForFewObject {
    
    CENChat *chat1 = [CENChat chatWithName:@"test1" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CENChat *chat2 = [CENChat chatWithName:@"test2" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    __block BOOL extensionRequest = NO;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat1 firstInList:NO
                      completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat2 firstInList:NO
                      completion:nil];
    [self.manager extensionForObject:chat1 withIdentifier:identifier context:^(CEPExtension *extension) {
        ((CEDummyExtension *)extension).constructWorks = NO;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    
    [self.manager extensionForObject:chat2 withIdentifier:identifier context:^(CEPExtension *extension) {
        extensionRequest = YES;
        
        XCTAssertTrue(((CEDummyExtension *)extension).constructWorks);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(extensionRequest, @"It took too long to get execution context for extension.");
}

- (void)testExtensionForObject_ShouldThrowException_WhenNonNSStringNilIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:chat withIdentifier:identifier context:^(CEPExtension *extension) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testExtensionForObject_ShouldThrowException_WhenNilIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:chat withIdentifier:identifier context:^(CEPExtension *extension) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testExtensionForObject_ShouldThrowException_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSString *identifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:chat withIdentifier:identifier context:^(CEPExtension *extension) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testExtensionForObject_ShouldThrowException_WhenUnknownObjectPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:(id)[NSArray new] withIdentifier:identifier context:^(CEPExtension *extension) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testExtensionForObject_ShouldThrowException_WhenNilBlockPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    void(^handleBlock)(CEPExtension *) = nil;
    NSString *identifier = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:chat withIdentifier:identifier context:handleBlock],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: runMiddlewaresAtLocation

- (void)testRunMiddlewaresAtLocation_ShouldRunMiddleware_WhenRegisteredPluginWithMiddlewares {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"payload" }];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSString *identifier1 = CEDummyPlugin.identifier;
    NSString *identifier2 = [CEDummyPlugin.identifier stringByAppendingString:@"2"];
    __block BOOL middlewareRequest = NO;
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier2 configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    
    [self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on forEvent:@"test" object:chat withPayload:payload
                                completion:^(BOOL rejected, NSMutableDictionary *data) {
        middlewareRequest = YES;
        
        XCTAssertNotNil(data[@"broadcast"]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.testCompletionDelay * NSEC_PER_SEC)));
    XCTAssertTrue(middlewareRequest, @"It took too long to get execution context for middleware.");
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenNonNSStringEventPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *event = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:event
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenNilEventPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *event = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:event
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldNotThrowException_WhenNilPayloadPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = nil;
    
    XCTAssertNoThrow([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                   forEvent:@"chat"
                                                     object:chat
                                                withPayload:payload
                                                 completion:^(BOOL rejected, id data) {}]);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenEmptyEventPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *event = @"";
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:event
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenNilLocationPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *location = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:location
                                                               forEvent:@"test"
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenUnknownLocationPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *location = @"PubNub";
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:location
                                                               forEvent:@"test"
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenUnknownObjectPassed {
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:@"test"
                                                                 object:(id)[NSArray new]
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenNilBlockPassed {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    void(^handleBlock)(BOOL, id) = nil;
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:@"test"
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:handleBlock],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: destroy

- (void)testDestroy_ShouldUnregisterPluginForObject {
    
    CENChat *chat = [CENChat chatWithName:@"test" namespace:@"test" group:CENChatGroup.custom private:NO metaData:@{} chatEngine:self.client];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    CENPluginsManager *manager = [CENPluginsManager managerForChatEngine:self.client];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    [manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO completion:nil];
    
    id managerPartialMock = [self partialMockForObject:manager];
    OCMExpect([managerPartialMock unregisterAllFromObjects:chat]).andForwardToRealObject();
    
    [manager destroy];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)));
    OCMVerifyAll(managerPartialMock);
}


#pragma mark - Misc

- (void)threadSafeManagerDataAccessWith:(dispatch_block_t)block {
    
    dispatch_async(self.manager.resourceAccessQueue, block);
}

#pragma mark -


@end
