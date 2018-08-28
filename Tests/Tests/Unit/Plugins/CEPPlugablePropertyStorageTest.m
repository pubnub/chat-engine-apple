/**
 * @author Serhii Mamontov
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CENDummyWithPluggablePropertyStorageIgnoredFields.h"
#import "CENDummyWithPluggablePropertyStorage.h"
#import <OCMock/OCMock.h>
#import "CENTestCase.h"


static NSString * const kCENTWeakPropertiesStorageKey = @"cenbs_weak_storage";


@interface CEPPlugablePropertyStorageTest : CENTestCase


#pragma mark - Information

@property (nonatomic, strong) NSDictionary *storage;
@property (nonatomic, strong) CENDummyWithPluggablePropertyStorage *object;

#pragma mark -


@end


@implementation CEPPlugablePropertyStorageTest


#pragma mark - Setup / Tear down

- (BOOL)shouldSetupVCR {
    
    return NO;
}

- (void)setUp {
    
    [super setUp];
    
    if ([self.name rangeOfString:@"testNonbindableProperties_ShouldNotStoreValueInStorage_WhenExplicitlyPlacedInIgnoreList"].location != NSNotFound) {
        self.object = (CENDummyWithPluggablePropertyStorage *)[CENDummyWithPluggablePropertyStorageIgnoredFields new];
    } else {
        self.object = [CENDummyWithPluggablePropertyStorage new];
    }
    
    self.object.storage = [CEPPlugablePropertyStorage newStorageForProperties];
    self.storage = @{
        @"string": @"ChatEngine #1",
        @"mutableString": [@"ChatEngine #2" mutableCopy],
        @"array": @[@"ChatEngine #1", @"ChatEngine #2"],
        @"mutableArray": [@[@"ChatEngine #1", @"ChatEngine #2"] mutableCopy],
        @"exception": [NSException exceptionWithName:@"TestExceptino" reason:@"For test" userInfo:@{ @"exception": @"data" }],
        @"dictionary": @{ @"test": @"data #1" },
        @"mutableDictionary": [@{ @"test": @"data #2" } mutableCopy],
        @"error": [NSError errorWithDomain:@"TestDomain" code:1000 userInfo:@{ @"error": @"data" }],
        @"number": @2010,
        @"data": [@"ChatEngine #1" dataUsingEncoding:NSUTF8StringEncoding],
        @"mutableData": [@"ChatEngine #2" dataUsingEncoding:NSUTF8StringEncoding],
        @"date": [NSDate date],
        @"block": ^{}
    };
}


#pragma mark - Tests :: nonbindableProperties

- (void)testNonbindableProperties_ShouldReturnNilByDefault {
    
    XCTAssertNil([CEPPlugablePropertyStorage valueForKey:@"nonbindableProperties"]);
}

- (void)testNonbindableProperties_ShouldNotStoreValueInStorage_WhenExplicitlyPlacedInIgnoreList {
    
    self.object.strongString = self.storage[@"string"];
    
    XCTAssertNil(self.object.storage[@"strongString"]);
    XCTAssertEqual(self.object.storage.count, 1);
    XCTAssertTrue([self.object.strongString isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(self.object.strongString, self.storage[@"string"]);
    XCTAssertEqual(self.object.strongString, self.storage[@"string"]);
}


#pragma mark - Tests :: Objects :: Store

- (void)testProperty_ShouldStoreStrongNSString_WhenPropertyHasStrongAttribute {
    
    self.object.strongString = self.storage[@"string"];
    
    XCTAssertNotNil(self.object.storage[@"strongString"]);
    XCTAssertTrue([self.object.strongString isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(self.object.strongString, self.storage[@"string"]);
    XCTAssertEqual(self.object.strongString, self.storage[@"string"]);
}

- (void)testProperty_ShouldStoreWeakNSStringReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakString = self.storage[@"string"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakString"]);
    XCTAssertTrue([self.object.weakString isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(self.object.weakString, self.storage[@"string"]);
    XCTAssertEqual(self.object.weakString, self.storage[@"string"]);
}

- (void)testProperty_ShouldStoreCopyNSString_WhenPropertyHasCopyAttribute {
    
    self.object.stringCopy = self.storage[@"string"];
    
    XCTAssertNotNil(self.object.storage[@"stringCopy"]);
    XCTAssertTrue([self.object.stringCopy isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(self.object.stringCopy, self.storage[@"string"]);
    XCTAssertEqual(self.object.stringCopy, self.storage[@"string"]);
}

- (void)testProperty_ShouldStoreStrongNSMutableString_WhenPropertyHasStrongAttribute {
    
    self.object.strongMutableString = self.storage[@"mutableString"];
    
    XCTAssertNotNil(self.object.storage[@"strongMutableString"]);
    XCTAssertTrue([self.object.strongMutableString isKindOfClass:[NSMutableString class]]);
    XCTAssertEqualObjects(self.object.strongMutableString, self.storage[@"mutableString"]);
    XCTAssertEqual(self.object.strongMutableString, self.storage[@"mutableString"]);
}

- (void)testProperty_ShouldStoreWeakNSMutableStringReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakMutableString = self.storage[@"mutableString"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakMutableString"]);
    XCTAssertTrue([self.object.weakMutableString isKindOfClass:[NSMutableString class]]);
    XCTAssertEqualObjects(self.object.weakMutableString, self.storage[@"mutableString"]);
    XCTAssertEqual(self.object.weakMutableString, self.storage[@"mutableString"]);
}

- (void)testProperty_ShouldStoreCopyNSMutableString_WhenPropertyHasCopyAttribute {
    
    self.object.mutableStringCopy = self.storage[@"mutableString"];
    
    XCTAssertNotNil(self.object.storage[@"mutableStringCopy"]);
    XCTAssertTrue([self.object.mutableStringCopy isKindOfClass:[NSMutableString class]]);
    XCTAssertEqualObjects(self.object.mutableStringCopy, self.storage[@"mutableString"]);
    XCTAssertNotEqual(self.object.mutableStringCopy, self.storage[@"mutableString"]);
}

- (void)testProperty_ShouldStoreStrongNSArray_WhenPropertyHasStrongAttribute {
    
    self.object.strongArray = self.storage[@"array"];
    
    XCTAssertNotNil(self.object.storage[@"strongArray"]);
    XCTAssertTrue([self.object.strongArray isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(self.object.strongArray, self.storage[@"array"]);
    XCTAssertEqual(self.object.strongArray, self.storage[@"array"]);
}

- (void)testProperty_ShouldStoreWeakNSArreayReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakArray = self.storage[@"array"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakArray"]);
    XCTAssertTrue([self.object.weakArray isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(self.object.weakArray, self.storage[@"array"]);
    XCTAssertEqual(self.object.weakArray, self.storage[@"array"]);
}

- (void)testProperty_ShouldStoreCopyNSArray_WhenPropertyHasCopyAttribute {
    
    self.object.arrayCopy = self.storage[@"array"];
    
    XCTAssertNotNil(self.object.storage[@"arrayCopy"]);
    XCTAssertTrue([self.object.arrayCopy isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(self.object.arrayCopy, self.storage[@"array"]);
    XCTAssertEqual(self.object.arrayCopy, self.storage[@"array"]);
}

- (void)testProperty_ShouldStoreStrongNSMutableArray_WhenPropertyHasStrongAttribute {
    
    self.object.strongMutableArray = self.storage[@"mutableArray"];
    
    XCTAssertNotNil(self.object.storage[@"strongMutableArray"]);
    XCTAssertTrue([self.object.strongMutableArray isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects(self.object.strongMutableArray, self.storage[@"mutableArray"]);
    XCTAssertEqual(self.object.strongMutableArray, self.storage[@"mutableArray"]);
}

- (void)testProperty_ShouldStoreWeakNSMutableArrayReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakMutableArray = self.storage[@"mutableArray"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakMutableArray"]);
    XCTAssertTrue([self.object.weakMutableArray isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects(self.object.weakMutableArray, self.storage[@"mutableArray"]);
    XCTAssertEqual(self.object.weakMutableArray, self.storage[@"mutableArray"]);
}

- (void)testProperty_ShouldStoreCopyNSMutableArray_WhenPropertyHasCopyAttribute {
    
    self.object.mutableArrayCopy = self.storage[@"mutableArray"];
    
    XCTAssertNotNil(self.object.storage[@"mutableArrayCopy"]);
    XCTAssertTrue([self.object.mutableArrayCopy isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(self.object.mutableArrayCopy, self.storage[@"mutableArray"]);
    XCTAssertNotEqual(self.object.mutableArrayCopy, self.storage[@"mutableArray"]);
}

- (void)testProperty_ShouldStoreStrongNSDictionary_WhenPropertyHasStrongAttribute {
    
    self.object.strongDictionary = self.storage[@"dictionary"];
    
    XCTAssertNotNil(self.object.storage[@"strongDictionary"]);
    XCTAssertTrue([self.object.strongDictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(self.object.strongDictionary, self.storage[@"dictionary"]);
    XCTAssertEqual(self.object.strongDictionary, self.storage[@"dictionary"]);
}

- (void)testProperty_ShouldStoreWeakNSDictionaryReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakDictionary = self.storage[@"dictionary"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakDictionary"]);
    XCTAssertTrue([self.object.weakDictionary isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(self.object.weakDictionary, self.storage[@"dictionary"]);
    XCTAssertEqual(self.object.weakDictionary, self.storage[@"dictionary"]);
}

- (void)testProperty_ShouldStoreCopyNSDictionary_WhenPropertyHasCopyAttribute {
    
    self.object.dictionaryCopy = self.storage[@"dictionary"];
    
    XCTAssertNotNil(self.object.storage[@"dictionaryCopy"]);
    XCTAssertTrue([self.object.dictionaryCopy isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(self.object.dictionaryCopy, self.storage[@"dictionary"]);
    XCTAssertEqual(self.object.dictionaryCopy, self.storage[@"dictionary"]);
}

- (void)testProperty_ShouldStoreStrongNSMutableDictionary_WhenPropertyHasStrongAttribute {
    
    self.object.strongMutableDictionary = self.storage[@"mutableDictionary"];
    
    XCTAssertNotNil(self.object.storage[@"strongMutableDictionary"]);
    XCTAssertTrue([self.object.strongMutableDictionary isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertEqualObjects(self.object.strongMutableDictionary, self.storage[@"mutableDictionary"]);
    XCTAssertEqual(self.object.strongMutableDictionary, self.storage[@"mutableDictionary"]);
}

- (void)testProperty_ShouldStoreWeakNSMutableDictionaryReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakMutableDictionary = self.storage[@"mutableDictionary"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakMutableDictionary"]);
    XCTAssertTrue([self.object.weakMutableDictionary isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertEqualObjects(self.object.weakMutableDictionary, self.storage[@"mutableDictionary"]);
    XCTAssertEqual(self.object.weakMutableDictionary, self.storage[@"mutableDictionary"]);
}

- (void)testProperty_ShouldStoreCopyNSMutableDictionary_WhenPropertyHasCopyAttribute {
    
    self.object.mutableDictionaryCopy = self.storage[@"mutableDictionary"];
    
    XCTAssertNotNil(self.object.storage[@"mutableDictionaryCopy"]);
    XCTAssertTrue([self.object.mutableDictionaryCopy isKindOfClass:[NSDictionary class]]);
    XCTAssertEqualObjects(self.object.mutableDictionaryCopy, self.storage[@"mutableDictionary"]);
    XCTAssertNotEqual(self.object.mutableDictionaryCopy, self.storage[@"mutableDictionary"]);
}

- (void)testProperty_ShouldStoreStrongNSException_WhenPropertyHasStrongAttribute {
    
    self.object.strongException = self.storage[@"exception"];
    
    XCTAssertNotNil(self.object.storage[@"strongException"]);
    XCTAssertTrue([self.object.strongException isKindOfClass:[NSException class]]);
    XCTAssertEqualObjects(self.object.strongException, self.storage[@"exception"]);
    XCTAssertEqual(self.object.strongException, self.storage[@"exception"]);
}

- (void)testProperty_ShouldStoreWeakNSExceptionReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakException = self.storage[@"exception"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakException"]);
    XCTAssertTrue([self.object.weakException isKindOfClass:[NSException class]]);
    XCTAssertEqualObjects(self.object.weakException, self.storage[@"exception"]);
    XCTAssertEqual(self.object.weakException, self.storage[@"exception"]);
}

- (void)testProperty_ShouldStoreCopyNSException_WhenPropertyHasCopyAttribute {
    
    self.object.exceptionCopy = self.storage[@"exception"];
    
    XCTAssertNotNil(self.object.storage[@"exceptionCopy"]);
    XCTAssertTrue([self.object.exceptionCopy isKindOfClass:[NSException class]]);
    XCTAssertEqualObjects(self.object.exceptionCopy, self.storage[@"exception"]);
    XCTAssertEqual(self.object.exceptionCopy, self.storage[@"exception"]);
}

- (void)testProperty_ShouldStoreStrongNSError_WhenPropertyHasStrongAttribute {
    
    self.object.strongError = self.storage[@"error"];
    
    XCTAssertNotNil(self.object.storage[@"strongError"]);
    XCTAssertTrue([self.object.strongError isKindOfClass:[NSError class]]);
    XCTAssertEqualObjects(self.object.strongError, self.storage[@"error"]);
    XCTAssertEqual(self.object.strongError, self.storage[@"error"]);
}

- (void)testProperty_ShouldStoreWeakNSErrorReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakError = self.storage[@"error"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakError"]);
    XCTAssertTrue([self.object.weakError isKindOfClass:[NSError class]]);
    XCTAssertEqualObjects(self.object.weakError, self.storage[@"error"]);
    XCTAssertEqual(self.object.weakError, self.storage[@"error"]);
}

- (void)testProperty_ShouldStoreCopyNSError_WhenPropertyHasCopyAttribute {
    
    self.object.errorCopy = self.storage[@"error"];
    
    XCTAssertNotNil(self.object.storage[@"errorCopy"]);
    XCTAssertTrue([self.object.errorCopy isKindOfClass:[NSError class]]);
    XCTAssertEqualObjects(self.object.errorCopy, self.storage[@"error"]);
    XCTAssertNotEqual(self.object.errorCopy, self.storage[@"error"]);
}

- (void)testProperty_ShouldStoreStrongNSNumber_WhenPropertyHasStrongAttribute {
    
    self.object.strongNumber = self.storage[@"number"];
    
    XCTAssertNotNil(self.object.storage[@"strongNumber"]);
    XCTAssertTrue([self.object.strongNumber isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(self.object.strongNumber, self.storage[@"number"]);
    XCTAssertEqual(self.object.strongNumber, self.storage[@"number"]);
}

- (void)testProperty_ShouldStoreWeakNSNumberReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakNumber = self.storage[@"number"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakNumber"]);
    XCTAssertTrue([self.object.weakNumber isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(self.object.weakNumber, self.storage[@"number"]);
    XCTAssertEqual(self.object.weakNumber, self.storage[@"number"]);
}

- (void)testProperty_ShouldStoreCopyNSNumber_WhenPropertyHasCopyAttribute {
    
    self.object.numberCopy = self.storage[@"number"];
    
    XCTAssertNotNil(self.object.storage[@"numberCopy"]);
    XCTAssertTrue([self.object.numberCopy isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(self.object.numberCopy, self.storage[@"number"]);
    XCTAssertEqual(self.object.numberCopy, self.storage[@"number"]);
}

- (void)testProperty_ShouldStoreStrongNSData_WhenPropertyHasStrongAttribute {
    
    self.object.strongData = self.storage[@"data"];
    
    XCTAssertNotNil(self.object.storage[@"strongData"]);
    XCTAssertTrue([self.object.strongData isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(self.object.strongData, self.storage[@"data"]);
    XCTAssertEqual(self.object.strongData, self.storage[@"data"]);
}

- (void)testProperty_ShouldStoreWeakNSDataReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakData = self.storage[@"data"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakData"]);
    XCTAssertTrue([self.object.weakData isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(self.object.weakData, self.storage[@"data"]);
    XCTAssertEqual(self.object.weakData, self.storage[@"data"]);
}

- (void)testProperty_ShouldStoreCopyNSData_WhenPropertyHasCopyAttribute {
    
    self.object.dataCopy = self.storage[@"data"];
    
    XCTAssertNotNil(self.object.storage[@"dataCopy"]);
    XCTAssertTrue([self.object.dataCopy isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(self.object.dataCopy, self.storage[@"data"]);
    XCTAssertNotEqual(self.object.dataCopy, self.storage[@"data"]);
}

- (void)testProperty_ShouldStoreStrongNSMutableData_WhenPropertyHasStrongAttribute {
    
    self.object.strongMutableData = self.storage[@"mutableData"];
    
    XCTAssertNotNil(self.object.storage[@"strongMutableData"]);
    XCTAssertTrue([self.object.strongMutableData isKindOfClass:[NSMutableData class]]);
    XCTAssertEqualObjects(self.object.strongMutableData, self.storage[@"mutableData"]);
    XCTAssertEqual(self.object.strongMutableData, self.storage[@"mutableData"]);
}

- (void)testProperty_ShouldStoreWeakNSMutableDataReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakMutableData = self.storage[@"mutableData"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakMutableData"]);
    XCTAssertTrue([self.object.weakMutableData isKindOfClass:[NSMutableData class]]);
    XCTAssertEqualObjects(self.object.weakMutableData, self.storage[@"mutableData"]);
    XCTAssertEqual(self.object.weakMutableData, self.storage[@"mutableData"]);
}

- (void)testProperty_ShouldStoreCopyNSMutableData_WhenPropertyHasCopyAttribute {
    
    self.object.mutableDataCopy = self.storage[@"mutableData"];
    
    XCTAssertNotNil(self.object.storage[@"mutableDataCopy"]);
    XCTAssertTrue([self.object.mutableDataCopy isKindOfClass:[NSData class]]);
    XCTAssertEqualObjects(self.object.mutableDataCopy, self.storage[@"mutableData"]);
    XCTAssertNotEqual(self.object.mutableDataCopy, self.storage[@"mutableData"]);
}

- (void)testProperty_ShouldStoreStrongNSDate_WhenPropertyHasStrongAttribute {
    
    self.object.strongDate = self.storage[@"date"];
    
    XCTAssertNotNil(self.object.storage[@"strongDate"]);
    XCTAssertTrue([self.object.strongDate isKindOfClass:[NSDate class]]);
    XCTAssertEqualObjects(self.object.strongDate, self.storage[@"date"]);
    XCTAssertEqual(self.object.strongDate, self.storage[@"date"]);
}

- (void)testProperty_ShouldStoreWeakNSDateReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakDate = self.storage[@"date"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakDate"]);
    XCTAssertTrue([self.object.weakDate isKindOfClass:[NSDate class]]);
    XCTAssertEqualObjects(self.object.weakDate, self.storage[@"date"]);
    XCTAssertEqual(self.object.weakDate, self.storage[@"date"]);
}

- (void)testProperty_ShouldStoreCopyNSDate_WhenPropertyHasCopyAttribute {
    
    self.object.dateCopy = self.storage[@"date"];
    
    XCTAssertNotNil(self.object.storage[@"dateCopy"]);
    XCTAssertTrue([self.object.dateCopy isKindOfClass:[NSDate class]]);
    XCTAssertEqualObjects(self.object.dateCopy, self.storage[@"date"]);
    XCTAssertEqual(self.object.dateCopy, self.storage[@"date"]);
}

- (void)testProperty_ShouldStoreStrongGCDBlock_WhenPropertyHasStrongAttribute {
    
    self.object.strongBlock = self.storage[@"block"];
    
    XCTAssertNotNil(self.object.storage[@"strongBlock"]);
    XCTAssertEqualObjects(self.object.strongBlock, self.storage[@"block"]);
    XCTAssertEqual((id)self.object.strongBlock, self.storage[@"block"]);
}

- (void)testProperty_ShouldStoreWeakGCDBlockReference_WhenPropertyHasWeakAttribute {
    
    self.object.weakBlock = self.storage[@"block"];
    
    XCTAssertNotNil([self.object.storage[kCENTWeakPropertiesStorageKey] objectForKey:@"weakBlock"]);
    XCTAssertEqualObjects(self.object.weakBlock, self.storage[@"block"]);
    XCTAssertEqual((id)self.object.weakBlock, self.storage[@"block"]);
}

- (void)testProperty_ShouldStoreCopyGCDBlock_WhenPropertyHasCopyAttribute {
    
    self.object.blockCopy = self.storage[@"block"];
    
    XCTAssertNotNil(self.object.storage[@"blockCopy"]);
    XCTAssertEqualObjects(self.object.blockCopy, self.storage[@"block"]);
    // Because block inside of 'storage' is copied by default.
    XCTAssertEqual((id)self.object.blockCopy, self.storage[@"block"]);
}


#pragma mark - Tests :: Objects :: Remove

- (void)testProperty_ShouldRemovePropertyValue_WhenNilPassed {
    
    self.object.strongString = self.storage[@"string"];
    
    XCTAssertEqualObjects(self.object.strongString, self.storage[@"string"]);
    self.object.strongString = nil;

    XCTAssertNil(self.object.storage[@"strongString"]);
    XCTAssertEqual(self.object.storage.count, 1);
}


#pragma mark - Tests :: Primitives :: Store

- (void)testProperty_ShouldStoreCString {
    
    char *value = (char *)[(NSString *)self.storage[@"string"] cStringUsingEncoding:NSUTF8StringEncoding];
    self.object.cStringValue = value;
    id stored = self.object.storage[@"cStringValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(stored, self.storage[@"string"]);
    XCTAssertEqual(strcmp(self.object.cStringValue, value), 0);
}

- (void)testProperty_ShouldStoreChar {
    
    char value = 1;
    self.object.charValue = value;
    id stored = self.object.storage[@"charValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.charValue, value);
}

- (void)testProperty_ShouldStoreUnsignedChar {
    
    unsigned char value = 125;
    self.object.unsignedCharValue = value;
    id stored = self.object.storage[@"unsignedCharValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.unsignedCharValue, value);
}

- (void)testProperty_ShouldStoreFloat {
    
    float value = 100.f;
    self.object.floatValue = value;
    id stored = self.object.storage[@"floatValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.floatValue, value);
}

- (void)testProperty_ShouldStoreFloat_WhenCustomSetterDefined {
    
    float value = 100.f;
    self.object.customFloatValue = value;
    id stored = self.object.storage[@"customFloatValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.customFloatValue, value);
}

- (void)testProperty_ShouldStoreDouble {
    
    float value = 200.f;
    self.object.doubleValue = value;
    id stored = self.object.storage[@"doubleValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.doubleValue, value);
}

- (void)testProperty_ShouldStoreBool {
    
    BOOL value = YES;
    self.object.boolValue = value;
    id stored = self.object.storage[@"boolValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.boolValue, value);
}

- (void)testProperty_ShouldStoreBool_WhenCustomGetterDefined {
    
    BOOL value = YES;
    self.object.customBoolValue = value;
    id stored = self.object.storage[@"customBoolValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.isCustomBoolValue, value);
}

- (void)testProperty_ShouldStoreInt {
    
    int value = -32000;
    self.object.intValue = value;
    id stored = self.object.storage[@"intValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.intValue, value);
}

- (void)testProperty_ShouldStoreUnsignedInt {
    
    unsigned int value = 65000;
    self.object.unsignedIntValue = value;
    id stored = self.object.storage[@"unsignedIntValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.unsignedIntValue, value);
}

- (void)testProperty_ShouldStoreShort {
    
    short value = 32000;
    self.object.shortValue = value;
    id stored = self.object.storage[@"shortValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.shortValue, value);
}

- (void)testProperty_ShouldStoreUnsignedShort {
    
    unsigned short value = 65530;
    self.object.unsignedShortValue = value;
    id stored = self.object.storage[@"unsignedShortValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.unsignedShortValue, value);
}

- (void)testProperty_ShouldStoreLong {
    
    long value = -2147483000;
    self.object.longValue = value;
    id stored = self.object.storage[@"longValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.longValue, value);
}

- (void)testProperty_ShouldStoreUnsignedLong {
    
    unsigned long value = 3000967000;
    self.object.unsignedLongValue = value;
    id stored = self.object.storage[@"unsignedLongValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.unsignedLongValue, value);
}

- (void)testProperty_ShouldStoreLongLong {
    
    long value = -900368545007;
    self.object.longLongValue = value;
    id stored = self.object.storage[@"longLongValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.longLongValue, value);
}

- (void)testProperty_ShouldStoreUnsignedLongLong {
    
    unsigned long value = 12446744073615;
    self.object.unsignedLongLongValue = value;
    id stored = self.object.storage[@"unsignedLongLongValue"];
    
    XCTAssertNotNil(stored);
    XCTAssertTrue([stored isKindOfClass:[NSNumber class]]);
    XCTAssertEqualObjects(stored, @(value));
    XCTAssertEqual(self.object.unsignedLongLongValue, value);
}


#pragma mark - Tests :: Primitives :: Remove

- (void)testProperty_ShouldRemovePropertyValue_WhenNullPassed {
    
    char *value = (char *)[(NSString *)self.storage[@"string"] cStringUsingEncoding:NSUTF8StringEncoding];
    self.object.cStringValue = value;
    
    XCTAssertEqual(strcmp(self.object.cStringValue, value), 0);
    
    self.object.cStringValue = NULL;
    
    XCTAssertNil(self.object.storage[@"cStringValue"]);
    XCTAssertEqual(self.object.storage.count, 1);
}

#pragma mark -


@end
