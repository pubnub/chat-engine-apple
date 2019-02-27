/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import "CENEmojiOnMiddleware.h"
#import <CENChatEngine/CEPMiddleware+Developer.h>
#import "CENEmojiMiddleware+Private.h"
#import "CENEmojiPlugin.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENEmojiOnMiddleware ()


#pragma mark - Information

/**
 * @brief \a NSDictionary which is used to store previuosly downloaded emoji representation image
 * instances (depends on platform).
 */
@property (class, nonatomic, readonly, strong) NSMutableDictionary *emojiCache;

/**
 * @brief Regular expression which used to find textified emoji entries in tested strings.
 */
@property (class, nonatomic, readonly, strong) NSRegularExpression *regex;


#pragma mark - Misc

/**
 * @brief Retrieve previously cached \c emoji image representation.
 *
 * @param emojiName Name of emoji for which image has been downloaded and placed into cache before.
 *
 * @return Image representing instance (depends on platform) for specified \c emojiName or \c nil in
 * case if image not cached yet.
 */
+ (nullable id)cachedImageForEmoji:(NSString *)emojiName;

/**
 * @brief Cache image representation for \c emoji.
 *
 * @param image Downloaded \c emoji image representation instance (depends on platform).
 * @param emojiName Name of emoji for which image has been downloaded and placed into cache before.
 */
+ (void)cacheImage:(id)image forEmoji:(NSString *)emojiName;

/**
 * @brief Pre-process passed string and replace any known textual emoji representation with native
 * version.
 *
 * @param string String which should be pre-processed.
 *
 * @return String with native emoji representation.
 */
- (NSString *)stringByParsingNativeEmojiFrom:(NSString *)string;

/**
 * @brief Pre-process passed string by transforming it to \a NSAttributedString and replace any
 * textual emoji representation with \a NSTextAttachment pointing to remote PNG file which represent
 * target emoji.
 *
 * @param string String which should be pre-processed.
 * @param url URL which point to remote host, which can be used in path concatination to append
 *     emoji name to it.
 *
 * @return Attributed string with attachments as emoji representation.
 */
- (NSAttributedString *)stringByParsingRemoteEmojiFrom:(NSString *)string
                                          withEmojiURL:(NSString *)url;

/**
 * @brief Find and return ranges of emoji which has been found in tested \c string.
 *
 * @param string String inside of which textified emoji should be found.
 *
 * @return List of ranges which represent emoji.
 */
- (NSArray<NSTextCheckingResult *> *)emojiRangesFrom:(NSString *)string;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CENEmojiOnMiddleware


#pragma mark - Information

+ (NSString *)location {
    
    return CEPMiddlewareLocation.on;
}

+ (NSArray<NSString *> *)events {
    
    return @[@"*"];
}

+ (NSMutableDictionary *)emojiCache {
    
    static NSMutableDictionary *_sharedEmojiCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEmojiCache = [NSMutableDictionary new];
    });
    
    return _sharedEmojiCache;
}

+ (NSRegularExpression *)regex {
    
    static NSRegularExpression *_sharedRegex;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSRegularExpressionOptions option = NSRegularExpressionCaseInsensitive;
        NSString *pattern = @":.+?:";
        
        _sharedRegex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                 options:option
                                                                   error:nil];
    });
    
    return _sharedRegex;
}


#pragma mark - Call

- (void)runForEvent:(NSString *)__unused event
           withData:(NSMutableDictionary *)data
         completion:(void (^)(BOOL rejected))block {
    
    NSString *messageKey = self.configuration[CENEmojiConfiguration.messageKey];
    id message = [(NSDictionary *)data[CENEventData.data] valueForKeyPath:messageKey];
    NSString *emojiURL = self.configuration[CENEmojiConfiguration.emojiURL];
    id parsedMessage = nil;
    
    if (![message isKindOfClass:[NSString class]] || !((NSString *)message).length) {
        block(NO);
        return;
    }
    
    if (!((NSNumber *)self.configuration[CENEmojiConfiguration.useNative]).boolValue) {
        parsedMessage = [self stringByParsingRemoteEmojiFrom:message withEmojiURL:emojiURL];
    } else {
        parsedMessage = [self stringByParsingNativeEmojiFrom:message];
    }
    
    if ([parsedMessage isKindOfClass:[NSAttributedString class]] ||
        ![parsedMessage isEqualToString:messageKey]) {
        NSMutableDictionary *payloadData = [self dictionaryDeepMutableFrom:data[CENEventData.data]];
        
        [self setValue:[parsedMessage copy] forKeyPath:messageKey inDictionary:payloadData];
        data[CENEventData.data] = payloadData;
    }
    
    block(NO);
}


