/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENMarkdownParser+Private.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENMarkdownMiddleware.h>
#import <CENChatEngine/CENMarkdownPlugin.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENMarkdownMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENMarkdownMiddleware *middleware;
@property (nonatomic, strong) NSDictionary *parserConfiguration;

#pragma mark -


@end


@implementation CENMarkdownMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.parserConfiguration = @{
        CENMarkdownParserElement.boldAttributes: @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.f] }
    };
    
    NSMutableDictionary *middlewareConfiguration = [@{ CENMarkdownConfiguration.messageKey: @"text" } mutableCopy];
    if ([self.name rangeOfString:@"ParserWithCustomConfiguration"].location != NSNotFound) {
        middlewareConfiguration[CENMarkdownConfiguration.parserConfiguration] = self.parserConfiguration;
    }
    
    self.middleware = [CENMarkdownMiddleware new];
    
    id middlewareMock = [self mockForObject:self.middleware];
    OCMStub([middlewareMock configuration]).andReturn(middlewareConfiguration);
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENMarkdownMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENMarkdownMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: Handler

- (void)testOnCreate_ShouldConfigureParserWithCustomConfiguration {
    
    id parserMock = [self mockForObject:[CENMarkdownParser class]];
    id recorded = OCMExpect([parserMock parserWithConfiguration:self.parserConfiguration]);
    [self waitForObject:parserMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.middleware onCreate];
    }];
}

- (void)testOnCreate_ShouldConfigureParserWithEmptyConfiguration_WhenParserConfigurationNotProvided {

    id parserMock = [self mockForObject:[CENMarkdownParser class]];
    id recorded = OCMExpect([parserMock parserWithConfiguration:@{}]);
    [self waitForObject:parserMock recordedInvocationCall:recorded withinInterval:self.testCompletionDelay afterBlock:^{
        [self.middleware onCreate];
    }];
}


#pragma mark - Tests :: Parser

- (void)testParser_ShouldParseMarkdownString {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": @"**some** ~~text~~" } } mutableCopy];
    [self.middleware onCreate];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
            handler();
        }];
    }];
}

- (void)testParser_ShouldNotParseMarkdownString_WhenStringDoesntContainMarkdownSyntax {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": @"some text" } } mutableCopy];
    [self.middleware onCreate];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
            handler();
        }];
    }];
}

- (void)testParser_ShouldNotChangePayload_WhenDataAtSpecifiedKeyNotFound {
    
    NSDictionary *originalPayload = @{ CENEventData.data : @{ @"message": @"**some** ~~text~~" } };
    NSMutableDictionary *payload = [originalPayload mutableCopy];
    [self.middleware onCreate];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(payload, originalPayload);
            handler();
        }];
    }];
}

#pragma mark -


@end
