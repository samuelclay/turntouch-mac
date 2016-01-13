//
//  TTModeWebWindowController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/29/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeWebWindowController.h"

@interface TTModeWebWindowController ()

@end

@implementation TTModeWebWindowController

@synthesize webWindow;
@synthesize backgroundView;
@synthesize browserView;
@synthesize menuView;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];

        [self showWindow:appDelegate];
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

- (void)fadeIn {
    [webWindow setFrame:[self visibleFrame] display:YES];
    [webWindow makeKeyAndOrderFront:nil];
    [browserView setNeedsDisplay:YES];
    [menuView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [[webWindow animator] setAlphaValue:1.f];
    [webWindow setFrame:[self visibleFrame] display:YES];

    [browserView setNeedsDisplay:YES];

    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut {
    //    __block __unsafe_unretained NSWindow *window = webWindow;
    if (isFading) return;
    isFading = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.65f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        //        [webWindow orderOut:nil];
        isFading = NO;
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[webWindow animator] setAlphaValue:0.f];
    
    [NSAnimationContext endGrouping];
}

@end
