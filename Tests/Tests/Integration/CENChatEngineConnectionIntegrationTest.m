/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"


#pragma mark Interface declaration

@interface CENChatEngineConnectionIntegrationTest: CENTestCase


#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENChatEngineConnectionIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    [self setupChatEngineForUser:@"serhii" withSynchronization:NO meta:NO state:@{ @"works": @YES }];
}

- (void)testConnect_ShouldSetProperValues_WhenChatEngineConnected {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    
    XCTAssertTrue(client.isReady);
    XCTAssertNotNil(client.pubnub);
}

- (void)testChats_ShouldContainGlobalFeedDirect_WhenChatEngineConnected {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    NSArray<NSString *> *chatNames = [client.chats.allValues valueForKey:@"name"];
    
    XCTAssertTrue([chatNames containsObject:@"feed"]);
    XCTAssertTrue([chatNames containsObject:@"direct"]);
    XCTAssertNotNil(client.global);
}

- (void)testLocalUser_ShouldNotBeNil_WhenChatEngineConnected {
    
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    
    XCTAssertNotNil(client.me);
}

- (void)testHandleEvent_ShouldBeNotified_WhenNewChatCreated {
    
    NSString *chatName = [@[@"this-is-only-a-test-1", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Test chat should notify on create."];
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    
    client.on(@"$.created.chat", ^(CENChat *chat) {
        NSString *expectedChannel = [@[client.currentConfiguration.globalChannel, @"chat#public.", chatName] componentsJoinedByString:@"#"];
        if ([expectedChannel isEqualToString:chat.channel]) {
            [expectation fulfill];
        }
    });
    
    CENChat *chat = client.Chat().name(chatName).create();
    chat.on(@"$.connected", ^{
        chat.leave();
    });
    
    [self waitForExpectations:@[expectation] timeout:3.f];
}

- (void)testHandleEvent_ShouldBeNotified_WhenChatConnected {
    
    NSString *chatName = [@[@"this-is-only-a-test-2", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Test chat should notify on connection."];
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    CENChat *chat = nil;
    
    client.on(@"$.connected", ^(CENChat *chat) {
        if ([chat.channel isEqualToString:chat.channel]) {
            [expectation fulfill];
        }
    });
    
    chat = client.Chat().name(chatName).create();
    
    [self waitForExpectations:@[expectation] timeout:3.f];
}

- (void)testHandleEvent_ShouldBeNotified_WhenChatDisconnected {
    
    NSString *chatName = [@[@"this-is-only-a-test-3", @([NSDate date].timeIntervalSince1970)] componentsJoinedByString:@""];
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription:@"Test chat should notify on disconnection."];
    CENChatEngine *client = [self chatEngineForUser:@"serhii"];
    CENChat *chat = nil;
    
    client.on(@"$.disconnected", ^(CENChat *chat) {
        if ([chat.channel isEqualToString:chat.channel]) {
            [expectation fulfill];
        }
    });
    
    chat = client.Chat().name(chatName).create();
    chat.on(@"$.connected", ^{
        chat.leave();
    });
    
    [self waitForExpectations:@[expectation] timeout:3.f];
}

#pragma mark -


@end
