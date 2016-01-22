//
//  TTPanelController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTPanelController.h"
#import "TTBackgroundView.h"
#import "TTStatusItemView.h"
#import "TTMenubarController.h"
#import "TTPanel.h"

#define PANEL_OPEN_DURATION .12
#define PANEL_CLOSE_DURATION .14

#define SEARCH_INSET 17

#define PANEL_HEIGHT 262
#define PANEL_WIDTH 362
#define MENU_ANIMATION_DURATION .12

#pragma mark -

@implementation TTPanelController

@synthesize backgroundView = _backgroundView;
@synthesize delegate = _delegate;

#pragma mark -

- (id)initWithDelegate:(id<TTPanelControllerDelegate>)delegate {
    self = [super initWithWindowNibName:@"TTPanel"];
    if (self != nil) {
        _delegate = delegate;
        appDelegate = (TTAppDelegate *)[NSApp delegate];
    }
    return self;
}

- (void)dealloc {

}

#pragma mark -

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSPanel *panel = (id)[self window];
    [panel setDelegate:self];
    [panel setAcceptsMouseMovedEvents:YES];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];

    self.backgroundView = [[TTBackgroundView alloc] init];
    [panel setContentView:self.backgroundView];

    [appDelegate.modeMap reset];

    [self registerAsObserver];
}


#pragma mark - KVO

- (void)registerAsObserver {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(resize:)
//                                                 name:NSWindowDidResizeNotification
//                                               object:self.window];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(frame))]) {
        [self resize:nil];
    }
}

- (void)resize:(NSNotification *)notification {
//    NSLog(@"Resize notification: %@", NSStringFromRect(self.window.frame));
//    [self.window display];
//    [self.window setHasShadow:NO];
//    [self.window setHasShadow:YES];
//    [self.window invalidateShadow];
  /*  [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:self.window];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resize:)
                                                 name:NSWindowDidResizeNotification
                                               object:self.window];*/

}

#pragma mark - Public accessors

- (BOOL)hasActivePanel {
    return _hasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag {
    if (_hasActivePanel != flag) {
        _hasActivePanel = flag;
        
        if (_hasActivePanel) {
            [self openPanel];
        } else {
            // Comment closePanel to debug.
            [self closePanel];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification {
    if ([[self window] isVisible]) {
        self.hasActivePanel = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification {
//    NSLog(@"windowDidResize: %@", notification);

//    [self.window display];
//    [self.window invalidateShadow];
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender {
    self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window {
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = NSZeroRect;
    
    TTStatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)]) {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    
    if (statusItemView) {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect) - 2;
    } else {
        statusRect.size = NSMakeSize(STATUS_ITEM_VIEW_WIDTH, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    
    return statusRect;
}

- (void)openPanel {
    NSWindow *panel = [self window];
    
    NSRect screenRect = [[[NSScreen screens] objectAtIndex:0] frame];
    NSRect statusRect = [self statusRectForWindow:panel];
    
    [self.backgroundView resetPosition];

    NSRect panelRect = [panel frame];
    panelRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(panelRect) / 2);
    panelRect.origin.y = NSMaxY(statusRect) - NSHeight(panelRect);
    
    if (NSMaxX(panelRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        panelRect.origin.x -= NSMaxX(panelRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
//    NSLog(@"Panel rect: %@ (%@)", NSStringFromRect(statusRect), NSStringFromRect(panelRect));

    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:panelRect display:YES];
    [panel setDelegate:self];
    [panel makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = PANEL_OPEN_DURATION;
    
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown) {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed) {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(panelRect));
        }
    }
    
    NSDictionary *fadeIn = [NSDictionary dictionaryWithObjectsAndKeys:
                            panel, NSViewAnimationTargetKey,
                            NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:@[fadeIn]];
    [animation setAnimationBlockingMode: NSAnimationNonblocking];
    [animation setAnimationCurve: NSAnimationEaseIn];
    [animation setDuration: openDuration];
    [animation startAnimation];
}

- (void)closePanel {
//    return; // Enable this line to never close app. Useful for debugging
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:PANEL_CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * PANEL_CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        [self.window orderOut:nil];
    });
}

@end
