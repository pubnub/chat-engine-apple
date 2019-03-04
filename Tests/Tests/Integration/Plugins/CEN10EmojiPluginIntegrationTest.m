/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENEmojiPlugin.h>


@interface CEN10EmojiPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CEN10EmojiPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"NativeEmojiEnabled"].location != NSNotFound) {
        configuration = @{ CENEmojiConfiguration.useNative: @YES };
    }
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
    [self chatEngineForUser:@"ian"].global.plugin([CENEmojiPlugin class]).configuration(configuration).store();
    
    if ([self.name rangeOfString:@"ShouldTranslateToText"].location == NSNotFound) {
        [self chatEngineForUser:@"stephen"].global.plugin([CENEmojiPlugin class]).configuration(configuration).store();
    }
}


#pragma mark - Tests :: Translation to text

- (void)testToText_ShouldTranslateToTextRepresentation_WhenStringWithNativeEmojiPassed {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSString *message = ((NSDictionary *)emittedEvent.data[CENEventData.data])[@"text"];
            
            XCTAssertNotEqual([message rangeOfString:@":gift:"].location, NSNotFound);
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Here is 🎁 for you!" }).perform();
    }];
}


#pragma mark - Tests :: Translation to emoji

- (void)testToEmoji_ShouldTranslateToNativeEmojiRepresentation_WhenConfiguredWithNativeEmojiEnabled {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2 shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSString *message = ((NSDictionary *)emittedEvent.data[CENEventData.data])[@"text"];
            
            XCTAssertEqualObjects(message, @"Here is 🎁 for you!");
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Here is :gift: for you!" }).perform();
    }];
}

- (void)testToEmoji_ShouldTranslateToRemoteEmojiRepresentation_WhenConfiguredWithNativeEmojiDisabled {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    NSUInteger expectedNumberAttachments = 1;
    
    
    [self object:client2 shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSAttributedString *message = ((NSDictionary *)emittedEvent.data[CENEventData.data])[@"text"];
            __block NSUInteger numberOfAttachments = 0;
            
            XCTAssertTrue([message isKindOfClass:[NSAttributedString class]]);
            [message enumerateAttributesInRange:NSMakeRange(0, message.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(NSDictionary<NSAttributedStringKey,id> *attributes,
                                                  NSRange range,
                                                  BOOL *stop) {
                                         
                if (attributes[NSAttachmentAttributeName]) {
                    numberOfAttachments++;
                }
            }];
            
            XCTAssertEqual(numberOfAttachments, expectedNumberAttachments);
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"message").data(@{ @"text": @"Here is :gift: for you!" }).perform();
    }];
}

#pragma mark -


@end
