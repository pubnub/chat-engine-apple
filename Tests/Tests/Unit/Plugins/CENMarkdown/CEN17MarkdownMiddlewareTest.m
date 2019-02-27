/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENMarkdownParser+Private.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENMarkdownMiddleware.h>
#import <CENChatEngine/CENMarkdownPlugin.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEN17MarkdownMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENMarkdownMiddleware *middleware;
@property (nonatomic, strong) NSDictionary *parserConfiguration;
@property (nonatomic, strong) NSString *expectedParsedString;

#pragma mark -


@end


#pragma mark - Tests

@implementation CEN17MarkdownMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.expectedParsedString = @"Parsed Markdown from custom parser";
    self.parserConfiguration = @{
        CENMarkdownParserElement.boldAttributes: @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:16.f] }
    };
    
    NSMutableDictionary *middlewareConfiguration = [@{
        CENMarkdownConfiguration.messageKey: @"text",
        CENMarkdownConfiguration.parsedMessageKey: @"text"
    } mutableCopy];
    if ([self.name rangeOfString:@"ParserWithCustomConfiguration"].location != NSNotFound) {
        middlewareConfiguration[CENMarkdownConfiguration.parserConfiguration] = self.parserConfiguration;
    }
    
    if ([self.name rangeOfString:@"WhenCustomParserPassed"].location != NSNotFound ||
        [self.name rangeOfString:@"testCustomParser"].location != NSNotFound) {
        
        middlewareConfiguration[CENMarkdownConfiguration.parser] = ^(NSString *message, void(^completion)(id parsed)){
            completion(self.expectedParsedString);
        };
    }
    
    if ([self.name rangeOfString:@"WhenParsedMessageKeyConfigured"].location != NSNotFound) {
        middlewareConfiguration[CENMarkdownConfiguration.messageKey] = @"markdown.source";
        middlewareConfiguration[CENMarkdownConfiguration.parsedMessageKey] = @"markdown.parsed.data";
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
    [self waitForObject:parserMock recordedInvocationCall:recorded afterBlock:^{
        [self.middleware onCreate];
    }];
}

- (void)testOnCreate_ShouldConfigureParserWithEmptyConfiguration_WhenParserConfigurationNotProvided {
    
    id parserMock = [self mockForObject:[CENMarkdownParser class]];
    id recorded = OCMExpect([parserMock parserWithConfiguration:@{}]);
    [self waitForObject:parserMock recordedInvocationCall:recorded afterBlock:^{
        [self.middleware onCreate];
    }];
}

- (void)testOnCreate_ShouldNotConfigureParser_WhenCustomParserPassed {
    
    id parserMock = [self mockForObject:[CENMarkdownParser class]];
    id recorded = OCMExpect([[parserMock reject] parserWithConfiguration:@{}]);
    [self waitForObject:parserMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.middleware onCreate];
    }];
}


#pragma mark - Tests :: Default Parser

- (void)testDefaultParser_ShouldParseMarkdownString {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": @"**some** ~~text~~" } } mutableCopy];
    [self.middleware onCreate];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
            handler();
        }];
    }];
}

- (void)testDefaultParser_ShouldStoreParsedMarkdownAtSpecifiedLocaltion_WhenParsedMessageKeyConfigured {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"markdown": @{ @"source": @"**some** ~~text~~" } } } mutableCopy];
    NSString *parsedMessageKey = @"markdown.parsed.data";
    [self.middleware onCreate];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            id parsedMarkdown = [payload[CENEventData.data] valueForKeyPath:parsedMessageKey];
            
            XCTAssertTrue([parsedMarkdown isKindOfClass:[NSAttributedString class]]);
            handler();
        }];
    }];
}

- (void)testDefaultParser_ShouldNotParseMarkdownString_WhenStringDoesntContainMarkdownSyntax {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": @"some text" } } mutableCopy];
    [self.middleware onCreate];


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertFalse([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
            handler();
        }];
    }];
}

- (void)testDefaultParser_ShouldNotChangePayload_WhenDataAtSpecifiedKeyNotFound {
    
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


#pragma mark - Tests :: Custom Parser

- (void)testCustomParser_ShouldParseMarkdownString {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": @"**some** ~~text~~" } } mutableCopy];
    [self.middleware onCreate];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            XCTAssertEqualObjects(payload[CENEventData.data][@"text"], self.expectedParsedString);
            handler();
        }];
    }];
}

- (void)testCustomParser_ShouldStoreParsedMarkdownAtSpecifiedLocaltion_WhenParsedMessageKeyConfigured {
    
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"markdown": @{ @"source": @"**some** ~~text~~" } } } mutableCopy];
    NSString *parsedMessageKey = @"markdown.parsed.data";
    [self.middleware onCreate];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            id parsedMarkdown = [payload[CENEventData.data] valueForKeyPath:parsedMessageKey];
            
            XCTAssertEqualObjects(parsedMarkdown, self.expectedParsedString);
            handler();
        }];
    }];
}

#pragma mark -


@end
