/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENEmojiMiddleware+Private.h>
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import <CENChatEngine/CENEmojiOnMiddleware.h>
#import <CENChatEngine/CENEmojiPlugin.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CEN10EmojiOnMiddlewareTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENEmojiOnMiddleware *middleware;
@property (nonatomic, nullable, strong) id middlewareMock;

#pragma mark -


@end


#pragma mark - Tests

@implementation CEN10EmojiOnMiddlewareTest


#pragma mark - Setup / Tear down

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    
    return ([name rangeOfString:@"testMuteUser"].location != NSNotFound ||
            [name rangeOfString:@"testUnmuteUser"].location != NSNotFound ||
            [name rangeOfString:@"testIsMutedUser"].location != NSNotFound);
}

- (BOOL)shouldSetupVCR {
    
    return [self.name rangeOfString:@"testRemoteEmoji"].location != NSNotFound;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSMutableDictionary *configuration = [@{
        CENEmojiConfiguration.events: @[@"message"],
        CENEmojiConfiguration.messageKey: @"text",
        CENEmojiConfiguration.useNative: @NO,
        CENEmojiConfiguration.emojiURL: @"https://www.webpagefx.com/tools/emoji-cheat-sheet/graphics/emojis"
    } mutableCopy];
    
    if ([self.name rangeOfString:@"testNativeEmoji"].location != NSNotFound) {
        configuration[CENEmojiConfiguration.useNative] = @YES;
    }
    
    if ([self.name rangeOfString:@"KeyPath"].location != NSNotFound) {
        configuration[CENEmojiConfiguration.messageKey] = @"payload.text";
    }
    
    self.middleware = [CENEmojiOnMiddleware new];
    
    self.middlewareMock = [self mockForObject:self.middleware];
    OCMStub([self.middlewareMock configuration]).andReturn(configuration);
}


#pragma mark - Tests :: Information

- (void)testEvents_ShouldBeSetToWildcard {
    
    XCTAssertEqualObjects(CENEmojiOnMiddleware.events, @[@"*"]);
}

- (void)testLocation_ShouldBeSetToOn {
    
    XCTAssertEqualObjects(CENEmojiOnMiddleware.location, CEPMiddlewareLocation.on);
}


#pragma mark - Tests :: Native emoji parser

- (void)testNativeEmoji_ShouldReplaceTextRepresentationWithNative_WhenKnownEmojiRepresentationPassed {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @"It is time to set a :christmas_tree: and put some :gift:" }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertNotEqual([parsedMessage rangeOfString:@"🎄"].location, NSNotFound);
            XCTAssertNotEqual([parsedMessage rangeOfString:@"🎁"].location, NSNotFound);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldReplaceTextRepresentationWithNative_WhenPassedByKeyPath {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"payload": @{ @"text": @"It is time to set a :christmas_tree: and put some :gift:" } }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = [payload[CENEventData.data] valueForKeyPath:@"payload.text"];
            
            XCTAssertNotEqual([parsedMessage rangeOfString:@"🎄"].location, NSNotFound);
            XCTAssertNotEqual([parsedMessage rangeOfString:@"🎁"].location, NSNotFound);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceTextRepresentationWithNative_WhenKnownMissingEmojiRepresentationPassed {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @"Why there is :trollface: here?" }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertNotEqual([parsedMessage rangeOfString:@":trollface:"].location, NSNotFound);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceTextRepresentationWithNative_WhenUnknownEmojiRepresentationPassed {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @"Why there is :testemoji: here?" }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertNotEqual([parsedMessage rangeOfString:@":testemoji:"].location, NSNotFound);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceTextRepresentationWithNative_WhenMessageWithOutEmojiPassed {
    
    NSString *expectedMessage = @"Hello there!";
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": expectedMessage }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSString *parsedMessage = payload[CENEventData.data][@"text"];
            
            XCTAssertEqualObjects(parsedMessage, expectedMessage);
            handler();
        }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceTextRepresentationWithNative_WhenNonNSStringMessagePassed {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @{ @"hello": @"there!" } }
    } mutableCopy];
    
    id recorded = OCMStub([self.middlewareMock dictionaryDeepMutableFrom:[OCMArg any]]);
    [self waitForObject:self.middlewareMock recordedInvocationNotCall:recorded afterBlock:^{
        
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceTextRepresentationWithNative_WhenEmptyMessagePassed {
    
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @"" }
    } mutableCopy];
    
    id recorded = OCMStub([self.middlewareMock dictionaryDeepMutableFrom:[OCMArg any]]);
    [self waitForObject:self.middlewareMock recordedInvocationNotCall:recorded afterBlock:^{
                 
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}

- (void)testNativeEmoji_ShouldNotReplaceTextRepresentationWithNative_WhenNilMessagePassed {
    
    NSMutableDictionary *payload = [NSMutableDictionary new];
    
    
    id recorded = OCMStub([self.middlewareMock dictionaryDeepMutableFrom:[OCMArg any]]);
    [self waitForObject:self.middlewareMock recordedInvocationNotCall:recorded afterBlock:^{
             
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) { }];
    }];
}


