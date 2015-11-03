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
@synthesize doubleTapSegRandomBrightness;
@synthesize doubleTapSegRandomColors;
@synthesize doubleTapSegRandomSaturation;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TTHueRandomColors randomColors = (TTHueRandomColors)[[NSAppDelegate.modeMap actionOptionValue:kRandomColors] integerValue];
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)[[NSAppDelegate.modeMap actionOptionValue:kRandomBrightness] integerValue];
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)[[NSAppDelegate.modeMap actionOptionValue:kRandomSaturation] integerValue];

    [segRandomColors setSelectedSegment:randomColors ? randomColors-1 : 2];
    [segRandomBrightness setSelectedSegment:randomBrightness ? randomBrightness-1 : 2];
    [segRandomSaturation setSelectedSegment:randomSaturation ? randomSaturation-1 : 2];

    TTHueRandomColors doubleTapRandomColors = (TTHueRandomColors)[[NSAppDelegate.modeMap actionOptionValue:kDoubleTapRandomColors] integerValue];
    TTHueRandomBrightness doubleTapRandomBrightness = (TTHueRandomBrightness)[[NSAppDelegate.modeMap actionOptionValue:kDoubleTapRandomBrightness] integerValue];
    TTHueRandomSaturation doubleTapRandomSaturation = (TTHueRandomSaturation)[[NSAppDelegate.modeMap actionOptionValue:kDoubleTapRandomSaturation] integerValue];
    
    [doubleTapSegRandomColors setSelectedSegment:doubleTapRandomColors ? doubleTapRandomColors-1 : 0];
    [doubleTapSegRandomBrightness setSelectedSegment:doubleTapRandomBrightness ? doubleTapRandomBrightness-1 : 1];
    [doubleTapSegRandomSaturation setSelectedSegment:doubleTapRandomSaturation ? doubleTapRandomSaturation-1 : 1];
}

- (IBAction)changeRandomColors:(id)sender {
    TTHueRandomColors randomColors = (TTHueRandomColors)segRandomColors.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomColors to:[NSNumber numberWithInteger:randomColors]];

    TTHueRandomColors doubleTapRandomColors = (TTHueRandomColors)doubleTapSegRandomColors.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kDoubleTapRandomColors to:[NSNumber numberWithInteger:doubleTapRandomColors]];
}

- (IBAction)changeRandomBrightness:(id)sender {
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)segRandomBrightness.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomBrightness to:[NSNumber numberWithInteger:randomBrightness]];

    TTHueRandomBrightness doubleTapRandomBrightness = (TTHueRandomBrightness)doubleTapSegRandomBrightness.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kDoubleTapRandomBrightness to:[NSNumber numberWithInteger:doubleTapRandomBrightness]];
}

- (IBAction)changeRandomSaturation:(id)sender {
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)segRandomSaturation.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kRandomSaturation to:[NSNumber numberWithInteger:randomSaturation]];

    TTHueRandomSaturation doubleTapRandomSaturation = (TTHueRandomSaturation)doubleTapSegRandomSaturation.selectedSegment+1;
    [NSAppDelegate.modeMap changeActionOption:kDoubleTapRandomSaturation to:[NSNumber numberWithInteger:doubleTapSegRandomSaturation]];
}

@end
