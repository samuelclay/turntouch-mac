//
//  TTBackgroundView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTPanelController.h"
#import "TTBackgroundView.h"

#define FILL_OPACITY 1.0f
#define STROKE_OPACITY .5f

#define LINE_THICKNESS 1.0f
#define CORNER_RADIUS 8.0f

#define SEARCH_INSET 10.0f
#define TITLE_BAR_HEIGHT 48.0f
#define MODE_MENU_HEIGHT 92.0f
#define DIAMOND_SIZE 100.0f

#pragma mark -

@implementation TTBackgroundView

@synthesize arrowX = _arrowX;
@synthesize titleBarView = _titleBarView;
@synthesize modeMenu = _modeMenu;
@synthesize diamondView = _diamondView;
@synthesize diamondLabels = _diamondLabels;
@synthesize optionsView = _optionsView;

#pragma mark -

- (void)awakeFromNib {
    appDelegate = [NSApp delegate];

    NSRect modeOptionsFrame = self.frame;
    modeOptionsFrame.size.height = 100;
    modeOptionsFrame.origin.y = NSMinY(self.frame);
    _optionsView = [[TTOptionsView alloc] initWithFrame:modeOptionsFrame];
//    _modeOptionsView.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin;
    [self addSubview:_optionsView];
    
    CGFloat centerHeight = DIAMOND_SIZE*2.5;
    // +1 X offset for panel width fudge
    NSRect diamondRect = NSMakeRect(NSWidth(self.frame) / 2 - (DIAMOND_SIZE * 1.3 / 2) + 1,
                                    centerHeight / 2 - DIAMOND_SIZE / 2 + NSHeight(modeOptionsFrame),
                                    DIAMOND_SIZE * 1.3, DIAMOND_SIZE);
    NSRect labelRect = NSMakeRect(0, NSHeight(modeOptionsFrame), NSWidth(self.bounds), centerHeight);
    _diamondLabels = [[TTDiamondLabels alloc] initWithFrame:labelRect diamondRect:diamondRect];
//    _diamondLabels.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin | NSViewMaxXMargin;
    [self addSubview:_diamondLabels];

    _diamondView = [[TTDiamondView alloc] initWithFrame:diamondRect];
    [_diamondView setIgnoreSelectedMode:YES];
    [_diamondView setShowOutline:YES];
    [_diamondView setInteractive:YES];
    [self addSubview:_diamondView];
    
    NSRect modeMenuFrame = self.frame;
    modeMenuFrame.size.height = MODE_MENU_HEIGHT;
    modeMenuFrame.origin.y = NSMaxY(labelRect);
    _modeMenu = [[TTModeMenuContainer alloc] initWithFrame:modeMenuFrame];
    [self addSubview:_modeMenu];
    
    NSRect titleBarFrame = self.frame;
    titleBarFrame.size.height = TITLE_BAR_HEIGHT;
    titleBarFrame.origin.y = NSMaxY(modeMenuFrame);
    _titleBarView = [[TTTitleBarView alloc] initWithFrame:titleBarFrame];
    [self addSubview:_titleBarView];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect contentRect = NSInsetRect(self.frame, LINE_THICKNESS, LINE_THICKNESS);
//    NSLog(@"Drawing background: %@", NSStringFromRect(dirtyRect));
//    [_modeMenu invalidateIntrinsicContentSize];
    NSBezierPath *path = [NSBezierPath bezierPath];

    [path moveToPoint:NSMakePoint(_arrowX - ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(_arrowX, NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(_arrowX + ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path closePath];
    
    [[NSColor colorWithDeviceWhite:1 alpha:FILL_OPACITY] setFill];
    [path fill];

    //
//    NSPoint topRightCorner = NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT);
//    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT - CORNER_RADIUS)
//         controlPoint1:topRightCorner controlPoint2:topRightCorner];
//    
//    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)];
//    
//    NSPoint bottomRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
//    [path curveToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect))
//         controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
//    
//    [path lineToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))];
//    
//    NSPoint bottomLeftCorner = NSMakePoint(NSMinX(contentRect), NSMinY(contentRect));
//    [path curveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)
//         controlPoint1:bottomLeftCorner controlPoint2:bottomLeftCorner];
//    
//    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT - CORNER_RADIUS)];
//    
//    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - ARROW_HEIGHT);
//    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)
//         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
//    
//    [path lineToPoint:NSMakePoint(_arrowX - ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
//
//    [path closePath];
//    
//    [[NSColor colorWithDeviceWhite:1 alpha:FILL_OPACITY] setFill];
//    [path fill];
//    
//    [NSGraphicsContext saveGraphicsState];
//
//    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
//    [clip appendBezierPath:path];
//    [clip addClip];
    
    [path setLineWidth:LINE_THICKNESS * 2];
    [[NSColor whiteColor] setStroke];
    [path stroke];
    
//    [NSGraphicsContext restoreGraphicsState];    
}

- (void)resetPosition {
    [appDelegate.modeMap reset];
}

#pragma mark -
#pragma mark Public accessors

- (void)setArrowX:(NSInteger)value {
    _arrowX = value;
    [self setNeedsDisplay:YES];
}

@end
