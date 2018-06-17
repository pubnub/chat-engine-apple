/**
 * @author Serhii Mamontov
 * @version 0.9.0
 * @copyright © 2009-2018 PubNub, Inc.
 */
#import "CEPPlugablePropertyStorage+Private.h"
#import <objc/runtime.h>


#pragma mark Static

/**
 @brief  Stores reference on key under which back storage hold reference on object which is able to store weak references.
 */
static NSString * const kCEBSWeakStorageKey = @"cebs_weak_storage";


NS_ASSUME_NONNULL_BEGIN


#pragma mark - Protected interface declaration

@interface CEPPlugablePropertyStorage ()


#pragma mark - Information

/**
 * @brief  Stores reference on dictionary which is used as storage for object's properties.
 */
@property (nonatomic, nullable, strong) NSMutableDictionary *storage;


#pragma mark - Properties binding

/**
 * @brief  List of properties which should be bound to their ivar(s).
 *
 * @return List of properties for which accessors shouldn't be changed.
 */
+ (NSArray<NSString *> *)nonbindableProperties;

/**
 * @brief Bind specified \c property getters/setters to use plugable storage.
 *
 * @param property  Reference on class instance property structure for which getter and setter method should be replaced with
 *                  methods which use plugable storage instead of instance ivar.
 * @param getter    Reference on property getter method selector.
 * @param setter    Reference on property setter method selector.
 * @param storeCopy Whether property stores reference on copy of passed value or not.
 * @param storeWeak Whether property stores weak reference on passed value or not.
 */
+ (void)bindProperty:(objc_property_t)property
    toStorageWithGetter:(SEL)getter
                 setter:(nullable SEL)setter
              valueCopy:(BOOL)storeCopy
                 orWeak:(BOOL)storeWeak;

/**
 * @brief      Bind one of methods for specified \c property to plugable storage.
 * @discussion Passed \c getter flag explain whether \c selector represent \c property setter or getter.
 *
 * @param property  Reference on class instance property structure for which accessor method should be replaced with methods
 *                  which use plugable storage instead of instance ivar.
 * @param getter    Whether passed selector represent getter or not.
 * @param selector  Reference on property accessor method selector for which replaCENMent should be done.
 * @param storeCopy Whether property stores reference on copy of passed value or not.
 * @param storeWeak Whether property stores weak reference on passed value or not.
 */
+ (void)bindProperty:(objc_property_t)property
    toStorageWithGetter:(BOOL)getter
               selector:(SEL)selector
              valueCopy:(BOOL)storeCopy
                 orWeak:(BOOL)storeWeak;

/**
 * @brief       Create new property's getter method implementation.
 * @diascussion Created implementation will use plugable storage instead of ivars to store values
 *              passed to property.
 *
 * @param property  Name of property for which getter method implementation should be created.
 * @param selector  Reference to original getter method selector which will be replaced later.
 * @param storeWeak Whether property configured to store weak reference to passed value or not.
 *
 * @return Reference on property's getter method implementation.
 */
+ (IMP)getterImplementationForProperty:(NSString *)property withSelector:(SEL)selector weak:(BOOL)storeWeak;

/**
 * @brief       Create new property's setter method implementation.
 * @diascussion Created implementation will use plugable storage instead of ivars to store values
 *              passed to property.
 *
 * @param property  Name of property for which setter method implementation should be created.
 * @param selector  Reference to original setter method selector which will be replaced later.
 * @param storeCopy Whether property configured to store copy of passed value or not.
 * @param storeWeak Whether property configured to store weak reference to passed value or not.
 *
 * @return Reference on property's getter method implementation.
 */
+ (IMP)setterImplementationForProperty:(NSString *)property withSelector:(SEL)selector valueCopy:(BOOL)storeCopy orWeak:(BOOL)storeWeak;


#pragma mark - Accessor methods swizzling

/**
 * @brief  Exchange implementation of \c original selector with swizzled.
 *
 * @param selector         Reference on selector which should provide only information about method signature.
 * @param swizzledSelector Reference on selector which represent method from which implementation will be taken for original
 *                         method.
 */
