/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENChatEngine+ChatPrivate.h>
#import <CENChatEngine/CENObject+PluginsPrivate.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENChatEngine+Private.h>
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

@property (nonatomic, nullable, strong) NSDictionary<NSString *, NSMutableDictionary *> *protoPlugins;
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSMutableArray *> *middlewares;
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *extensions;
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSHashTable *> *objects;
@property (nonatomic, strong) dispatch_queue_t resourceAccessQueue;


#pragma mark - Plugins management

- (void)registerPlugin:(CEPPlugin *)plugin forObject:(CENObject *)object firstInList:(BOOL)shouldBeFirstInList
 withRegistrationGroup:(dispatch_group_t)group;


#pragma mark - Middleware

- (nullable NSArray<CEPMiddleware *> *)middlewaresForObject:(CENObject *)object atLocation:(NSString *)location
                                                   forEvent:(NSString *)event;

#pragma mark -


@end


@interface CENPluginsManagerTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENPluginsManager *manager;


#pragma mark - Misc

- (void)threadSafeManagerDataAccessWith:(dispatch_block_t)block;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENPluginsManagerTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {
    
    return YES;
}

- (BOOL)shouldSetupVCR {

    return NO;
}

- (BOOL)shouldThrowExceptionForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];

    
    self.manager = [CENPluginsManager managerForChatEngine:self.client];

    XCTAssertTrue([self isObjectMocked:self.client]);

    OCMStub([self.client pluginsManager]).andReturn(self.manager);
}

- (void)tearDown {
    
    CEDummyPlugin.middlewareLocationClasses = nil;
    CEDummyPlugin.classesWithExtensions = nil;
    
    [self.manager destroy];
    self.manager = nil;
    
    [super tearDown];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldCreateInstance {
    
    XCTAssertNotNil(self.manager);
}

- (void)testConstructor_ShouldThrowException_WhenInstanceCreatedWithNew {
    
    XCTAssertThrowsSpecificNamed([CENPluginsManager new], NSException, NSDestinationInvalidException);
}


#pragma mark - Tests :: registerProtoPlugin

- (void)testRegisterProtoPlugin_ShouldRegister {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    
    XCTAssertTrue([self.manager hasProtoPluginWithIdentifier:identifier forObjectType:@"Chat"]);
}

- (void)testRegisterProtoPlugin_ShouldUnregisterOldProtoPlugin {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    id managerMock = [self mockForObject:self.manager];
    id recorded = OCMExpect([managerMock unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil
                            forObjectType:@"Chat"];
    }];
}

- (void)testRegisterProtoPlugin_ShouldThrow_WhenNonPluginSubclassPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[NSArray class] withIdentifier:identifier configuration:nil
                                                     forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrow_WhenUnknownObjectTypePassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                                     configuration:nil forObjectType:@"PubNub"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrow_WhenNonNSStringIdentifierPassed {
    
    NSString *identifier = (id)@2010;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                                     configuration:nil forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrow_WhenNilIdentifierPassed {
    
    NSString *identifier = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                                     configuration:nil forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrow_WhenEmptyIdentifierPassed {
    
    NSString *identifier = @"";
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                                     configuration:nil forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterProtoPlugin_ShouldThrow_WhenNonNSDictionaryConfigurationPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                                     configuration:(id)[NSArray class] forObjectType:@"Chat"],
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

- (void)testHasProtoPluginWithIdentifier_ShouldThrow_WhenNonNSStringNilIdentifierPassed {
    
    NSString *searchIdentifier = (id)@2010;
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:searchIdentifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasProtoPluginWithIdentifier_ShouldThrow_WhenNilIdentifierPassed {
    
    NSString *searchIdentifier = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:searchIdentifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasProtoPluginWithIdentifier_ShouldThrow_WhenEmptyIdentifierPassed {
    
    NSString *searchIdentifier = @"";
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:searchIdentifier forObjectType:@"Chat"],
                                 NSException, NSInvalidArgumentException);
}

- (void)testHasProtoPluginWithIdentifier_ShouldThrow_WhenUnknownObjectTypePassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasProtoPluginWithIdentifier:identifier forObjectType:@"PubNub"],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: setupProtoPluginsForObject

- (void)testSetupProtoPluginsForObject_ShouldRegisterPluginInstance_WhenCreatedObjectOfSpecifiedType {
    
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    id managerMock = [self mockForObject:self.manager];
    id recorded = OCMExpect([managerMock registerPlugin:[OCMArg any] forObject:chat firstInList:NO
                                  withRegistrationGroup:[OCMArg any]]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager setupProtoPluginsForObject:chat withCompletion:^{
            
        }];
    }];
}

