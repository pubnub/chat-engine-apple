/**
 * @author Serhii Mamontov
 * @version 1.1.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENRandomUsernameExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENUser+Interface.h>
#import <CENChatEngine/CENMe+Interface.h>
#import "CENRandomUsernamePlugin.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Protected interface declaration

@interface CENRandomUsernameExtension ()


#pragma mark - Misc

/**
 * @brief Generate new random user name.
 *
 * @return Generated name.
 */
- (NSString *)randomName;

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
 *
 * @since 1.1.0
 */
- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary;

/**
 * @brief Generate random integer from within specified range.
 *
 * @param range Range from within which integer will be returned.
 *
 * @return Random integer from within specified range.
 */
- (NSUInteger)randomNumberInRange:(NSRange)range;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark Interface implementation

@implementation CENRandomUsernameExtension


#pragma mark - Handlers

- (void)onCreate {
    
    CENChat *chat = self.configuration[CENRandomUsernameConfiguration.chat];
    NSDictionary *userState = [(CENMe *)self.object stateForChat:chat] ?: @{};
    NSMutableDictionary *state = [self dictionaryDeepMutableFrom:userState];
    
    [self setValue:[self randomName]
        forKeyPath:self.configuration[CENRandomUsernameConfiguration.propertyName]
      inDictionary:state];
    
    [(CENMe *)self.object updateState:state forChat:chat];
}


#pragma mark - Misc

- (NSString *)randomName {
    
    static NSArray<NSString *> *_animals;
    static NSArray<NSString *> *_colors;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _animals = @[@"pigeon", @"seagull", @"bat", @"owl", @"sparrows", @"robin", @"bluebird",
                     @"cardinal", @"hawk", @"fish", @"shrimp", @"frog", @"whale", @"shark", @"eel",
                     @"seal", @"lobster", @"octopus", @"mole", @"shrew", @"rabbit", @"chipmunk",
                     @"armadillo", @"dog", @"cat", @"lynx", @"mouse", @"lion", @"moose", @"horse",
                     @"deer", @"raccoon", @"zebra", @"goat", @"cow", @"pig", @"tiger", @"wolf",
                     @"pony", @"antelope", @"buffalo", @"camel", @"donkey", @"elk", @"fox",
                     @"monkey", @"gazelle", @"impala", @"jaguar", @"leopard", @"lemur", @"yak",
                     @"elephant", @"giraffe", @"hippopotamus", @"rhinoceros", @"grizzlybear"];
        _colors = @[@"silver", @"gray", @"black", @"red", @"maroon", @"olive", @"lime", @"green",
                    @"teal", @"blue", @"navy", @"fuchsia", @"purple"];
    });
    
    NSUInteger randomColorIdx = [self randomNumberInRange:NSMakeRange(0, _colors.count - 1)];
    NSUInteger randomAnimalIdx = [self randomNumberInRange:NSMakeRange(0, _animals.count - 1)];
    NSString *randomColor = _colors[randomColorIdx];
    NSString *randomAnimal = _animals[randomAnimalIdx];
    
    return [@[randomColor,randomAnimal] componentsJoinedByString:@"_"];
}

- (void)setValue:(id)value
      forKeyPath:(NSString *)keyPath
    inDictionary:(NSMutableDictionary *)dictionary {
    
    NSArray<NSString *> *pathComponents = [keyPath componentsSeparatedByString:@"."];
    
    if (pathComponents.count > 1) {
        NSRange pathSubRange = NSMakeRange(0, pathComponents.count - 1);
        NSArray *pathSubComponents = [pathComponents subarrayWithRange:pathSubRange];
        NSMutableDictionary *currentRoot = dictionary;
        
        for (NSString *key in pathSubComponents) {
            if (!currentRoot[key]) {
                currentRoot[key] = [NSMutableDictionary new];
            }
            
            currentRoot = currentRoot[key];
        }
        
        [currentRoot setValue:value forKeyPath:pathComponents.lastObject];
    } else {
        [dictionary setValue:value forKeyPath:keyPath];
    }
}

- (NSMutableDictionary *)dictionaryDeepMutableFrom:(NSDictionary *)dictionary {
    
    NSMutableDictionary *mutable = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    for (NSString *key in dictionary) {
        if ([dictionary[key] isKindOfClass:[NSDictionary class]]) {
            mutable[key] = [self dictionaryDeepMutableFrom:dictionary[key]];
        }
    }
    
    return mutable;
}

- (NSUInteger)randomNumberInRange:(NSRange)range {
    
    return (arc4random() % (range.length - range.location + 1)) + range.location;
}

#pragma mark -


@end
