/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENEventStatusPlugin.h>


@interface CEN13EventStatusPluginIntegrationTest : CENTestCase


#pragma mark -


@end


#pragma mark - Tests

@implementation CEN13EventStatusPluginIntegrationTest


#pragma mark - Setup / Tear down

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
    
    [super updateVCRConfigurationFromDefaultConfiguration:configuration];
    
    YHVPathFilterBlock pathFilter = configuration.pathFilter;
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        NSMutableArray *pathComponents = [[pathFilter(request) componentsSeparatedByString:@"/"] mutableCopy];
        NSString *eventStatusString = [NSString stringWithFormat:@"\"%@\"", CENEventStatusData.data];
        
        if ([request.URL.path hasPrefix:@"/publish/"] &&
            ([request.URL.path rangeOfString:eventStatusString].location != NSNotFound ||
             [request.URL.path rangeOfString:@"\"id\""].location != NSNotFound)) {
                
            NSArray *messageParts = [pathComponents subarrayWithRange:NSMakeRange(7, pathComponents.count - 7)];
            NSString *messageString = [messageParts componentsJoinedByString:@"/"];
            NSData *messageData = [messageString dataUsingEncoding:NSUTF8StringEncoding];
            NSJSONReadingOptions options = NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves;
            NSMutableDictionary *message = [NSJSONSerialization JSONObjectWithData:messageData
                                                                           options:options error:nil];
                
            if ([request.URL.path rangeOfString:eventStatusString].location != NSNotFound) {
                message[CENEventStatusData.data] = @{ CENEventStatusData.identifier: @"test-event-id" };
            } else {
                message[CENEventData.data][CENEventStatusData.identifier] = @"test-event-id";
            }
            NSData *filteredData = [NSJSONSerialization dataWithJSONObject:message options:(NSJSONWritingOptions)0
                                                                     error:nil];
                
            [pathComponents removeObjectsInArray:messageParts];
            [pathComponents addObject:[[NSString alloc] initWithData:filteredData encoding:NSUTF8StringEncoding]];
        }
        
        return [pathComponents componentsJoinedByString:@"/"];
    };
}

- (BOOL)shouldConnectChatEngineForTestCaseWithName:(NSString *)name {
    
    return YES;
}

- (void)setUp {
    
    [super setUp];
    
    
    NSDictionary *configuration = @{ CENEventStatusConfiguration.events: @[@"test-message"] };
    
    [self setupChatEngineForUser:@"ian"];
    [self setupChatEngineForUser:@"stephen"];
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    client1.global.plugin([CENEventStatusPlugin class]).configuration(configuration).store();
    client1.proto(@"Event", [CENEventStatusPlugin class]).configuration(configuration).store();
    client2.global.plugin([CENEventStatusPlugin class]).configuration(configuration).store();
    client2.proto(@"Event", [CENEventStatusPlugin class]).configuration(configuration).store();
}


#pragma mark - Tests :: Event emitting

- (void)testEventEmitting_ShouldEmitEventWithEventStatusInformation {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"test-message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = (NSDictionary *)emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventStatusData.data]);
            XCTAssertNotNil(payload[CENEventStatusData.data][CENEventStatusData.identifier]);
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"test-message").data(@{ @"message": @"test-message" }).perform();
    }];
}

- (void)testEventEmitting_ShouldEmitLocalEvent_WhenEventIsAboutToBeEmitted {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    
    
    [self object:client.global shouldHandleEvent:@"$.eventStatus.created" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = (NSDictionary *)emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.data]);
            XCTAssertNotNil(payload[CENEventData.data][CENEventStatusData.identifier]);
            handler();
        };
    } afterBlock:^{
        client.global.emit(@"test-message").data(@{ @"message": @"test-message" }).perform();
    }];
}

- (void)testEventEmitting_ShouldEmitLocalEvent_WhenEventHasBeenSent {
    
    CENChatEngine *client = [self chatEngineForUser:@"ian"];
    
    
    [self object:client.global shouldHandleEvent:@"$.eventStatus.sent" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = (NSDictionary *)emittedEvent.data;
            
            XCTAssertNotNil(payload[CENEventData.data]);
            XCTAssertNotNil(payload[CENEventData.data][CENEventStatusData.identifier]);
            handler();
        };
    } afterBlock:^{
        client.global.emit(@"test-message").data(@{ @"message": @"test-message" }).perform();
    }];
}


#pragma mark - Tests :: Event delivery

- (void)testEventDelivery_ShouldEmitEvent_WhenEventHasBeenReceivedBySender {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    
    
    [self object:client2.global shouldHandleEvent:@"$.eventStatus.delivered" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *payload = (NSDictionary *)emittedEvent.data[CENEventData.data];
            
            XCTAssertNotNil(payload[CENEventStatusData.identifier]);
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"test-message").data(@{ @"message": @"test-message" }).perform();
    }];
}

- (void)testEventDelivery_ShouldEmitSeen_WhenRemoteUserMarkEventAsSeen {
    
    CENChatEngine *client1 = [self chatEngineForUser:@"ian"];
    CENChatEngine *client2 = [self chatEngineForUser:@"stephen"];
    __block NSDictionary *expectedPayload = nil;
    
    
    [self object:client2.global shouldHandleEvent:@"test-message" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            expectedPayload = (NSDictionary *)emittedEvent.data;
            handler();
        };
    } afterBlock:^{
        client1.global.emit(@"test-message").data(@{ @"message": @"test-message" }).perform();
    }];
    
    [self object:client1.global shouldHandleEvent:@"$.eventStatus.read" withHandler:^CENEventHandlerBlock (dispatch_block_t handler) {
        return ^(CENEmittedEvent *emittedEvent) {
            NSDictionary *receivedPayload = (NSDictionary *)emittedEvent.data;
            
            XCTAssertEqualObjects(receivedPayload[CENEventData.data][CENEventStatusData.identifier],
                                  expectedPayload[CENEventStatusData.data][CENEventStatusData.identifier]);
            handler();
        };
    } afterBlock:^{
        [CENEventStatusPlugin readEvent:expectedPayload inChat:client2.global];
    }];
}

#pragma mark -


@end
