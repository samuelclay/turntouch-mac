//
//  TTModeNestSetTemperatureOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/19/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestSetTempOptions.h"
#import "TTModeNest.h"
#import "NestThermostatManager.h"

@interface TTModeNestSetTempOptions ()

@end

@implementation TTModeNestSetTempOptions

@synthesize thermostatPopup;
@synthesize labelTemp;
@synthesize sliderTemp;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSInteger temperature = [[self.action optionValue:kNestSetTemperature
                                          inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    
    [sliderTemp setIntegerValue:temperature];
    [self updateTempLabel];
    
    [self selectThermostat];
}

- (void)updateTempLabel {
    NSInteger temperature = [[self.action optionValue:kNestSetTemperature
                                          inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    
    TTModeNest *nestMode = (TTModeNest *)self.action.mode;
    Thermostat *thermostat = [nestMode selectedThermostat];
    [labelTemp setStringValue:[NSString stringWithFormat:@"%ld°%@",
                               temperature, [thermostat temperatureScale]]];
}

- (IBAction)changeTempSlider:(id)sender {
    [self.action changeActionOption:kNestSetTemperature
                                 to:[NSNumber numberWithInteger:sliderTemp.integerValue]];
    [self updateTempLabel];
}

- (void)selectThermostat {
    NSString *thermostatSelectedIdentifier = [appDelegate.modeMap mode:self.mode
                                                     actionOptionValue:kNestThermostat
                                                           inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *thermostatSelected;
    NSMutableArray *thermostats = [NSMutableArray array];
    [thermostatPopup removeAllItems];
    TTModeNest *modeNest = (TTModeNest *)self.mode;
    for (Thermostat *thermostat in [modeNest.currentStructure objectForKey:@"thermostats"]) {
        [thermostats addObject:@{@"name": thermostat.nameLong, @"identifier": thermostat.thermostatId}];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [thermostats sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *thermostatData in thermostats) {
        [thermostatPopup addItemWithTitle:thermostatData[@"name"]];
        if ([thermostatData[@"identifier"] isEqualToString:thermostatSelectedIdentifier]) {
            thermostatSelected = thermostatData[@"name"];
        }
    }
    if (thermostatSelected) {
        [thermostatPopup selectItemWithTitle:thermostatSelected];
    }
}

- (void)didChangeThermostat:(id)sender {
    
}

@end
