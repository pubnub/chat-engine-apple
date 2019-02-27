/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENEventStatusExtension.h>
#import <CENChatEngine/CENEventStatusPlugin.h>
#import <CENChatEngine/CEPExtension+Private.h>
#import <CENChatEngine/CENChat+Interface.h>
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


@interface CENEventStatusExtensionTest : CENTestCase


#pragma mark - Information

@property (nonatomic, nullable, strong) CENEventStatusExtension *extension;
@property (nonatomic, nullable, strong) CENChat *chat;

#pragma mark -


@end


#pragma mark - Tests

@implementation CENEventStatusExtensionTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {

    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    
    self.chat = [self publicChatWithChatEngine:self.client];
    self.extension = [CENEventStatusExtension extensionForObject:self.chat withIdentifier:@"test" configuration:nil];
}


#pragma mark - Tests :: Mark as readed

- (void)testRead_ShouldEmitEvent {
    
    NSDictionary *eventStatusData = @{ CENEventStatusData.identifier: [NSUUID UUID].UUIDString };
    NSMutableDictionary *payload = [@{ CENEventStatusData.data: eventStatusData } mutableCopy];
    
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([chatMock emitEvent:@"$.eventStatus.read" withData:eventStatusData]);
    [self waitForObject:chatMock recordedInvocationCall:recorded afterBlock:^{
        [self.extension readEvent:payload];
    }];
}

- (void)testRead_ShouldNotEmitEvent_WhenEventStatusDataIsMissing {
    
    NSMutableDictionary *payload = [@{  } mutableCopy];
    
    
    id chatMock = [self mockForObject:self.chat];
    id recorded = OCMExpect([[chatMock reject] emitEvent:@"$.eventStatus.read" withData:[OCMArg any]]);
    [self waitForObject:chatMock recordedInvocationNotCall:recorded afterBlock:^{
        [self.extension readEvent:payload];
    }];
}


#pragma mark -

@end
