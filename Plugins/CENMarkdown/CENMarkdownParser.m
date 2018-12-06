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

/**
 * @brief \c Markdown markup parser configuration.
 */
@property (nonatomic, copy) NSMutableDictionary<NSString *, NSDictionary<NSAttributedStringKey, id> *> *configuration;

/**
 * @brief RegExp to get text with italic markup based on underscores.
 */
@property (nonatomic, strong) NSRegularExpression *underscoreItalicMatchRegExp;

/**
 * @brief RegExp to get text with italic markup based on asterisks.
 */
@property (nonatomic, strong) NSRegularExpression *asteriskItalicMatchRegExp;

/**
 * @brief RegExp to get text with bold markup based on underscores.
 */
@property (nonatomic, strong) NSRegularExpression *underscoreBoldMatchRegExp;

/**
 * @brief RegExp to get text with strikethrough markup.
 */
@property (nonatomic, strong) NSRegularExpression *strikethroughMatchRegExp;

/**
 * @brief RegExp to get text with bold markup based on asterisks.
 */
@property (nonatomic, strong) NSRegularExpression *asteriskBoldMatchRegExp;

/**
 * @brief RegExp to get text with image markup.
 */
@property (nonatomic, strong) NSRegularExpression *imageMatchRegExp;

/**
 * @brief RegExp to get text with link markup.
 */
@property (nonatomic, strong) NSRegularExpression *linkMatchRegExp;

/**
 * @brief RegExp to get text with monospace / code markup.
 */
@property (nonatomic, strong) NSRegularExpression *codeMatchRegExp;

/**
 * @brief \a NSDictionary with list of calculated attributes which will be applied depending from
 * markup on piece of text covered with it.
 */
@property (nonatomic, strong) NSMutableDictionary *attributesMap;



#pragma mark - Initialization and Configuration

/**
 * @brief Initialize \c Markdown markup language parser.
 *
 * @param configuration \a NSDictionary with information which is required to set layout for various
 *     text styles which can be expressed by \c Markdown markup.
 *
 * @return Initialized and ready to use parser.
 */
- (instancetype)initWithConfiguration:(NSDictionary<NSString *, NSDictionary<NSAttributedStringKey, id> *> *)configuration;


#pragma mark - Substitution

/**
 * @brief Parse inline code markup markers.
 *
 * @param string Attributes string which represent currently processed markup string.
 *
 * @return Whether there was code markup and it has been parsed or not.
 */
- (BOOL)substituteInlineCodeIn:(NSMutableAttributedString *)string;

/**
 * @brief Parse bold text markup markers.
 *
 * @param string Attributes string which represent currently processed markup string.
 *
 * @return Whether there was bold markup and it has been parsed or not.
 */
- (BOOL)substituteBoldIn:(NSMutableAttributedString *)string;

/**
 * @brief Parse italic text markup markers.
 *
 * @param string Attributes string which represent currently processed markup string.
 *
 * @return Whether there was italic markup and it has been parsed or not.
 */
- (BOOL)substituteItalicIn:(NSMutableAttributedString *)string;

/**
 * @brief Parse strikethrough text markup markers.
 *
 * @param string Attributes string which represent currently processed markup string.
 *
 * @return Whether there was strikethrough markup and it has been parsed or not.
 */
- (BOOL)substituteStrikethroughIn:(NSMutableAttributedString *)string;

/**
 * @brief Process \c Markdown markup in passed list of matches.
 *
 * @param match Object which represent ranges of \c Markdown markup which should be parsed with
 *     layout described in \c attributes.
 * @param string Attributes string which represent currently processed markup string.
 */
- (void)substituteDataMatchedBy:(NSTextCheckingResult *)match
                       inString:(NSMutableAttributedString *)string
                usingAttributes:(NSDictionary *)attributes;


#pragma mark - Misc

/**
 * @brief Prepare default text layout attributes.
 */
- (void)setDefaultAttributes;

/**
 * @brief Prepare italic text layout attributes.
 */
- (void)setDefaultItalicAttributes;

/**
 * @brief Prepare bold text layout attributes.
 */
- (void)setDefaultBoldAttributes;

/**
 * @brief Prepare bold italic text layout attributes.
 */
- (void)setDefaultBoldItalicAttributes;

/**
 * @brief Prepare strikethrough text layout attributes.
 */
- (void)setDefaultStrikethroughAttributes;

