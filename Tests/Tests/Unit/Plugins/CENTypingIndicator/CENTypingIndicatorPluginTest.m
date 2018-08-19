/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTestCase.h"
#import <CENChatEngine/CENTypingIndicatorPlugin.h>
#import <CENChatEngine/CEPPlugin+Private.h>


@interface CENTypingIndicatorPluginTest : CENTestCase


#pragma mark -


@end


@implementation CENTypingIndicatorPluginTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}


#pragma mark - Tests :: Configuration

- (void)testConfiguration_ShouldSetDefaultTimeout_WhenNilConfigurationPassed {
    
    CENTypingIndicatorPlugin *plugin = [CENTypingIndicatorPlugin pluginWithIdentifier:@"test" configuration:nil];
    
    XCTAssertNotNil(plugin);
    XCTAssertEqual(((NSNumber *)plugin.configuration[CENTypingIndicatorConfiguration.timeout]).floatValue, 1.f);
}

#pragma mark -


@end
