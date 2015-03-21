//
//  TTHUDViewController.m
//  Turn Touch Remote
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
    
    return NSMakeRect(0, 0, NSWidth(mainScreen.frame), NSHeight(mainScreen.frame));
}

- (NSRect)hiddenFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, 0, NSWidth(mainScreen.frame), NSHeight(mainScreen.frame));
}

- (void)fadeIn:(BOOL)animate {
    [hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:appDelegate];
    [hudView setupTitleAttributes];
    hudView.isTeaser = NO;
    [hudView setNeedsDisplay:YES];

    if (hudWindow.frame.origin.y != [self visibleFrame].origin.y) {
        [hudWindow setFrame:[self visibleFrame] display:YES];
    }
    if (!animate) {
        [[hudView gradientView] setAlphaValue:1.f];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [[hudWindow animator] setAlphaValue:1.f];
    [[hudWindow animator] setFrame:[self visibleFrame] display:YES];
    if (animate) {
        [[[hudView gradientView] animator] setAlphaValue:1.f];
    }
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut:(id)sender {
    //    __block __unsafe_unretained NSWindow *window = hudWindow;
    if (isFading) return;
    isFading = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.55f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
//        [hudWindow orderOut:nil];
        isFading = NO;
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[hudWindow animator] setAlphaValue:0.f];
    [[hudWindow animator] setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (void)teaseMode:(TTModeDirection)direction {
    hudView.isTeaser = YES;
    [hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:appDelegate];
    [hudView setupTitleAttributes:[appDelegate.modeMap modeInDirection:direction]];
    [hudView setNeedsDisplay:YES];
    [[hudView gradientView] setAlphaValue:0.f];
    [[hudView teaserGradientView] setAlphaValue:1.f];

    if (hudWindow.frame.origin.y == [self hiddenFrame].origin.y) {
        [hudWindow setFrame:[self visibleFrame] display:YES];
        [[hudWindow animator] setAlphaValue:0.f];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.4f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[hudWindow animator] setAlphaValue:1.f];
    [[hudWindow animator] setFrame:[self visibleFrame] display:YES];

    [NSAnimationContext endGrouping];
}

@end