- (void)testSetupProtoPluginsForObject_ShouldCreateExtension_WhenProtoPluginRegisteredForSameObjectType {
    
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager setupProtoPluginsForObject:chat withCompletion:^{
            id extension = [self.manager extensionForObject:chat withIdentifier:identifier];
            
            XCTAssertNotNil(extension);
            handler();
        }];
    }];
}

- (void)testSetupProtoPluginsForObject_ShouldNotCreateExtension_WhenProtoPluginRegisteredForDifferentObjectType {
    
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"User"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager setupProtoPluginsForObject:chat withCompletion:^{
            id extension = [self.manager extensionForObject:chat withIdentifier:identifier];
            
            XCTAssertNil(extension);
            handler();
        }];
    }];
}

- (void)testSetupProtoPluginsForObject_ShouldThrow_WhenUknownObjectPassed {
    
    XCTAssertThrowsSpecificNamed([self.manager setupProtoPluginsForObject:(id)@2010 withCompletion:^{}], NSException,
                                 NSInvalidArgumentException);
}

- (void)testSetupProtoPluginsForObject_ShouldCreateMiddleware_WhenProtoPluginRegisteredForRegisteredMiddlewareLocation {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    CEDummyPlugin.middlewareLocationEvents = @{ CEPMiddlewareLocation.on: @[@"event"] };
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager setupProtoPluginsForObject:chat withCompletion:^{
            [self threadSafeManagerDataAccessWith:^{
                XCTAssertNotNil([self.manager middlewaresForObject:chat atLocation:CEPMiddlewareLocation.on forEvent:@"event"]);
                handler();
            }];
        }];
    }];
}

- (void)testSetupProtoPluginsForObject_ShouldNotCreateMiddleware_WhenProtoPluginRegisteredForDifferentMiddlewareLocation {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    CEDummyPlugin.middlewareLocationEvents = @{ CEPMiddlewareLocation.on: @[@"event"] };
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager setupProtoPluginsForObject:chat withCompletion:^{
            [self threadSafeManagerDataAccessWith:^{
                XCTAssertNil([self.manager middlewaresForObject:chat atLocation:CEPMiddlewareLocation.emit forEvent:@"event"]);
                handler();
            }];
        }];
    }];
}


#pragma mark - Tests :: unregisterProtoPluginWithIdentifier

- (void)testUnregisterProtoPluginWithIdentifier_ShouldRemoveProtoPlugin_WhenNotAppliedToAnyObjects {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    CEDummyPlugin.middlewareLocationEvents = @{ CEPMiddlewareLocation.on: @[@"event"] };
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];

    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager setupProtoPluginsForObject:chat withCompletion:^{
            handler();
        }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self threadSafeManagerDataAccessWith:^{
            XCTAssertNotNil([self.manager middlewaresForObject:chat atLocation:CEPMiddlewareLocation.on forEvent:@"event"]);
            handler();
        }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        id extension = [self.manager extensionForObject:chat withIdentifier:identifier];
        XCTAssertNotNil(extension);
        handler();
    }];
    
    [self.manager unregisterProtoPluginWithIdentifier:identifier forObjectType:@"Chat"];
    
    XCTAssertFalse([self.manager hasProtoPluginWithIdentifier:identifier forObjectType:@"Chat"]);
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self threadSafeManagerDataAccessWith:^{
            XCTAssertNil([self.manager middlewaresForObject:chat atLocation:CEPMiddlewareLocation.emit forEvent:@"event"]);
            handler();
        }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        id extension = [self.manager extensionForObject:chat withIdentifier:identifier];
        
        XCTAssertNil(extension);
        handler();
    }];
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


#pragma mark - Tests :: registerPlugin

