//
//  TTModeTab.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeTab.h"

#define DIAMOND_SIZE 22.0f

@interface TTModeTab ()

@property (nonatomic) TTModeDirection modeDirection;
@property (nonatomic, strong) TTDiamondView *diamondView;
@property (nonatomic, strong) TTMode *itemMode;

@property (nonatomic, strong) NSString *modeTitle;
@property (nonatomic, strong) NSDictionary *modeAttributes;
@property (nonatomic) CGSize textSize;
@property (nonatomic) BOOL hoverActive;
@property (nonatomic) BOOL mouseDownActive;

@end

@implementation TTModeTab

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.modeDirection = direction;
        self.hoverActive = NO;
        self.mouseDownActive = NO;
        
        self.diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero];
        [self.diamondView setOverrideSelectedDirection:self.modeDirection];
        [self.diamondView setIgnoreSelectedMode:YES];
        [self addSubview:self.diamondView];

        [self setupMode];
        [self registerAsObserver];
        [self createTrackingArea];
    }
    
    return self;
}

- (void)setupMode {
    switch (self.modeDirection) {
        case NORTH:
            self.itemMode = self.appDelegate.modeMap.northMode;
            break;
        case EAST:
            self.itemMode = self.appDelegate.modeMap.eastMode;
            break;
        case WEST:
            self.itemMode = self.appDelegate.modeMap.westMode;
            break;
        case SOUTH:
            self.itemMode = self.appDelegate.modeMap.southMode;
            break;
        case NO_DIRECTION:
        case INFO:
            break;
    }
    
    [self setupTitleAttributes];
    [self.appDelegate.menubarController.statusItemView setNeedsDisplay:YES];
}

- (void)setupTitleAttributes {
    self.modeTitle = [[[self.itemMode class] title] uppercaseString];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = (self.hoverActive && self.appDelegate.modeMap.selectedModeDirection != self.modeDirection) ? NSColorFromRGB(0x404A60) :
    self.appDelegate.modeMap.selectedModeDirection == self.modeDirection ?
    NSColorFromRGB(0x404A60) : NSColorFromRGB(0x808388);
    self.modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    self.textSize = [self.modeTitle sizeWithAttributes:self.modeAttributes];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setupMode];
    }
    if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))] ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        if (self.appDelegate.modeMap.selectedModeDirection == self.modeDirection) {
            [self.diamondView setIgnoreSelectedMode:NO];
            [self.diamondView setIgnoreActiveMode:NO];
        } else {
            [self.diamondView setIgnoreSelectedMode:YES];
            [self.diamondView setIgnoreActiveMode:YES];
        }
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
    
    NSSize titleSize = [self.modeTitle sizeWithAttributes:self.modeAttributes];
    NSPoint titlePoint = NSMakePoint((NSWidth(self.frame)/2) - (titleSize.width/2),
                                     18);

    [self.modeTitle drawAtPoint:titlePoint withAttributes:self.modeAttributes];
    
    NSRect diamondRect = NSMakeRect((NSWidth(self.frame) / 2) - (DIAMOND_SIZE * 1.3 / 2),
                                    NSHeight(self.frame) - 18 - DIAMOND_SIZE,
                                    DIAMOND_SIZE * 1.3, DIAMOND_SIZE);
    [self.diamondView setFrame:diamondRect];
}

- (void)updateTrackingAreas {
    [self createTrackingArea];
}

- (void)createTrackingArea {
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)drawBackground {
    CGContextRef context = (CGContextRef) [[NSGraphicsContext currentContext] graphicsPort];
    if (self.appDelegate.modeMap.selectedModeDirection == self.modeDirection) {
        CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    } else if (self.mouseDownActive) {
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.025);
    } else {
        [[NSColor clearColor] set];
    }
    CGContextFillRect(context, NSRectToCGRect(self.bounds));
}

- (void)drawBorders {
    BOOL active = self.appDelegate.modeMap.selectedModeDirection == self.modeDirection;

    if (active) {
        [self drawActiveBorder];
    } else {
        [self drawInactiveBorder];
    }
}

- (void)drawActiveBorder {
    NSBezierPath *line = [NSBezierPath bezierPath];
    
    // Left border
    if (self.modeDirection != NORTH) {
        [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
        [line lineToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xC2CBCE) set];
        [line stroke];
    }
    
    // Right border
    if (self.modeDirection != SOUTH) {
        [line moveToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
        [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xC2CBCE) set];
        [line stroke];
    }
}

- (void)drawInactiveBorder {
    NSBezierPath *line = [NSBezierPath bezierPath];
    TTModeDirection activeDirection = self.appDelegate.modeMap.selectedModeDirection;

    // Right border
    if ((self.modeDirection == NORTH && activeDirection == EAST) ||
        (self.modeDirection == EAST && activeDirection == WEST) ||
        (self.modeDirection == WEST && activeDirection == SOUTH) ||
        self.modeDirection == SOUTH) {
        
    } else {
        [line moveToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds) + 24)];
        [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds) - 24)];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xC2CBCE) set];
        [line stroke];
    }
    
    // Bottom border
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xC2CBCE) set];
    [line stroke];
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    
//    NSLog(@"Mouse entered");
    self.hoverActive = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];

//    NSLog(@"Mouse exited");
    self.hoverActive = NO;
//    [self setupMode];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    self.mouseDownActive = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    self.mouseDownActive = NO;

    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL inside = NSPointInRect(clickPoint, self.bounds);
    if (!inside) {
        [self setNeedsDisplay:YES];
        return;
    }
    
    [self.appDelegate.panelController.backgroundView resetPosition];
    [self.appDelegate.modeMap switchMode:self.modeDirection modeName:nil];
}

@end
