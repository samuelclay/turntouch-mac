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
    
    return NSMakeRect(0, 0, NSWidth(mainScreen.frame), 200);
}

- (NSRect)hiddenFrame {
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return NSMakeRect(0, -200, NSWidth(mainScreen.frame), 200);
}

- (IBAction)fadeIn:(TTModeDirection)direction {
    [self fadeIn:direction withMode:NSAppDelegate.modeMap.selectedMode];
}

- (IBAction)fadeIn:(TTModeDirection)direction withMode:(TTMode *)mode {
    [self fadeIn:direction withMode:mode actionType:ACTION_TYPE_PRESSUP];
}

- (IBAction)fadeIn:(TTModeDirection)direction withMode:(TTMode *)mode actionType:(TTActionType)actionType {
    [hudWindow makeKeyAndOrderFront:nil];
    [self showWindow:self];

    [hudView setMode:mode];
    [hudView setDirection:direction];
//    [hudView setActionType:actionType];
    [hudView drawProgressBar:progressBar];
    [hudView drawImageLayoutView];
    [hudView setNeedsDisplay:YES];
    
    if (hudWindow.frame.origin.y == [self hiddenFrame].origin.y) {
        [hudWindow setFrame:[self visibleFrame] display:YES];
        [[hudWindow animator] setAlphaValue:0.f];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.2f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [[hudWindow animator] setAlphaValue:1.f];
    [[hudWindow animator] setFrame:[self visibleFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut:(id)sender {
//    __block __unsafe_unretained NSWindow *window = hudWindow;

    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.25f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
//        [window orderOut:nil];
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[hudWindow animator] setAlphaValue:0.f];
//    [[hudWindow animator] setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (IBAction)slideOut:(id)sender {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.55f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[hudWindow animator] setAlphaValue:0.15f];
    [[hudWindow animator] setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

@end
