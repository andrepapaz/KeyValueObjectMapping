//
//  DCKeyValueObjectMapping.m
//  DCKeyValueObjectMapping
//
//  Created by Diego Chohfi on 4/13/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "DCKeyValueObjectMapping.h"
#import "DCGenericConverter.h"
#import "DCDynamicAttribute.h"
#import "DCReferenceKeyParser.h"
#import "DCPropertyFinder.h"
#import "DCAttributeSetter.h"
#import "DCDictionaryRearranger.h"

@interface DCKeyValueObjectMapping()

@property(nonatomic, strong) DCGenericConverter *converter;
@property(nonatomic, strong) DCPropertyFinder *propertyFinder;
@property(nonatomic, strong) DCParserConfiguration *configuration;

@end

@implementation DCKeyValueObjectMapping
@synthesize converter, propertyFinder, configuration, classToGenerate;

+ (DCKeyValueObjectMapping *) mapperForClass: (Class) classToGenerate {
    return [self mapperForClass:classToGenerate andConfiguration:[DCParserConfiguration configuration]];
}
+ (DCKeyValueObjectMapping *) mapperForClass: (Class) classToGenerate andConfiguration: (DCParserConfiguration *) configuration {
    return [[self alloc] initWithClass: classToGenerate forConfiguration: configuration];
}

- (id) initWithClass: (Class) _classToGenerate forConfiguration: (DCParserConfiguration *) _configuration {
    self = [super init];
    if (self) {
        configuration = _configuration;
        DCReferenceKeyParser *keyParser = [DCReferenceKeyParser parserForToken: configuration.splitToken];
        
        propertyFinder = [DCPropertyFinder finderWithKeyParser:keyParser];
        [propertyFinder setMappers:[configuration objectMappers]];
        
        converter = [[DCGenericConverter alloc] initWithConfiguration:configuration];
        classToGenerate = _classToGenerate;
    }
    return self;   
}

- (NSArray *) parseArray: (NSArray *) array {
    if(!array){
        return nil;
    }
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (NSDictionary *dictionary in array) {
        id value = [self parseDictionary:dictionary];
        [values addObject:value];
    }
    return [NSArray arrayWithArray:values];
}
- (id) parseDictionary: (NSDictionary *) dictionary {
    if(!dictionary || !classToGenerate){
        return nil;
    }
    NSObject *object = [[classToGenerate alloc] init];
    
    dictionary = [DCDictionaryRearranger rearrangeDictionary:dictionary forAggregators:configuration.aggregators];
    
    NSArray *keys = [dictionary allKeys];
    for (NSString *key in keys) {
        id value = [dictionary valueForKey:key];
        DCDynamicAttribute *dynamicAttribute = [propertyFinder findAttributeForKey:key onClass:classToGenerate];
        if(dynamicAttribute){
            [self parseValue:value forObject:object inAttribute:dynamicAttribute];
        }
    }
    return object;
}
- (void) parseValue: (id) value forObject: (id) object inAttribute: (DCDynamicAttribute *) dynamicAttribute {
    DCObjectMapping *objectMapping = dynamicAttribute.objectMapping;
    
    NSString *attributeName = objectMapping.attributeName;
    value = [converter transformValue:value forDynamicAttribute:dynamicAttribute];
    [DCAttributeSetter assingValue:value forAttributeName:attributeName andAttributeClass:objectMapping.classReference onObject:object];
}
@end
