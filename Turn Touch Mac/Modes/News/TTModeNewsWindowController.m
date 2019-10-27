//
//  TTModeNewsWindowController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/7/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNewsWindowController.h"
#import <QuartzCore/QuartzCore.h>

@interface TTModeNewsWindowController ()

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) BOOL isFading;

@end

@implementation TTModeNewsWindowController

- (instancetype)initWithWindowNibName:(NSString *)windowNibName {
    if (self = [super initWithWindowNibName:windowNibName]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self.menuView setDelegate:self];
        [self showWindow:self.appDelegate];
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
    [self.webWindow setFrame:[self visibleFrame] display:YES];
    [self.webWindow makeKeyAndOrderFront:nil];
    [self.browserView setNeedsDisplay:YES];
    [self.menuView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.5f];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [[self.webWindow animator] setAlphaValue:1.f];
    [self.webWindow setFrame:[self visibleFrame] display:YES];
    
    [self.browserView setNeedsDisplay:YES];
    
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut {
    //    __block __unsafe_unretained NSWindow *window = webWindow;
    if (self.isFading) return;
    self.isFading = YES;
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.65f];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        //        [webWindow orderOut:nil];
        self.isFading = NO;
    }];
    [[NSAnimationContext currentContext]
     setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [[self.webWindow animator] setAlphaValue:0.f];
    
    [NSAnimationContext endGrouping];
}

- (void)addFeeds:(NSArray *)stories {
    [self.browserView addFeeds:stories];
}

- (void)addStories:(NSArray *)stories {
    [self.browserView addStories:stories];
}

@end