- (void)testRegisterPlugin_ShouldRegisterPluginForObject {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    CEDummyPlugin.middlewareLocationEvents = @{ CEPMiddlewareLocation.on: @[@"event"] };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                         firstInList:NO completion:^{
                             handler();
                         }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self threadSafeManagerDataAccessWith:^{
            XCTAssertNotNil([self.manager middlewaresForObject:chat atLocation:CEPMiddlewareLocation.on forEvent:@"event"]);
            handler();
        }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        id extension = [self.manager extensionForObject:chat withIdentifier:identifier];
        XCTAssertNotNil(extension);
        handler();
    }];
}

- (void)testRegisterPlugin_ShouldPlacePluginFirstInList_WhenCorrespondingFlagIsSet {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    CEDummyPlugin.middlewareLocationEvents = @{ CEPMiddlewareLocation.on: @[@"event"] };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                         firstInList:YES completion:^{
                             handler();
                         }];
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self threadSafeManagerDataAccessWith:^{
            XCTAssertTrue([self.manager.middlewares[chat.identifier].firstObject isKindOfClass:[CEDummyOnMiddleware class]]);
            handler();
        }];
    }];
}

- (void)testRegisterPlugin_ShouldUnregisterPreviousPlugin {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    id managerMock = [self mockForObject:self.manager];
    id recorded = OCMExpect([managerMock unregisterObjects:chat pluginWithIdentifier:identifier]);
    [self waitForObject:managerMock recordedInvocationCall:recorded afterBlock:^{
        [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat
                         firstInList:NO completion:nil];
    }];
}

- (void)testRegisterPlugin_ShouldThrow_WhenNonPluginSubclassPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[NSArray class] withIdentifier:identifier configuration:nil
                                                    forObject:chat firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}
- (void)testRegisterPlugin_ShouldThrow_WhenUnknownObjectPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil
                                                    forObject:(id)[NSArray new] firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrowException_WhenNonNSStringIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = (id)@2010;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil
                                                    forObject:chat firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrow_WhenNilIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil
                                                    forObject:chat firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrow_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = @"";
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil
                                                    forObject:chat firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRegisterPlugin_ShouldThrow_WhenNonNSdictionaryConfigurationPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier
                                                configuration:(id)[NSNumber class] forObject:chat firstInList:NO completion:nil],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: hasPluginWithIdentifier

- (void)testHasPluginWithIdentifier_ShouldReturnTrue_WhenPluginWithSpecifiedIdentifierRegistered {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    
    XCTAssertTrue([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
}

- (void)testHasPluginWithIdentifier_ShouldReturnFalse_WhenPluginWithSpecifiedIdentifierNotRegistered {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:[identifier stringByAppendingString:@"2"] forObject:chat]);
}

- (void)testHasPluginWithIdentifier_ShouldThrow_WhenNonNSStringNilIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *searchIdentifier = (id)@2010;
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:chat], NSException,
                                 NSInvalidArgumentException);
}

- (void)testHasPluginWithIdentifier_ShouldThrow_WhenNilIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *searchIdentifier = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:chat], NSException,
                                 NSInvalidArgumentException);
}

- (void)testHasPluginWithIdentifier_ShouldThrow_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *searchIdentifier = @"";
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:chat], NSException,
                                 NSInvalidArgumentException);
}

- (void)testHasPluginWithIdentifier_ShouldThrow_WhenUnknownObjectPassed {
    
    NSString *searchIdentifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager hasPluginWithIdentifier:searchIdentifier forObject:(id)[NSArray new]],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: unregisterObjects

- (void)testUnregisterObjects_ShouldRemovedPlugin_WhenPluginWithIdentifierRegistered {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    
    [self.manager unregisterObjects:chat pluginWithIdentifier:identifier];
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
}

- (void)testUnregisterObjects_ShouldRemovedPlugin_WhenProvidedByProtoPlugin {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObjectType:@"Chat"];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager setupProtoPluginsForObject:chat withCompletion:^{
            [self.manager unregisterObjects:chat pluginWithIdentifier:identifier];
            handler();
        }];
    }];
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
    XCTAssertTrue([self.manager hasProtoPluginWithIdentifier:identifier forObjectType:@"Chat"]);
}

