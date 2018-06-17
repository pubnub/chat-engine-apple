#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  Useful NSDictionary additions collection.
 *
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENDictionary : NSObject


///------------------------------------------------
/// @name URL helper
///------------------------------------------------

/**
 * @brief  Encode provided \c dictionary to string which can be used with reuests.
 *
 * @param dictionary Dictionary which should be encoded.
 *
 * @return Joined string with percent-escaped kevy values.
 */
+ (nullable NSString *)queryStringFrom:(NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