+ (void)swizzleOriginalSelector:(SEL)selector with:(SEL)swizzledSelector;


#pragma mark - Misc

/**
 * @brief      Compose \c property getter method signature.
 * @discussion Check property attributes and compose getter method signature from it's name or use custom getter provided
 *             during property declaration.
 *
 * @param property Reference on class instance property structure which should be used during getter method signature
 *                 generation.
 *
 * @return Reference on target property getter method signature.
 */
+ (NSString *)propertyGetterFromProperty:(objc_property_t)property;

/**
 * @brief      Compose \c property setter method signature if required.
 * @discussion Check property attributes and compose setter method signature from it's name or use custom setter provided
 *             during property declaration.
 *
 * @param property Reference on class instance property structure which should be used during setter method signature
 *                 generation.
 *
 * @return Reference on target property setter method signature or \c nil in case if \c property is read-only.
 */
+ (nullable NSString *)propertySetterFromProperty:(objc_property_t)property;

/**
 * @brief      Convert passed number object to primitive data type.
 * @discussion Target primitive data \c type used to make proper conversion.
 *
 * @param type   Reference on single char (provided by ObjC run-time and same as 'encode' output) which should be used to
 *               make proper conversion.
 * @param number Reference on \a NSNumber object which should be converted to target primitive data \c type.
 *
 * @return Number as one of pre-defined primitive data types or \c NULL in case if unknown data \c type has been requested.
 */
+ (void *)primitiveOfType:(char)type fromNumber:(NSNumber *)number;

/**
 * @brief      Convert primitive data type to \a NSNumber object.
 * @discussion Conversion flow depends from passed primitive data \c type.
 *
 * @param primitive Reference on address on which stored primitive value which should be converted to \a NSNumber instance.
 * @param type      Reference on single char (provided by ObjC run-time and same as 'encode' output) which should be used to
 *                  make proper conversion.
 *
 * @return Reference on \a NSNumber object created from primitive or \c nil in case if unknown data \c type conversion has
 *         been requested.
 */
+ (nullable NSNumber *)numberFromPrimitive:(void *)primitive ofType:(char)type;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation CEPPlugablePropertyStorage


#pragma mark - Initialization and Configuration

+ (void)initialize {
    
    if (self != [CEPPlugablePropertyStorage class]) {
        [self bindPropertiesIvarToStorage];
    }
}


#pragma mark - Storage

+ (NSMutableDictionary *)newStorageForProperties {
    
    return [@{ kCEBSWeakStorageKey: [NSMapTable strongToWeakObjectsMapTable] } mutableCopy];
}


#pragma mark - Properties bind

+ (NSArray<NSString *> *)nonbindableProperties {
    
    return nil;
}

+ (void)bindPropertiesIvarToStorage {
    
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(self, &propertiesCount);
    NSArray<NSString *> *nonbindableProperties = [self nonbindableProperties];
    
    for (unsigned int propertyIdx = 0; propertyIdx < propertiesCount; propertyIdx++) {
        objc_property_t property = properties[propertyIdx];
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        
        if ([nonbindableProperties containsObject:propertyName]) {
            continue;
        }
        
        char *weakAttr = property_copyAttributeValue(property, "W");
        char *copyAttr = property_copyAttributeValue(property, "C");
        BOOL storeCopy = copyAttr != nil;
        BOOL storeWeak = weakAttr != nil;
        
        [self bindProperty:property
       toStorageWithGetter:NSSelectorFromString([self propertyGetterFromProperty:property])
                    setter:NSSelectorFromString([self propertySetterFromProperty:property])
                 valueCopy:storeCopy
                    orWeak:storeWeak];
        
        free(copyAttr);
        free(weakAttr);
    }
    free(properties);
}