- (void)testUnregisterObjects_ShouldNotRemoveSamePlugin_WhenRegisteredWithDifferentIdentifiers {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    CENChat *chat1 = [self publicChatWithChatEngine:self.client];
    CENChat *chat2 = [self publicChatWithChatEngine:self.client];
    NSString *identifier1 = CEDummyPlugin.identifier;
    NSString *identifier2 = [identifier1 stringByAppendingString:@"2"];
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObject:chat1
                     firstInList:NO completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier2 configuration:nil forObject:chat1
                     firstInList:NO completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObject:chat2
                     firstInList:NO completion:nil];

    [self.manager unregisterObjects:chat2 pluginWithIdentifier:identifier2];
    
    XCTAssertTrue([self.manager hasPluginWithIdentifier:identifier1 forObject:chat1]);
    XCTAssertTrue([self.manager hasPluginWithIdentifier:identifier2 forObject:chat1]);
}

- (void)testUnregisterObjects_ShouldThrow_WhenNonNSStringIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = (id)@2010;
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:chat pluginWithIdentifier:identifier], NSException,
                                 NSInvalidArgumentException);
}

- (void)testUnregisterObjects_ShouldThrow_WhenNilIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:chat pluginWithIdentifier:identifier], NSException,
                                 NSInvalidArgumentException);
}

- (void)testUnregisterObjects_ShouldThrow_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = @"";
    
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:chat pluginWithIdentifier:identifier], NSException,
                                 NSInvalidArgumentException);
}

- (void)testUnregisterObjects_ShouldThrow_WhenUnknownObjectPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterObjects:(id)[NSArray new] pluginWithIdentifier:identifier], NSException,
                                 NSInvalidArgumentException);
}


#pragma mark - Tests :: unregisterAllFromObjects

- (void)testUnregisterAllFromObjects_ShouldRemovedPlugin_WhenPluginWithIdentifierRegistered {
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class], [CENUser class]] };
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    [self.manager unregisterAllFromObjects:chat];
    
    XCTAssertFalse([self.manager hasPluginWithIdentifier:identifier forObject:chat]);
}

- (void)testUnregisterAllFromObjects_ShouldThrow_WhenUnknownObjectPassed {
    
    XCTAssertThrowsSpecificNamed([self.manager unregisterAllFromObjects:(id)[NSArray new]], NSException,
                                 NSInvalidArgumentException);
}


#pragma mark - Tests :: extensionForObject

- (void)testExtensionForObject_ShouldReceiveExtensionExecutionContext_WhenPluginRegisteredForObject {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        id extension = [self.manager extensionForObject:chat withIdentifier:identifier];
        
        XCTAssertNotNil(extension);
        handler();
    }];
}

- (void)testExtensionForObject_ShouldNotReceiveExtensionExecutionContext_WhenUsedNotRegisteredPluginIdentifier {
    
    NSString *wrongIdentifier = [CEDummyPlugin.identifier stringByAppendingString:@"2"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        id extension = [self.manager extensionForObject:chat withIdentifier:wrongIdentifier];
        
        XCTAssertNil(extension);
        handler();
    }];
}

- (void)testExtensionForObject_ShouldThrow_WhenNonNSStringNilIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = (id)@2010;
    
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:chat withIdentifier:identifier],
                                 NSException, NSInvalidArgumentException);
}

- (void)testExtensionForObject_ShouldThrow_WhenNilIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:chat withIdentifier:identifier],
                                 NSException, NSInvalidArgumentException);
}

- (void)testExtensionForObject_ShouldThrow_WhenEmptyIdentifierPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier = @"";
    
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:chat withIdentifier:identifier],
                                 NSException, NSInvalidArgumentException);
}

- (void)testExtensionForObject_ShouldThrow_WhenUnknownObjectPassed {
    
    NSString *identifier = CEDummyPlugin.identifier;
    
    
    XCTAssertThrowsSpecificNamed([self.manager extensionForObject:(id)[NSArray new] withIdentifier:identifier],
                                 NSException, NSInvalidArgumentException);
}


#pragma mark - Tests :: runMiddlewaresAtLocation

