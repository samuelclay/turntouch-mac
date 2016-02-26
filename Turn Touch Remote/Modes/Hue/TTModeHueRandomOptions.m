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
    
    TTHueRandomColors randomColors = (TTHueRandomColors)[[self.action optionValue:kRandomColors
                                                                      inDirection:appDelegate.modeMap.inspectingModeDirection]
                                                         integerValue];
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)[[self.action optionValue:kRandomBrightness
                                                                                  inDirection:appDelegate.modeMap.inspectingModeDirection]
                                                                     integerValue];
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)[[self.action optionValue:kRandomSaturation
                                                                                  inDirection:appDelegate.modeMap.inspectingModeDirection]
                                                                     integerValue];

    [segRandomColors setSelectedSegment:randomColors ? randomColors-1 : 2];
    [segRandomBrightness setSelectedSegment:randomBrightness ? randomBrightness-1 : 2];
    [segRandomSaturation setSelectedSegment:randomSaturation ? randomSaturation-1 : 2];

    TTHueRandomColors doubleTapRandomColors = (TTHueRandomColors)[[self.action optionValue:kDoubleTapRandomColors
                                                                               inDirection:appDelegate.modeMap.inspectingModeDirection]
                                                                  integerValue];
    TTHueRandomBrightness doubleTapRandomBrightness = (TTHueRandomBrightness)[[self.action optionValue:kDoubleTapRandomBrightness
                                                                                           inDirection:appDelegate.modeMap.inspectingModeDirection]
                                                                              integerValue];
    TTHueRandomSaturation doubleTapRandomSaturation = (TTHueRandomSaturation)[[self.action optionValue:kDoubleTapRandomSaturation
                                                                                           inDirection:appDelegate.modeMap.inspectingModeDirection]
                                                                              integerValue];
    
    [doubleTapSegRandomColors setSelectedSegment:doubleTapRandomColors ? doubleTapRandomColors-1 : 0];
    [doubleTapSegRandomBrightness setSelectedSegment:doubleTapRandomBrightness ? doubleTapRandomBrightness-1 : 1];
    [doubleTapSegRandomSaturation setSelectedSegment:doubleTapRandomSaturation ? doubleTapRandomSaturation-1 : 1];
}

- (IBAction)changeRandomColors:(id)sender {
    TTHueRandomColors randomColors = (TTHueRandomColors)segRandomColors.selectedSegment+1;
    [self.action changeActionOption:kRandomColors to:[NSNumber numberWithInteger:randomColors]];

    TTHueRandomColors doubleTapRandomColors = (TTHueRandomColors)doubleTapSegRandomColors.selectedSegment+1;
    [self.action changeActionOption:kDoubleTapRandomColors to:[NSNumber numberWithInteger:doubleTapRandomColors]];
}

- (IBAction)changeRandomBrightness:(id)sender {
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)segRandomBrightness.selectedSegment+1;
    [self.action changeActionOption:kRandomBrightness to:[NSNumber numberWithInteger:randomBrightness]];

    TTHueRandomBrightness doubleTapRandomBrightness = (TTHueRandomBrightness)doubleTapSegRandomBrightness.selectedSegment+1;
    [self.action changeActionOption:kDoubleTapRandomBrightness to:[NSNumber numberWithInteger:doubleTapRandomBrightness]];
}

- (IBAction)changeRandomSaturation:(id)sender {
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)segRandomSaturation.selectedSegment+1;
    [self.action changeActionOption:kRandomSaturation to:[NSNumber numberWithInteger:randomSaturation]];

    TTHueRandomSaturation doubleTapRandomSaturation = (TTHueRandomSaturation)doubleTapSegRandomSaturation.selectedSegment+1;
    [self.action changeActionOption:kDoubleTapRandomSaturation to:[NSNumber numberWithInteger:doubleTapRandomSaturation]];
}

@end
