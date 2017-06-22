//
//  TTModeWemoSwitchDevice.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/21/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeWemoSwitchDevice.h"

@interface TTModeWemoSwitchDevice ()

@end

@implementation TTModeWemoSwitchDevice

@synthesize nameLabel;
@synthesize selectedLabel;

- (id)initWithDevice:(TTModeWemoDevice *)_device {
    if (self = [super init]) {
        self.wantsLayer = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;

        device = _device;
        
        nameLabel = [[NSTextField alloc] init];
        [nameLabel setFont:[NSFont fontWithName:@"Effra" size:16.f]];
        [nameLabel setTextColor:NSColorFromRGB(0x303030)];
        [nameLabel setBackgroundColor:[NSColor clearColor]];
        [nameLabel setBezeled:NO];
        [nameLabel setEditable:NO];
        [nameLabel setSelectable:NO];
        [nameLabel setDrawsBackground:NO];
        [nameLabel sizeToFit];
        nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:nameLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:32.f]];
        
        selectedLabel = [[NSTextField alloc] init];
        [selectedLabel setFont:[NSFont fontWithName:@"Effra" size:16.f]];
        [selectedLabel setTextColor:NSColorFromRGB(0x303030)];
        [selectedLabel setBackgroundColor:[NSColor clearColor]];
        [selectedLabel setBezeled:NO];
        [selectedLabel setEditable:NO];
        [selectedLabel setSelectable:NO];
        [selectedLabel setDrawsBackground:NO];
        [selectedLabel setAlignment:NSTextAlignmentRight];
        selectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:selectedLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:selectedLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:nameLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-6]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:selectedLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-12.f]];
        
        [self redraw];
    }
    
    return self;
}

- (void)redraw {
    BOOL selected = [self.delegate isSelected:device];
    [nameLabel setStringValue:device.deviceName];
    [selectedLabel setStringValue:selected ? @"✔︎" : @""];
    if (selected) {
        [self.layer setBackgroundColor:NSColorFromRGB(0xF0F0F0).CGColor];
    } else {
        [self.layer setBackgroundColor:[NSColor whiteColor].CGColor];
    }
    [self createTrackingAreas];
}

-(void)createTrackingAreas {
    if (trackingArea != nil) {
        [self removeTrackingArea:trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    [self.layer setBackgroundColor:NSColorFromRGB(0xF9F9F9).CGColor];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event {
    [self redraw];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
    [self.delegate toggleDevice:device];
    
    [self redraw];
}

@end
