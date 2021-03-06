//
//  DCNSDateConverter.m
//  DCKeyValueObjectMapping
//
//  Created by Diego Chohfi on 4/13/12.
//  Copyright (c) 2012 None. All rights reserved.
//

#import "DCNSDateConverter.h"
@interface DCNSDateConverter()
@property(nonatomic, strong) NSString *pattern;
- (BOOL) validDouble: (NSString *) doubleValue;
@end

@implementation DCNSDateConverter
@synthesize pattern;


+ (DCNSDateConverter *) dateConverterForPattern: (NSString *) pattern{
    return [[self alloc] initWithDatePattern: pattern];
}

- (id) initWithDatePattern: (NSString *) _pattern {
    self = [super init];
    if (self) {
        pattern = _pattern;
    }
    return self;
}
- (id)transformValue:(id)value forDynamicAttribute:(DCDynamicAttribute *)attribute {
    BOOL validDouble = [self validDouble:[NSString stringWithFormat:@"%@", value]];
    if(validDouble){
        return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
    }else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = pattern;
        return [formatter dateFromString:value];
    }
}
- (BOOL) canTransformValueForClass: (Class) class {
    return [class isSubclassOfClass:[NSDate class]];
}
- (BOOL) validDouble: (NSString *) doubleValue {
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:doubleValue];
    
    return [alphaNums isSupersetOfSet:inStringSet];
}
@end