/**
 * @brief Prepare link text layout attributes.
 */
- (void)setDefaultLinkAttributes;

/**
 * @brief Prepare italic link text layout attributes.
 */
- (void)setDefaultLinkItalicAttributes;

/**
 * @brief Prepare bold link text layout attributes.
 */
- (void)setDefaultLinkBoldAttributes;

/**
 * @brief Prepare italic bold link text layout attributes.
 */
- (void)setDefaultLinkBoldItalicAttributes;

/**
 * @brief Prepare code text layout attributes.
 */
- (void)setDefaultCodeAttributes;

/**
 * @brief Prepare code link text layout attributes.
 */
- (void)setDefaultCodeLinkAttributes;

/**
 * @brief Prepare code bold text layout attributes.
 */
- (void)setDefaultCodeBoldAttributes;

/**
 * @brief Prepare code bold link text layout attributes.
 */
- (void)setDefaultCodeBoldLinkAttributes;

/**
 * @brief Prepare code italic text layout attributes.
 */
- (void)setDefaultCodeItalicAttributes;

/**
 * @brief Prepare code italic link text layout attributes.
 */
- (void)setDefaultCodeItalicLinkAttributes;

/**
 * @brief Prepare code bold italic text layout attributes.
 */
- (void)setDefaultCodeBoldItalicAttributes;

/**
 * @brief Prepare code bold italic link text layout attributes.
 */
- (void)setDefaultCodeBoldItalicLinkAttributes;

/**
 * @brief Create font from base font and traits applying on it.
 *
 * @param traits Bit filed which compose final font layout properties.
 * @param font Base font from which new should be created.
 *
 * @return Font with new layout traits based on base \c font.
 */
- (id)fontForTraits:(CENMPFontDescriptorSymbolicTraits)traits from:(id)font;

/**
 * @brief Check whether matched data is inside of code representing block or not.
 *
 * @param match RegExp matched string information.
 * @param string String with \c Markdown markup which should be examined.
 *
 * @return Whether \c match located in code representing block or not.
 */
- (BOOL)isDataMatchedBy:(NSTextCheckingResult *)match
    insideOfCodeBlockInString:(NSMutableAttributedString *)string;

/**
 * @brief Prepare \c Markdown markup matchers.
 */
- (void)prepareMatchers;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation CENMarkdownParser


#pragma mark - Initialization and Configuration

+ (instancetype)parserWithConfiguration:(NSDictionary *)configuration {
    
    return [[self alloc] initWithConfiguration:configuration];
}

- (instancetype)initWithConfiguration:(NSDictionary *)configuration {
    
    if ((self = [super init])) {
        _configuration = [(configuration ?: @{}) mutableCopy];
        _attributesMap = [NSMutableDictionary new];
        
        [self setDefaultAttributes];
        [self prepareMatchers];
        
    }
    
    return self;
}


#pragma mark - Parse

- (void)parseMarkdownString:(NSString *)markdown withCompletion:(void (^)(id result))completion {
    
    __block NSMutableAttributedString *attributedString = nil;
    markdown = [NSString stringWithFormat:@" %@ ", markdown];
    
    dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, DISPATCH_QUEUE_SERIAL), ^{
        NSDictionary *attributes = self.configuration[CENMarkdownParserElement.defaultAttributes];
        attributedString = [[NSMutableAttributedString alloc] initWithString:markdown
                                                                  attributes:attributes];
        
        BOOL imagesFound = [self substituteImageURLWithAttachmensIn:attributedString];
        BOOL linksFound = [self substituteLinksIn:attributedString];
        BOOL inlineCodeFound = [self substituteInlineCodeIn:attributedString];
        BOOL boldFound = [self substituteBoldIn:attributedString];
        BOOL italicFound = [self substituteItalicIn:attributedString];
        BOOL strikethroughFound = [self substituteStrikethroughIn:attributedString];
        BOOL hasMarkdownMarkup = (imagesFound || inlineCodeFound || linksFound || boldFound ||
                                  italicFound || strikethroughFound);
        
        // Trimming spaces which has been added to allow RegExp handle properly.
        if (hasMarkdownMarkup) {
            [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];
            [attributedString replaceCharactersInRange:NSMakeRange(attributedString.length - 1, 1)
                                            withString:@""];
        }
        
        completion(hasMarkdownMarkup ? (id)attributedString : (id)markdown);
    });
}


