//
//  TTModeCustomKeyboardOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/1/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTModeCustomKeyboardOptions.h"
#import "TTModeCustom.h"

@interface TTModeCustomKeyboardOptions ()

@end

@implementation TTModeCustomKeyboardOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self loadKeys];
}

- (void)loadKeys {
    NSString *singleKeyPref = [self.action optionValue:kCustomSingleKey];
    NSString *doubleKeyPref = [self.action optionValue:kCustomDoubleKey];
    
    [self.singleKey setStringValue:singleKeyPref];
    [self.doubleKey setStringValue:doubleKeyPref];
}

- (void)changeKey:(id)sender {
    if (self.singleKey.stringValue.length > 0) {
        [self.action changeActionOption:kCustomSingleKey to:[self.singleKey.stringValue substringToIndex:1]];
    }
    if (self.doubleKey.stringValue.length > 0) {
        [self.action changeActionOption:kCustomDoubleKey to:[self.doubleKey.stringValue substringToIndex:1]];
    }
    
    if (self.singleKey.stringValue.length > 0 && self.doubleKey.stringValue.length > 0) {
        [self loadKeys];
    }
}

-(void)keyUp:(NSEvent *)event {
    [super keyUp:event];
    
    [self changeKey:nil];
}

@end
