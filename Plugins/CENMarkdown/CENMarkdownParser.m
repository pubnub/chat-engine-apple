/**
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENMarkdownParser.h"
#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#else
#import <UIKit/UIKit.h>
#endif // TARGET_OS_OSX


#pragma mark Extern

CENMarkdownParserElements CENMarkdownParserElement = {
    .defaultAttributes = @"default",
    .italicAttributes = @"italic",
    .boldAttributes = @"bold",
    .strikethroughAttributes = @"strikethrough",
    .linkAttributes = @"link",
    .codeAttributes = @"code"
};

struct CENMarkdownParserExtendedElements {
    __unsafe_unretained NSString *boldItalicAttributes;
    __unsafe_unretained NSString *linkItalicAttributes;
    __unsafe_unretained NSString *linkBoldAttributes;
    __unsafe_unretained NSString *linkBoldItalicAttributes;
    __unsafe_unretained NSString *codeLinkAttributes;
    __unsafe_unretained NSString *codeItalicAttributes;
    __unsafe_unretained NSString *codeItalicLinkAttributes;
    __unsafe_unretained NSString *codeBoldAttributes;
    __unsafe_unretained NSString *codeBoldLinkAttributes;
    __unsafe_unretained NSString *codeBoldItalicAttributes;
    __unsafe_unretained NSString *codeBoldItalicLinkAttributes;
} CENMarkdownParserExtendedElement = {
    .boldItalicAttributes = @"boldItalic",
    .linkItalicAttributes = @"linkItalic",
    .linkBoldAttributes = @"linkBold",
    .linkBoldItalicAttributes = @"linkBoldItalic",
    .codeLinkAttributes = @"codeLink",
    .codeItalicAttributes = @"codeItalic",
    .codeItalicLinkAttributes = @"codeItalicLink",
    .codeBoldAttributes = @"codeBold",
    .codeBoldLinkAttributes = @"codeBoldLink",
    .codeBoldItalicAttributes = @"codeBoldItalic",
    .codeBoldItalicLinkAttributes = @"codeBoldItalicLink"
};


#pragma mark - Enums

typedef NS_OPTIONS(uint32_t, CENMPFontDescriptorSymbolicTraits) {
    CENMPFontDescriptorTraitRegular = 0,
#if TARGET_OS_OSX
    CENMPFontDescriptorTraitItalic = NSFontDescriptorTraitItalic,
    CENMPFontDescriptorTraitBold = NSFontDescriptorTraitBold,
    CENMPFontDescriptorTraitMonoSpace = NSFontDescriptorTraitMonoSpace,
    CENMPFontDescriptorTraitLink = NSFontDescriptorTraitCondensed,
    CENMPFontDescriptorTraitStrikethrough = NSFontDescriptorTraitExpanded
#else
    CENMPFontDescriptorTraitItalic = UIFontDescriptorTraitItalic,
    CENMPFontDescriptorTraitBold = UIFontDescriptorTraitBold,
    CENMPFontDescriptorTraitMonoSpace = UIFontDescriptorTraitMonoSpace,
    CENMPFontDescriptorTraitLink = UIFontDescriptorTraitCondensed,
    CENMPFontDescriptorTraitStrikethrough = UIFontDescriptorTraitExpanded
#endif // TARGET_OS_OSX
};


#pragma mark - Statics

static CGFloat kCENMPDefaultFontSize = 14.f;


#pragma mark - Const

static NSString * const kCENMPTraitsAttributeKey = @"CENMPTraitsAttributeKey";
static NSString * const kCENMPDefaultMonospaceFontName = @"Courier";
static NSString * const kCENMPDefaultFontName = @"HelveticaNeue";


#pragma mark - Protected interface

@interface CENMarkdownParser ()


#pragma mark - Information

@property (nonatomic, copy) NSMutableDictionary<NSString *, NSDictionary<NSAttributedStringKey, id> *> *configuration;
@property (nonatomic, strong) NSRegularExpression *underscoreItalicMatchRegExp;
@property (nonatomic, strong) NSRegularExpression *asteriskItalicMatchRegExp;
@property (nonatomic, strong) NSRegularExpression *underscoreBoldMatchRegExp;
@property (nonatomic, strong) NSRegularExpression *strikethroughMatchRegExp;
@property (nonatomic, strong) NSRegularExpression *asteriskBoldMatchRegExp;
@property (nonatomic, strong) NSRegularExpression *imageMatchRegExp;
@property (nonatomic, strong) NSRegularExpression *linkMatchRegExp;
@property (nonatomic, strong) NSRegularExpression *codeMatchRegExp;
@property (nonatomic, strong) NSMutableDictionary *attributesMap;
@property (nonatomic, strong) NSCharacterSet *verificationSet;



#pragma mark - Initialization and Configuration

- (instancetype)initWithConfiguration:(nullable NSDictionary<NSString *, NSDictionary<NSAttributedStringKey, id> *> *)configuration;


#pragma mark - Substitution

- (BOOL)substituteInlineCodeIn:(NSMutableAttributedString *)string;
- (BOOL)substituteBoldIn:(NSMutableAttributedString *)string;
- (BOOL)substituteItalicIn:(NSMutableAttributedString *)string;
- (BOOL)substituteStrikethroughIn:(NSMutableAttributedString *)string;
- (void)substituteDataMatchedBy:(NSTextCheckingResult *)match
                       inString:(NSMutableAttributedString *)string
                usingAttributes:(NSDictionary *)attributes;


#pragma mark - Misc

- (void)setDefaultAttributes;
- (void)prepareMatchers;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENMarkdownParser


#pragma mark - Initialization and Configuration

+ (instancetype)parserWithConfiguration:(NSDictionary<NSString *,NSDictionary<NSAttributedStringKey,id> *> *)configuration {
    
    return [[self alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(NSDictionary<NSString *,NSDictionary<NSAttributedStringKey,id> *> *)configuration {
    
    if ((self = [super init])) {
        _verificationSet = [NSCharacterSet alphanumericCharacterSet];
        _configuration = [(configuration ?: @{}) mutableCopy];
        _attributesMap = [NSMutableDictionary new];
        
        [self setDefaultAttributes];
        [self prepareMatchers];
        
    }
    
    return self;
}


#pragma mark - Parse

- (void)parseMarkdownString:(NSString *)markdown withCompletion:(void (^)(id result))completion {
    
    dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *defaultAttributes = self.configuration[CENMarkdownParserElement.defaultAttributes];
        NSString *targetMarkdownString = [NSString stringWithFormat:@" %@ ", markdown];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:targetMarkdownString
                                                                                             attributes:defaultAttributes];
        
        BOOL imagesFound = [self substituteImageURLWithAttachmensIn:attributedString];
        BOOL linksFound = [self substituteLinksIn:attributedString];
        BOOL inlineCodeFound = [self substituteInlineCodeIn:attributedString];
        BOOL boldFound = [self substituteBoldIn:attributedString];
        BOOL italicFound = [self substituteItalicIn:attributedString];
        BOOL strikethroughFound = [self substituteStrikethroughIn:attributedString];
        BOOL hasMarkdownMarkup = imagesFound || inlineCodeFound || linksFound || boldFound || italicFound || strikethroughFound;
        
        // Trimming spaces which has been added to allow RegExp handle properly.
        if (hasMarkdownMarkup) {
            [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
            [attributedString replaceCharactersInRange:NSMakeRange(attributedString.length - 1, 1) withString:@""];
        }
        
        completion(hasMarkdownMarkup ? attributedString : markdown);
    });
}


#pragma mark - Substitution

- (BOOL)substituteInlineCodeIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSArray<NSTextCheckingResult *> *matches = [self.codeMatchRegExp matchesInString:string.string options:0 range:searchRange];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match,
                                                                           __unused NSUInteger matchIdx,
                                                                           __unused BOOL *stop) {
        
        [self substituteDataMatchedBy:match inString:string usingAttributes:self.configuration[CENMarkdownParserElement.codeAttributes]];
    }];
    
    return matches.count > 0;
}

- (BOOL)substituteBoldIn:(NSMutableAttributedString *)string {
    
    NSArray<NSRegularExpression *> *matchRegExps = @[self.underscoreBoldMatchRegExp, self.asteriskBoldMatchRegExp];
    __block NSUInteger matchesFound = 0;
    
    for (NSRegularExpression *matchRegExp in matchRegExps) {
        NSRange searchRange = NSMakeRange(0, string.length);
        NSArray<NSTextCheckingResult *> *matches = [matchRegExp matchesInString:string.string options:0 range:searchRange];
        
        [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match,
                                                                               __unused NSUInteger matchIdx,
                                                                               __unused BOOL *stop) {
            
            [self substituteDataMatchedBy:match inString:string usingAttributes:self.configuration[CENMarkdownParserElement.boldAttributes]];
        }];
        
        matchesFound += matches.count;
    }
    
    return matchesFound > 0;
}

- (BOOL)substituteItalicIn:(NSMutableAttributedString *)string {
    
    NSArray<NSRegularExpression *> *matchRegExps = @[self.underscoreItalicMatchRegExp, self.asteriskItalicMatchRegExp];
    __block NSUInteger matchesFound = 0;
    
    for (NSRegularExpression *matchRegExp in matchRegExps) {
        NSRange searchRange = NSMakeRange(0, string.length);
        NSArray<NSTextCheckingResult *> *matches = [matchRegExp matchesInString:string.string options:0 range:searchRange];
        
        [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match,
                                                                               __unused NSUInteger matchIdx,
                                                                               __unused BOOL *stop) {
            
            [self substituteDataMatchedBy:match inString:string usingAttributes:self.configuration[CENMarkdownParserElement.italicAttributes]];
        }];
        
        matchesFound += matches.count;
    }
    
    return matchesFound > 0;
}

- (BOOL)substituteStrikethroughIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSArray<NSTextCheckingResult *> *matches = [self.strikethroughMatchRegExp matchesInString:string.string options:0 range:searchRange];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match,
                                                                           __unused NSUInteger matchIdx,
                                                                           __unused BOOL *stop) {
        
        [self substituteDataMatchedBy:match inString:string usingAttributes:self.configuration[CENMarkdownParserElement.strikethroughAttributes]];
    }];
    
    return matches.count > 0;
}

- (void)substituteDataMatchedBy:(NSTextCheckingResult *)match
                       inString:(NSMutableAttributedString *)string
                usingAttributes:(NSDictionary *)attributes {
    
    NSUInteger targetTraits = ((NSNumber *)attributes[kCENMPTraitsAttributeKey]).unsignedIntegerValue;
    BOOL isLink = targetTraits == CENMPFontDescriptorTraitLink;
    BOOL isCode = (targetTraits & CENMPFontDescriptorTraitMonoSpace) != 0;
    BOOL isStrikethrough = targetTraits == CENMPFontDescriptorTraitStrikethrough;
    NSRange dataRange = !isLink ? [match rangeAtIndex:2] : [match rangeAtIndex:1];
    NSMutableAttributedString *attributedString = nil;
    NSRange replacementRange = match.range;
    
    if (!isLink) {
        replacementRange = NSMakeRange([match rangeAtIndex:1].location, NSMaxRange([match rangeAtIndex:3]) - [match rangeAtIndex:1].location);
    }
    
    if ([self isDataMatchedBy:match insideOfCodeBlockInString:string]) {
        return;
    }
    
    attributedString = [[string attributedSubstringFromRange:dataRange] mutableCopy];
    dataRange = NSMakeRange(0, attributedString.length);
    NSUInteger processedDataLength = 0;
    
    do {
        NSRange attributesRange;
        NSMutableDictionary *storedAttributes = [[attributedString attributesAtIndex:processedDataLength
                                                               longestEffectiveRange:&attributesRange
                                                                             inRange:dataRange] mutableCopy];
        NSUInteger storedTraits = ((NSNumber *)storedAttributes[kCENMPTraitsAttributeKey]).unsignedIntegerValue;
        id foregroundColor = storedAttributes[NSForegroundColorAttributeName];
        id backgroundColor = storedAttributes[NSBackgroundColorAttributeName];
        NSUInteger aggregatedTraits = !isLink || isCode ? storedTraits | targetTraits : storedTraits;
        
        
        if (storedTraits == 0 || (storedTraits & aggregatedTraits) != 0 || isLink) {
            [storedAttributes addEntriesFromDictionary:self.attributesMap[@(aggregatedTraits)]];
            
            if (isLink || isStrikethrough) {
                [storedAttributes addEntriesFromDictionary:attributes];
            }
            
            if (isStrikethrough) {
                storedAttributes[NSStrikethroughColorAttributeName] = storedAttributes[NSForegroundColorAttributeName];
            }
            
            if ((storedTraits & CENMPFontDescriptorTraitMonoSpace) != 0) {
                storedAttributes[NSForegroundColorAttributeName] = foregroundColor;
                storedAttributes[NSBackgroundColorAttributeName] = backgroundColor;
            }
            
            [attributedString setAttributes:storedAttributes range:attributesRange];
        }
        
        processedDataLength += attributesRange.length;
    } while (processedDataLength < dataRange.length);
    
    [string replaceCharactersInRange:replacementRange withAttributedString:attributedString];
}

- (BOOL)substituteImageURLWithAttachmensIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSArray<NSTextCheckingResult *> *matches = [self.imageMatchRegExp matchesInString:string.string options:0 range:searchRange];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match,
                                                                           __unused NSUInteger matchIdx,
                                                                           __unused BOOL *stop) {
        
        NSString *imageURL = [string.string substringWithRange:[match rangeAtIndex:1]];
        
        if (imageURL.length) {
            NSTextAttachment *attachment = [NSTextAttachment new];
            
            if ([imageURL hasPrefix:@"http"]) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
                attachment.image = [UIImage imageWithData:imageData];
            } else {
                attachment.image = [UIImage imageWithContentsOfFile:imageURL];
            }
            
            NSAttributedString *attributedStringWithImage = [NSAttributedString attributedStringWithAttachment:attachment];
            
            [string replaceCharactersInRange:[match rangeAtIndex:0] withAttributedString:attributedStringWithImage];
        }
    }];
    
    return matches.count > 0;
}

- (BOOL)substituteLinksIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSArray<NSTextCheckingResult *> *matches = [self.linkMatchRegExp matchesInString:string.string options:0 range:searchRange];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSTextCheckingResult *match,
                                                                           __unused NSUInteger matchIdx,
                                                                           __unused BOOL *stop) {
        
        NSString *linkTitle = [string.string substringWithRange:[match rangeAtIndex:1]];
        NSString *url = [string.string substringWithRange:[match rangeAtIndex:2]];
        
        if (linkTitle.length && url.length) {
            NSMutableDictionary *attriutes = [self.configuration[CENMarkdownParserElement.linkAttributes] mutableCopy];
            attriutes[NSLinkAttributeName] = url;
            
            [self substituteDataMatchedBy:match inString:string usingAttributes:attriutes];
        }
    }];
    
    return matches.count > 0;
}


#pragma mark - Misc

- (void)setDefaultAttributes {
    
    Class fontClass = nil;
    Class colorClass = nil;
#if TARGET_OS_OSX
    colorClass = [NSColor class];
    fontClass = [NSFont class];
#else
    colorClass = [UIColor class];
    fontClass = [UIFont class];
#endif // TARGET_OS_OSX
    
    
    NSMutableDictionary *attributes = nil;
    if (!self.configuration[CENMarkdownParserElement.defaultAttributes]) {
        id defaultFont = [fontClass fontWithName:kCENMPDefaultFontName size:kCENMPDefaultFontSize];
        attributes = [@{ NSFontAttributeName: defaultFont, NSForegroundColorAttributeName: [colorClass blackColor] } mutableCopy];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.defaultAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitRegular);
    self.configuration[CENMarkdownParserElement.defaultAttributes] = attributes;
    self.attributesMap[@(CENMPFontDescriptorTraitRegular)] = self.configuration[CENMarkdownParserElement.defaultAttributes];
    
    [self setDefaultItalicAttributes];
    [self setDefaultBoldAttributes];
    [self setDefaultBoldItalicAttributes];
    [self setDefaultStrikethroughAttributes];
    [self setDefaultLinkAttributes];
    [self setDefaultLinkItalicAttributes];
    [self setDefaultLinkBoldAttributes];
    [self setDefaultLinkBoldItalicAttributes];
    [self setDefaultCodeAttributes];
    [self setDefaultCodeLinkAttributes];
    [self setDefaultCodeItalicAttributes];
    [self setDefaultCodeItalicLinkAttributes];
    [self setDefaultCodeBoldAttributes];
    [self setDefaultCodeBoldLinkAttributes];
    [self setDefaultCodeBoldItalicAttributes];
    [self setDefaultCodeBoldItalicLinkAttributes];
}

- (void)setDefaultItalicAttributes {
    
    NSMutableDictionary *attributes = nil;
    if (!self.configuration[CENMarkdownParserElement.italicAttributes]) {
        id defaultFont = self.configuration[CENMarkdownParserElement.defaultAttributes][NSFontAttributeName];
        id italicFont = [self fontForTraits:CENMPFontDescriptorTraitItalic from:defaultFont];
        attributes = [self.configuration[CENMarkdownParserElement.defaultAttributes] mutableCopy];
        [attributes addEntriesFromDictionary:@{ NSFontAttributeName: italicFont ?: defaultFont }];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.italicAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitItalic);
    self.configuration[CENMarkdownParserElement.italicAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = self.configuration[CENMarkdownParserElement.italicAttributes];
}

- (void)setDefaultBoldAttributes {
    
    NSMutableDictionary *attributes = nil;
    if (!self.configuration[CENMarkdownParserElement.boldAttributes]) {
        id defaultFont = self.configuration[CENMarkdownParserElement.defaultAttributes][NSFontAttributeName];
        id boldFont = [self fontForTraits:CENMPFontDescriptorTraitBold from:defaultFont];
        attributes = [self.configuration[CENMarkdownParserElement.defaultAttributes] mutableCopy];
        [attributes addEntriesFromDictionary:@{ NSFontAttributeName: boldFont ?: defaultFont }];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.boldAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitBold);
    self.configuration[CENMarkdownParserElement.boldAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = self.configuration[CENMarkdownParserElement.boldAttributes];
}

- (void)setDefaultBoldItalicAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.boldAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic);
    id boldFont = attributes[NSFontAttributeName];
    id boldItalicFont = [self fontForTraits:(CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic) from:boldFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: boldItalicFont ?: boldFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.boldItalicAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.boldItalicAttributes];
}

- (void)setDefaultStrikethroughAttributes {
    
    NSMutableDictionary *attributes = nil;
    if (!self.configuration[CENMarkdownParserElement.strikethroughAttributes]) {
        attributes = [@{ NSStrikethroughStyleAttributeName: @(NSUnderlineStyleThick) } mutableCopy];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.strikethroughAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitStrikethrough);
    self.configuration[CENMarkdownParserElement.strikethroughAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = self.configuration[CENMarkdownParserElement.strikethroughAttributes];
}

- (void)setDefaultLinkAttributes {
    
    id defaultFont = self.configuration[CENMarkdownParserElement.defaultAttributes][NSFontAttributeName];
    NSMutableDictionary *attributes = [(self.configuration[CENMarkdownParserElement.linkAttributes] ?: @{}) mutableCopy];
    attributes[NSFontAttributeName] = attributes[NSFontAttributeName] ?:defaultFont;
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitLink);
    self.configuration[CENMarkdownParserElement.linkAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = self.configuration[CENMarkdownParserElement.linkAttributes];
}

- (void)setDefaultLinkItalicAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.linkAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitLink | CENMPFontDescriptorTraitItalic);
    id linkFont = attributes[NSFontAttributeName];
    id linkItalicFont = [self fontForTraits:CENMPFontDescriptorTraitItalic from:linkFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: linkItalicFont ?: linkFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.linkItalicAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.linkItalicAttributes];
}

- (void)setDefaultLinkBoldAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.linkAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitLink | CENMPFontDescriptorTraitBold);
    id linkFont = attributes[NSFontAttributeName];
    id linkBoldFont = [self fontForTraits:CENMPFontDescriptorTraitBold from:linkFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: linkBoldFont ?: linkFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.linkBoldAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.linkBoldAttributes];
}

- (void)setDefaultLinkBoldItalicAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.linkAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitLink | CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic);
    id linkFont = attributes[NSFontAttributeName];
    id linkBoldItalicFont = [self fontForTraits:(CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic) from:linkFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: linkBoldItalicFont ?: linkFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.linkBoldItalicAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.linkBoldItalicAttributes];
}

- (void)setDefaultCodeAttributes {
    
    Class fontClass = nil;
    Class colorClass = nil;
#if TARGET_OS_OSX
    colorClass = [NSColor class];
    fontClass = [NSFont class];
#else
    colorClass = [UIColor class];
    fontClass = [UIFont class];
#endif // TARGET_OS_OSX
    
    NSMutableDictionary *attributes = nil;
    if (!self.configuration[CENMarkdownParserElement.codeAttributes]) {
        id defaultFont = self.configuration[CENMarkdownParserElement.defaultAttributes][NSFontAttributeName];
        id monospaceFont = [fontClass fontWithName:kCENMPDefaultMonospaceFontName size:[defaultFont pointSize]];
        attributes = [self.configuration[CENMarkdownParserElement.defaultAttributes] mutableCopy];
        [attributes addEntriesFromDictionary:@{
                                               NSFontAttributeName: monospaceFont ?: defaultFont,
                                               NSBackgroundColorAttributeName: [colorClass lightGrayColor],
                                               NSForegroundColorAttributeName: [colorClass darkGrayColor]
                                               }];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.codeAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitMonoSpace);
    self.configuration[CENMarkdownParserElement.codeAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = self.configuration[CENMarkdownParserElement.codeAttributes];
}

- (void)setDefaultCodeLinkAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.codeAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeLinkAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.codeLinkAttributes];
}

- (void)setDefaultCodeBoldAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.codeAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold);
    id codeFont = attributes[NSFontAttributeName];
    id codeBoldFont = [self fontForTraits:CENMPFontDescriptorTraitBold from:codeFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: codeBoldFont ?: codeFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.codeBoldAttributes];
}

- (void)setDefaultCodeBoldLinkAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserExtendedElement.codeBoldAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldLinkAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.codeBoldLinkAttributes];
}

- (void)setDefaultCodeItalicAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.codeAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitItalic);
    id codeFont = attributes[NSFontAttributeName];
    id codeItalicFont = [self fontForTraits:CENMPFontDescriptorTraitItalic from:codeFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: codeItalicFont ?: codeFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.codeItalicAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.codeItalicAttributes];
}

- (void)setDefaultCodeItalicLinkAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserExtendedElement.codeItalicAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitItalic | CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeItalicLinkAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.codeItalicLinkAttributes];
}

- (void)setDefaultCodeBoldItalicAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserElement.codeAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic);
    id codeFont = attributes[NSFontAttributeName];
    id codeBoldItalicFont = [self fontForTraits:(CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic) from:codeFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: codeBoldItalicFont ?: codeFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicAttributes];
}

- (void)setDefaultCodeBoldItalicLinkAttributes {
    
    NSMutableDictionary *attributes = [self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicAttributes] mutableCopy];
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic |
    CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicLinkAttributes] = attributes;
    self.attributesMap[trait] = self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicLinkAttributes];
}

- (id)fontForTraits:(CENMPFontDescriptorSymbolicTraits)traits from:(id)font {
    
    Class fontClass = nil;
#if TARGET_OS_OSX
    fontClass = [NSFont class];
#else
    fontClass = [UIFont class];
#endif // TARGET_OS_OSX
    
    NSArray<NSString *> *boldItalicTraitNames = @[@"BoldItalic", @"BlackItalic", @"BoldOblique", @"BlackOblique"];
    UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits = [font fontDescriptor].symbolicTraits;
    BOOL alreadyItalicFont = (fontDescriptorSymbolicTraits & CENMPFontDescriptorTraitItalic) != 0;
    BOOL alreadyBoldFont = (fontDescriptorSymbolicTraits & CENMPFontDescriptorTraitBold) != 0;
    NSArray<NSString *> *traitNames = @[@"Italic", @"Bold", @"Oblique", @"Black"];
    BOOL italicRequired = (traits & CENMPFontDescriptorTraitItalic) != 0;
    BOOL boldRequired = (traits & CENMPFontDescriptorTraitBold) != 0;
    NSArray<NSString *> *italicTraitNames = @[@"Italic", @"Oblique"];
    NSArray<NSString *> *boldTraitNames = @[@"Bold", @"Black"];
    NSString *fontName = [font fontName];
    CGFloat fontSize = [font pointSize];
    NSArray *targetTraitNames = nil;
    
    if ((italicRequired && alreadyItalicFont && !boldRequired) || (boldRequired && alreadyBoldFont && !italicRequired) ||
        (italicRequired && alreadyItalicFont && boldRequired && alreadyBoldFont)) {
        
        return font;
    }
    
    for (NSString *traitName in traitNames) {
        if ([fontName rangeOfString:traitName options:(NSBackwardsSearch | NSCaseInsensitiveSearch)].location != NSNotFound) {
            fontName = [fontName substringToIndex:[fontName rangeOfString:@"-" options:NSBackwardsSearch].location];
            break;
        }
    }
    
    if (italicRequired && boldRequired) {
        targetTraitNames = boldItalicTraitNames;
    } else if (italicRequired) {
        targetTraitNames = italicTraitNames;
    } else if (boldRequired) {
        targetTraitNames = boldTraitNames;
    }
    
    for (NSString *traitName in targetTraitNames) {
        font = [fontClass fontWithName:[@[fontName, traitName] componentsJoinedByString:@"-"] size:fontSize];
        
        if (font) {
            break;
        }
    }
    
    return font;
}

- (BOOL)isDataMatchedBy:(NSTextCheckingResult *)match insideOfCodeBlockInString:(NSMutableAttributedString *)string {
    
    NSRange dataRange = [match rangeAtIndex:2];
    NSRange previousAttributesSearchRange = NSMakeRange(dataRange.location - 1, string.length - dataRange.location - 1);
    NSRange previousAttributesRange;
    NSDictionary *previousAttributes = [string attributesAtIndex:previousAttributesSearchRange.location
                                           longestEffectiveRange:&previousAttributesRange
                                                         inRange:previousAttributesSearchRange];
    NSUInteger previousTraits = ((NSNumber *)previousAttributes[kCENMPTraitsAttributeKey]).unsignedIntegerValue;
    
    return ((previousTraits & CENMPFontDescriptorTraitMonoSpace) != 0 && dataRange.location >= previousAttributesRange.location &&
            NSMaxRange(dataRange) < NSMaxRange(previousAttributesRange));
}

- (void)prepareMatchers {
    
    NSRegularExpressionOptions options = (NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators);
    self.imageMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"!\\[(?:.*?)\\]\\((.*?)\\)(?=.)" options:options error:nil];
    self.linkMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]\\((.*?)\\)(?=.)" options:options error:nil];
    self.codeMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([`]+)(.*?)(\\1)" options:options error:nil];
    
    self.underscoreBoldMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([_]{2})(.*?)(\\1)" options:options error:nil];
    self.asteriskBoldMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([*]{2})(.*?)(\\1)" options:options error:nil];
    self.underscoreItalicMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([_]{1})(.*?)(\\1)" options:options error:nil];
    self.asteriskItalicMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([*]{1})(.*?)(\\1)" options:options error:nil];
    
    self.strikethroughMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([~]+)(.*?)(\\1)" options:options error:nil];
}


#pragma mark -


@end
