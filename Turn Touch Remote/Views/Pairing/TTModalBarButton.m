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

- (instancetype)initWithPairing:(TTModalPairing)_modalPairing {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        modalPairing = _modalPairing;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self resetBackgroundColor];
        
        if (modalPairing == MODAL_PAIRING_SEARCH) {
            // Just need the background color, no actual button
            [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:12.0f]];
            return self;
        }
        
        buttonLabel = [[NSTextField alloc] init];
        
        if (modalPairing == MODAL_PAIRING_INTRO) {
            buttonLabel.stringValue = @"Pair Remote";
        } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
            buttonLabel.stringValue = @"Show me how it works";
        } else if (modalPairing == MODAL_PAIRING_FAILURE) {
            buttonLabel.stringValue = @"Try again";
        }
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

- (void)resetBackgroundColor {
    if (modalPairing == MODAL_PAIRING_INTRO) {
        self.backgroundColor = NSColorFromRGB(0x4383C0);
    } else if (modalPairing == MODAL_PAIRING_SEARCH) {
        self.backgroundColor = NSColorFromRGB(0xEFF1F3);
    } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x2FB789);
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xFFCA44);
    }
}

- (void)createTrackingArea {
    if (trackingArea) {
        [self removeTrackingArea:trackingArea];
        trackingArea = nil;
    }
    
    NSLog(@"Creating tracking area: %@", NSStringFromRect(self.bounds));
    
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
        self.backgroundColor = NSColorFromRGB(0x1FA779);
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xDFAA34);
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
        self.backgroundColor = NSColorFromRGB(0x366B9C);
    } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
        self.backgroundColor = NSColorFromRGB(0x1FA779);
    } else if (modalPairing == MODAL_PAIRING_FAILURE) {
        self.backgroundColor = NSColorFromRGB(0xDFAA34);
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
    }
}

@end
