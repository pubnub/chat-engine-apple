/**
 * @author Serhii Mamontov
 * @since 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEDummyExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>


#pragma mark - Protected interface declaration

@interface CEDummyExtension ()


#pragma mark - Information

@property (nonatomic, strong) NSTimer *testTimer;


#pragma mark - Handlers

- (void)handleTimer:(NSTimer *)timer;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CEDummyExtension


#pragma mark - Extension methods

- (CENObject *)testMethodReturningParentObject {
    
    return self.object;
}


#pragma mark - Handlers

- (void)onCreate {
    
    self.constructWorks = YES;
    self.testTimer = [NSTimer scheduledTimerWithTimeInterval:1000.f target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (void)handleTimer:(NSTimer *)timer {
    
}

#pragma mark -


@end
