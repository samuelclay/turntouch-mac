//
//  TTModeHueSceneRandom.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/15/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHueSceneRandomOptions.h"
#import "TTModeHue.h"

@interface TTModeHueSceneRandomOptions ()

@end

@implementation TTModeHueSceneRandomOptions

@synthesize segRandomBrightness;
@synthesize segRandomColors;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTHueRandomColors randomColors = (TTHueRandomColors)[[NSAppDelegate.modeMap actionOptionValue:kRandomColors] integerValue];
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)[[NSAppDelegate.modeMap actionOptionValue:kRandomBrightness] integerValue];

    [segRandomColors setSelectedSegment:randomColors ? randomColors-1 : 2];
    [segRandomBrightness setSelectedSegment:randomBrightness ? randomBrightness-1 : 0];
}

- (IBAction)changeRandomColors:(id)sender {
    TTHueRandomColors randomColors = (TTHueRandomColors)segRandomColors.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomColors to:[NSNumber numberWithInteger:randomColors]];
}

- (IBAction)changeRandomBrightness:(id)sender {
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)segRandomBrightness.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomBrightness to:[NSNumber numberWithInteger:randomBrightness]];
}

@end
