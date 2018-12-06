#import <Foundation/Foundation.h>


/**
 * @brief Structure which provides keys available for parsed Markdown markup visual layout with
 * \a NSAttributedString.
 */
typedef struct CENMarkdownParserElements {
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with out any markup on it.
     *
     * @note Should include value for \a NSFontAttributeName because this font will be used by rest
     * elements.
     */
    __unsafe_unretained NSString *defaultAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with italic emphasis markup on it.
     *
     * @note May contain any properties except \a NSFontAttributeName (this value will be taken from
     * \b CENMarkdownParserElement.defaultAttributes).
     */
    __unsafe_unretained NSString *italicAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with bold emphasis markup on it.
     *
     * @note May contain any properties except \a NSFontAttributeName (this value will be taken from
     * \b CENMarkdownParserElement.defaultAttributes).
     */
    __unsafe_unretained NSString *boldAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with strikethrough emphasis markup on it.
     *
     * @note May contain any properties except \a NSFontAttributeName (this value will be taken from
     * \b CENMarkdownParserElement.defaultAttributes).
     */
    __unsafe_unretained NSString *strikethroughAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with link markup on it.
     *
     * @discussion Attributes for link may specify \a NSForegroundColorAttributeName, but it can be
     * ignored by element which is used to represent \a Markdown formatted string.
     *
     * @note May contain any properties except \a NSFontAttributeName (this value will be taken from
     * \b CENMarkdownParserElement.defaultAttributes).
     */
    __unsafe_unretained NSString *linkAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with inline code markup on it.
     */
    __unsafe_unretained NSString *codeAttributes;
} CENMarkdownParserElements;

extern CENMarkdownParserElements CENMarkdownParserElement;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Simple \a Markdown markup parser.
 *
 * @author Serhii Mamontov
 * @version 1.0.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
@interface CENMarkdownParser : NSObject


#pragma mark -


@end

NS_ASSUME_NONNULL_END
