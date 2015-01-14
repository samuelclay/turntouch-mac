//
//  TTOptionsView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/26/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTOptionsDetailViewController.h"
#import "TTOptionsModeTitle.h"
#import "TTOptionsActionTitle.h"

#define MARGIN 0.0f
#define CORNER_RADIUS 8.0f

@implementation TTOptionsView

@synthesize modeOptionsViewController;
@synthesize actionOptionsViewController;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self clearOptionDetailViews];
//        [self drawModeOptions];
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

    if (modeOptionsViewController) {
        [modeOptionsViewController.view removeFromSuperview];
        modeOptionsViewController = nil;
    }
    if (actionOptionsViewController) {
        [actionOptionsViewController.view removeFromSuperview];
        actionOptionsViewController = nil;
    }
    if (actionTitleView) {
        [actionTitleView removeFromSuperview];
        actionTitleView = nil;
    }
}

- (void)drawModeOptions {
    if (appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION) return;
    [self clearOptionDetailViews];

    NSString *modeName = NSStringFromClass([appDelegate.modeMap.selectedMode class]);
    NSString *modeOptionsViewControllerName = [NSString stringWithFormat:@"%@Options", modeName];
    modeOptionsViewController = [[NSClassFromString(modeOptionsViewControllerName) alloc]
                                 initWithNibName:modeOptionsViewControllerName bundle:nil];
//    NSLog(@"Options frame %@ pre: %@", modeOptionsViewControllerName, NSStringFromRect(self.frame));
    
    if (!modeOptionsViewController) {
        NSLog(@" --- Missing mode options view for %@", modeName);
        modeOptionsViewController = (TTOptionsDetailViewController *)[[NSViewController alloc] init];
        [modeOptionsViewController setView:[[TTOptionsDetailView alloc] init]];
        [self addSubview:modeOptionsViewController.view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsViewController.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:CORNER_RADIUS]];
    } else {
        modeOptionsViewController.menuType = MODE_MENU_TYPE;
        [self addSubview:modeOptionsViewController.view];
    }

    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:modeOptionsViewController.view
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0 constant:0]];

    [appDelegate.panelController.backgroundView adjustOptionsHeight:modeOptionsViewController.view];
//    NSLog(@"Options frame %@ post: %@ (%@)", modeOptionsViewControllerName, NSStringFromRect(self.frame), NSStringFromRect(modeOptionsViewController.view.frame));
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
    NSString *actionName = [appDelegate.modeMap.selectedMode
                            actionNameInDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *actionOptionsViewControllerName = [NSString stringWithFormat:@"%@Options", actionName];
    actionOptionsViewController = [[NSClassFromString(actionOptionsViewControllerName) alloc]
                                   initWithNibName:actionOptionsViewControllerName bundle:nil];
    
    
    if (!actionOptionsViewController) {
        NSLog(@" --- Missing action options view for %@", actionName);
        actionOptionsViewController = (TTOptionsDetailViewController *)[[NSViewController alloc] init];
        [actionOptionsViewController setView:[[TTOptionsDetailView alloc] init]];
        [self addSubview:actionOptionsViewController.view];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsViewController.view
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:0
                                                        multiplier:1.0 constant:CORNER_RADIUS]];
    } else {
        actionOptionsViewController.menuType = ACTION_MENU_TYPE;
        [self addSubview:actionOptionsViewController.view];
    }
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsViewController.view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:actionTitleView
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsViewController.view
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:actionTitleView
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:actionOptionsViewController.view
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:actionTitleView
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0 constant:0]];
    [appDelegate.panelController.backgroundView adjustOptionsHeight:actionOptionsViewController.view];
}

@end