#pragma mark - Tests :: Remote emoji parser

- (void)testRemoteEmoji_ShouldReplaceTextRepresentationWithAttachment_WhenKnownEmojiRepresentationPassed {
    
    NSUInteger expectedNumberOfAttachments = 2;
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @"It is time to set a :christmas_tree: and put some :gift:" }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSAttributedString *parsedMessage = payload[CENEventData.data][@"text"];
            __block NSUInteger numberOfAttachments = 0;
            
            [parsedMessage enumerateAttributesInRange:NSMakeRange(0, parsedMessage.length)
                                              options:NSAttributedStringEnumerationReverse
                                           usingBlock:^(NSDictionary<NSAttributedStringKey,id> *attributes,
                                                        NSRange range,
                                                        BOOL *stop) {
                                               
                if (attributes[NSAttachmentAttributeName]) {
                    numberOfAttachments++;
                }
            }];
            
            XCTAssertTrue([parsedMessage isKindOfClass:[NSAttributedString class]]);
            XCTAssertTrue([parsedMessage containsAttachmentsInRange:NSMakeRange(0, parsedMessage.length)]);
            XCTAssertEqual(numberOfAttachments, expectedNumberOfAttachments);
            handler();
        }];
    }];
}

- (void)testRemoteEmoji_ShouldReplaceTextRepresentationWithCachedAttachment_WhenSameStringPassed {
    
    NSString *text = @"There is :rocket: and :stars: above us.";
    NSMutableDictionary *payload = [@{ CENEventData.data: @{ @"text": text } } mutableCopy];
    
    
#if TARGET_OS_OSX
    NSImage *image = [NSImage alloc];
    id imageClassMock = [self mockForObject:[NSImage class]];
    id image = [NSImage alloc];
    OCMStub([imageClassMock alloc]).andReturn(image);
    id imageMock = [self mockForObject:image];
    OCMExpect([imageMock initWithData:[OCMArg any]]).andForwardToRealObject();
#else
    id imageMock = [self mockForObject:[UIImage class]];
    OCMExpect([imageMock imageWithData:[OCMArg any]]).andForwardToRealObject();
#endif // TARGET_OS_OSX
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            OCMVerifyAll(imageMock);
            handler();
        }];
    }];
    
    payload[CENEventData.data] = @{ @"text": text };
#if TARGET_OS_OSX
    OCMExpect([[imageMock reject] initWithData:[OCMArg any]]);
#else
    OCMExpect([[imageMock reject] imageWithData:[OCMArg any]]);
#endif // TARGET_OS_OSX
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            OCMVerifyAll(imageMock);
            handler();
        }];
    }];
}

- (void)testRemoteEmoji_ShouldNotReplaceTextRepresentationWithAttachment_WhenUnknownEmojiRepresentationPassed {
    
    NSUInteger expectedNumberOfAttachments = 1;
    NSMutableDictionary *payload = [@{
        CENEventData.data: @{ @"text": @"Why there is :testemoji: here? I was epxecting for :gift:" }
    } mutableCopy];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.middleware runForEvent:@"message" withData:payload completion:^(BOOL rejected) {
            NSAttributedString *parsedMessage = payload[CENEventData.data][@"text"];
            __block NSUInteger numberOfAttachments = 0;
            
            [parsedMessage enumerateAttributesInRange:NSMakeRange(0, parsedMessage.length)
                                              options:NSAttributedStringEnumerationReverse
                                           usingBlock:^(NSDictionary<NSAttributedStringKey,id> *attributes,
                                                        NSRange range,
                                                        BOOL *stop) {
                                               
                if (attributes[NSAttachmentAttributeName]) {
                    numberOfAttachments++;
                }
            }];
            
            XCTAssertTrue([parsedMessage isKindOfClass:[NSAttributedString class]]);
            XCTAssertTrue([parsedMessage containsAttachmentsInRange:NSMakeRange(0, parsedMessage.length)]);
            XCTAssertEqual(numberOfAttachments, expectedNumberOfAttachments);
            handler();
        }];
    }];
}

#pragma mark -


@end
