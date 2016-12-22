//
//  TTModeSpotifyVolumeJumpOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/19/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeSpotifyVolumeJumpOptions.h"
#import "TTModeSpotify.h"

@interface TTModeSpotifyVolumeJumpOptions ()

@end

@implementation TTModeSpotifyVolumeJumpOptions

@synthesize volumeSlider;
@synthesize percentageLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger volumeJump = [[self.action optionValue:kSpotifyVolumeJump inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    // Run in TTModeSpotify:
    // NSInteger volumeJump = [[NSAppDelegate.modeMap actionOptionValue:kSpotifyVolumeJump inDirection:direction] integerValue];

    [volumeSlider setIntegerValue:volumeJump];
    [self updateVolumeJumpLabel];
}

- (void)updateVolumeJumpLabel {
    NSInteger volumeJump = [[self.action optionValue:kSpotifyVolumeJump inDirection:appDelegate.modeMap.inspectingModeDirection] integerValue];
    
    [percentageLabel setStringValue:[NSString stringWithFormat:@"%ld%%", (long)volumeJump]];
}

- (IBAction)slideVolume:(id)sender {
    [self.action changeActionOption:kSpotifyVolumeJump to:[NSNumber numberWithInteger:volumeSlider.integerValue]];
    
    [self updateVolumeJumpLabel];
}

@end
