//
//  TTModeWemoSwitchDevice.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/21/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeWemoSwitchDevice.h"

@interface TTModeWemoSwitchDevice ()

@property (nonatomic, strong) TTModeWemoDevice *device;
@property (nonatomic, strong) NSTrackingArea *trackingArea;

@end

@implementation TTModeWemoSwitchDevice

- (id)initWithDevice:(TTModeWemoDevice *)_device {
    if (self = [super init]) {
        self.wantsLayer = YES;
        self.translatesAutoresizingMaskIntoConstraints = NO;

        self.device = _device;
        
        self.nameLabel = [[NSTextField alloc] init];
        [self.nameLabel setFont:[NSFont fontWithName:@"Effra" size:16.f]];
        [self.nameLabel setTextColor:NSColorFromRGB(0x303030)];
        [self.nameLabel setBackgroundColor:[NSColor clearColor]];
        [self.nameLabel setBezeled:NO];
        [self.nameLabel setEditable:NO];
        [self.nameLabel setSelectable:NO];
        [self.nameLabel setDrawsBackground:NO];
        [self.nameLabel sizeToFit];
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.nameLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:5.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:5.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:32.f]];
        
        self.selectedLabel = [[NSTextField alloc] init];
        [self.selectedLabel setFont:[NSFont fontWithName:@"Effra" size:16.f]];
        [self.selectedLabel setTextColor:NSColorFromRGB(0x303030)];
        [self.selectedLabel setBackgroundColor:[NSColor clearColor]];
        [self.selectedLabel setBezeled:NO];
        [self.selectedLabel setEditable:NO];
        [self.selectedLabel setSelectable:NO];
        [self.selectedLabel setDrawsBackground:NO];
        [self.selectedLabel setAlignment:NSTextAlignmentRight];
        self.selectedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.selectedLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-6]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:-12.f]];
        
        [self redraw];
    }
    
    return self;
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self createTrackingAreas];
}

- (void)redraw {
    BOOL selected = [self.delegate isSelected:self.device];
    [self.nameLabel setStringValue:self.device.deviceName];
    [self.selectedLabel setStringValue:selected ? @"✔︎" : @""];
    if (selected) {
        [self.layer setBackgroundColor:NSColorFromRGB(0xF0F0F0).CGColor];
    } else {
        [self.layer setBackgroundColor:[NSColor whiteColor].CGColor];
    }
}

-(void)createTrackingAreas {
    if (self.trackingArea != nil) {
        [self removeTrackingArea:self.trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:opts
                                                   owner:self
                                                userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
    BOOL selected = [self.delegate isSelected:self.device];
    if (!selected) {
        [self.layer setBackgroundColor:NSColorFromRGB(0xF9F9F9).CGColor];
        [self setNeedsDisplay:YES];
    }
}

- (void)mouseExited:(NSEvent *)event {
    [self redraw];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)event {
    [self.delegate toggleDevice:self.device];
    
    [self redraw];
}

@end
