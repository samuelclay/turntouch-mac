//
//  TTModeAirfoilVolumeJumpOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/19/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeAirfoilVolumeJumpOptions.h"
#import "TTModeAirfoil.h"

@interface TTModeAirfoilVolumeJumpOptions ()

@end

@implementation TTModeAirfoilVolumeJumpOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger volumeJump = [[self.action optionValue:kAirfoilVolumeJump inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];

    [self.volumeSlider setIntegerValue:volumeJump];
    [self updateVolumeJumpLabel];
}

- (void)updateVolumeJumpLabel {
    NSInteger volumeJump = [[self.action optionValue:kAirfoilVolumeJump inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    
    [self.percentageLabel setStringValue:[NSString stringWithFormat:@"%ld%%", (long)volumeJump]];
}

- (IBAction)slideVolume:(id)sender {
    [self.action changeActionOption:kAirfoilVolumeJump to:[NSNumber numberWithInteger:self.volumeSlider.integerValue]];
    
    [self updateVolumeJumpLabel];
}

@end
