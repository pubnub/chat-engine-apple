#import "CENMe+Interface.h"


#pragma mark Private interface declaration

@interface CENMe (Private)


#pragma mark - State

- (void)updateState:(nullable NSDictionary *)state withCompletion:(nullable dispatch_block_t)block;

#pragma mark -


@end
