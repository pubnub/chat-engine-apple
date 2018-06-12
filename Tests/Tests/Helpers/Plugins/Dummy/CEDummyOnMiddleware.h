#import <CENChatEngine/CEPMiddleware.h>


#pragma mark Interface declaration

@interface CEDummyOnMiddleware : CEPMiddleware


#pragma mark - Configuration

/**
 * @brief  Update list of handled events.
 *
 * @param events Reference on list of event names on which middleware should respond.
 */
+ (void)resetEventNames:(NSArray<NSString *> *)events;

#pragma mark -


@end
