#import <Foundation/Foundation.h>


/**
 * @brief  Structure which describe keys under which stored \b ChatEngine data passed with emitted
 *         event.
 */
typedef struct CENMarkdownParserElements {
    
    /**
     * @brief  Stores reference on name of key under which dictionary with \a NSAttributedStringKey keys and values which
     *         specify layout for whole string.
     * @note   Passed dictionary should include value for \a NSFontAttributeName because this font will be used by rest
     *         elements.
     */
    __unsafe_unretained NSString *defaultAttributes;
    
    /**
     * @brief  Stores reference on name of key under which dictionary with \a NSAttributedStringKey keys and values which
     *         specify layout for text with italic emphasis markup.
     * @note   Dictionary may contain any properties except \a NSFontAttributeName (this value will be taken from
     *         \a CENMarkdownParserElement.defaultAttributes)
     */
    __unsafe_unretained NSString *italicAttributes;
    
    /**
     * @brief  Stores reference on name of key under which dictionary with \a NSAttributedStringKey keys and values which
     *         specify layout for text with bold emphasis markup.
     * @note   Dictionary may contain any properties except \a NSFontAttributeName (this value will be taken from
     *         \a CENMarkdownParserElement.defaultAttributes)
     */
    __unsafe_unretained NSString *boldAttributes;
    
    /**
     * @brief  Stores reference on name of key under which dictionary with \a NSAttributedStringKey keys and values which
     *         specify layout for text with strikethrough emphasis markup.
     * @note   Dictionary may contain any properties except \a NSFontAttributeName (this value will be taken from
     *         \a CENMarkdownParserElement.defaultAttributes)
     */
    __unsafe_unretained NSString *strikethroughAttributes;
    
    /**
     * @brief      Stores reference on name of key under which dictionary with \a NSAttributedStringKey keys and values which
     *             specify layout for text with link markup.
     * @discussion Attributes for link may specify \a NSForegroundColorAttributeName, but it can be ignored by element which
     *             is used to represent \a Markdown formatted string.
     * @note       Dictionary may contain any properties except \a NSFontAttributeName (this value will be taken from
     *             \a CENMarkdownParserElement.defaultAttributes)
     */
    __unsafe_unretained NSString *linkAttributes;
    
    /**
     * @brief  Stores reference on name of key under which dictionary with \a NSAttributedStringKey keys and values which
     *         specify layout for text with inline code markup.
     */
    __unsafe_unretained NSString *codeAttributes;
} CENMarkdownParserElements;

extern CENMarkdownParserElements CENMarkdownParserElement;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief  Simple \a Markdown markup parser.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENMarkdownParser : NSObject


#pragma mark -


@end

NS_ASSUME_NONNULL_END
