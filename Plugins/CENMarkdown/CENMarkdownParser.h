#import <Foundation/Foundation.h>


/**
 * @brief Structure which provides keys available for parsed Markdown markup visual layout with
 * \a NSAttributedString.
 *
 * @ref 5f121146-c27b-42cf-b5f8-14b12231363e
 */
typedef struct CENMarkdownParserElements {
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with out any markup on it.
     *
     * @note Should include value for \a NSFontAttributeName because this font will be used by rest
     * elements.
     *
     * @ref 206d6b37-50c4-4e5c-923d-8cf51a454765
     */
    __unsafe_unretained NSString *defaultAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with italic emphasis markup on it.
     *
     * @note May contain any properties except \a NSFontAttributeName (this value will be taken from
     * \b CENMarkdownParserElement.defaultAttributes).
     *
     * @ref 59b7cec6-56a6-4393-a6c6-04379a61fcdc
     */
    __unsafe_unretained NSString *italicAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with bold emphasis markup on it.
     *
     * @note May contain any properties except \a NSFontAttributeName (this value will be taken from
     * \b CENMarkdownParserElement.defaultAttributes).
     *
     * @ref 955e910c-01d7-4c52-8b10-77b6feaff6e5
     */
    __unsafe_unretained NSString *boldAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with strikethrough emphasis markup on it.
     *
     * @note May contain any properties except \a NSFontAttributeName (this value will be taken from
     * \b CENMarkdownParserElement.defaultAttributes).
     *
     * @ref df630b29-2dbf-47ea-a953-5c8d9d8d5bba
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
     *
     * @ref 376623cf-1db6-4cf1-a250-d2a88073d03e
     */
    __unsafe_unretained NSString *linkAttributes;
    
    /**
     * @brief \a NSDictionary with \a NSAttributedStringKey keys and values which specify layout for
     * text with inline code markup on it.
     *
     * @ref 17329c0a-5229-47cc-ac57-ec6bb862732c
     */
    __unsafe_unretained NSString *codeAttributes;
} CENMarkdownParserElements;

extern CENMarkdownParserElements CENMarkdownParserElement;


NS_ASSUME_NONNULL_BEGIN

/**
 * @brief Simple \a Markdown markup parser.
 *
 * @ref d95c354b-80b7-4882-8d65-5b2d1b179a0c
 *
 * @author Serhii Mamontov
 * @version 0.0.2
 * @copyright © 2010-2019 PubNub, Inc.
 */
@interface CENMarkdownParser : NSObject


#pragma mark -


@end

NS_ASSUME_NONNULL_END
