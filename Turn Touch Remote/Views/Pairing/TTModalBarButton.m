//
//  TTModalBarButton.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalBarButton.h"

@interface TTModalBarButton ()

@end

@implementation TTModalBarButton

@synthesize buttonLabel;
@synthesize chevronImage;


- (instancetype)init {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        buttonLabel = [[NSTextField alloc] init];
        buttonLabel.editable = NO;
        buttonLabel.bordered = NO;
        buttonLabel.backgroundColor = [NSColor clearColor];
        buttonLabel.font = [NSFont fontWithName:@"Effra" size:16.f];
        buttonLabel.textColor = NSColorFromRGB(0xFFFFFF);
        buttonLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [buttonLabel sizeToFit];
        [self addSubview:buttonLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-20.0f]];
        
        chevronImage = [[NSImageView alloc] init];
        chevronImage.image = [NSImage imageNamed:@"modal_bar_button_chevron"];
        chevronImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:chevronImage];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:2.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:buttonLabel attribute:NSLayoutAttributeRight multiplier:1.0f constant:2.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:12.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:14.0f]];
        
        [self createTrackingArea];
    }

    return self;
}

- (void)setPagePairing:(TTModalPairing)_modalPairing {
    modalPairing = _modalPairing;
    modalFTUX = 0;
    modalSupport = 0;
    
    [self updateModal];
    [self setNeedsDisplay:YES];
}

- (void)setPageFTUX:(TTModalFTUX)_modalFTUX {
    modalPairing = 0;
    modalFTUX = _modalFTUX;
    modalSupport = 0;
    
    [self updateModal];
    [self setNeedsDisplay:YES];
}

- (void)setPageSupport:(TTModalSupport)_modalSupport {
    modalSupport = _modalSupport;
    modalFTUX = 0;
    modalPairing = 0;

    [self updateModal];
    [self setNeedsDisplay:YES];
}

- (void)updateModal {
    if (modalPairing == MODAL_PAIRING_SEARCH) {
        // Just need the background color, no actual button
        [self removeConstraints:[self constraints]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:12.0f]];
        return;
    }

    if (modalPairing == MODAL_PAIRING_INTRO) {
        buttonLabel.stringValue = @"Pair Remote";
    } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
        buttonLabel.stringValue = @"Show me how it works";
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        buttonLabel.stringValue = @"Try again";
    } else if (modalFTUX == MODAL_FTUX_INTRO) {
        buttonLabel.stringValue = @"Continue";
    } else if (modalFTUX == MODAL_FTUX_ACTIONS) {
        buttonLabel.stringValue = @"Continue";
    } else if (modalFTUX == MODAL_FTUX_MODES) {
        buttonLabel.stringValue = @"Continue";
    } else if (modalFTUX == MODAL_FTUX_BATCHACTIONS) {
        buttonLabel.stringValue = @"Continue";
    } else if (modalFTUX == MODAL_FTUX_HUD) {
        buttonLabel.stringValue = @"That's all there is to it";
    } else if (modalSupport == MODAL_SUPPORT_QUESTION) {
        buttonLabel.stringValue = @"Submit Question";
    } else if (modalSupport == MODAL_SUPPORT_IDEA) {
        buttonLabel.stringValue = @"Submit Idea";
    } else if (modalSupport == MODAL_SUPPORT_PROBLEM) {
        buttonLabel.stringValue = @"Submit Problem";
    }

    [self resetBackgroundColor];
}

- (void)resetBackgroundColor {
    if (modalPairing == MODAL_PAIRING_INTRO) {
        self.backgroundColor = NSColorFromRGB(0x4383C0);
    } else if (modalPairing == MODAL_PAIRING_SEARCH) {
        self.backgroundColor = NSColorFromRGB(0xEFF1F3);
    } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x2FB789);
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xFFCA44);
    } else if (modalFTUX == MODAL_FTUX_HUD) {
        self.backgroundColor = NSColorFromRGB(0x434340);
    } else if (modalFTUX) {
        self.backgroundColor = NSColorFromRGB(0x4383C0);
    } else if (modalSupport == MODAL_SUPPORT_QUESTION) {
        self.backgroundColor = NSColorFromRGB(0x4383C0);
    } else if (modalSupport == MODAL_SUPPORT_IDEA) {
        self.backgroundColor = NSColorFromRGB(0x2FB789);
    } else if (modalSupport == MODAL_SUPPORT_PROBLEM) {
        self.backgroundColor = NSColorFromRGB(0xFFCA44);
    }
}

- (void)createTrackingArea {
    if (trackingArea) {
        [self removeTrackingArea:trackingArea];
        trackingArea = nil;
    }
    
    NSTrackingAreaOptions opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect);
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:opts
                                                  owner:self
                                               userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    
    if (modalPairing == MODAL_PAIRING_INTRO) {
        self.backgroundColor = NSColorFromRGB(0x6B9DCB);
    } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x65C4A1);
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xFDD375);
    } else if (modalFTUX == MODAL_FTUX_HUD) {
        self.backgroundColor = NSColorFromRGB(0x535350);
    } else if (modalFTUX) {
        self.backgroundColor = NSColorFromRGB(0x6B9DCB);
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    
    [self resetBackgroundColor];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (modalPairing == MODAL_PAIRING_INTRO) {
        self.backgroundColor = NSColorFromRGB(0x396C9A);
    } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x36A07A);
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xE4B449);
    } else if (modalFTUX == MODAL_FTUX_HUD) {
        self.backgroundColor = NSColorFromRGB(0x333330);
    } else if (modalFTUX) {
        self.backgroundColor = NSColorFromRGB(0x396C9A);
    }

    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self resetBackgroundColor];
    [self setNeedsDisplay:YES];
    
    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL inside = NSPointInRect(clickPoint, self.bounds);
    if (!inside) {
        return;
    }

    if (modalPairing == MODAL_PAIRING_INTRO) {
        [appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_SEARCH];
    } else if (modalPairing == MODAL_PAIRING_SEARCH) {
        [appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_INTRO];
    } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
        [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_FTUX];
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        [appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_SEARCH];
    } else if (modalFTUX == MODAL_FTUX_INTRO) {
        [appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_ACTIONS];
    } else if (modalFTUX == MODAL_FTUX_ACTIONS) {
        [appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_MODES];
    } else if (modalFTUX == MODAL_FTUX_MODES) {
        [appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_BATCHACTIONS];
    } else if (modalFTUX == MODAL_FTUX_BATCHACTIONS) {
        [appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_HUD];
    } else if (modalFTUX == MODAL_FTUX_HUD) {
        [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
    }
}

@end