+ (void)bindProperty:(objc_property_t)property
    toStorageWithGetter:(SEL)getter
                 setter:(SEL)setter
              valueCopy:(BOOL)storeCopy
                 orWeak:(BOOL)storeWeak {
    
    [self bindProperty:property toStorageWithGetter:YES selector:getter valueCopy:storeCopy orWeak:storeWeak];
    
    if (setter) {
        [self bindProperty:property toStorageWithGetter:NO selector:setter valueCopy:storeCopy orWeak:storeWeak];
    }
}

+ (void)bindProperty:(objc_property_t)property
    toStorageWithGetter:(BOOL)getter
               selector:(SEL)selector
              valueCopy:(BOOL)storeCopy
                 orWeak:(BOOL)storeWeak {
    
    if (!property || !selector) {
        return;
    }
    
    NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    NSString *accessorName = [@[@"cebs", NSStringFromSelector(selector)] componentsJoinedByString:@"_"];
    const char *accessorTypeEncoding = method_getTypeEncoding(class_getInstanceMethod(self, selector));
    SEL accessorSwizzledSelector = NSSelectorFromString(accessorName);
    IMP implementation;
    
    if (getter) {
        implementation = [self getterImplementationForProperty:name withSelector:selector weak:storeWeak];
    } else {
        implementation = [self setterImplementationForProperty:name withSelector:selector valueCopy:storeCopy orWeak:storeWeak];
    }
    
    if (!class_addMethod(self, accessorSwizzledSelector, implementation, accessorTypeEncoding)) {
        return;
    }
    
    [self swizzleOriginalSelector:selector with:accessorSwizzledSelector];
}

+ (IMP)getterImplementationForProperty:(NSString *)property withSelector:(SEL)selector weak:(BOOL)storeWeak {
    
    char returnType[16];
    method_getReturnType(class_getInstanceMethod(self, selector), returnType, 16);
    char type = returnType[0];
    
    IMP getterImplementation;
    if (type == '@' || type == '#') {
        getterImplementation = imp_implementationWithBlock(^id(CEPPlugablePropertyStorage *_self) {
            id storage = storeWeak ? _self.storage[kCEBSWeakStorageKey] : _self.storage;
            
            return [storage objectForKey:property];
        });
    } else if (type == '*') {
        getterImplementation = imp_implementationWithBlock(^const char * (CEPPlugablePropertyStorage *_self) {
            return [(NSString *)_self.storage[property] cStringUsingEncoding:NSUTF8StringEncoding];
        });
    } else {
        getterImplementation = imp_implementationWithBlock(^void * (CEPPlugablePropertyStorage *_self) {
            return [[_self class] primitiveOfType:type fromNumber:_self.storage[property]];
        });
    }
    
    return getterImplementation;
}

+ (IMP)setterImplementationForProperty:(NSString *)property withSelector:(SEL)selector valueCopy:(BOOL)storeCopy orWeak:(BOOL)storeWeak {
    
    char argumentType[16];
    method_getArgumentType(class_getInstanceMethod(self, selector), 2, argumentType, 16);
    char type = argumentType[0];

    IMP setterImplementation;
    if (type == '@' || type == '#') {
        setterImplementation = imp_implementationWithBlock(^(CEPPlugablePropertyStorage *_self, id value) {
            id storage = storeWeak ? _self.storage[kCEBSWeakStorageKey] : _self.storage;
            
            if (value) {
                [storage setObject:(storeCopy ? [value copy] : value) forKey:property];
            } else {
                [storage removeObjectForKey:property];
            }
        });
    } else if (type == '*') {
        setterImplementation = imp_implementationWithBlock(^(CEPPlugablePropertyStorage *_self, char *value) {
            _self.storage[property] = [NSString stringWithCString:(value ?: "") encoding:NSUTF8StringEncoding];
        });
    } else if (type == 'f') {
        setterImplementation = imp_implementationWithBlock(^(CEPPlugablePropertyStorage *_self, float value) {
            _self.storage[property] = @(value);
        });
    } else if (type == 'd') {
        setterImplementation = imp_implementationWithBlock(^(CEPPlugablePropertyStorage *_self, double value) {
            _self.storage[property] = @(value);
        });
    } else {
        setterImplementation = imp_implementationWithBlock(^(CEPPlugablePropertyStorage *_self, void *value) {
            _self.storage[property] = [[_self class] numberFromPrimitive:value ofType:type];
        });
    }
    
    return setterImplementation;
}


