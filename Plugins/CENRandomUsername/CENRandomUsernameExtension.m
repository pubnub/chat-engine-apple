/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENRandomUsernameExtension.h"
#import <CENChatEngine/CEPExtension+Developer.h>
#import <CENChatEngine/CENMe+Interface.h>
#import "CENRandomUsernamePlugin.h"


#pragma mark Protected interface declaration

@interface CENRandomUsernameExtension ()


#pragma mark - Misc

/**
 * @brief  Generate new random user", name.
 *
 * @return Reference on randomly generated name.
 */
- (NSString *)randomName;

/**
 * @brief      Generate random integer from within specified range.
 * @discussion Range represent minimum (by \c location field) and maximum (by \c length field) to calculate random integer.
 *
 * @param range Reference on range from within which interger will be returned.
 *
 * @return Random integer from within specified range.
 */
- (NSInteger)randomNumberInRange:(NSRange)range;

#pragma mark -


@end


#pragma mark Interface implementation

@implementation CENRandomUsernameExtension


#pragma mark - Handlers

- (void)onCreate {
    
    NSMutableDictionary *state = [NSMutableDictionary dictionaryWithDictionary:((CENUser *)self.object).state];
    state[self.configuration[CENRandomUsernameConfiguration.propertyName]] = [self randomName];
    
    [(CENMe *)self.object updateState:state];
}


#pragma mark - Misc

- (NSString *)randomName {
    
    static NSArray<NSString *> *_animals;
    static NSArray<NSString *> *_colors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _animals = @[@"igeon", @"eagull", @"at", @"wl", @"parrows", @"obin", @"luebird", @"ardinal", @"awk", @"ish", @"hrimp", @"rog", @"hale",
                     @"hark", @"el", @"eal", @"obster", @"ctopus", @"ole", @"hrew", @"abbit", @"hipmunk", @"rmadillo", @"og", @"at", @"ynx",
                     @"ouse", @"ion", @"oose", @"orse", @"eer", @"accoon", @"ebra", @"oat", @"ow", @"ig", @"iger", @"olf", @"ony", @"ntelope",
                     @"uffalo", @"amel", @"onkey", @"lk", @"ox", @"onkey", @"azelle", @"mpala", @"aguar", @"eopard", @"emur", @"ak", @"lephant",
                     @"iraffe", @"ippopotamus", @"hinoceros", @"rizzlybear"];
        _colors = @[@"ilver", @"ray", @"lack", @"ed", @"aroon", @"live", @"ime", @"reen", @"eal", @"lue", @"avy", @"uchsia", @"urple"];
    });
    
    NSString *randomColor = _colors[[self randomNumberInRange:NSMakeRange(0, _colors.count - 1)]];
    NSString *randomAnimal = _animals[[self randomNumberInRange:NSMakeRange(0, _animals.count - 1)]];
    
    return [@[randomColor,randomAnimal] componentsJoinedByString:@"_"];
}

- (NSInteger)randomNumberInRange:(NSRange)range {
    
    return (arc4random() % (range.length - range.location + 1)) + range.location;
}

#pragma mark -


@end
