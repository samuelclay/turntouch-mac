//
//  TTHUDViewController.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeHUDWindowController.h"

@implementation TTModeHUDWindowController

@synthesize hudView;
@synthesize hudWindow;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [hudWindow setFrame:[self hiddenFrame] display:YES];
    }
    
    return self;
}

#pragma mark - Window management

- (NSRect)visibleFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, 0, CGRectGetWidth(mainScreen.frame), CGRectGetHeight(mainScreen.frame));
}

- (NSRect)hiddenFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, 0, CGRectGetWidth(mainScreen.frame), CGRectGetHeight(mainScreen.frame));
}

- (IBAction)fadeIn:(id)sender
{
    [hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:appDelegate];

    if (hudWindow.frame.origin.y == [self hiddenFrame].origin.y) {
        [hudWindow setFrame:[self visibleFrame] display:YES];
        [[hudWindow animator] setAlphaValue:0.f];
    }
    
    [hudView setupTitleAttributes];
    [hudView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [[hudWindow animator] setAlphaValue:1.f];
    [[hudWindow animator] setFrame:[self visibleFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut:(id)sender
{
    //    __block __unsafe_unretained NSWindow *window = hudWindow;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.55f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [hudWindow orderOut:nil];
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[hudWindow animator] setAlphaValue:0.f];
    [[hudWindow animator] setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}


@end
