//
//  TTDiamondLabels.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/7/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabels.h"
#import "TTDiamondView.h"

#define LINE_SIZE 6.0f
#define MARGIN 0.0f

@implementation TTDiamondLabels

@synthesize diamondRect;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero interactive:YES];
        [diamondView setIgnoreSelectedMode:YES];
        [diamondView setShowOutline:YES];
        [diamondView setInteractive:YES];
        [self addSubview:diamondView];
        
        northLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:NORTH];
        [self addSubview:northLabel];
        eastLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:EAST];
        [self addSubview:eastLabel];
        westLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:WEST];
        [self addSubview:westLabel];
        southLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:SOUTH];
        [self addSubview:southLabel];

        [self registerAsObserver];
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    [[NSColor whiteColor] set];
    NSRectFill(self.bounds);
    
    diamondRect = NSInsetRect(self.bounds, 24, 24);
    [diamondView setFrame:diamondRect];
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {    
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
//    NSLog(@"Drawing labels: %@", NSStringFromRect(dirtyRect));
	[super drawRect:dirtyRect];

    [self drawLabels];
    [self drawBackground];
}


- (void)drawBackground {
    
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
}

- (void)drawLabels {
    CGFloat offsetX = NSMinX(diamondRect);
    CGFloat offsetY = NSMaxY(self.bounds) - NSMaxY(diamondRect);
    CGFloat width = NSWidth(diamondRect);
    CGFloat height = NSHeight(diamondRect);
//    NSLog(@"Labels rect: %@", NSStringFromRect(diamondRect));
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        if (direction == NORTH) {
            northLine = [NSBezierPath bezierPath];
            [northLine moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + height - 0*LINE_SIZE/2)];
            [northLine lineToPoint:NSMakePoint(offsetX + width / 2, offsetY + height + LINE_SIZE*2)];
        } else if (direction == EAST) {
            eastLine = [NSBezierPath bezierPath];
            [eastLine moveToPoint:NSMakePoint(offsetX + width - 0*LINE_SIZE, offsetY + height * 1/2)];
            [eastLine lineToPoint:NSMakePoint(offsetX + width + LINE_SIZE*2, offsetY + height * 1/2)];
        } else if (direction == WEST) {
            westLine = [NSBezierPath bezierPath];
            [westLine moveToPoint:NSMakePoint(offsetX - LINE_SIZE*2, offsetY + height * 1/2)];
            [westLine lineToPoint:NSMakePoint(offsetX + 0*LINE_SIZE, offsetY + height * 1/2)];
        } else if (direction == SOUTH) {
            southLine = [NSBezierPath bezierPath];
            [southLine moveToPoint:NSMakePoint(offsetX + width / 2, offsetY + 0*LINE_SIZE/2)];
            [southLine lineToPoint:NSMakePoint(offsetX + width / 2, offsetY - LINE_SIZE * 2)];
        }
    }
    
    CGFloat spacing = SPACING_PCT * width;
    CGFloat textHeight = 24;
    
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSRect textRect = diamondRect;
        
        if (direction == NORTH) {
            textRect = NSMakeRect(offsetX, height * 3/4 + spacing + textHeight/2,
                                  width, textHeight);
            [northLabel setFrame:textRect];
        } else if (direction == EAST) {
            textRect = NSMakeRect(offsetX + width/2 + spacing*2, height/2 + textHeight/2,
                                  width/2 - spacing*2, textHeight);
            [eastLabel setFrame:textRect];
        } else if (direction == WEST) {
            textRect = NSMakeRect(offsetX, height/2 + textHeight/2,
                                  width/2 - spacing*2, textHeight);
            [westLabel setFrame:textRect];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(offsetX, height * 1/4 - spacing + textHeight/2,
                                  width, textHeight);
            [southLabel setFrame:textRect];
        }
//        NSLog(@"Label rect: %@", NSStringFromRect(textRect));
    }
}

#pragma mark - Events

- (void)mouseUp:(NSEvent *)theEvent {
    
}

@end
