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
@synthesize browserView;
@synthesize backgroundView;

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [webWindow setFrame:[self hiddenFrame] display:YES];
        
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
    [webWindow makeKeyAndOrderFront:nil];
    [browserView setNeedsDisplay:YES];
    
    if (webWindow.frame.origin.y != [self visibleFrame].origin.y) {
        [webWindow setFrame:[self visibleFrame] display:YES];
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [webWindow setFrame:[self visibleFrame] display:YES];
    
    [[webWindow animator] setAlphaValue:1.f];

    [browserView setNeedsDisplay:YES];

    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut {
    //    __block __unsafe_unretained NSWindow *window = webWindow;
    if (isFading) return;
    isFading = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.55f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        //        [webWindow orderOut:nil];
        isFading = NO;
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[webWindow animator] setAlphaValue:0.f];
    [webWindow setFrame:[self hiddenFrame] display:YES];
    
    [NSAnimationContext endGrouping];
}

@end
