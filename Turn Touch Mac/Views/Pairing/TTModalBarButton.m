//
//  TTModalBarButton.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalBarButton.h"

@interface TTModalBarButton ()

@property (nonatomic) TTModalPairing modalPairing;
@property (nonatomic) TTModalFTUX modalFTUX;
@property (nonatomic) TTModalSupport modalSupport;
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation TTModalBarButton

- (instancetype)init {
    if (self = [super init]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.buttonLabel = [[NSTextField alloc] init];
        self.buttonLabel.editable = NO;
        self.buttonLabel.bordered = NO;
        self.buttonLabel.backgroundColor = [NSColor clearColor];
        self.buttonLabel.font = [NSFont fontWithName:@"Effra" size:16.f];
        self.buttonLabel.textColor = NSColorFromRGB(0xFFFFFF);
        self.buttonLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.buttonLabel sizeToFit];
        [self addSubview:self.buttonLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:20.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.buttonLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-20.0f]];
        
        self.chevronImage = [[NSImageView alloc] init];
        self.chevronImage.image = [NSImage imageNamed:@"modal_bar_button_chevron"];
        self.chevronImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.chevronImage];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chevronImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:2.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chevronImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.buttonLabel attribute:NSLayoutAttributeRight multiplier:1.0f constant:2.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chevronImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:12.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.chevronImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:14.0f]];
        
        [self createTrackingArea];
    }

    return self;
}

- (void)setPagePairing:(TTModalPairing)_modalPairing {
    self.modalPairing = _modalPairing;
    self.modalFTUX = 0;
    self.modalSupport = 0;
    
    [self updateModal];
    [self setNeedsDisplay:YES];
}

- (void)setPageFTUX:(TTModalFTUX)_modalFTUX {
    self.modalPairing = 0;
    self.modalFTUX = _modalFTUX;
    self.modalSupport = 0;
    
    [self updateModal];
    [self setNeedsDisplay:YES];
}

- (void)setPageSupport:(TTModalSupport)_modalSupport {
    self.modalSupport = _modalSupport;
    self.modalFTUX = 0;
    self.modalPairing = 0;

    [self updateModal];
    [self setNeedsDisplay:YES];
}

- (void)updateModal {
    if (self.modalPairing == MODAL_PAIRING_SEARCH) {
        // Just need the background color, no actual button
        for (NSLayoutConstraint *constraint in [self constraints]) {
            [self removeConstraint:constraint];
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:12.0f]];
        return;
    }

    [self.chevronImage setHidden:NO];
    
    if (self.modalPairing == MODAL_PAIRING_INTRO) {
        self.buttonLabel.stringValue = @"Pair Remote";
    } else if (self.modalPairing == MODAL_PAIRING_SUCCESS) {
        self.buttonLabel.stringValue = @"Show me how it works";
    } else if (self.modalPairing == MODAL_PAIRING_FAILURE) {
        self.buttonLabel.stringValue = @"Try again";
    } else if (self.modalFTUX == MODAL_FTUX_INTRO) {
        self.buttonLabel.stringValue = @"Continue";
    } else if (self.modalFTUX == MODAL_FTUX_ACTIONS) {
        self.buttonLabel.stringValue = @"Continue";
    } else if (self.modalFTUX == MODAL_FTUX_MODES) {
        self.buttonLabel.stringValue = @"Continue";
    } else if (self.modalFTUX == MODAL_FTUX_BATCHACTIONS) {
        self.buttonLabel.stringValue = @"Continue";
    } else if (self.modalFTUX == MODAL_FTUX_HUD) {
        self.buttonLabel.stringValue = @"That's all there is to it";
    } else if (self.modalSupport == MODAL_SUPPORT_QUESTION) {
        self.buttonLabel.stringValue = @"Submit Question";
    } else if (self.modalSupport == MODAL_SUPPORT_IDEA) {
        self.buttonLabel.stringValue = @"Submit Idea";
    } else if (self.modalSupport == MODAL_SUPPORT_PROBLEM) {
        self.buttonLabel.stringValue = @"Submit Problem";
    } else if (self.modalSupport == MODAL_SUPPORT_PRAISE) {
        self.buttonLabel.stringValue = @"Send Praise";
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTING) {
        self.buttonLabel.stringValue = @"Sending...";
        [self.chevronImage setHidden:YES];
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTED) {
        self.buttonLabel.stringValue = @"All done";
    }

    [self resetBackgroundColor];
}

