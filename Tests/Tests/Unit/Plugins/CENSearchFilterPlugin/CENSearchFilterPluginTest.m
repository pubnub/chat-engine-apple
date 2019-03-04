/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENSearchFilterMiddleware.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENSearchFilterPlugin.h>
#import <CENChatEngine/CEPPlugin+Private.h>
#import <CENChatEngine/CENSearch+Private.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENSearchFilterPluginTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENSearchFilterPlugin *plugin;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENSearchFilterPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.plugin = [CENSearchFilterPlugin pluginWithIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Information

- (void)testIdentifier_ShouldHavePropertyIdentifier {
    
    XCTAssertEqualObjects(CENSearchFilterPlugin.identifier, @"com.chatengine.plugin.search.filter");
}


#pragma mark - Tests :: Middleware

- (void)testMiddleware_ShouldProvideOnMiddleware_WhenCENSearchInstancePassedForEmitLocation {
    
    CENChat *chat = self.client.Chat().name([NSUUID UUID].UUIDString).autoConnect(NO).create();
    CENUser *user = self.client.User([NSUUID UUID].UUIDString).create();
    CENSearch *search = [CENSearch searchForEvent:@"event" inChat:chat sentBy:user withLimit:0
                                            pages:0 count:100 start:nil end:nil chatEngine:self.client];
    
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:search];
    
    XCTAssertNotNil(middlewareClass);
    XCTAssertEqualObjects(middlewareClass, [CENSearchFilterMiddleware class]);
}

- (void)testMiddleware_ShouldNotProvideOnMiddleware_WhenNonCENSearchInstancePassedForEmitLocation {
    
    Class middlewareClass = [self.plugin middlewareClassForLocation:CEPMiddlewareLocation.on object:(id)@2010];
    
    XCTAssertNil(middlewareClass);
}

#pragma mark -


@end
