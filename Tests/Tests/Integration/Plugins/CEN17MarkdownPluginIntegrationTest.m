/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENMarkdownPlugin.h>


#pragma mark Interface declaration

@interface CEN17MarkdownPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEN17MarkdownPluginIntegrationTest


#pragma mark - Setup / Tear down

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = nil;
    
    if ([self.name rangeOfString:@"testDefaultCondfiguration"].location == NSNotFound) {
        configuration = @{ CENMarkdownConfiguration.events: @[@"message"], CENMarkdownConfiguration.messageKey: @"text" };
    }
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
    [self chatEngineForUser:@"ian"].global.plugin([CENMarkdownPlugin class]).configuration(configuration).store();
    [self chatEngineForUser:@"stephen"].global.plugin([CENMarkdownPlugin class]).configuration(configuration).store();
}

- (void)testDefaultCondfiguration_ShouldHandleMessageEventsByDefault {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client1.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.data][@"text"]);
            XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
            handler();
        };
    } afterBlock:^{
        client2.global.emit(@"message").data(@{ @"text": @"_Italic_ text" }).perform();
    }];
}

- (void)testDefaultCondfiguration_ShouldHandleMessagesUnderDefaultDataKey {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client1.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.data][@"text"]);
            XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
            handler();
        };
    } afterBlock:^{
        client2.global.emit(@"message").data(@{ @"text": @"**Bold** text" }).perform();
    }];
}

- (void)testMarkdownFormat_ShouldNotFormatReceivedMessage_WhenReceivedMessageWithOutMarkdownMarkup {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client1.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.data][@"text"]);
            XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSString class]]);
            handler();
        };
    } afterBlock:^{
        client2.global.emit(@"message").data(@{ @"text": @"Simple text" }).perform();
    }];
}

- (void)testMarkdownFormat_ShouldFormatReceivedMessage_WhenReceivedMessageWithMarkdownMarkup {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client1.global shouldHandleEvent:@"message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.data][@"text"]);
            XCTAssertTrue([payload[CENEventData.data][@"text"] isKindOfClass:[NSAttributedString class]]);
            handler();
        };
    } afterBlock:^{
        client2.global.emit(@"message").data(@{ @"text": @"**Bold** text" }).perform();
    }];
}

#pragma mark -


@end
