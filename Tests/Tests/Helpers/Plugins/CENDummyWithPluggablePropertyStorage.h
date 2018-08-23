#import <CENChatEngine/CEPPlugablePropertyStorage+Private.h>


#pragma mark Interface declaration

@interface CENDummyWithPluggablePropertyStorage : CEPPlugablePropertyStorage


#pragma mark - Information

@property (nonatomic, strong) NSString *strongString;
@property (nonatomic, weak) NSString *weakString;
@property (nonatomic, copy) NSString *stringCopy;

@property (nonatomic, strong) NSMutableString *strongMutableString;
@property (nonatomic, weak) NSMutableString *weakMutableString;
@property (nonatomic, copy) NSMutableString *mutableStringCopy;

@property (nonatomic, strong) NSArray *strongArray;
@property (nonatomic, weak) NSArray *weakArray;
@property (nonatomic, copy) NSArray *arrayCopy;

@property (nonatomic, strong) NSMutableArray *strongMutableArray;
@property (nonatomic, weak) NSMutableArray *weakMutableArray;
@property (nonatomic, copy) NSMutableArray *mutableArrayCopy;

@property (nonatomic, strong) NSDictionary *strongDictionary;
@property (nonatomic, weak) NSDictionary *weakDictionary;
@property (nonatomic, copy) NSDictionary *dictionaryCopy;

@property (nonatomic, strong) NSMutableDictionary *strongMutableDictionary;
@property (nonatomic, weak) NSMutableDictionary *weakMutableDictionary;
@property (nonatomic, copy) NSMutableDictionary *mutableDictionaryCopy;

@property (nonatomic, strong) NSException *strongException;
@property (nonatomic, weak) NSException *weakException;
@property (nonatomic, copy) NSException *exceptionCopy;

@property (nonatomic, strong) NSError *strongError;
@property (nonatomic, weak) NSError *weakError;
@property (nonatomic, copy) NSError *errorCopy;

@property (nonatomic, strong) NSNumber *strongNumber;
@property (nonatomic, weak) NSNumber *weakNumber;
@property (nonatomic, copy) NSNumber *numberCopy;

@property (nonatomic, strong) NSData *strongData;
@property (nonatomic, weak) NSData *weakData;
@property (nonatomic, copy) NSData *dataCopy;

@property (nonatomic, strong) NSMutableData *strongMutableData;
@property (nonatomic, weak) NSMutableData *weakMutableData;
@property (nonatomic, copy) NSMutableData *mutableDataCopy;

@property (nonatomic, strong) NSDate *strongDate;
@property (nonatomic, weak) NSDate *weakDate;
@property (nonatomic, copy) NSDate *dateCopy;

@property (nonatomic, strong) dispatch_block_t strongBlock;
@property (nonatomic, weak) dispatch_block_t weakBlock;
@property (nonatomic, copy) dispatch_block_t blockCopy;


@property (nonatomic, assign) char *cStringValue;
@property (nonatomic, assign) char charValue;
@property (nonatomic, assign) unsigned char unsignedCharValue;

@property (nonatomic, assign) float floatValue;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) BOOL boolValue;

@property (nonatomic, assign) int intValue;
@property (nonatomic, assign) unsigned int unsignedIntValue;

@property (nonatomic, assign) short shortValue;
@property (nonatomic, assign) unsigned short unsignedShortValue;

@property (nonatomic, assign) long longValue;
@property (nonatomic, assign) unsigned long unsignedLongValue;

@property (nonatomic, assign) long long longLongValue;
@property (nonatomic, assign) unsigned long long unsignedLongLongValue;


@property (nonatomic, assign, getter = isCustomBoolValue) BOOL customBoolValue;
@property (nonatomic, assign, setter = testCustomFloatValue:) float customFloatValue;


+ (NSArray<NSString *> *)nonbindableProperties;

#pragma mark -


@end
