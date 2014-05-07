//
//  TTModeMenuContainer.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuContainer.h"
#import "TTBackgroundView.h"
#import "TTModeMenuItem.h"
#import <QuartzCore/QuartzCore.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation TTModeMenuContainer

@synthesize collectionView;
@synthesize bordersView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        collectionView = [[TTModeMenuCollectionView alloc] init];
        [collectionView setItemPrototype:[TTModeMenuItem new]];
        [collectionView setContent:appDelegate.modeMap.availableModes];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:1.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0 constant:-1.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:28]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0]];
        [self addSubview:collectionView];
        
        bordersView = [[TTModeMenuBordersView alloc] init];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:bordersView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:bordersView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0.0]];
        [self addSubview:bordersView];
        
        [self registerAsObserver];
    }
    return self;
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        if (appDelegate.modeMap.inspectingModeDirection != NO_DIRECTION &&
            appDelegate.modeMap.openedModeChangeMenu) {
            [appDelegate.modeMap setOpenedModeChangeMenu:NO];
        }
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [bordersView drawRect:dirtyRect];
    [collectionView drawRect:dirtyRect];
}


- (void)drawBorder {
    // Top border
    BOOL open = appDelegate.modeMap.openedModeChangeMenu;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds) + (open ? 0 : 12), NSMinY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds) - (open ? 0 : 12), NSMinY(self.bounds))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
    
    // Bottom border
    if (open) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
        [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xD0D0D0) set];
        [line stroke];
    }
}

@end