#pragma mark - Accessor methods swizzling

+ (void)swizzleOriginalSelector:(SEL)selector with:(SEL)swizzledSelector {

    if (!selector || !swizzledSelector) {
        return;
    }
    
    Method method = class_getInstanceMethod(self, selector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    if (class_addMethod(self, selector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(self, swizzledSelector, method_getImplementation(method), method_getTypeEncoding(method));
    } else {
        method_exchangeImplementations(method, swizzledMethod);
    }
}


#pragma mark - Misc

+ (NSString *)propertyGetterFromProperty:(objc_property_t)property {
    
    NSString *getter = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    char *getterAttr = property_copyAttributeValue(property, "G");
    
    if (getterAttr) {
        getter = [NSString stringWithCString:getterAttr encoding:NSUTF8StringEncoding];
        free(getterAttr);
    }
    
    return getter;
}

+ (nullable NSString *)propertySetterFromProperty:(objc_property_t)property {
    
    char *readOnlyAttr = property_copyAttributeValue(property, "R");
    
    if (readOnlyAttr != nil) {
        free(readOnlyAttr);
        return nil;
    }
    
    NSString *name = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    name = [[name substringToIndex:1].capitalizedString stringByAppendingString:[name substringFromIndex:1]];
    NSString *setter = [@[@"set", name, @":"] componentsJoinedByString:@""];
    char *setterAttr = property_copyAttributeValue(property, "S");
    
    if (setterAttr) {
        setter = [NSString stringWithCString:setterAttr encoding:NSUTF8StringEncoding];
        free(setterAttr);
    }
    
    return setter;
}

+ (void *)primitiveOfType:(char)type fromNumber:(NSNumber *)number {
    
    if (!type || !number) {
        return NULL;
    }
    
    switch (type) {
        case 'c':
        case 'B':
            return (void *)(size_t)number.boolValue;
            break;
        case 'i':
            return (void *)(size_t)number.intValue;
            break;
        case 's':
            return (void *)(size_t)number.shortValue;
            break;
        case 'l':
            return (void *)(size_t)number.longValue;
            break;
        case 'q':
            return (void *)(size_t)number.longLongValue;
            break;
        case 'C':
            return (void *)(size_t)number.unsignedCharValue;
            break;
        case 'I':
            return (void *)(size_t)number.unsignedIntValue;
            break;
        case 'S':
            return (void *)(size_t)number.unsignedShortValue;
            break;
        case 'L':
            return (void *)(size_t)number.unsignedLongValue;
            break;
        case 'Q':
            return (void *)(size_t)number.unsignedLongLongValue;
            break;
        case 'f':
            return (void *)(size_t)number.floatValue;
            break;
        case 'd':
            return (void *)(size_t)number.doubleValue;
            break;
    }
    
    return NULL;
}

+ (NSNumber *)numberFromPrimitive:(void *)primitive ofType:(char)type {

    if (!type || primitive == NULL) {
        return nil;
    }
    
    switch (type) {
        case 'c':
        case 'B':
            return @((BOOL)primitive);
            break;
        case 'i':
            return @((int)primitive);
            break;
        case 's':
            return @((short)primitive);
            break;
        case 'l':
            return @((long)primitive);
            break;
        case 'q':
            return @((long long)primitive);
            break;
        case 'C':
            return @((unsigned char)primitive);
            break;
        case 'I':
            return @((unsigned int)primitive);
            break;
        case 'S':
            return @((unsigned short)primitive);
            break;
        case 'L':
            return @((unsigned long)primitive);
            break;
        case 'Q':
            return @((unsigned long long)primitive);
            break;
    }
    
    return nil;
}

#pragma mark -


@end
