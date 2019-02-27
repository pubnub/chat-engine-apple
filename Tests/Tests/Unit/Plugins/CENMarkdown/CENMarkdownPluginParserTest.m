/**
 * @author Serhii Mamontov
 * @copyright © 2010-2018 PubNub, Inc.
 */
#import <CENChatEngine/CENMarkdownParser+Private.h>
#import "CENTestCase.h"


@interface CENMarkdownPluginParserTest : CENTestCase


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

- (BOOL)shouldSetupVCR {
    
    return [self.name rangeOfString:@"testImage_ShouldAddImageAttachment"].location != NSNotFound;
}

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
    self.customItalicFont = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-Italic"]
                                            size:self.customDefaultFontSize];
    self.customBoldFont = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-Bold"]
                                          size:self.customDefaultFontSize];
    self.customLinkFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"]
                                          size:self.customDefaultFontSize];
    self.customCodeFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"]
                                          size:self.customCodeFontSize];
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
    NSString *markdownString = @"some **bold text**";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [parser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertNotNil(string);
            XCTAssertTrue([string isKindOfClass:[NSAttributedString class]]);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Parse

- (void)testParse_ShouldReturnNSString_WhenStringWithOutMarkdownMarkupPassed {
    
    NSString *markdownString = @"some text";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            XCTAssertNotNil(string);
            XCTAssertFalse([string isKindOfClass:[NSAttributedString class]]);
            XCTAssertTrue([string isKindOfClass:[NSString class]]);
            handler();
        }];
    }];
}

- (void)testParse_ShouldReturnNSAttributedString_WhenStringWithMarkdownMarkupPassed {
    
    NSString *markdownString = @"some **bold text**";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            XCTAssertNotNil(string);
            XCTAssertTrue([string isKindOfClass:[NSAttributedString class]]);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Font

- (void)testDefaultFont_ShouldSetDefaultFontPartially_WhenTextPartDoesntHaveMarkupOnIt {
    
    NSString *markdownString = @"some **bold text**";
    UIFont *expected = self.defaultFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testDefaultFont_ShouldSetMonospaceFont_WhenStringWithCodeMarkdownMarkupPassed {
    
    NSString *markdownString = @"`code`";
    UIFont *expected = self.codeFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testDefaultFont_ShouldUseItalicCreatedFromDefault_WhenStringWithItalicMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Italic"] size:self.defaultFontSize];
    NSString *markdownString = @"*italic text*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testDefaultFont_ShouldUseBoldCreatedFromDefault_WhenStringWithBoldMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Bold"] size:self.defaultFontSize];
    NSString *markdownString = @"**bold text**";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testDefaultFont_ShouldUseBoldItalicCreatedFromDefault_WhenStringWithBoldItalicMarkdownMarkupPassed {

    UIFont *expected = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-BoldItalic"]
                                       size:self.defaultFontSize];
    NSString *markdownString = @"___bold text___";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testDefaultFont_ShouldUseMonospaceBoldCreatedFromDefault_WhenStringWithBoldCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Bold"] size:self.codeFontSize];
    NSString *markdownString = @"**``bold code``**";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testDefaultFont_ShouldUseMonospaceItalicCreatedFromDefault_WhenStringWithItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Oblique"] size:self.codeFontSize];
    NSString *markdownString = @"*``bold code``*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testDefaultFont_ShouldUseMonospaceBoldItalicCreatedFromDefault_WhenStringWithBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-BoldOblique"] size:self.codeFontSize];
    NSString *markdownString = @"*__``bold code``__*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldSetDefaultFontPartially_WhenTextPartDoesntHaveMarkupOnIt {
    
    NSString *markdownString = @"some **bold text**";
    UIFont *expected = self.customDefaultFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldSetMonospaceFont_WhenStringWithCodeMarkdownMarkupPassed {
    
    UIFont *expected = self.customCodeFont;
    NSString *markdownString = @"`code`";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldUseItalicFont_WhenStringWithItalicMarkdownMarkupPassed {
    
    NSString *markdownString = @"*italic text*";
    UIFont *expected = self.customItalicFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldUseBoldCreatedFont_WhenStringWithBoldMarkdownMarkupPassed {
    
    NSString *markdownString = @"**bold text**";
    UIFont *expected = self.customBoldFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldUseBoldItalicCreatedFromCustom_WhenStringWithBoldItalicMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-BoldItalic"]
                                       size:self.customDefaultFontSize];
    NSString *markdownString = @"___bold text___";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldUseMonospaceBoldCreatedFromCustom_WhenStringWithBoldCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"]
                                       size:self.customCodeFontSize];
    NSString *markdownString = @"**``bold code``**";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldUseMonospaceItalicCreatedFromCustom_WhenStringWithItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"]
                                       size:self.customCodeFontSize];
    NSString *markdownString = @"*``bold code``*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}

