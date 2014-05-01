//
//  TTPanel.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTPanel.h"
#import "TTAppDelegate.h"
#import "TTPanelController.h"

@implementation TTPanel

@synthesize backgroundView;

- (BOOL)canBecomeKeyWindow {
    return YES;
}

- (void)awakeFromNib {
}

@end
