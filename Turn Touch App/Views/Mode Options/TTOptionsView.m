//
//  TTOptionsView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/26/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTOptionsView.h"
#import "TTOptionsModeTitle.h"
#import "TTOptionsActionTitle.h"

#define MARGIN 0.0f
#define CORNER_RADIUS 8.0f

@implementation TTOptionsView

@synthesize modeOptionsView;
@synthesize actionOptionsView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self clearOptionDetailViews];
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
        [self redrawOptions];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self drawModeOptions];
    }
}

#pragma mark - Drawing

- (void)redrawOptions {
    if (appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) {
        [self drawActionOptions];
    } else {
        [self drawModeOptions];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [self drawBackground];
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

- (void)clearOptionDetailViews {
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([[constraint.firstItem class] isSubclassOfClass:[TTOptionsDetailView class]]) {
            [self removeConstraint:constraint];
        }
    }

    if (modeOptionsView) {
        [modeOptionsView removeFromSuperview];
        modeOptionsView = nil;
    }
    if (actionOptionsView) {
        [actionOptionsView removeFromSuperview];
        actionOptionsView = nil;
    }
    if (actionTitleView) {
        [actionTitleView removeFromSuperview];
        actionTitleView = nil;
    }
}

- (void)drawModeOptions {
    if (appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) return;

    [self clearOptionDetailViews];

    NSArray *nibArray = [NSArray array];
    NSString *modeName = NSStringFromClass([appDelegate.modeMap.selectedMode class]);
    [[NSBundle mainBundle] loadNibNamed:modeName owner:self topLevelObjects:&nibArray];
    
    for (id view in nibArray) {
        if ([[view class] isSubclassOfClass:[TTOptionsDetailView class]]) {
            modeOptionsView = view;
            break;
        }
    }

    if (!modeOptionsView) {
        NSLog(@" --- Missing mode options view for %@", modeName);
        modeOptionsView = (TTOptionsDetailView *)[[NSView alloc] init];
        modeOptionsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:modeOptionsView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:CORNER_RADIUS]];
    } else {
        modeOptionsView.menuType = MODE_MENU_TYPE;
        modeOptionsView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:modeOptionsView];
    }
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0 constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsView
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeWidth
//                                                    multiplier:1.0 constant:0]];
    [appDelegate.panelController.backgroundView adjustOptionsHeight:modeOptionsView];

}

- (void)drawActionOptions {
    if (appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) return;

    [self clearOptionDetailViews];

    // Draw action title
    actionTitleView = [[TTOptionsActionTitle alloc] initWithFrame:CGRectZero];
    actionTitleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:actionTitleView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionTitleView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionTitleView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionTitleView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0 constant:48]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionTitleView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0 constant:0]];

    // Draw action options
    if (actionOptionsView) {
        [actionOptionsView removeFromSuperview];
        for (NSLayoutConstraint *constraint in self.constraints) {
            if ([[constraint.firstItem class] isSubclassOfClass:[TTOptionsDetailView class]]) {
                [self removeConstraint:constraint];
            }
        }
        actionOptionsView = nil;
    }
    
    NSArray *nibArray = [NSArray array];
    NSString *actionName = [appDelegate.modeMap.selectedMode
                            actionNameInDirection:appDelegate.modeMap.inspectingModeDirection];
    [[NSBundle mainBundle] loadNibNamed:actionName owner:self topLevelObjects:&nibArray];
    
    for (id view in nibArray) {
        if ([[view class] isSubclassOfClass:[TTOptionsDetailView class]]) {
            actionOptionsView = view;
            break;
        }
    }
    
    if (!actionOptionsView) {
        if (![appDelegate.modeMap.selectedMode.optionlessActions containsObject:actionName]) {
            NSLog(@" --- Missing action options view for %@", actionName);
        }
        [appDelegate.panelController.backgroundView adjustOptionsHeight:actionTitleView];
        return;
    }
    
    actionOptionsView.menuType = ACTION_MENU_TYPE;
    actionOptionsView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:actionOptionsView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:actionTitleView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0 constant:0]];
    //    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsView
    //                                                     attribute:NSLayoutAttributeWidth
    //                                                     relatedBy:NSLayoutRelationEqual
    //                                                        toItem:self
    //                                                     attribute:NSLayoutAttributeWidth
    //                                                    multiplier:1.0 constant:0]];
    [appDelegate.panelController.backgroundView adjustOptionsHeight:actionOptionsView];
}

@end