- (void)testCustomFont_ShouldUseMonospaceBoldItalicCreatedFromCustom_WhenStringWithBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expected = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"]
                                       size:self.customCodeFontSize];
    NSString *markdownString = @"*__``bold code``__*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expected);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Decoration

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenTextStringWithStrikethroughMarkdownMarkupPassed {
    
    NSString *markdownString = @"~strikethrough text~";
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    UIFont *expectedFont = self.defaultFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenTextStringWithStrikethroughItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Italic"]
                                           size:self.defaultFontSize];
    NSString *markdownString = @"_~~italic strikethrough text~~_";
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenTextStringWithStrikethroughBoldMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Bold"]
                                           size:self.defaultFontSize];
    NSString *markdownString = @"**~bold strikethrough text~**";
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-BoldItalic"]
                                           size:self.defaultFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    NSString *markdownString = @"___~bold text~___";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughCodeMarkdownMarkupPassed {
    
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    NSString *markdownString = @"~`bold code`~";
    UIFont *expectedFont = self.codeFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Bold"] size:self.codeFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    NSString *markdownString = @"~**``bold code``**~";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-Oblique"] size:self.codeFontSize];
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    NSString *markdownString = @"*~``bold code``~*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id  string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.codeFontName stringByAppendingString:@"-BoldOblique"]
                                           size:self.codeFontSize];
    NSString *markdownString = @"*~__``bold code``__~*";
    NSUnderlineStyle expected = NSUnderlineStyleThick;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenTextStringWithStrikethroughMarkdownMarkupPassed {
    
    NSUnderlineStyle expected = self.customStrikethrough;
    NSString *markdownString = @"~strikethrough text~";
    UIFont *expectedFont = self.customDefaultFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenTextStringWithStrikethroughItalicMarkdownMarkupPassed {
    
    NSString *markdownString = @"_~~italic strikethrough text~~_";
    NSUnderlineStyle expected = self.customStrikethrough;
    UIFont *expectedFont = self.customItalicFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenTextStringWithStrikethroughBoldMarkdownMarkupPassed {
    
    NSString *markdownString = @"**~bold strikethrough text~**";
    NSUnderlineStyle expected = self.customStrikethrough;
    UIFont *expectedFont = self.customBoldFont;
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customDefaultFontName stringByAppendingString:@"-BoldItalic"]
                                           size:self.customDefaultFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    NSString *markdownString = @"___~bold text~___";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughCodeMarkdownMarkupPassed {
    
    NSUnderlineStyle expected = self.customStrikethrough;
    NSString *markdownString = @"~`bold code`~";
    UIFont *expectedFont = self.customCodeFont;


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"]
                                           size:self.customCodeFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    NSString *markdownString = @"~**``bold code``**~";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"]
                                           size:self.customCodeFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    NSString *markdownString = @"*~``bold code``~*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id  string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomDecoration_ShouldAddStrikethroughDecoration_WhenStringWithStrikethroughBoldItalicCodeMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"]
                                           size:self.customCodeFontSize];
    NSUnderlineStyle expected = self.customStrikethrough;
    NSString *markdownString = @"*~__``bold code``__~*";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            NSNumber *style = [attributesString attribute:NSStrikethroughStyleAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqual(style.integerValue, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Link

- (void)testDefaultLink_ShouldAddLink_WhenTextStringWithLinkMarkdownMarkupPassed {
    
    NSString *markdownString = @"[PubNub](https://pubnub.com)";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            handler();
        }];
    }];
}

