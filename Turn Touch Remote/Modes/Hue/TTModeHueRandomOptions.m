//
//  TTModeHueRandom.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/15/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHueRandomOptions.h"
#import "TTModeHue.h"

@interface TTModeHueRandomOptions ()

@end

@implementation TTModeHueRandomOptions

@synthesize segRandomBrightness;
@synthesize segRandomColors;
@synthesize segRandomSaturation;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTHueRandomColors randomColors = (TTHueRandomColors)[[NSAppDelegate.modeMap actionOptionValue:kRandomColors] integerValue];
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)[[NSAppDelegate.modeMap actionOptionValue:kRandomBrightness] integerValue];
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)[[NSAppDelegate.modeMap actionOptionValue:kRandomSaturation] integerValue];

    [segRandomColors setSelectedSegment:randomColors ? randomColors-1 : 2];
    [segRandomBrightness setSelectedSegment:randomBrightness ? randomBrightness-1 : 0];
    [segRandomSaturation setSelectedSegment:randomSaturation ? randomSaturation-1 : 0];
}

- (IBAction)changeRandomColors:(id)sender {
    TTHueRandomColors randomColors = (TTHueRandomColors)segRandomColors.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomColors to:[NSNumber numberWithInteger:randomColors]];
}

- (IBAction)changeRandomBrightness:(id)sender {
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)segRandomBrightness.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomBrightness to:[NSNumber numberWithInteger:randomBrightness]];
}

- (IBAction)changeRandomSaturation:(id)sender {
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)segRandomSaturation.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomSaturation to:[NSNumber numberWithInteger:randomSaturation]];
}

@end