#pragma mark - Substitution

- (BOOL)substituteInlineCodeIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSRegularExpression *regExp = self.codeMatchRegExp;
    NSArray<NSTextCheckingResult *> *matches = [regExp matchesInString:string.string
                                                               options:0
                                                                 range:searchRange];
    NSDictionary *attributes = self.configuration[CENMarkdownParserElement.codeAttributes];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:^(NSTextCheckingResult *match,
                                           __unused NSUInteger matchIdx,
                                           __unused BOOL *stop) {
        
        [self substituteDataMatchedBy:match inString:string usingAttributes:attributes];
    }];
    
    return matches.count > 0;
}

- (BOOL)substituteBoldIn:(NSMutableAttributedString *)string {
    
    NSDictionary *attributes = self.configuration[CENMarkdownParserElement.boldAttributes];
    NSArray<NSRegularExpression *> *matchRegExps = @[self.underscoreBoldMatchRegExp,
                                                     self.asteriskBoldMatchRegExp];
    __block NSUInteger matchesFound = 0;
    
    for (NSRegularExpression *matchRegExp in matchRegExps) {
        NSRange searchRange = NSMakeRange(0, string.length);
        NSArray<NSTextCheckingResult *> *matches = [matchRegExp matchesInString:string.string
                                                                        options:0
                                                                          range:searchRange];
        
        [matches enumerateObjectsWithOptions:NSEnumerationReverse
                                  usingBlock:^(NSTextCheckingResult *match,
                                               __unused NSUInteger matchIdx,
                                               __unused BOOL *stop) {
            
            [self substituteDataMatchedBy:match inString:string usingAttributes:attributes];
        }];
        
        matchesFound += matches.count;
    }
    
    return matchesFound > 0;
}

- (BOOL)substituteItalicIn:(NSMutableAttributedString *)string {
    
    NSDictionary *attributes = self.configuration[CENMarkdownParserElement.italicAttributes];
    NSArray<NSRegularExpression *> *matchRegExps = @[self.underscoreItalicMatchRegExp,
                                                     self.asteriskItalicMatchRegExp];
    __block NSUInteger matchesFound = 0;
    
    for (NSRegularExpression *matchRegExp in matchRegExps) {
        NSRange searchRange = NSMakeRange(0, string.length);
        NSArray<NSTextCheckingResult *> *matches = [matchRegExp matchesInString:string.string
                                                                        options:0
                                                                          range:searchRange];
        
        [matches enumerateObjectsWithOptions:NSEnumerationReverse
                                  usingBlock:^(NSTextCheckingResult *match,
                                               __unused NSUInteger matchIdx,
                                               __unused BOOL *stop) {
            
            [self substituteDataMatchedBy:match inString:string usingAttributes:attributes];
        }];
        
        matchesFound += matches.count;
    }
    
    return matchesFound > 0;
}

- (BOOL)substituteStrikethroughIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSRegularExpression *regExp = self.strikethroughMatchRegExp;
    NSDictionary *attributes = self.configuration[CENMarkdownParserElement.strikethroughAttributes];
    NSArray<NSTextCheckingResult *> *matches = [regExp matchesInString:string.string
                                                               options:0
                                                                 range:searchRange];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:^(NSTextCheckingResult *match,
                                           __unused NSUInteger matchIdx,
                                           __unused BOOL *stop) {
        
        [self substituteDataMatchedBy:match inString:string usingAttributes:attributes];
    }];
    
    return matches.count > 0;
}

