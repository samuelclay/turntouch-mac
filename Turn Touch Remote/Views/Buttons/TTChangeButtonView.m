//
//  TTChangeButtonView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTChangeButtonView.h"
#import "TTChangeButtonCell.h"

@implementation TTChangeButtonView

@synthesize borderRadius;
@synthesize useAltStyle;

- (void)awakeFromNib {
    cell = self.cell;
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

- (void)setBorderRadius:(CGFloat)_borderRadius {
    borderRadius = _borderRadius;
    [cell setBorderRadius:borderRadius];
}

- (void)setUseAltStyle:(BOOL)_useAltStyle {
    useAltStyle = _useAltStyle;
    [cell setUseAltStyle:useAltStyle];
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
