#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief \a NSDictionary interface extension
 *
 * @author Serhii Mamontov
 * @version 0.10.0
 * @copyright © 2010-2018 PubNub, Inc.
 */
@interface CENDictionary : NSObject


#pragma mark URL helper

/**
 * @brief Encode provided \c dictionary to query string.
 *
 * @param dictionary \a NSDictionary which should be encoded.
 *
 * @return Joined string with percent-escaped values.
 */
+ (nullable NSString *)queryStringFrom:(NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
