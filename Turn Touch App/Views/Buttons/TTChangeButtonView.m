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

- (void)awakeFromNib {
    cell = [[TTChangeButtonCell alloc] init];
    cell.attributedTitle = self.attributedTitle;
    cell.action = self.action;
    cell.target = self.target;
    [self setCell:cell];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        cell = [[TTChangeButtonCell alloc] init];
        [self setCell:cell];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self setBezelStyle:NSRoundRectBezelStyle];
    [self setButtonType:NSMomentaryChangeButton];
    cell.attributedTitle = self.attributedTitle;
    [super drawRect:dirtyRect];
}

#pragma mark - Events

- (void)mouseDown:(NSEvent *)theEvent {
    cell.mouseDown = YES;
    NSLog(@"Cell mousedown: %@ - %d", cell, cell.mouseDown);
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
