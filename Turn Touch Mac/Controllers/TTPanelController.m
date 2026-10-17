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
#import "../Views/Panel/TTPanelGeometry.h"

#define PANEL_OPEN_DURATION .12
#define PANEL_CLOSE_DURATION .14

#pragma mark -

@interface TTPanelController ()

@property (nonatomic, unsafe_unretained, readwrite) id<TTPanelControllerDelegate> delegate;
@property (nonatomic) BOOL privateHasActivePanel;

@end

@implementation TTPanelController

- (id)initWithDelegate:(id<TTPanelControllerDelegate>)delegate {
    self = [super initWithWindowNibName:@"TTPanel"];
    if (self != nil) {
        self.delegate = delegate;
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
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
    [panel setHidesOnDeactivate:NO];
    [panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setBackgroundColor:[NSColor clearColor]];

    self.backgroundView = [[TTBackgroundView alloc] init];
    [panel setContentView:self.backgroundView];

    [self.appDelegate.modeMap reset];
    
    self.preventClosing = NO;
}

#pragma mark - Public accessors

- (BOOL)hasActivePanel {
    return self.privateHasActivePanel;
}

- (void)setHasActivePanel:(BOOL)flag {
    if (self.privateHasActivePanel != flag) {
        self.privateHasActivePanel = flag;
        
        if (self.privateHasActivePanel) {
            [self openPanel];
        } else {
            // Comment closePanel to debug.
            BOOL closed = [self closePanel];
            if (!closed) self.privateHasActivePanel = YES;
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    self.hasActivePanel = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification {
    // Configuration often involves another window (sign-in, permissions, or a
    // password manager). Keep the editor and its selection visible when focus
    // moves away. The menu-bar icon and Escape still dismiss the panel.
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender {
    self.hasActivePanel = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window {
    TTStatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForPanelController:)]) {
        statusItemView = [self.delegate statusItemViewForPanelController:self];
    }
    if (statusItemView.window) {
        return statusItemView.globalRect;
    }

    NSScreen *screen = window.screen ?: NSScreen.mainScreen;
    NSRect frame = screen.frame;
    CGFloat height = NSStatusBar.systemStatusBar.thickness;
    return NSMakeRect(NSMidX(frame) - STATUS_ITEM_VIEW_WIDTH / 2,
                      NSMaxY(frame) - height, STATUS_ITEM_VIEW_WIDTH, height);
}

- (NSScreen *)screenForPanel {
    NSRect anchor = [self statusRectForWindow:self.window];
    NSPoint center = NSMakePoint(NSMidX(anchor), NSMidY(anchor));
    for (NSScreen *screen in NSScreen.screens) {
        if (NSPointInRect(center, screen.frame)) return screen;
    }
    return self.window.screen ?: NSScreen.mainScreen;
}

- (void)openPanel {
    NSWindow *panel = [self window];
    
    NSRect screenRect = self.screenForPanel.visibleFrame;
    NSRect statusRect = [self statusRectForWindow:panel];
    
    [self.backgroundView resetPosition];
    [self.backgroundView switchPanelModal:PANEL_MODAL_APP];

    [self.backgroundView layoutSubtreeIfNeeded];
    NSRect panelRect = TTPanelFrameBelowStatusItem(statusRect,
        NSMakeSize(PANEL_WIDTH, [self.backgroundView preferredPanelHeight]), screenRect, ARROW_HEIGHT);
    NSLog(@"Panel anchor: %@ frame: %@ screen: %@", NSStringFromRect(statusRect),
          NSStringFromRect(panelRect), NSStringFromRect(screenRect));

    [NSApp activateIgnoringOtherApps:NO];
    [panel setAlphaValue:0];
    [panel setFrame:panelRect display:YES];
    [panel setDelegate:self];
    [panel makeKeyAndOrderFront:nil];
//    [panel performSelector:@selector(makeKeyAndOrderFront:) withObject:nil afterDelay:0.0];
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

- (BOOL)closePanel {
//        return NO; // Enable this line to never close app. Useful for debugging

    if (self.backgroundView.panelModal != PANEL_MODAL_APP) {
        // Don't close the window when not on main app unless clicking on status icon
        if (self.appDelegate.menubarController.hasActiveIcon) {
            return NO;
        }
    }
    
    if (self.preventClosing) {
        return NO;
    }
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:PANEL_CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * PANEL_CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        // A prompt can return focus before the fade-out finishes.
        if (!self.hasActivePanel) [self.window orderOut:nil];
    });
    
    return YES;
}

- (void)openModal:(TTModalPairing)modal {
    // This is a hack, but the panelController doesn't have a backgroundView if it hasn't
    // been opened yet, so only open it if it hasn't been opened.
    if (!self.backgroundView) {
        [self.appDelegate openPanel];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.backgroundView switchPanelModalPairing:modal];
    });
}

@end