- (void)testDefaultLink_ShouldAddLink_WhenTextStringWithLinkItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Italic"]
                                           size:self.defaultFontSize];
    NSString *markdownString = @"_[PubNub](https://pubnub.com)_";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultLink_ShouldAddLink_WhenTextStringWithLinkBoldMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-Bold"]
                                           size:self.defaultFontSize];
    NSString *markdownString = @"__[PubNub](https://pubnub.com)__";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testDefaultLink_ShouldAddLink_WhenTextStringWithLinkBoldItalicMarkdownMarkupPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.defaultFontName stringByAppendingString:@"-BoldItalic"]
                                           size:self.defaultFontSize];
    NSString *markdownString = @"**_[PubNub](https://pubnub.com)_**";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithLinkMarkdownMarkupPassed {
    
    NSString *markdownString = @"[PubNub](https://pubnub.com)";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithItalicMarkdownMarkupInsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"]
                                           size:self.customDefaultFontSize];
    NSString *markdownString = @"[_PubNub_](https://pubnub.com)";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithItalicMarkdownMarkupOutsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Oblique"]
                                           size:self.customDefaultFontSize];
    NSString *markdownString = @"_[PubNub](https://pubnub.com)_";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithBoldMarkdownMarkupInsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"]
                                           size:self.customDefaultFontSize];
    NSString *markdownString = @"[__PubNub__](https://pubnub.com)";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithBoldMarkdownMarkupOutsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-Bold"]
                                           size:self.customDefaultFontSize];
    NSString *markdownString = @"__[PubNub](https://pubnub.com)__";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithBoldItalicMarkdownMarkupInsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"]
                                           size:self.customDefaultFontSize];
    NSString *markdownString = @"[**_PubNub_**](https://pubnub.com)";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithBoldItalicMarkdownMarkupOutsideOfLinkPassed {
    
    UIFont *expectedFont = [UIFont fontWithName:[self.customCodeFontName stringByAppendingString:@"-BoldOblique"]
                                           size:self.customDefaultFontSize];
    NSString *markdownString = @"**_[PubNub](https://pubnub.com)_**";
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}

- (void)testCustomLink_ShouldAddLink_WhenTextStringWithLinkCodeMarkdownMarkupPassed {
    
    NSString *markdownString = @"[`PubNub`](https://pubnub.com)";
    UIFont *expectedFont = self.customCodeFont;
    NSString *expected = @"https://pubnub.com";
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.customParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id link = [attributesString attribute:NSLinkAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertEqualObjects(link, expected);
            XCTAssertEqualObjects([attributesString attribute:NSFontAttributeName atIndex:0 effectiveRange:nil], expectedFont);
            handler();
        }];
    }];
}


#pragma mark - Tests :: Image

- (void)testImage_ShouldAddImageAttachment_WhenTextStringWithImageMarkdownMarkupPassed {
    
    NSString *markdownString = @"![](https://cdn0.iconfinder.com/data/icons/easter-2020/42/rabbit_smiled-128.png)";
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self.defaultParser parseMarkdownString:markdownString withCompletion:^(id string) {
            NSAttributedString *attributesString = (NSAttributedString *)string;
            id attachment = [attributesString attribute:NSAttachmentAttributeName atIndex:0 effectiveRange:nil];
            
            XCTAssertTrue([attachment isKindOfClass:[NSTextAttachment class]]);
            XCTAssertNotNil(((NSTextAttachment *)attachment).image);
            XCTAssertTrue([((NSTextAttachment *)attachment).image isKindOfClass:[UIImage class]]);
            handler();
        }];
    }];
}

#pragma mark -


@end
