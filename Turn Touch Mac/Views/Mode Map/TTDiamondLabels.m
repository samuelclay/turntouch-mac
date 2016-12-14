//
//  TTDiamondLabels.m
//  Turn Touch Remote
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
@synthesize interactive;
@synthesize isHud;

- (id)initWithInteractive:(BOOL)_interactive {
    return [self initWithInteractive:_interactive isHud:NO];
}

- (id)initWithInteractive:(BOOL)_interactive isHud:(BOOL)_isHud {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        interactive = _interactive;
        isHud = _isHud;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (isHud) {
            diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero diamondType:DIAMOND_TYPE_HUD];
        } else {
            diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero diamondType:DIAMOND_TYPE_INTERACTIVE];
        }
        [diamondView setIgnoreSelectedMode:YES];
        [diamondView setShowOutline:!isHud];
        [self addSubview:diamondView];
        
        northLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:NORTH];
        [northLabel setInteractive:interactive];
        [northLabel setIsHud:isHud];
        [northLabel setupLabels];
        [self addSubview:northLabel];

        eastLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:EAST];
        [eastLabel setInteractive:interactive];
        [eastLabel setIsHud:isHud];
        [eastLabel setupLabels];
        [self addSubview:eastLabel];

        westLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:WEST];
        [westLabel setInteractive:interactive];
        [westLabel setIsHud:isHud];
        [westLabel setupLabels];
        [self addSubview:westLabel];

        southLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:SOUTH];
        [southLabel setInteractive:interactive];
        [southLabel setIsHud:isHud];
        [southLabel setupLabels];
        [self addSubview:southLabel];
        
        if (interactive) {
            [self registerAsObserver];
        }
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    if (interactive) {
        diamondRect = NSInsetRect(self.bounds, 24, 24);
    } else {
        diamondRect = NSInsetRect(self.bounds, 48, 48);
    }
    [diamondView setFrame:diamondRect];
}

- (void)setMode:(TTMode *)mode {
    diamondMode = mode;
    [northLabel setMode:mode];
    [eastLabel setMode:mode];
    [westLabel setMode:mode];
    [southLabel setMode:mode];
}

#pragma mark - KVO

- (void)dealloc {
    if (interactive) {
        [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
        [appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
        [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    }
}

- (void)registerAsObserver {
    if (interactive) {
        [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                                 options:0 context:nil];
        [appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                                 options:0 context:nil];
        [appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                                 options:0 context:nil];
    }
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if (!interactive) return;
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
//    NSLog(@"Drawing labels: %@", NSStringFromRect(dirtyRect));
	[super drawRect:dirtyRect];

    if (isHud) {
        [self drawHudLabels];
    } else {
        [self drawDiamondLabels];
    }
    if (interactive) {
        [self drawBackground];
    }
}



- (void)drawBackground {
    [NSColorFromRGB(0xF5F6F8) set];
    NSRectFill(self.bounds);
}

- (void)drawDiamondLabels {
    CGFloat offsetX = NSMinX(diamondRect);
    CGFloat offsetY = NSMinY(diamondRect);
    CGFloat width = NSWidth(diamondRect);
    CGFloat height = NSHeight(diamondRect);
    CGFloat spacing = SPACING_PCT * width;

    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSRect textRect = diamondRect;
        
        if (direction == NORTH) {
            textRect = NSMakeRect(offsetX, offsetY + height/2 + spacing*2,
                                  width, height/2 - spacing*2);
            [northLabel setFrame:textRect];
        } else if (direction == EAST) {
            textRect = NSMakeRect(offsetX + width/2 + 1.3*spacing*2, 0,
                                  width/2 - 1.3*spacing*2, offsetY*2 + height);
            [eastLabel setFrame:textRect];
        } else if (direction == WEST) {
            textRect = NSMakeRect(offsetX, 0,
                                  width/2 - 1.3*spacing*2, offsetY*2 + height);
            [westLabel setFrame:textRect];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(offsetX, offsetY,
                                  width, height/2 - spacing*2);
            [southLabel setFrame:textRect];
        }

//        NSLog(@"Label rect: %@", NSStringFromRect(textRect));
    }

    // Draw border, used for debugging
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:self.bounds];
//    [textViewSurround setLineWidth:1];
//    [[NSColor cyanColor] set];
//    [textViewSurround stroke];
}

- (void)drawHudLabels {
    CGFloat offsetX = NSMinX(self.bounds);
    CGFloat offsetY = NSMinY(self.bounds);
    CGFloat width = NSWidth(self.bounds);
    CGFloat height = NSHeight(self.bounds);
    
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSRect textRect;
        
        if (direction == NORTH) {
            textRect = NSMakeRect(offsetX, offsetY + height/2,
                                  width, height/2);
            [northLabel setFrame:textRect];
        } else if (direction == EAST) {
            textRect = NSMakeRect(offsetX + width/2, 0,
                                  width/2, offsetY*2 + height);
            [eastLabel setFrame:textRect];
        } else if (direction == WEST) {
            textRect = NSMakeRect(offsetX, 0,
                                  width/2, offsetY*2 + height);
            [westLabel setFrame:textRect];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(offsetX, offsetY,
                                  width, height/2);
            [southLabel setFrame:textRect];
        }
        
        //        NSLog(@"Label rect: %@", NSStringFromRect(textRect));
    }
    
    // Draw border, used for debugging
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:self.bounds];
//    [textViewSurround setLineWidth:1];
//    [[NSColor cyanColor] set];
//    [textViewSurround stroke];
}

#pragma mark - Events

- (void)mouseUp:(NSEvent *)theEvent {
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self setNeedsDisplay:YES];
}

@end
