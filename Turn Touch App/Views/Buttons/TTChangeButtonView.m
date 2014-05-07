//
//  TTChangeButtonView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTChangeButtonView.h"
#import "TTChangeButtonCell.h"

@implementation TTChangeButtonView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        cell = [[TTChangeButtonCell alloc] init];
        [self setCell:cell];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

#pragma mark - Events

- (void)mouseDown:(NSEvent *)theEvent {
    cell.mouseDown = YES;
    [self setNeedsDisplay];
    
    // this blocks until the button is released
    [super mouseDown:theEvent];
    // we know the button was released, so we can send this
    [self mouseUp:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    cell.mouseDown = NO;
    [self setNeedsDisplay];
}

@end
