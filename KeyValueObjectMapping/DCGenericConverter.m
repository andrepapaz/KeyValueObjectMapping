//
//  DCGenericConverter.m
//  DCKeyValueObjectMapping
//
//  Created by Diego Chohfi on 4/13/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "DCGenericConverter.h"
#import "DCNSDateConverter.h"
#import "DCNSURLConverter.h"
#import "DCSimpleConverter.h"
#import "DCNSArrayConverter.h"
#import "DCKeyValueObjectMapping.h"

@interface DCGenericConverter()
@property(nonatomic, strong) DCParserConfiguration *configuration;
@property(nonatomic, strong) NSArray *parsers;
@end

@implementation DCGenericConverter
@synthesize configuration, parsers;

- (id)initWithConfiguration:(DCParserConfiguration *) _configuration
{
    self = [super init];
    if (self) {
        configuration = _configuration;
        parsers = [NSArray arrayWithObjects:
                   [DCNSDateConverter dateConverterForPattern:configuration.datePattern],
                   [DCNSURLConverter urlConverter],
                   [DCNSArrayConverter arrayConverterForConfiguration: configuration], nil];
    }
    return self;
}

- (id)transformValue:(id)value forDynamicAttribute: (DCDynamicAttribute *) attribute {
    if([attribute isValidObject]){
        BOOL valueIsKindOfDictionary = [value isKindOfClass:[NSDictionary class]];
        BOOL attributeNotKindOfDictionary = ![attribute.objectMapping.classReference isSubclassOfClass:[NSDictionary class]];
        if( valueIsKindOfDictionary && attributeNotKindOfDictionary){
            DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:attribute.objectMapping.classReference andConfiguration:self.configuration];
            value = [parser parseDictionary:(NSDictionary *) value];
        }else {        
            for(id<DCValueConverter> parser in parsers){
                if([parser canTransformValueForClass:attribute.objectMapping.classReference]){
                    return [parser transformValue:value forDynamicAttribute:attribute];
                }
            }
        }
    }
    DCSimpleConverter *simpleParser = [[DCSimpleConverter alloc] init];
    return [simpleParser transformValue:value forDynamicAttribute:attribute];
}

@end