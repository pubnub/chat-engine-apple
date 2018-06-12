/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import <XCTest/XCTest.h>
#import <CENChatEngine/CENMarkdownParser.h>


@interface CENMarkdownPluginParserTest : XCTestCase


#pragma mark - Information

@property (nonatomic, strong) CENMarkdownParser *defaultParser;
@property (nonatomic, strong) NSString *defaultFontName;
@property (nonatomic, assign) CGFloat defaultFontSize;
@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) NSString *codeFontName;
@property (nonatomic, assign) CGFloat codeFontSize;
@property (nonatomic, strong) UIFont *codeFont;

@property (nonatomic, strong) CENMarkdownParser *customParser;
@property (nonatomic, strong) NSString *customDefaultFontName;
@property (nonatomic, assign) CGFloat customDefaultFontSize;
@property (nonatomic, strong) NSString *customCodeFontName;
@property (nonatomic, assign) CGFloat customCodeFontSize;
@property (nonatomic, strong) UIFont *customDefaultFont;
@property (nonatomic, strong) UIFont *customItalicFont;
@property (nonatomic, strong) UIFont *customBoldFont;
@property (nonatomic, strong) UIFont *customLinkFont;
@property (nonatomic, strong) UIFont *customCodeFont;
@property (nonatomic, assign) NSUnderlineStyle customStrikethrough;

#pragma mark -

@end

@implementation CENMarkdownPluginParserTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    self.defaultFontName = @"HelveticaNeue";
    self.defaultFontSize = 20.f;
    self.defaultFont = [UIFont fontWithName:self.defaultFontName size:self.defaultFontSize];
    
    self.codeFontName = @"Courier";
    self.codeFontSize = 22.f;
    self.codeFont = [UIFont fontWithName:self.codeFontName size:self.codeFontSize];
    
    self.defaultParser = [CENMarkdownParser parserWithConfiguration:@{
        CENMarkdownParserElement.defaultAttributes: @{ NSFontAttributeName: self.defaultFont },
        CENMarkdownParserElement.codeAttributes: @{ NSFontAttributeName: self.codeFont }
    }];
    
    self.customDefaultFontName = @"Menlo";
    self.customCodeFontName = @"Courier";
    self.customDefaultFontSize = 26.f;
    self.customCodeFontSize = 30.f;
    self.customDefaultFont = [UIFont fontWithName:self.customDefaultFontName size:self.customDefaultFontSize];
    self.customItalicFont = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-Italic"] size:self.customDefaultFontSize];
    self.customBoldFont = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-Bold"] size:self.customDefaultFontSize];
    self.customLinkFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"] size:self.customDefaultFontSize];
    self.customCodeFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"] size:self.customCodeFontSize];
    self.customStrikethrough = NSUnderlinePatternDashDotDot;
    
    self.customParser = [CENMarkdownParser parserWithConfiguration:@{
        CENMarkdownParserElement.defaultAttributes: @{ NSFontAttributeName: self.customDefaultFont },
        CENMarkdownParserElement.italicAttributes: @{ NSFontAttributeName: self.customItalicFont },
        CENMarkdownParserElement.boldAttributes: @{ NSFontAttributeName: self.customBoldFont },
        CENMarkdownParserElement.linkAttributes: @{ NSFontAttributeName: self.customLinkFont },
        CENMarkdownParserElement.codeAttributes: @{ NSFontAttributeName: self.customCodeFont },
        CENMarkdownParserElement.strikethroughAttributes: @{ NSStrikethroughStyleAttributeName: @(self.customStrikethrough) }
    }];
}


#pragma mark - Tests :: Constructor