- (void)testRunMiddlewaresAtLocation_ShouldRunMiddleware_WhenRegisteredPluginWithMiddlewares {
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"payload" }];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    CEDummyPlugin.middlewareLocationEvents = @{ CEPMiddlewareLocation.on: @[@"test"] };
    NSString *identifier2 = [CEDummyPlugin.identifier stringByAppendingString:@"2"];
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSString *identifier1 = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier2 configuration:nil forObject:chat firstInList:NO
                      completion:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on forEvent:@"test" object:chat withPayload:payload
                                    completion:^(BOOL rejected, NSMutableDictionary *data) {
                                        XCTAssertNotNil(data[@"broadcast"]);
                                        handler();
                                    }];
    }];
}

- (void)testRunMiddlewaresAtLocation_ShouldNotRunMiddleware_WhenCalledWithUnknownEvent {
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithDictionary:@{ @"test": @"payload" }];
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENUser class]] };
    CEDummyPlugin.middlewareLocationEvents = @{ CEPMiddlewareLocation.on: @[@"test"] };
    NSString *identifier2 = [CEDummyPlugin.identifier stringByAppendingString:@"2"];
    CENUser *user = [self.client.usersManager createUserWithUUID:[NSUUID UUID].UUIDString state:nil];
    NSString *identifier1 = CEDummyPlugin.identifier;
    
    
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObject:user firstInList:NO
                      completion:nil];
    [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier2 configuration:nil forObject:user firstInList:NO
                      completion:nil];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on forEvent:@"test2" object:user withPayload:payload
                                    completion:^(BOOL rejected, NSMutableDictionary *data) {
                                        XCTAssertNil(data[@"broadcast"]);
                                        handler();
                                    }];
    }];
}

- (void)testRunMiddlewaresAtLocation_ShouldThrow_WhenNonNSStringEventPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *event = (id)@2010;
    
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:event
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrow_WhenNilEventPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = [NSMutableDictionary new];
    NSString *event = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:event
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrow_WhenNilPayloadPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    NSMutableDictionary *payload = nil;
    
    
    XCTAssertThrowsSpecificNamed([self.manager runMiddlewaresAtLocation:CEPMiddlewareLocation.on
                                                               forEvent:@"chat"
                                                                 object:chat
                                                            withPayload:payload
                                                             completion:^(BOOL rejected, id data) {}],
                                 NSException, NSInvalidArgumentException);
}

- (void)testRunMiddlewaresAtLocation_ShouldThrowException_WhenEmptyEventPassed {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
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
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
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
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
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
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
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
    
    CEDummyPlugin.middlewareLocationClasses = @{ CEPMiddlewareLocation.on: @[[CENChat class]] };
    NSString *identifier2 = [CEDummyPlugin.identifier stringByAppendingString:@"2"];
    CEDummyPlugin.classesWithExtensions = @[[CENChat class]];
    NSString *identifier1 = CEDummyPlugin.identifier;
    
    
    [self.manager registerProtoPlugin:[CEDummyPlugin class] withIdentifier:identifier1 configuration:nil forObjectType:@"Chat"];
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.manager registerPlugin:[CEDummyPlugin class] withIdentifier:identifier2 configuration:nil forObject:chat
                         firstInList:NO completion:handler];
    }];
    
    [self threadSafeManagerDataAccessWith:^{
        XCTAssertGreaterThan(self.manager.protoPlugins.count, 0);
        XCTAssertGreaterThan(self.manager.middlewares.count, 0);
        XCTAssertGreaterThan(self.manager.extensions.count, 0);
        XCTAssertGreaterThan(self.manager.objects.count, 0);
    }];

    [self.manager destroy];
    
    [self waitTask:@"waitManagerCleanup" completionFor:self.delayedCheck];
    
    [self threadSafeManagerDataAccessWith:^{
        XCTAssertEqual(self.manager.protoPlugins.count, 0);
        XCTAssertEqual(self.manager.middlewares.count, 0);
        XCTAssertEqual(self.manager.extensions.count, 0);
        XCTAssertEqual(self.manager.objects.count, 0);
    }];
}


#pragma mark - Misc

- (void)threadSafeManagerDataAccessWith:(dispatch_block_t)block {
    
    dispatch_async(self.manager.resourceAccessQueue, block);
}

#pragma mark -


@end