- (void)substituteDataMatchedBy:(NSTextCheckingResult *)match
                       inString:(NSMutableAttributedString *)string
                usingAttributes:(NSDictionary *)attributes {
    
    NSNumber *traits = attributes[kCENMPTraitsAttributeKey];
    NSUInteger targetTraits = traits.unsignedIntegerValue;
    BOOL isLink = targetTraits == CENMPFontDescriptorTraitLink;
    BOOL isCode = (targetTraits & CENMPFontDescriptorTraitMonoSpace) != 0;
    BOOL isStrikethrough = targetTraits == CENMPFontDescriptorTraitStrikethrough;
    NSRange dataRange = !isLink ? [match rangeAtIndex:2] : [match rangeAtIndex:1];
    NSMutableAttributedString *attributedString = nil;
    NSRange replacementRange = match.range;
    
    if (!isLink) {
        NSUInteger length = NSMaxRange([match rangeAtIndex:3]) - [match rangeAtIndex:1].location;
        replacementRange = NSMakeRange([match rangeAtIndex:1].location, length);
    }
    
    if ([self isDataMatchedBy:match insideOfCodeBlockInString:string]) {
        return;
    }
    
    attributedString = [[string attributedSubstringFromRange:dataRange] mutableCopy];
    dataRange = NSMakeRange(0, attributedString.length);
    NSMutableDictionary *storedAttributes = nil;
    NSUInteger processedDataLength = 0;
    
    do {
        NSRange attributesRange;
        storedAttributes = [[attributedString attributesAtIndex:processedDataLength
                                          longestEffectiveRange:&attributesRange
                                                        inRange:dataRange] mutableCopy];
        traits = storedAttributes[kCENMPTraitsAttributeKey];
        NSUInteger storedTraits = traits.unsignedIntegerValue;
        id foregroundColor = storedAttributes[NSForegroundColorAttributeName];
        id backgroundColor = storedAttributes[NSBackgroundColorAttributeName];
        NSUInteger aggregatedTraits = (!isLink || isCode ? storedTraits | targetTraits
                                                         : storedTraits);
        
        
        if (storedTraits == 0 || (storedTraits & aggregatedTraits) != 0 || isLink) {
            [storedAttributes addEntriesFromDictionary:self.attributesMap[@(aggregatedTraits)]];
            
            if (isLink || isStrikethrough) {
                [storedAttributes addEntriesFromDictionary:attributes];
            }
            
            if ((storedTraits & CENMPFontDescriptorTraitMonoSpace) != 0) {
                storedAttributes[NSForegroundColorAttributeName] = foregroundColor;
                storedAttributes[NSBackgroundColorAttributeName] = backgroundColor;
            }
            
            if (isStrikethrough) {
                id storedForegroundColor = storedAttributes[NSForegroundColorAttributeName];
                storedAttributes[NSStrikethroughColorAttributeName] = storedForegroundColor;
            }
            
            [attributedString setAttributes:storedAttributes range:attributesRange];
        }
        
        processedDataLength += attributesRange.length;
    } while (processedDataLength < dataRange.length);
    
    [string replaceCharactersInRange:replacementRange withAttributedString:attributedString];
}

- (BOOL)substituteImageURLWithAttachmensIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSArray<NSTextCheckingResult *> *matches = [self.imageMatchRegExp matchesInString:string.string
                                                                              options:0
                                                                                range:searchRange];
    __block NSAttributedString *stringWithAttachment = nil;
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:^(NSTextCheckingResult *match,
                                           __unused NSUInteger matchIdx,
                                           __unused BOOL *stop) {
        
        NSString *imageURL = [string.string substringWithRange:[match rangeAtIndex:1]];
        
        if (imageURL.length) {
            NSTextAttachment *attachment = [NSTextAttachment new];

            if ([imageURL hasPrefix:@"http"]) {
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
#if TARGET_OS_OSX
                attachment.image = [[NSImage alloc] initWithData:imageData];
#else
                attachment.image = [UIImage imageWithData:imageData];
#endif // TARGET_OS_OSX
                
            } else {
#if TARGET_OS_OSX
                attachment.image = [[NSImage alloc] initWithContentsOfFile:imageURL];
#else
                attachment.image = [UIImage imageWithContentsOfFile:imageURL];
#endif // TARGET_OS_OSX
            }
            
            stringWithAttachment = [NSAttributedString attributedStringWithAttachment:attachment];
            
            [string replaceCharactersInRange:[match rangeAtIndex:0]
                        withAttributedString:stringWithAttachment];
        }
    }];
    
    return matches.count > 0;
}

