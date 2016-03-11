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
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = NSColorFromRGB(0x4383C0);
        buttonLabel = [[NSTextField alloc] init];
        buttonLabel.stringValue = @"Pair Remote";
        buttonLabel.font = [NSFont fontWithName:@"Effra" size:14.f];
        buttonLabel.textColor = NSColorFromRGB(0xFFFFFF);
        buttonLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:buttonLabel];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:buttonLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        
        chevronImage = [[NSImageView alloc] init];
        chevronImage.image = [NSImage imageNamed:@"modal_bar_button_chevron"];
        chevronImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:chevronImage];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:buttonLabel attribute:NSLayoutAttributeRight multiplier:1.0f constant:2.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:12.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:chevronImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:14.0f]];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

@end
