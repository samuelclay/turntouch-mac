//
//  TTModeMusicVolumeJumpOptions.m
//  Turn Touch App
//
//  Created by Samuel Clay on 2/19/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeMusicVolumeJumpOptions.h"
#import "TTModeMusic.h"

@interface TTModeMusicVolumeJumpOptions ()

@end

@implementation TTModeMusicVolumeJumpOptions

@synthesize volumeSlider;
@synthesize percentageLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSInteger volumeJump = [[NSAppDelegate.modeMap actionOptionValue:kMusicVolumeJump] integerValue];
    [volumeSlider setIntegerValue:volumeJump];
    [self updateVolumeJumpLabel];
}



- (void)updateVolumeJumpLabel {
    NSInteger volumeJump = [[NSAppDelegate.modeMap actionOptionValue:kMusicVolumeJump] integerValue];
    
    [percentageLabel setStringValue:[NSString stringWithFormat:@"%ld%%", (long)volumeJump]];
}

- (IBAction)slideVolume:(id)sender {
    [NSAppDelegate.modeMap changeActionOption:kMusicVolumeJump to:[NSNumber numberWithInteger:volumeSlider.integerValue]];
    
    [self updateVolumeJumpLabel];
}

@end