- (void)testConstructor_ShouldInitializeWithDefaults_WhenConfigurationNotPassed {
    
    CENMarkdownParser *parser = [CENMarkdownParser parserWithConfiguration:nil];
    UIFont *expected = [UIFont fontWithName:self.defaultFontName size:14.f];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [parser parseMarkdownString:@"some **bold text**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertNotNil(string);
        XCTAssertTrue([string isKindOfClass:[NSAttributedString class]]);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Parse

- (void)testParse_ShouldReturnNSString_WhenStringWithOutMarkdownMarkupPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"some text" withCompletion:^(id string) {
        handlerCalled = YES;
        
        XCTAssertNotNil(string);
        XCTAssertFalse([string isKindOfClass:[NSAttributedString class]]);
        XCTAssertTrue([string isKindOfClass:[NSString class]]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testParse_ShouldReturnNSAttributedString_WhenStringWithMarkdownMarkupPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"some **bold text**" withCompletion:^(id string) {
        handlerCalled = YES;
        
        XCTAssertNotNil(string);
        XCTAssertTrue([string isKindOfClass:[NSAttributedString class]]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Font

- (void)testDefaultFont_ShuldSetDefaultFontPartially_WhenTextPartDoesntHaveMarkupOnIt {
    
    UIFont *expected = self.defaultFont;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"some **bold text**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFont_ShuldSetMonospaceFont_WhenStringWithCodeMarkdownMarkupPassed {
    
    UIFont *expected = self.codeFont;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"`code`" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFont_ShuldUseItalicCreatedFromDefault_WhenStringWithItalicMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Italic"] size:self.defaultFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"*italic text*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFont_ShuldUseBoldCreatedFromDefault_WhenStringWithBoldMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Bold"] size:self.defaultFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"**bold text**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFont_ShuldUseBoldItalicCreatedFromDefault_WhenStringWithBoldItalicMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-BoldItalic"] size:self.defaultFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"___bold text___" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFont_ShuldUseMonospaceBoldCreatedFromDefault_WhenStringWithBoldCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Bold"] size:self.codeFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"**``bold code``**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFont_ShuldUseMonospaceItalicCreatedFromDefault_WhenStringWithItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Oblique"] size:self.codeFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"*``bold code``*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultFont_ShuldUseMonospaceBoldItalicCreatedFromDefault_WhenStringWithBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-BoldOblique"] size:self.codeFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"*__``bold code``__*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldSetDefaultFontPartially_WhenTextPartDoesntHaveMarkupOnIt {
    
    UIFont *expected = self.customDefaultFont;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"some **bold text**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldSetMonospaceFont_WhenStringWithCodeMarkdownMarkupPassed {
    
    UIFont *expected = self.customCodeFont;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"`code`" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldUseItalicFont_WhenStringWithItalicMarkdownMarkupPassed {
    
    UIFont *expected = self.customItalicFont;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"*italic text*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldUseBoldCreatedFont_WhenStringWithBoldMarkdownMarkupPassed {
    
    UIFont *expected = self.customBoldFont;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"**bold text**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldUseBoldItalicCreatedFromCustom_WhenStringWithBoldItalicMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-BoldItalic"] size:self.customDefaultFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"___bold text___" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldUseMonospaceBoldCreatedFromCustom_WhenStringWithBoldCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"] size:self.customCodeFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"**``bold code``**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldUseMonospaceItalicCreatedFromCustom_WhenStringWithItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"] size:self.customCodeFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"*``bold code``*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomFont_ShuldUseMonospaceBoldItalicCreatedFromCustom_WhenStringWithBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"] size:self.customCodeFontSize];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"*__``bold code``__*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Decoration

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenTextStringWithStrikethroughMarkdownMarkupPassed {
    
    UIFont *expectedFont = self.defaultFont;
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"~strikethrough text~" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenTextStringWithStrikethroughItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Italic"] size:self.defaultFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"_~~italic strikethrough text~~_" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenTextStringWithStrikethroughBoldMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Bold"] size:self.defaultFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"**~bold strikethrough text~**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-BoldItalic"] size:self.defaultFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"___~bold text~___" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = self.codeFont;
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"~`bold code`~" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Bold"] size:self.codeFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"~**``bold code``**~" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Oblique"] size:self.codeFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"*~``bold code``~*" withCompletion:^(id  string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-BoldOblique"] size:self.codeFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"*~__``bold code``__~*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenTextStringWithStrikethroughMarkdownMarkupPassed {
    
    UIFont *expectedFont = self.customDefaultFont;
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"~strikethrough text~" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenTextStringWithStrikethroughItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = self.customItalicFont;
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"_~~italic strikethrough text~~_" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenTextStringWithStrikethroughBoldMarkdownMarkupPassed {
    
    UIFont *expectedFont = self.customBoldFont;
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"**~bold strikethrough text~**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-BoldItalic"] size:self.customDefaultFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"___~bold text~___" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = self.customCodeFont;
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"~`bold code`~" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"] size:self.customCodeFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"~**``bold code``**~" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"] size:self.customCodeFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"*~``bold code``~*" withCompletion:^(id  string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomDecoration_ShuldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"] size:self.customCodeFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"*~__``bold code``__~*" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqual(style.integerValue, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Link

- (void)testDefaultLink_ShuldAddLink_WhenTextStringWithLinkMarkdownMarkupPassed {
    
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"[PubNub](https://pubnub.com)" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultLink_ShuldAddLink_WhenTextStringWithLinkItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Italic"] size:self.defaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"_[PubNub](https://pubnub.com)_" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultLink_ShuldAddLink_WhenTextStringWithLinkBoldMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Bold"] size:self.defaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"__[PubNub](https://pubnub.com)__" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testDefaultLink_ShuldAddLink_WhenTextStringWithLinkBoldItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-BoldItalic"] size:self.defaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"**_[PubNub](https://pubnub.com)_**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithLinkMarkdownMarkupPassed {
    
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"[PubNub](https://pubnub.com)" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithItalicMarkdownMarkupInsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"] size:self.customDefaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"[_PubNub_](https://pubnub.com)" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithItalicMarkdownMarkupOutsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"] size:self.customDefaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"_[PubNub](https://pubnub.com)_" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithBoldMarkdownMarkupInsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"] size:self.customDefaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"[__PubNub__](https://pubnub.com)" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithBoldMarkdownMarkupOutsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"] size:self.customDefaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"__[PubNub](https://pubnub.com)__" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithBoldItalicMarkdownMarkupInsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"] size:self.customDefaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"[**_PubNub_**](https://pubnub.com)" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithBoldItalicMarkdownMarkupOutsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"] size:self.customDefaultFontSize];
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"**_[PubNub](https://pubnub.com)_**" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

- (void)testCustomLink_ShuldAddLink_WhenTextStringWithLinkCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = self.customCodeFont;
    NSString *expected = @"https://pubnub.com";
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.customParser parseMarkdownString:@"[`PubNub`](https://pubnub.com)" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertEqualObjects(link, expected);
        XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}


#pragma mark - Tests :: Image

- (void)testImage_ShuldAddImageAttachment_WhenTextStringWithImageMarkdownMarkupPassed {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self.defaultParser parseMarkdownString:@"![](https://cdn0.iconfinder.com/data/icons/easter-2020/42/rabbit_smiled-128.png)" withCompletion:^(id string) {
        NSAttributedString *attributesString = (NSAttributedString *)string;
        handlerCalled = YES;
        
        id attachment = [attributesString attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:nil];
        XCTAssertTrue([attachment isKindOfClass:[NSTextAttachment class]]);
        XCTAssertNotNil(((NSTextAttachment *)attachment).image);
        XCTAssertTrue([((NSTextAttachment *)attachment).image isKindOfClass:[UIImage class]]);
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)));
    XCTAssertTrue(handlerCalled);
}

#pragma mark -


@end
