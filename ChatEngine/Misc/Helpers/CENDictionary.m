/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENDictionary.h"


#pragma mark - Interface implementation

@implementation CENDictionary


#pragma mark - URL helper

+ (NSString *)queryStringFrom:(NSDictionary *)dictionary {
    
    NSMutableString *query = [NSMutableString new];
    NSCharacterSet *allowedCharacters = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    for (NSString *queryKey in dictionary) {
        NSString *encodedValue = [(NSString *)dictionary[queryKey] stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        [query appendFormat:@"%@%@=%@", (query.length ? @"&" : @""), queryKey, encodedValue];
    }
    
    return query.length ? [query copy] : nil;
}

#pragma mark -


@end
