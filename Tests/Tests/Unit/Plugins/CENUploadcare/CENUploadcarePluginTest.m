/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENUploadcareMiddleware.h>
#import <CENChatEngine/CENUploadcareExtension.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENUploadcarePlugin.h>
#import <CENChatEngine/CEPPlugin+Developer.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENUploadcarePluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENUploadcarePlugin *plugin;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENUploadcarePluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

-(void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = @{ CENUploadcareConfiguration.publicKey: @"secret-key" };
    
    self.plugin = [CENUploadcarePlugin pluginWithIdentifier:@"test" configuration:configuration];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
    XCTAssertEqualObjects(CENUploadcarePlugin.identifier, @"com.chatengine.plugin.uploadcare");
}


#pragma mark - Tests :: Extension

- (void)testExtension_ShouldProvideExtension_WhenCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:[self publicChatWithChatEngine:self.client]];
    
    XCTAssertNotNil(extensionClass);
    XCTAssertEqualObjects(extensionClass, [CENUploadcareExtension class]);
}

- (void)testExtension_ShouldNotProvideExtension_WhenNonCENChatInstancePassed {
    
    Class extensionClass = [self.plugin extensionClassFor:(id)@2010];
    
    XCTAssertNil(extensionClass);
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideMiddleware_WhenCENChatInstancePassedForOnLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:chat];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENUploadcareMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenNonCENChatInstancePassedForOnLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    XCTAssertNil(middlewareClass);
}

- (void)testMiddleware_ShouldNotProvideMiddleware_WhenCENChatInstancePassedForUnexpectedLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.emit object:chat];
    XCTAssertNil(middlewareClass);
}


#pragma mark - Tests :: shareFile

- (void)testShareFile_ShouldRequestExtensionWithPluginIdentifier {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    
    
    id chatMock = [self mockForObject:chat];
    id recorded = OCMExpect([chatMock extensionWithIdentifier:CENUploadcarePlugin.identifier]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUploadcarePlugin shareFileWithIdentifier:@"123456789" toChat:chat];
    }];
}

- (void)testShareFile_ShouldCallExtensionMethod {
    
    CENChat *chat = [self publicChatWithChatEngine:self.client];
    CENUploadcareExtension *extension = [CENUploadcareExtension extensionForObject:chat withIdentifier:@"test"
                                                                     configuration:self.plugin.configuration];
    NSString *expected = @"1234567890";
    
    
    id extensionMock = [self mockForObject:extension];
    
    id chatMock = [self mockForObject:chat];
    OCMStub([chatMock extensionWithIdentifier:[OCMArg any]]).andReturn(extensionMock);
    
    id recorded = OCMExpect([(CENUploadcareExtension *)extensionMock shareFileWithIdentifier:expected]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [CENUploadcarePlugin shareFileWithIdentifier:expected toChat:chat];
    }];
}


#pragma mark - Tests :: Handlers

- (void)testOnCreate_ShouldThrow_WhenPublicKeyNotPassed {
    
    XCTAssertThrows([CENUploadcarePlugin pluginWithIdentifier:@"test" configuration:nil]);
}

#pragma mark -


@end