- (BOOL)substituteLinksIn:(NSMutableAttributedString *)string {
    
    NSRange searchRange = NSMakeRange(0, string.length);
    NSArray<NSTextCheckingResult *> *matches = [self.linkMatchRegExp matchesInString:string.string
                                                                             options:0
                                                                               range:searchRange];
    
    NSDictionary *attributes = self.configuration[CENMarkdownParserElement.linkAttributes];
    
    [matches enumerateObjectsWithOptions:NSEnumerationReverse
                              usingBlock:^(NSTextCheckingResult *match,
                                           __unused NSUInteger matchIdx,
                                           __unused BOOL *stop) {
        
        NSString *linkTitle = [string.string substringWithRange:[match rangeAtIndex:1]];
        NSString *url = [string.string substringWithRange:[match rangeAtIndex:2]];
        
        if (linkTitle.length && url.length) {
            NSMutableDictionary *mutableAttriutes = [attributes mutableCopy];
            mutableAttriutes[NSLinkAttributeName] = url;
            
            [self substituteDataMatchedBy:match inString:string usingAttributes:mutableAttriutes];
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
        attributes = [@{
            NSFontAttributeName: defaultFont,
            NSForegroundColorAttributeName: [colorClass blackColor]
        } mutableCopy];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.defaultAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitRegular);
    self.configuration[CENMarkdownParserElement.defaultAttributes] = attributes;
    self.attributesMap[@(CENMPFontDescriptorTraitRegular)] = attributes;
    
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
    
    NSDictionary *defaults = self.configuration[CENMarkdownParserElement.defaultAttributes];
    NSMutableDictionary *attributes = nil;
    
    if (!self.configuration[CENMarkdownParserElement.italicAttributes]) {
        id defaultFont = defaults[NSFontAttributeName];
        id italicFont = [self fontForTraits:CENMPFontDescriptorTraitItalic from:defaultFont];
        attributes = [defaults mutableCopy];
        [attributes addEntriesFromDictionary:@{ NSFontAttributeName: italicFont ?: defaultFont }];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.italicAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitItalic);
    self.configuration[CENMarkdownParserElement.italicAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = attributes;
}

- (void)setDefaultBoldAttributes {
    
    NSDictionary *defaults = self.configuration[CENMarkdownParserElement.defaultAttributes];
    NSMutableDictionary *attributes = nil;
    
    if (!self.configuration[CENMarkdownParserElement.boldAttributes]) {
        id defaultFont = defaults[NSFontAttributeName];
        id boldFont = [self fontForTraits:CENMPFontDescriptorTraitBold from:defaultFont];
        attributes = [defaults mutableCopy];
        [attributes addEntriesFromDictionary:@{ NSFontAttributeName: boldFont ?: defaultFont }];
    } else {
        attributes = [self.configuration[CENMarkdownParserElement.boldAttributes] mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitBold);
    self.configuration[CENMarkdownParserElement.boldAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = attributes;
}

- (void)setDefaultBoldItalicAttributes {
    
    NSDictionary *boldAttributes = self.configuration[CENMarkdownParserElement.boldAttributes];
    NSMutableDictionary *attributes = [boldAttributes mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitBold | CENMPFontDescriptorTraitItalic);
    id boldFont = attributes[NSFontAttributeName];
    id boldItalicFont = [self fontForTraits:(CENMPFontDescriptorSymbolicTraits)trait.longValue
                                       from:boldFont];
    [attributes addEntriesFromDictionary:@{
        NSFontAttributeName: boldItalicFont ?: boldFont,
        kCENMPTraitsAttributeKey: trait
    }];
    
    self.configuration[CENMarkdownParserExtendedElement.boldItalicAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultStrikethroughAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.strikethroughAttributes];
    NSMutableDictionary *attributes = nil;
    
    if (!storedAttr) {
        attributes = [@{ NSStrikethroughStyleAttributeName: @(NSUnderlineStyleThick) } mutableCopy];
    } else {
        attributes = [storedAttr mutableCopy];
    }
    
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitStrikethrough);
    self.configuration[CENMarkdownParserElement.strikethroughAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = attributes;
}

- (void)setDefaultLinkAttributes {
    
    NSDictionary *defaults = self.configuration[CENMarkdownParserElement.defaultAttributes];
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.linkAttributes];
    id defaultFont = defaults[NSFontAttributeName];
    NSMutableDictionary *attributes = nil;
    
    if (!storedAttr) {
        attributes = [NSMutableDictionary new];
    } else {
        attributes = [storedAttr mutableCopy];
    }
    
    attributes[NSFontAttributeName] = attributes[NSFontAttributeName] ?: defaultFont;
    attributes[kCENMPTraitsAttributeKey] = @(CENMPFontDescriptorTraitLink);
    self.configuration[CENMarkdownParserElement.linkAttributes] = attributes;
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = attributes;
}

- (void)setDefaultLinkItalicAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.linkAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitLink | CENMPFontDescriptorTraitItalic);
    id linkFont = attributes[NSFontAttributeName];
    id linkItalicFont = [self fontForTraits:(CENMPFontDescriptorSymbolicTraits)trait.longValue
                                       from:linkFont];
    [attributes addEntriesFromDictionary:@{
        NSFontAttributeName: linkItalicFont ?: linkFont,
        kCENMPTraitsAttributeKey: trait
    }];
    
    self.configuration[CENMarkdownParserExtendedElement.linkItalicAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultLinkBoldAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.linkAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitLink | CENMPFontDescriptorTraitBold);
    id linkFont = attributes[NSFontAttributeName];
    id linkBoldFont = [self fontForTraits:(CENMPFontDescriptorSymbolicTraits)trait.longValue
                                     from:linkFont];
    [attributes addEntriesFromDictionary:@{
        NSFontAttributeName: linkBoldFont ?: linkFont,
        kCENMPTraitsAttributeKey: trait
    }];
    
    self.configuration[CENMarkdownParserExtendedElement.linkBoldAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultLinkBoldItalicAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.linkAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitLink | CENMPFontDescriptorTraitBold |
                        CENMPFontDescriptorTraitItalic);
    id linkFont = attributes[NSFontAttributeName];
    id linkBoldItalicFont = [self fontForTraits:(CENMPFontDescriptorSymbolicTraits)trait.longValue
                                           from:linkFont];
    [attributes addEntriesFromDictionary:@{
        NSFontAttributeName: linkBoldItalicFont ?: linkFont,
        kCENMPTraitsAttributeKey: trait
    }];
    
    self.configuration[CENMarkdownParserExtendedElement.linkBoldItalicAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultCodeAttributes {
    
    NSDictionary *defaults = self.configuration[CENMarkdownParserElement.defaultAttributes];
    NSMutableDictionary *attributes = nil;
    Class fontClass = nil;
    Class colorClass = nil;
#if TARGET_OS_OSX
    colorClass = [NSColor class];
    fontClass = [NSFont class];
#else
    colorClass = [UIColor class];
    fontClass = [UIFont class];
#endif // TARGET_OS_OSX
    
    if (!self.configuration[CENMarkdownParserElement.codeAttributes]) {
        id defaultFont = defaults[NSFontAttributeName];
        id monospaceFont = [fontClass fontWithName:kCENMPDefaultMonospaceFontName
                                              size:[defaultFont pointSize]];
        attributes = [defaults mutableCopy];
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
    self.attributesMap[attributes[kCENMPTraitsAttributeKey]] = attributes;
}

- (void)setDefaultCodeLinkAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.codeAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeLinkAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultCodeBoldAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.codeAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold);
    id codeFont = attributes[NSFontAttributeName];
    id codeBoldFont = [self fontForTraits:(CENMPFontDescriptorSymbolicTraits)trait.longValue
                                     from:codeFont];
    [attributes addEntriesFromDictionary:@{ NSFontAttributeName: codeBoldFont ?: codeFont, kCENMPTraitsAttributeKey: trait }];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultCodeBoldLinkAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserExtendedElement.codeBoldAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold |
                        CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldLinkAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultCodeItalicAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.codeAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitItalic);
    id codeFont = attributes[NSFontAttributeName];
    id codeItalicFont = [self fontForTraits:(CENMPFontDescriptorSymbolicTraits)trait.longValue
                                       from:codeFont];
    [attributes addEntriesFromDictionary:@{
        NSFontAttributeName: codeItalicFont ?: codeFont,
        kCENMPTraitsAttributeKey: trait
    }];
    
    self.configuration[CENMarkdownParserExtendedElement.codeItalicAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultCodeItalicLinkAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserExtendedElement.codeItalicAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitItalic |
                        CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeItalicLinkAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultCodeBoldItalicAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserElement.codeAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold |
                        CENMPFontDescriptorTraitItalic);
    id codeFont = attributes[NSFontAttributeName];
    id codeBoldItalicFont = [self fontForTraits:(CENMPFontDescriptorSymbolicTraits)trait.longValue
                                           from:codeFont];
    [attributes addEntriesFromDictionary:@{
        NSFontAttributeName: codeBoldItalicFont ?: codeFont,
        kCENMPTraitsAttributeKey: trait
    }];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (void)setDefaultCodeBoldItalicLinkAttributes {
    
    NSDictionary *storedAttr = self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicAttributes];
    NSMutableDictionary *attributes = [storedAttr mutableCopy];
    
    NSNumber *trait = @(CENMPFontDescriptorTraitMonoSpace | CENMPFontDescriptorTraitBold |
                        CENMPFontDescriptorTraitItalic | CENMPFontDescriptorTraitLink);
    [attributes removeObjectForKey:NSForegroundColorAttributeName];
    
    self.configuration[CENMarkdownParserExtendedElement.codeBoldItalicLinkAttributes] = attributes;
    self.attributesMap[trait] = attributes;
}

- (id)fontForTraits:(CENMPFontDescriptorSymbolicTraits)traits from:(id)font {
    
    Class fontClass = nil;
#if TARGET_OS_OSX
    fontClass = [NSFont class];
    NSFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits;
#else
    fontClass = [UIFont class];
    UIFontDescriptorSymbolicTraits fontDescriptorSymbolicTraits;
#endif // TARGET_OS_OSX
    
    NSArray<NSString *> *boldItalicTraitNames = @[@"BoldItalic",
                                                  @"BlackItalic",
                                                  @"BoldOblique",
                                                  @"BlackOblique"];
    fontDescriptorSymbolicTraits = [font fontDescriptor].symbolicTraits;
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
    
    if ((italicRequired && alreadyItalicFont && !boldRequired) ||
        (boldRequired && alreadyBoldFont && !italicRequired) ||
        (italicRequired && alreadyItalicFont && boldRequired && alreadyBoldFont)) {
        
        return font;
    }
    
    for (NSString *traitName in traitNames) {
        NSStringCompareOptions options = NSBackwardsSearch | NSCaseInsensitiveSearch;
        
        if ([fontName rangeOfString:traitName options:options].location != NSNotFound) {
            NSRange dashRange = [fontName rangeOfString:@"-" options:NSBackwardsSearch];
            fontName = [fontName substringToIndex:dashRange.location];
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
        font = [fontClass fontWithName:[@[fontName, traitName] componentsJoinedByString:@"-"]
                                  size:fontSize];
        
        if (font) {
            break;
        }
    }
    
    return font;
}

- (BOOL)isDataMatchedBy:(NSTextCheckingResult *)match
    insideOfCodeBlockInString:(NSMutableAttributedString *)string {
    
    NSRange dataRange = [match rangeAtIndex:2];
    NSRange previousSearchRange = NSMakeRange(dataRange.location - 1,
                                              string.length - dataRange.location - 1);
    NSRange previousRange;
    NSDictionary *previousAttributes = [string attributesAtIndex:previousSearchRange.location
                                           longestEffectiveRange:&previousRange
                                                         inRange:previousSearchRange];
    NSNumber *traits = previousAttributes[kCENMPTraitsAttributeKey];
    NSUInteger previousTraits = traits.unsignedIntegerValue;
    
    return ((previousTraits & CENMPFontDescriptorTraitMonoSpace) != 0 &&
            dataRange.location >= previousRange.location &&
            NSMaxRange(dataRange) < NSMaxRange(previousRange));
}

- (void)prepareMatchers {
    
    NSRegularExpressionOptions options = (NSRegularExpressionCaseInsensitive |
                                          NSRegularExpressionDotMatchesLineSeparators);
    self.imageMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"!\\[(?:.*?)\\]\\((.*?)\\)(?=.)"
                                                                      options:options
                                                                        error:nil];
    self.linkMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"\\[(.*?)\\]\\((.*?)\\)(?=.)"
                                                                     options:options
                                                                       error:nil];
    self.codeMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([`]+)(.*?)(\\1)"
                                                                     options:options
                                                                       error:nil];
    
    self.underscoreBoldMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([_]{2})(.*?)(\\1)"
                                                                               options:options
                                                                                 error:nil];
    self.asteriskBoldMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([*]{2})(.*?)(\\1)"
                                                                             options:options
                                                                               error:nil];
    self.underscoreItalicMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([_]{1})(.*?)(\\1)"
                                                                                 options:options
                                                                                   error:nil];
    self.asteriskItalicMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([*]{1})(.*?)(\\1)"
                                                                               options:options
                                                                                 error:nil];
    
    self.strikethroughMatchRegExp = [NSRegularExpression regularExpressionWithPattern:@"([~]+)(.*?)(\\1)"
                                                                              options:options
                                                                                error:nil];
}


#pragma mark -


@end
