/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENEmojiMiddleware+Private.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENEmojiEmitMiddleware.h>
#import <CENChatEngine/CENEmojiPlugin.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEN10EmojiEmitMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENEmojiEmitMiddleware *middleware;
@property (nonatomic, nullable, strong) id middlewareMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CEN10EmojiEmitMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSMutableDictionary *configuration = [@{
        CENEmojiConfiguration.events: @[@"message"],
        CENEmojiConfiguration.messageKey: @"text",
        CENEmojiConfiguration.useNative: @NO,
        CENEmojiConfiguration.emojiURL: @"https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis"
    } mutableCopy];
    
    if ([self.name rangeOfString:@"KeyPath"].location != NSNotFound) {
        configuration[CENEmojiConfiguration.messageKey] = @"payload.text";
    }
    
    self.middleware = [CENEmojiEmitMiddleware new];
    
    self.middlewareMock = [self mockForObject:self.middleware];
    OCMStub([self.middlewareMock configuration]).andReturn(configuration);
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENEmojiEmitMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENEmojiEmitMiddleware.location, CEPMiddlewareLocation.emit);
}


#pragma mark - Tests :: Emoji to text parser

- (void)testNativeEmoji_ShouldReplaceWithTextRepresentation_WhenNSStringWithKnownEmojiPassed {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @"It is time to set a 🎄 and put some 🎁" }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertNotEqual([parsedMessage rangeOfString:@":christmas_tree:"].location, NSNotFound);
            XCTAssertNotEqual([parsedMessage rangeOfString:@":gift:"].location, NSNotFound);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldReplaceWithTextRepresentation_WhenNSAttributedStringWithKnownEmojiPassed {
    
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@"It is time to set a 🎄 and put some 🎁"];
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": string } } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertNotEqual([parsedMessage rangeOfString:@":christmas_tree:"].location, NSNotFound);
            XCTAssertNotEqual([parsedMessage rangeOfString:@":gift:"].location, NSNotFound);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldReplaceWithTextRepresentation_WhenPassedByKeyPath {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"payload": @{ @"text": @"It is time to set a 🎄 and put some 🎁" } }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = [payload[CENEventData.data] valueForKeyPath:@"payload.text"];
            
            XCTAssertNotEqual([parsedMessage rangeOfString:@":christmas_tree:"].location, NSNotFound);
            XCTAssertNotEqual([parsedMessage rangeOfString:@":gift:"].location, NSNotFound);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceWithTextRepresentation_WhenNoKnownEmojiPassed {
    
    NSString *expected = @"There is 🤖 in the corner.";
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": expected } } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertEqualObjects(parsedMessage, expected);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceWithTextRepresentation_WhenUnknownDataPassed {
    
    id expected = @[@"It is time to set a 🎄 and put some 🎁"];
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": expected } } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            id parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertEqualObjects(parsedMessage, expected);
            handler();
        }];
    }];
}

#pragma mark -


@end
