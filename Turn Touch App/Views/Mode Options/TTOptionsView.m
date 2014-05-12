//
//  TTModeOptionsView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/26/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTOptionsView.h"
#import "TTOptionsModeTitle.h"
#import "TTOptionsActionTitle.h"

#define MARGIN 0.0f
#define CORNER_RADIUS 8.0f

@implementation TTOptionsView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;

//        modeTitleView = [[TTOptionsModeTitle alloc] initWithFrame:CGRectZero];
//        [actionTitleView setHidden:NO];
//        [self addSubview:modeTitleView];

        actionTitleView = [[TTOptionsActionTitle alloc] initWithFrame:CGRectZero];
        [actionTitleView setHidden:YES];
        [self addSubview:actionTitleView];

        [self drawModeOptions];

        [self registerAsObserver];
    }
    
    return self;
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
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
        [self drawActionOptions];
        [self drawModeOptions];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
        [self drawModeOptions];
    }
}

#pragma mark - Drawing

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];

//    [modeTitleView setFrame:self.frame];
    [actionTitleView setFrame:self.frame];
}

- (void)drawRect:(NSRect)dirtyRect {
    [self drawBackground];
    
    if (appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) {
//        [modeTitleView setHidden:NO];
        [modeOptionsView setHidden:NO];
        [actionTitleView setHidden:YES];
    } else {
//        [modeTitleView setHidden:YES];
        [modeOptionsView setHidden:YES];
        [actionTitleView setHidden:NO];
    }
}

- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], MARGIN, MARGIN);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)];
    
    NSPoint bottomLeftCorner = NSMakePoint(NSMinX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMinY(contentRect))
         controlPoint1:bottomLeftCorner controlPoint2:bottomLeftCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMinY(contentRect))];
    
    NSPoint bottomRightCorner = NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect) + CORNER_RADIUS)
         controlPoint1:bottomRightCorner controlPoint2:bottomRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect))];
    
    [path closePath];
    
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:NSColorFromRGB(0xFFFFFF)
                             endingColor:NSColorFromRGB(0xFFFFFF)];
    [aGradient drawInBezierPath:path angle:-90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [NSGraphicsContext restoreGraphicsState];
    
//    NSBezierPath *line = [NSBezierPath bezierPath];
//    [line moveToPoint:NSMakePoint(NSMinX([path bounds]), NSMaxY([path bounds]))];
//    [line lineToPoint:NSMakePoint(NSMaxX([path bounds]), NSMaxY([path bounds]))];
//    [line setLineWidth:1.0];
//    [NSColorFromRGB(0xD0D0D0) set];
//    [line stroke];
}

#pragma mark - Options views

- (void)drawModeOptions {
    if (appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) return;
    
    NSArray *nibArray = [NSArray array];
    NSString *modeName = NSStringFromClass([appDelegate.modeMap.selectedMode class]);
    [[NSBundle mainBundle] loadNibNamed:modeName owner:self topLevelObjects:&nibArray];
    
    for (id view in self.subviews) {
        if ([view class] == [TTModeOptionsView class]) {
            [view removeFromSuperview];
        }
    }
    
    modeOptionsView = nil;
    for (id view in nibArray) {
        if ([view class] == [TTModeOptionsView class]) {
            modeOptionsView = view;
            break;
        }
    }

    if (!modeOptionsView) {
        NSLog(@" --- Missing mode options view for %@", modeName);
        [appDelegate.panelController.backgroundView adjustOptionsHeight:12];
        return;
    }

    [self addSubview:modeOptionsView];
    modeOptionsView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0.0]];
    
    NSLog(@"Mode options height: %f", modeOptionsView.bounds.size.height);
    [appDelegate.panelController.backgroundView adjustOptionsHeight:modeOptionsView.bounds.size.height];
}

- (void)drawActionOptions {
    [appDelegate.panelController.backgroundView adjustOptionsHeight:48];
}

@end
