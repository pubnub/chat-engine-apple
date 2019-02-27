/**
 * @author Serhii Mamontov
 * @version 0.0.1
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <CENChatEngine/CEPExtension+Developer.h>
#import "CENEmojiMiddleware+Private.h"
#import "CENEmojiExtension.h"
#import "CENEmojiPlugin.h"


#pragma mark Interface implementation

@implementation CENEmojiExtension


#pragma mark - Preprocessing

- (NSString *)emojiFrom:(NSString *)string {
    
    NSString *emoji = [CENEmojiMiddleware textToEmojiMap][string];
    
    if (!((NSNumber *)self.configuration[CENEmojiConfiguration.useNative]).boolValue && emoji) {
        NSString *emojiURL = self.configuration[CENEmojiConfiguration.emojiURL];
        NSURL *emojiHostURL = [NSURL URLWithString:emojiURL];
        NSString *emojiFile = [[string stringByAppendingString:@".png"]
                               stringByReplacingOccurrencesOfString:@":" withString:@""];
        emoji = [emojiHostURL URLByAppendingPathComponent:emojiFile].absoluteString;
    }
    
    return emoji;
}


#pragma mark - Search

- (NSArray<NSString *> *)emojiWithName:(NSString *)name {
    
    static NSArray *_emojiNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _emojiNames = [CENEmojiMiddleware textToEmojiMap].allKeys;
    });
    
    NSMutableArray *emojiList = [NSMutableArray new];
    
    for (NSString *emoji in _emojiNames) {
        if ([emoji hasPrefix:name]) {
            [emojiList addObject:emoji];
        }
    }
    
    return emojiList;
}


#pragma mark -


@end
