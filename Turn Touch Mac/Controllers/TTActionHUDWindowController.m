//
//  TTHUDViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTActionHUDWindowController.h"

@interface TTActionHUDWindowController ()

@property (nonatomic) BOOL fadingIn;

@end

@implementation TTActionHUDWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self.hudWindow setFrame:[self hiddenFrame] display:YES];
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

- (IBAction)fadeIn:(NSString *)actionName inDirection:(TTModeDirection)direction {
    [self fadeIn:actionName inDirection:direction withMode:nil];
}

- (IBAction)fadeIn:(NSString *)actionName inDirection:(TTModeDirection)direction withMode:(TTMode *)mode {
    [self fadeIn:actionName inDirection:direction withMode:mode buttonMoment:BUTTON_MOMENT_PRESSUP];
}

- (IBAction)fadeIn:(NSString *)actionName inDirection:(TTModeDirection)direction withMode:(TTMode *)mode buttonMoment:(TTButtonMoment)buttonMoment {
    if (!mode) mode = self.appDelegate.modeMap.selectedMode;

    if ([self.appDelegate.modeMap shouldHideHud:direction]) return;

    NSLog(@" ---> Fade in action: %d", direction);
//    [hudWindow setLevel:10];
    [self.hudWindow makeKeyAndOrderFront:NSApp];
    [self showWindow:nil];
    
    [self.hudView setMode:mode];
    [self.hudView setDirection:direction];
    [self.hudView setActionName:actionName];
    [self.hudView setButtonMoment:buttonMoment];
    [self.hudView drawProgressBar:self.progressBar];
    [self.hudView drawImageLayoutView];
    [self.hudView setHidden:NO];
    [self.hudView setNeedsDisplay:YES];
    
    if (self.hudWindow.frame.origin.y == [self hiddenFrame].origin.y) {
        [self.hudWindow setFrame:[self visibleFrame] display:YES];
        [[self.hudWindow animator] setAlphaValue:0.1f];
    }
    
    self.fadingIn = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.2f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        self.fadingIn = NO;
    }];
    
    [[self.hudWindow animator] setAlphaValue:1.f];
    [[self.hudWindow animator] setFrame:[self visibleFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut:(id)sender {
//    __block __unsafe_unretained NSWindow *window = hudWindow;
//    NSLog(@" ---> Fade out action");
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.25f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        if (self.fadingIn) return;
        [self.hudView setHidden:YES];
        
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[self.hudWindow animator] setAlphaValue:0.f];
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
        if (self.fadingIn) return;
        [self.hudView setHidden:YES];
    }];
    
    [[self.hudWindow animator] setAlphaValue:0.15f];
    [[self.hudWindow animator] setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

@end
