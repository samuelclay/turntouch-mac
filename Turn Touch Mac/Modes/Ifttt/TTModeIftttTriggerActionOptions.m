//
//  TTModeIftttTriggerActionOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIftttTriggerActionOptions.h"

@interface TTModeIftttTriggerActionOptions ()

@end

@implementation TTModeIftttTriggerActionOptions

@synthesize modeIfttt;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    modeIfttt = (TTModeIfttt *)self.action.mode;
}

- (IBAction)openRecipe:(id)sender {
    [modeIfttt registerTriggers:^{
        [self.modeIfttt openRecipe:self.action.direction];
    }];
}

@end