#pragma mark - Misc

+ (id)cachedImageForEmoji:(NSString *)emojiName {
    
    __block id image = nil;
    
    dispatch_sync(self.resourcesAccessQueue, ^{
        image = self.emojiCache[emojiName];
    });
    
    return image;
}

+ (void)cacheImage:(id)image forEmoji:(NSString *)emojiName {
    
    if (!image) {
        return;
    }
    
    dispatch_async(self.resourcesAccessQueue, ^{
        self.emojiCache[emojiName] = image;
    });
}

- (NSString *)stringByParsingNativeEmojiFrom:(NSString *)string {
    
    NSArray<NSTextCheckingResult *> *matches = [self emojiRangesFrom:string];
    NSMutableString *mutableMessage = [string mutableCopy];
    NSDictionary *emojiMap = [[self class] textToEmojiMap];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:^(NSTextCheckingResult *result,
                                           NSUInteger __unused idx,
                                           BOOL * __unused stop) {
        
        NSRange emojiRange = [result rangeAtIndex:0];
        NSString *nativeRepresentation = emojiMap[[string substringWithRange:emojiRange]];
                                  
        if (nativeRepresentation) {
            [mutableMessage replaceCharactersInRange:emojiRange withString:nativeRepresentation];
        }
    }];
    
    return matches.count > 0 ? mutableMessage : string;
}

- (NSAttributedString *)stringByParsingRemoteEmojiFrom:(NSString *)string
                                          withEmojiURL:(NSString *)url {
    
    NSMutableAttributedString *mutableMessage;
    mutableMessage = [[NSMutableAttributedString alloc] initWithString:string];
    NSArray<NSTextCheckingResult *> *matches = [self emojiRangesFrom:string];
    __block NSAttributedString * stringWithAttachment = nil;
    NSURL *emojiHostURL = [NSURL URLWithString:url];
    __block NSUInteger numberOfReplacements = 0;
    __block NSTextAttachment *attachment = nil;
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:^(NSTextCheckingResult *result,
                                           NSUInteger __unused idx,
                                           BOOL *__unused stop) {
                                  
        NSRange emojiRange = [result rangeAtIndex:0];
        NSString *emojiName = [string substringWithRange:emojiRange];
        NSString *emojiFile = [[emojiName stringByAppendingString:@".png"]
                               stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSURL *emojiURL = [emojiHostURL URLByAppendingPathComponent:emojiFile];
        attachment = [NSTextAttachment new];
        attachment.image = [[self class] cachedImageForEmoji:emojiName];
                                  
        if (!attachment.image) {
            NSData *imageData = [NSData dataWithContentsOfURL:emojiURL];
#if TARGET_OS_OSX
            attachment.image = [[NSImage alloc] initWithData:imageData];
#else
            attachment.image = [UIImage imageWithData:imageData];
#endif // TARGET_OS_OSX
            [[self class] cacheImage:attachment.image forEmoji:emojiName];
        }
                                  
        if (attachment.image) {
            stringWithAttachment = [NSAttributedString attributedStringWithAttachment:attachment];

            [mutableMessage replaceCharactersInRange:emojiRange
                                withAttributedString:stringWithAttachment];
            numberOfReplacements++;
        }
    }];
    
    return numberOfReplacements > 0 ? mutableMessage : (id)string;
}

- (NSArray<NSTextCheckingResult *> *)emojiRangesFrom:(NSString *)string {
    
    NSRegularExpression *regex  = [self class].regex;
    
    return [regex matchesInString:string options:0 range:NSMakeRange(0, string.length)];
}

#pragma mark -


@end
