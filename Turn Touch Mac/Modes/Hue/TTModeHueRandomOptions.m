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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self drawControls];
}

- (void)drawControls {
    TTHueRandomColors randomColors = (TTHueRandomColors)[[self.action optionValue:kRandomColors
                                                                      inDirection:self.appDelegate.modeMap.inspectingModeDirection]
                                                         integerValue];
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)[[self.action optionValue:kRandomBrightness
                                                                                  inDirection:self.appDelegate.modeMap.inspectingModeDirection]
                                                                     integerValue];
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)[[self.action optionValue:kRandomSaturation
                                                                                  inDirection:self.appDelegate.modeMap.inspectingModeDirection]
                                                                     integerValue];
    
    [self.segRandomColors setSelectedSegment:randomColors ? randomColors : 2];
    [self.segRandomBrightness setSelectedSegment:randomBrightness ? randomBrightness : 2];
    [self.segRandomSaturation setSelectedSegment:randomSaturation ? randomSaturation : 2];
    
    TTHueRandomColors doubleTapRandomColors = (TTHueRandomColors)[[self.action optionValue:kDoubleTapRandomColors
                                                                               inDirection:self.appDelegate.modeMap.inspectingModeDirection]
                                                                  integerValue];
    TTHueRandomBrightness doubleTapRandomBrightness = (TTHueRandomBrightness)[[self.action optionValue:kDoubleTapRandomBrightness
                                                                                           inDirection:self.appDelegate.modeMap.inspectingModeDirection]
                                                                              integerValue];
    TTHueRandomSaturation doubleTapRandomSaturation = (TTHueRandomSaturation)[[self.action optionValue:kDoubleTapRandomSaturation
                                                                                           inDirection:self.appDelegate.modeMap.inspectingModeDirection]
                                                                              integerValue];
    
    [self.doubleTapSegRandomColors setSelectedSegment:doubleTapRandomColors ? doubleTapRandomColors : 0];
    [self.doubleTapSegRandomBrightness setSelectedSegment:doubleTapRandomBrightness ? doubleTapRandomBrightness : 1];
    [self.doubleTapSegRandomSaturation setSelectedSegment:doubleTapRandomSaturation ? doubleTapRandomSaturation : 1];
}

#pragma mark - Actions

- (IBAction)changeRandomColors:(id)sender {
    TTHueRandomColors randomColors = (TTHueRandomColors)self.segRandomColors.selectedSegment;
    [self.action changeActionOption:kRandomColors to:[NSNumber numberWithInteger:randomColors]];
    
    TTHueRandomColors doubleTapRandomColors = (TTHueRandomColors)self.doubleTapSegRandomColors.selectedSegment;
    [self.action changeActionOption:kDoubleTapRandomColors to:[NSNumber numberWithInteger:doubleTapRandomColors]];
}

- (IBAction)changeRandomBrightness:(id)sender {
    TTHueRandomBrightness randomBrightness = (TTHueRandomBrightness)self.segRandomBrightness.selectedSegment;
    [self.action changeActionOption:kRandomBrightness to:[NSNumber numberWithInteger:randomBrightness]];
    
    TTHueRandomBrightness doubleTapRandomBrightness = (TTHueRandomBrightness)self.doubleTapSegRandomBrightness.selectedSegment;
    [self.action changeActionOption:kDoubleTapRandomBrightness to:[NSNumber numberWithInteger:doubleTapRandomBrightness]];
}

- (IBAction)changeRandomSaturation:(id)sender {
    TTHueRandomSaturation randomSaturation = (TTHueRandomSaturation)self.segRandomSaturation.selectedSegment;
    [self.action changeActionOption:kRandomSaturation to:[NSNumber numberWithInteger:randomSaturation]];
    
    TTHueRandomSaturation doubleTapRandomSaturation = (TTHueRandomSaturation)self.doubleTapSegRandomSaturation.selectedSegment;
    [self.action changeActionOption:kDoubleTapRandomSaturation to:[NSNumber numberWithInteger:doubleTapRandomSaturation]];
}

@end
