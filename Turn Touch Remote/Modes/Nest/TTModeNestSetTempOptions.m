//
//  TTModeNestSetTemperatureOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestSetTempOptions.h"
#import "TTModeNest.h"
@interface TTModeNestSetTempOptions ()

@end

@implementation TTModeNestSetTempOptions

@synthesize labelTemp;
@synthesize sliderTemp;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSInteger temperature = [[self.action optionValue:kNestSetTemperature
                                          inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    
    [sliderTemp setIntegerValue:temperature];
    [self updateTempLabel];
}

- (void)updateTempLabel {
    NSInteger temperature = [[self.action optionValue:kNestSetTemperature
                                          inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    
    TTModeNest *nestMode = (TTModeNest *)self.mode;
    Thermostat *thermostat = [nestMode selectedThermostat];
    [labelTemp setStringValue:[NSString stringWithFormat:@"%ld°%@",
                               temperature, [thermostat temperatureScale]]];
}

- (IBAction)changeTempSlider:(id)sender {
    [self.action changeActionOption:kNestSetTemperature
                                 to:[NSNumber numberWithInteger:sliderTemp.integerValue]];
    [self updateTempLabel];
}

@end
