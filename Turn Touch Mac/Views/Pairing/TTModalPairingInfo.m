//
//  TTModalPairingInfo.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalPairingInfo.h"

@implementation TTModalPairingInfo

- (instancetype)initWithPairing:(TTModalPairing)modalPairing {
    if (self = [super init]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        self.closeButton = [[NSButton alloc] init];
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.closeButton setBordered:NO];
        [self.closeButton setButtonType:NSMomentaryPushInButton];
        [self.closeButton setImage:[NSImage imageNamed:NSImageNameStopProgressTemplate]];
        [self.closeButton setTarget:self];
        [self.closeButton setAction:@selector(closeModal:)];
        [self addSubview:self.closeButton];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:50.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:50.0f]];
        
        self.heroImage = [[NSImageView alloc] init];
        self.heroImage.translatesAutoresizingMaskIntoConstraints = NO;
        if (modalPairing == MODAL_PAIRING_INTRO) {
            self.heroImage.image = [NSImage imageNamed:@"modal_remote_hero"];
        } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
            self.heroImage.image = [NSImage imageNamed:@"modal_remote_paired"];
        } else if (modalPairing == MODAL_PAIRING_FAILURE) {
            self.heroImage.image = [NSImage imageNamed:@"modal_remote_failed"];
        }
        [self addSubview:self.heroImage];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.heroImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.heroImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:48.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.heroImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:256.f]];
        
        self.titleLabel = [[NSTextField alloc] init];
        if (modalPairing == MODAL_PAIRING_INTRO) {
            self.titleLabel.stringValue = @"Welcome to Turn Touch";
        } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
            self.titleLabel.stringValue = @"That worked perfectly";
        } else if (modalPairing == MODAL_PAIRING_FAILURE) {
            self.titleLabel.stringValue = @"Uh Oh...";
        }
        self.titleLabel.editable = NO;
        self.titleLabel.bordered = NO;
        self.titleLabel.backgroundColor = [NSColor clearColor];
        self.titleLabel.font = [NSFont fontWithName:@"Effra" size:23.f];
        self.titleLabel.textColor = NSColorFromRGB(0x7C878C);
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.titleLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.heroImage attribute:NSLayoutAttributeBottom multiplier:1.0f constant:36.0f]];
        
        self.subtitleLabel = [[NSTextField alloc] init];
        if (modalPairing == MODAL_PAIRING_INTRO) {
            self.subtitleLabel.stringValue = @"Four buttons of beautiful control";
        } else if (modalPairing == MODAL_PAIRING_SUCCESS) {
            self.subtitleLabel.stringValue = @"Your remote has been paired";
        } else if (modalPairing == MODAL_PAIRING_FAILURE) {
            self.subtitleLabel.stringValue = @"No remotes could be found";
        }
        self.subtitleLabel.editable = NO;
        self.subtitleLabel.bordered = NO;
        self.subtitleLabel.backgroundColor = [NSColor clearColor];
        self.subtitleLabel.font = [NSFont fontWithName:@"Effra" size:17.f];
        self.subtitleLabel.textColor = NSColorFromRGB(0x9A9A9C);
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.subtitleLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.titleLabel attribute:NSLayoutAttributeBottom multiplier:1.0f constant:4.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.subtitleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-36.0f]];
        
        if (modalPairing == MODAL_PAIRING_FAILURE) {
            [self checkBluetoothState];
        }
    }
    return self;
}

- (void)checkBluetoothState {
    switch ([self.appDelegate.bluetoothMonitor.manager state]) {
        case CBCentralManagerStatePoweredOn:
            return;
        case CBCentralManagerStateUnsupported:
            self.subtitleLabel.stringValue = @"This computer doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            self.subtitleLabel.stringValue = @"Turn Touch is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            self.subtitleLabel.stringValue = @"Bluetooth is currently powered off.";
            break;
        default:
            self.subtitleLabel.stringValue = @"Bluetooth is powered off or isn't responding.";
            break;
    }   
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [NSColorFromRGB(0xEFF1F3) setFill];
    NSRectFill(self.bounds);
}

#pragma mark - Actions

- (void)closeModal:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
