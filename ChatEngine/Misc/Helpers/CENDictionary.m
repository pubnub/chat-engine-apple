/**
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import "CENDictionary.h"


#pragma mark Interface implementation

@implementation CENDictionary


#pragma mark - URL helper

+ (NSString *)queryStringFrom:(NSDictionary *)dictionary {
    
    NSMutableString *query = [NSMutableString new];
    NSCharacterSet *allowed = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    for (NSString *queryKey in dictionary) {
        NSString *value = dictionary[queryKey];
        NSString *encodedValue = [value stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        [query appendFormat:@"%@%@=%@", (query.length ? @"&" : @""), queryKey, encodedValue];
    }
    
    return query.length ? [query copy] : nil;
}

#pragma mark -


@end
