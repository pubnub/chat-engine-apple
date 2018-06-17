/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENTypingIndicatorExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENChat+Interface.h>
#import "CENTypingIndicatorPlugin.h"


#pragma mark Static

/**
 * @brief  Reference on key under which timer instance store reference on object for which it has been created.
 */
static NSString * const kCENTIObjectKey = @"CENTIObject";


NS_ASSUME_NONNULL_BEGIN


#pragma mark Protected interface declaration

@interface CENTypingIndicatorExtension ()


#pragma mark - Information

/**
 * @brief  Stores whether user currently typing or not.
 */
@property (nonatomic, assign, getter = isTyping) BOOL typing;

/**
 * @brief  Stores reference on typing indicator idle timer.
 */
@property (nonatomic, nullable, strong) NSTimer *idleTimer;


#pragma mark - Handler

/**
 * @brief      Handle idle timer.
 * @discussion If timer fired, it mean what user didn't called \c startTyping in time (for long writting) and remote users
 *             should be notified about typing \b stop.
 *
 * @param timer Reference on timer which triggered this callback.
 */
- (void)handleTypingIdleTimer:(NSTimer *)timer;


#pragma mark - Misc

/**
 * @brief      Create and configure typing idle timer.
 * @discussion Timer instance should include reference on \c object in it's \c userInfo dictionary.
 */
- (void)startIdleTimer;

/**
 * @brief  Invalidate any active typing idle timers.
 */
- (void)stopIdleTimer;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENTypingIndicatorExtension


#pragma mark - Chat activity management

- (void)startTyping {
    
    if (!self.isTyping) {
        [(CENChat *)self.object emitEvent:@"$typingIndicator.startTyping" withData:nil];
    }
    
    self.typing = YES;
    
    [self startIdleTimer];
}

- (void)stopTyping {
    
    if (self.isTyping) {
        [(CENChat *)self.object emitEvent:@"$typingIndicator.stopTyping" withData:nil];
    }
    
    [self stopIdleTimer];
    
    self.typing = NO;
}


#pragma mark - Handlers

- (void)handleTypingIdleTimer:(NSTimer *)timer {
    
    CENChat *chat = timer.userInfo[kCENTIObjectKey];
    
    [chat extensionWithIdentifier:self.identifier context:^(__unused CENTypingIndicatorExtension *extension) {
        [self stopTyping];
    }];
}


#pragma mark - Misc

- (void)startIdleTimer {
    
    NSNumber *timeout = self.configuration[CENTypingIndicatorConfiguration.timeout];
    
    [self stopIdleTimer];
    self.idleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout.doubleValue
                                                      target:self
                                                    selector:@selector(handleTypingIdleTimer:)
                                                    userInfo:@{ kCENTIObjectKey: self.object }
                                                     repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.idleTimer forMode:NSDefaultRunLoopMode];
}

- (void)stopIdleTimer {
    
    if ([self.idleTimer isValid]) {
        [self.idleTimer invalidate];
    }
    
    self.idleTimer = nil;
}

#pragma mark -


@end
