//
//  TTChangeButtonView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTChangeButtonView.h"
#import "TTChangeButtonCell.h"

@interface TTChangeButtonView ()

@property (nonatomic, strong) TTChangeButtonCell *changeButtonCell;

@end

@implementation TTChangeButtonView

- (void)awakeFromNib {
    self.changeButtonCell = self.cell;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.changeButtonCell = [[TTChangeButtonCell alloc] init];
        [self setCell:self.changeButtonCell];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [self setBezelStyle:NSRoundRectBezelStyle];
    [self setButtonType:NSMomentaryChangeButton];
    self.changeButtonCell.attributedTitle = self.attributedTitle;
    [super drawRect:dirtyRect];
}

- (void)setBorderRadius:(CGFloat)borderRadius {
    _borderRadius = borderRadius;
    [self.changeButtonCell setBorderRadius:self.borderRadius];
}

- (void)setUseAltStyle:(BOOL)useAltStyle {
    _useAltStyle = useAltStyle;
    [self.changeButtonCell setUseAltStyle:self.useAltStyle];
}

- (void)setRightBorderRadius:(CGFloat)rightBorderRadius {
    _rightBorderRadius = rightBorderRadius;
    [self.changeButtonCell setRightBorderRadius:self.rightBorderRadius];
}

#pragma mark - Events

- (void)mouseDown:(NSEvent *)theEvent {
    self.changeButtonCell.mouseDown = YES;
    [self setNeedsDisplay];
    
    // this blocks until the button is released
    [super mouseDown:theEvent];
    // we know the button was released, so we can send this
    [self mouseUp:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [super mouseUp:theEvent];
    self.changeButtonCell.mouseDown = NO;
    [self setNeedsDisplay];
}

- (BOOL)isFlipped {
    return NO;
}
@end
