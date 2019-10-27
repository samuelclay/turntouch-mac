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

@interface TTDiamondLabels ()

@property (nonatomic) CGSize textSize;

@property (nonatomic, strong) TTDiamondLabel *northLabel;
@property (nonatomic, strong) TTDiamondLabel *eastLabel;
@property (nonatomic, strong) TTDiamondLabel *westLabel;
@property (nonatomic, strong) TTDiamondLabel *southLabel;

@property (nonatomic, strong) TTDiamondView *diamondView;
@property (nonatomic, strong) TTMode *diamondMode;

@end

@implementation TTDiamondLabels

- (id)initWithInteractive:(BOOL)_interactive {
    return [self initWithInteractive:_interactive isHud:NO];
}

- (id)initWithInteractive:(BOOL)_interactive isHud:(BOOL)_isHud {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.interactive = _interactive;
        self.isHud = _isHud;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        if (self.isHud) {
            self.diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero diamondType:DIAMOND_TYPE_HUD];
        } else {
            self.diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero diamondType:DIAMOND_TYPE_INTERACTIVE];
        }
        [self.diamondView setIgnoreSelectedMode:YES];
        [self.diamondView setShowOutline:!self.isHud];
        [self addSubview:self.diamondView];
        
        self.northLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:NORTH];
        [self.northLabel setInteractive:self.interactive];
        [self.northLabel setIsHud:self.isHud];
        [self.northLabel setupLabels];
        [self addSubview:self.northLabel];

        self.eastLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:EAST];
        [self.eastLabel setInteractive:self.interactive];
        [self.eastLabel setIsHud:self.isHud];
        [self.eastLabel setupLabels];
        [self addSubview:self.eastLabel];

        self.westLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:WEST];
        [self.westLabel setInteractive:self.interactive];
        [self.westLabel setIsHud:self.isHud];
        [self.westLabel setupLabels];
        [self addSubview:self.westLabel];

        self.southLabel = [[TTDiamondLabel alloc] initWithFrame:CGRectZero inDirection:SOUTH];
        [self.southLabel setInteractive:self.interactive];
        [self.southLabel setIsHud:self.isHud];
        [self.southLabel setupLabels];
        [self addSubview:self.southLabel];
        
        if (self.interactive) {
            [self registerAsObserver];
        }
    }
    
    return self;
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    
    if (self.interactive) {
        self.diamondRect = NSInsetRect(self.bounds, 24, 24);
    } else {
        self.diamondRect = NSInsetRect(self.bounds, 48, 48);
    }
    [self.diamondView setFrame:self.diamondRect];
}

- (void)setMode:(TTMode *)mode {
    self.diamondMode = mode;
    [self.northLabel setMode:mode];
    [self.eastLabel setMode:mode];
    [self.westLabel setMode:mode];
    [self.southLabel setMode:mode];
}

#pragma mark - KVO

- (void)dealloc {
    if (self.interactive) {
        [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
        [self.appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
        [self.appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    }
}

- (void)registerAsObserver {
    if (self.interactive) {
        [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                                 options:0 context:nil];
        [self.appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                                 options:0 context:nil];
        [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                                 options:0 context:nil];
    }
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if (!self.interactive) return;
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

    if (self.isHud) {
        [self drawHudLabels];
    } else {
        [self drawDiamondLabels];
    }
    if (self.interactive) {
        [self drawBackground];
    }
}



- (void)drawBackground {
    [NSColorFromRGB(0xF5F6F8) set];
    NSRectFill(self.bounds);
}

- (void)drawDiamondLabels {
    CGFloat offsetX = NSMinX(self.diamondRect);
    CGFloat offsetY = NSMinY(self.diamondRect);
    CGFloat width = NSWidth(self.diamondRect);
    CGFloat height = NSHeight(self.diamondRect);
    CGFloat spacing = SPACING_PCT * width;

    for (TTModeDirection direction=1; direction <= 4; direction++) {
        NSRect textRect = self.diamondRect;
        
        if (direction == NORTH) {
            textRect = NSMakeRect(offsetX, offsetY + height/2 + spacing*2,
                                  width, height/2 - spacing*2);
            [self.northLabel setFrame:textRect];
        } else if (direction == EAST) {
            textRect = NSMakeRect(offsetX + width/2 + 1.3*spacing*2, 0,
                                  width/2 - 1.3*spacing*2, offsetY*2 + height);
            [self.eastLabel setFrame:textRect];
        } else if (direction == WEST) {
            textRect = NSMakeRect(offsetX, 0,
                                  width/2 - 1.3*spacing*2, offsetY*2 + height);
            [self.westLabel setFrame:textRect];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(offsetX, offsetY,
                                  width, height/2 - spacing*2);
            [self.southLabel setFrame:textRect];
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
            [self.northLabel setFrame:textRect];
        } else if (direction == EAST) {
            textRect = NSMakeRect(offsetX + width/2, 0,
                                  width/2, offsetY*2 + height);
            [self.eastLabel setFrame:textRect];
        } else if (direction == WEST) {
            textRect = NSMakeRect(offsetX, 0,
                                  width/2, offsetY*2 + height);
            [self.westLabel setFrame:textRect];
        } else if (direction == SOUTH) {
            textRect = NSMakeRect(offsetX, offsetY,
                                  width, height/2);
            [self.southLabel setFrame:textRect];
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
