//
//  TTModeTab.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeTab.h"

#define DIAMOND_SIZE 22.0f

@implementation TTModeTab

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        modeDirection = direction;
        hoverActive = NO;
        mouseDownActive = NO;
        
        diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero];
        [diamondView setOverrideSelectedDirection:modeDirection];
        [diamondView setIgnoreSelectedMode:YES];
        [self addSubview:diamondView];

        [self setupMode];
        [self registerAsObserver];
        [self createTrackingArea];
    }
    
    return self;
}

- (void)setupMode {
    switch (modeDirection) {
        case NORTH:
            itemMode = appDelegate.modeMap.northMode;
            break;
        case EAST:
            itemMode = appDelegate.modeMap.eastMode;
            break;
        case WEST:
            itemMode = appDelegate.modeMap.westMode;
            break;
        case SOUTH:
            itemMode = appDelegate.modeMap.southMode;
            break;
        case NO_DIRECTION:
            break;
    }
    
    [self setupTitleAttributes];
    [appDelegate.menubarController.statusItemView setNeedsDisplay:YES];
}

- (void)setupTitleAttributes {
    modeTitle = [[[itemMode class] title] uppercaseString];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = (hoverActive && appDelegate.modeMap.selectedModeDirection != modeDirection) ? NSColorFromRGB(0x404A60) :
    appDelegate.modeMap.selectedModeDirection == modeDirection ?
    NSColorFromRGB(0x404A60) : NSColorFromRGB(0x808388);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

#pragma mark - KVO

- (void)registerAsObserver {
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
    if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))] ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        if (appDelegate.modeMap.selectedModeDirection == modeDirection) {
            [diamondView setIgnoreSelectedMode:NO];
            [diamondView setIgnoreActiveMode:NO];
            [self setupMode];
            [self setNeedsDisplay:YES];
        } else {
            [diamondView setIgnoreSelectedMode:YES];
            [diamondView setIgnoreActiveMode:YES];
        }
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setupMode];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
    [self setupTitleAttributes];
    [self drawBackground];
    
    [self drawBorders];
    
    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    NSPoint titlePoint = NSMakePoint((NSWidth(self.frame)/2) - (titleSize.width/2),
                                     18);

    [modeTitle drawAtPoint:titlePoint withAttributes:modeAttributes];
    
    NSRect diamondRect = NSMakeRect((NSWidth(self.frame) / 2) - (DIAMOND_SIZE * 1.3 / 2),
                                    NSHeight(self.frame) - 18 - DIAMOND_SIZE,
                                    DIAMOND_SIZE * 1.3, DIAMOND_SIZE);
    [diamondView setFrame:diamondRect];
}

- (void)updateTrackingAreas {
    [self createTrackingArea];
}

- (void)createTrackingArea {
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawBackground {
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    if (appDelegate.modeMap.selectedModeDirection == modeDirection) {
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    } else if (mouseDownActive) {
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.025);
    } else {
        [[NSColor clearColor] set];
    }
    CGContextFillRect(context, NSRectToCGRect(self.bounds));
}

- (void)drawBorders {
    BOOL active = appDelegate.modeMap.selectedModeDirection == modeDirection;

    if (active) {
        [self drawActiveBorder];
    } else {
        [self drawInactiveBorder];
    }
}

- (void)drawActiveBorder {
    NSBezierPath *line = [NSBezierPath bezierPath];
    
    // Left border
    if (modeDirection != NORTH) {
        [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
        [line lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xD0D0D0) set];
        [line stroke];
    }
    
    // Right border
    if (modeDirection != SOUTH) {
        [line moveToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
        [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xD0D0D0) set];
        [line stroke];
    }
}

- (void)drawInactiveBorder {
    NSBezierPath *line = [NSBezierPath bezierPath];
    TTModeDirection activeDirection = appDelegate.modeMap.selectedModeDirection;

    // Right border
    if ((modeDirection == NORTH && activeDirection == EAST) ||
        (modeDirection == EAST && activeDirection == WEST) ||
        (modeDirection == WEST && activeDirection == SOUTH)) {
        
    } else {
        [line moveToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) + 24)];
        [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 24)];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xD0D0D0) set];
        [line stroke];
    }
    
    // Bottom border
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    
//    NSLog(@"Mouse entered");
    hoverActive = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];

//    NSLog(@"Mouse exited");
    hoverActive = NO;
//    [self setupMode];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    mouseDownActive = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    mouseDownActive = NO;

    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL inside = NSPointInRect(clickPoint, self.bounds);
    if (!inside) {
        [self setNeedsDisplay:YES];
        return;
    }
    
    [appDelegate.panelController.backgroundView resetPosition];
    if (appDelegate.modeMap.selectedModeDirection != modeDirection) {
        [appDelegate.modeMap setSelectedModeDirection:modeDirection];
    }
}

@end
