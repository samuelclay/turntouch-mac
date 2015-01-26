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
@synthesize interactive;

- (id)initWithInteractive:(BOOL)_interactive {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        interactive = _interactive;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero interactive:YES];
        [diamondView setIgnoreSelectedMode:YES];
        [diamondView setShowOutline:YES];
        [self addSubview:diamondView];
        
        northLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:NORTH];
        [northLabel setInteractive:interactive];
        [self addSubview:northLabel];
        eastLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:EAST];
        [eastLabel setInteractive:interactive];
        [self addSubview:eastLabel];
        westLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:WEST];
        [westLabel setInteractive:interactive];
        [self addSubview:westLabel];
        southLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:SOUTH];
        [southLabel setInteractive:interactive];
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
        [self drawBackground];
    }
    
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
        [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedMode"];
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
        [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
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
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
//    NSLog(@"Drawing labels: %@", NSStringFromRect(dirtyRect));
	[super drawRect:dirtyRect];

    [self drawLabels];
    if (interactive) {
        [self drawBackground];
    }
}



- (void)drawBackground {
    [NSColorFromRGB(0xF5F6F8) set];
    NSRectFill(self.bounds);
}

- (void)drawLabels {
    CGFloat offsetX = NSMinX(diamondRect);
    CGFloat offsetY = NSMinY(diamondRect);
    CGFloat width = NSWidth(diamondRect);
    CGFloat height = NSHeight(diamondRect);
    CGFloat spacing = SPACING_PCT * width;
    
    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSRect textRect = diamondRect;
        
        if (direction == NORTH) {
            textRect = NSMakeRect(offsetX, height * 3/4 + spacing + offsetY/2,
                                  width, offsetY);
            [northLabel setFrame:textRect];
        } else if (direction == EAST) {
            textRect = NSMakeRect(offsetX + width/2 + spacing*2, height/2 + offsetY/2,
                                  width/2 - spacing*2, offsetY);
            [eastLabel setFrame:textRect];
        } else if (direction == WEST) {
            textRect = NSMakeRect(offsetX, height/2 + offsetY/2,
                                  width/2 - spacing*2, offsetY);
            [westLabel setFrame:textRect];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(offsetX, height * 1/4 - spacing + offsetY/2,
                                  width, offsetY);
            [southLabel setFrame:textRect];
        }
//        NSLog(@"Label rect: %@", NSStringFromRect(textRect));
    }
}

#pragma mark - Events

- (void)mouseUp:(NSEvent *)theEvent {
    
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self setNeedsDisplay:YES];
}

@end