- (void)resetBackgroundColor {
    if (self.modalPairing == MODAL_PAIRING_INTRO) {
        self.backgroundColor = NSColorFromRGB(0x4383C0);
    } else if (self.modalPairing == MODAL_PAIRING_SEARCH) {
        self.backgroundColor = NSColorFromRGB(0xEFF1F3);
    } else if (self.modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x2FB789);
    } else if (self.modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xFFCA44);
    } else if (self.modalFTUX == MODAL_FTUX_HUD) {
        self.backgroundColor = NSColorFromRGB(0x434340);
    } else if (self.modalFTUX) {
        self.backgroundColor = NSColorFromRGB(0x4383C0);
    } else if (self.modalSupport == MODAL_SUPPORT_QUESTION) {
        self.backgroundColor = NSColorFromRGB(0x4383C0);
    } else if (self.modalSupport == MODAL_SUPPORT_IDEA) {
        self.backgroundColor = NSColorFromRGB(0x2FB789);
    } else if (self.modalSupport == MODAL_SUPPORT_PROBLEM) {
        self.backgroundColor = NSColorFromRGB(0xFFCA44);
    } else if (self.modalSupport == MODAL_SUPPORT_PRAISE) {
        self.backgroundColor = NSColorFromRGB(0x2FB789);
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTING) {
        self.backgroundColor = NSColorFromRGB(0x838380);
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTED) {
        self.backgroundColor = NSColorFromRGB(0x434340);
    }
}

- (void)createTrackingArea {
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways |
                NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect);
    self.trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    
    if (self.modalPairing == MODAL_PAIRING_INTRO) {
        self.backgroundColor = NSColorFromRGB(0x6B9DCB);
    } else if (self.modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x65C4A1);
    } else if (self.modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xFDD375);
    } else if (self.modalFTUX == MODAL_FTUX_HUD) {
        self.backgroundColor = NSColorFromRGB(0x535350);
    } else if (self.modalFTUX) {
        self.backgroundColor = NSColorFromRGB(0x6B9DCB);
    } else if (self.modalSupport == MODAL_SUPPORT_QUESTION) {
        self.backgroundColor = NSColorFromRGB(0x6B9DCB);
    } else if (self.modalSupport == MODAL_SUPPORT_IDEA) {
        self.backgroundColor = NSColorFromRGB(0x65C4A1);
    } else if (self.modalSupport == MODAL_SUPPORT_PROBLEM) {
        self.backgroundColor = NSColorFromRGB(0xFDD375);
    } else if (self.modalSupport == MODAL_SUPPORT_PRAISE) {
        self.backgroundColor = NSColorFromRGB(0x65C4A1);
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTING) {
        // Do nothing
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTED) {
        self.backgroundColor = NSColorFromRGB(0x535350);
    }
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    
    [self resetBackgroundColor];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    if (self.modalPairing == MODAL_PAIRING_INTRO) {
        self.backgroundColor = NSColorFromRGB(0x396C9A);
    } else if (self.modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x36A07A);
    } else if (self.modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xE4B449);
    } else if (self.modalFTUX == MODAL_FTUX_HUD) {
        self.backgroundColor = NSColorFromRGB(0x333330);
    } else if (self.modalFTUX) {
        self.backgroundColor = NSColorFromRGB(0x396C9A);
    } else if (self.modalSupport == MODAL_SUPPORT_QUESTION) {
        self.backgroundColor = NSColorFromRGB(0x396C9A);
    } else if (self.modalSupport == MODAL_SUPPORT_IDEA) {
        self.backgroundColor = NSColorFromRGB(0x36A07A);
    } else if (self.modalSupport == MODAL_SUPPORT_PROBLEM) {
        self.backgroundColor = NSColorFromRGB(0xE4B449);
    } else if (self.modalSupport == MODAL_SUPPORT_PRAISE) {
        self.backgroundColor = NSColorFromRGB(0x36A07A);
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTING) {
        // Do nothing
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTED) {
        self.backgroundColor = NSColorFromRGB(0x333330);
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

    if (self.modalPairing == MODAL_PAIRING_INTRO) {
        [self.appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_SEARCH];
    } else if (self.modalPairing == MODAL_PAIRING_SEARCH) {
        [self.appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_INTRO];
    } else if (self.modalPairing == MODAL_PAIRING_SUCCESS) {
        [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_FTUX];
    } else if (self.modalPairing == MODAL_PAIRING_FAILURE) {
        [self.appDelegate.panelController.backgroundView switchPanelModalPairing:MODAL_PAIRING_SEARCH];
    } else if (self.modalFTUX == MODAL_FTUX_INTRO) {
        [self.appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_ACTIONS];
    } else if (self.modalFTUX == MODAL_FTUX_ACTIONS) {
        [self.appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_MODES];
    } else if (self.modalFTUX == MODAL_FTUX_MODES) {
        [self.appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_BATCHACTIONS];
    } else if (self.modalFTUX == MODAL_FTUX_BATCHACTIONS) {
        [self.appDelegate.panelController.backgroundView switchPanelModalFTUX:MODAL_FTUX_HUD];
    } else if (self.modalFTUX == MODAL_FTUX_HUD) {
        [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTED) {
        [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
    } else if (self.modalSupport == MODAL_SUPPORT_SUBMITTING) {
        // Do nothing
    } else if (self.modalSupport) {
        [self.appDelegate.panelController.backgroundView.modalSupportView submitSupport];
    }
}

@end
