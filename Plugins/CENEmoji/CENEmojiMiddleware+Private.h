/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEmojiMiddleware.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface CENEmojiMiddleware (Private)


#pragma mark - Information

/**
 * @brief Shared resources access serialization queue.
 */
@property (class, nonatomic, readonly, strong) dispatch_queue_t resourcesAccessQueue;


#pragma mark - Mapping

/**
 * @brief Map of system's emoji to their textual representation.
 *
 * @return \a NSDictionary with emoji mapped to their \c names.
 */
+ (NSDictionary *)emojiToTextMap;

/**
 * @brief Map of textual emoji representation to their system's representation.
 *
 * @return \a NSDictionary with emoji \c names mapped to their system's representation.
 */
+ (NSDictionary *)textToEmojiMap;


#pragma mark - Misc

/**
 * @brief Update value in \c dictionary.
 *
 * @param value Object which should be stored at specified location.
 * @param keyPath Key or path to location where \c value should be stored.
 * @param dictionary \a NSMutableDictionary with mutable content which should be modified.
 */
- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary;

/**
 * @brief Create mutable copy from \a NSDictionary by replacing other \a NSDictionary values in it
 * with \a NSMutableDictionary.
 *
 * @param dictionary \a NSDictionary from which deep mutable copy should be created.
 *
 * @return Mutable dictionary with mutable content.
 */
- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
