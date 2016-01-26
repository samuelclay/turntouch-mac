//
//  TTHUDViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTActionHUDWindowController.h"

@implementation TTActionHUDWindowController

@synthesize hudView;
@synthesize hudWindow;
@synthesize progressBar;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [hudWindow setFrame:[self hiddenFrame] display:YES];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Window management

- (NSRect)visibleFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, 0, NSWidth(mainScreen.frame), NSHeight(mainScreen.frame));
}

- (NSRect)hiddenFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, -200, NSWidth(mainScreen.frame), NSHeight(mainScreen.frame));
}

- (IBAction)fadeIn:(TTModeDirection)direction {
    [self fadeIn:direction withMode:nil];
}

- (IBAction)fadeIn:(TTModeDirection)direction withMode:(TTMode *)mode {
    [self fadeIn:direction withMode:mode buttonMoment:BUTTON_MOMENT_PRESSUP];
}

- (IBAction)fadeIn:(TTModeDirection)direction withMode:(TTMode *)mode buttonMoment:(TTButtonMoment)buttonMoment {
    if (!mode) mode = appDelegate.modeMap.selectedMode;

    if ([appDelegate.modeMap shouldHideHud:direction]) return;

    //    NSLog(@" ---> Fade in action: %d", direction);
    [hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:self];
    
    [hudView setMode:mode];
    [hudView setDirection:direction];
    [hudView setButtonMoment:buttonMoment];
    [hudView drawProgressBar:progressBar];
    [hudView drawImageLayoutView];
    [hudView setHidden:NO];
    [hudView setNeedsDisplay:YES];
    
    if (hudWindow.frame.origin.y == [self hiddenFrame].origin.y) {
        [hudWindow setFrame:[self visibleFrame] display:YES];
        [[hudWindow animator] setAlphaValue:0.f];
    }
    
    fadingIn = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.2f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        fadingIn = NO;
    }];
    
    [[hudWindow animator] setAlphaValue:1.f];
    [[hudWindow animator] setFrame:[self visibleFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut:(id)sender {
//    __block __unsafe_unretained NSWindow *window = hudWindow;
//    NSLog(@" ---> Fade out action");
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.25f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        if (fadingIn) return;
        [hudView setHidden:YES];
        
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[hudWindow animator] setAlphaValue:0.f];
//    [[hudWindow animator] setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (IBAction)slideOut:(id)sender {
//    NSLog(@" ---> Slide out action");
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.55f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        if (fadingIn) return;
        [hudView setHidden:YES];
    }];
    
    [[hudWindow animator] setAlphaValue:0.15f];
    [[hudWindow animator] setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

@end
