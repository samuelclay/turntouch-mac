//
//  TTAttributedString+Extra.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/12/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "NSAttributedString+Extra.h"

@implementation NSAttributedString (Extra)

- (NSAttributedString *)upperCaseAttributedStringFromAttributedString:(NSAttributedString *)inAttrString {
    // Make a mutable copy of your input string
    NSMutableAttributedString *attrString = [inAttrString mutableCopy];
    
    // Make an array to save the attributes in
    NSMutableArray *attributes = [NSMutableArray array];
    
    // Add each set of attributes to the array in a dictionary containing the attributes and range
    [attrString enumerateAttributesInRange:NSMakeRange(0, [attrString length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        [attributes addObject:@{@"attrs":attrs, @"range":[NSValue valueWithRange:range]}];
    }];
    
    // Make a plain uppercase string
    NSString *string = [[attrString string]uppercaseString];
    
    // Replace the characters with the uppercase ones
    [attrString replaceCharactersInRange:NSMakeRange(0, [attrString length]) withString:string];
    
    // Reapply each attribute
    for (NSDictionary *attribute in attributes) {
        [attrString setAttributes:attribute[@"attrs"] range:[attribute[@"range"] rangeValue]];
    }
    
    return attrString;
}

@end
