//
//  TTModeCustomScript.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 1/9/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTModeCustomScriptOptions.h"
#import "TTModeCustom.h"

@interface TTModeCustomScriptOptions ()

@end

@implementation TTModeCustomScriptOptions

@synthesize scriptText;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    scriptText.delegate = self;
    scriptText.automaticQuoteSubstitutionEnabled = NO;
    scriptText.enabledTextCheckingTypes = 0;
    
    NSString *script = [self.action optionValue:kCustomScriptText];
    if (script) {
        scriptText.string = script;
    }
}

-(void)textDidChange:(NSNotification *)notification {
    [self.action changeActionOption:kCustomScriptText to:scriptText.string];
}
- (void)controlTextDidChange:(NSNotification *)obj {
    [self.action changeActionOption:kCustomScriptText to:scriptText.string];
}

@end
