//
//  TTModeTVVolumeJumpOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/19/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeTVVolumeJumpOptions.h"
#import "TTModeTV.h"

@interface TTModeTVVolumeJumpOptions ()

@end

@implementation TTModeTVVolumeJumpOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger volumeJump = [[self.action optionValue:kTVVolumeJump inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];

    [self.volumeSlider setIntegerValue:volumeJump];
    [self updateVolumeJumpLabel];
}

- (void)updateVolumeJumpLabel {
    NSInteger volumeJump = [[self.action optionValue:kTVVolumeJump inDirection:self.appDelegate.modeMap.inspectingModeDirection] integerValue];
    
    [self.percentageLabel setStringValue:[NSString stringWithFormat:@"%ld%%", (long)volumeJump]];
}

- (IBAction)slideVolume:(id)sender {
    [self.action changeActionOption:kTVVolumeJump to:[NSNumber numberWithInteger:self.volumeSlider.integerValue]];
    
    [self updateVolumeJumpLabel];
}

@end
