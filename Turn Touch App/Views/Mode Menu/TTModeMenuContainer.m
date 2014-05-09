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

- (id)initWithType:(TTMenuType)_menuType {
    self = [super init];
    if (self) {
        menuType = _menuType;
        appDelegate = [NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        collectionView = [[TTModeMenuCollectionView alloc] init];
        [collectionView setItemPrototype:[TTModeMenuItem new]];
        NSArray *content;
        if (menuType == MODE_MENU_TYPE) {
            content = appDelegate.modeMap.availableModes;
        } else if (menuType == ACTION_MENU_TYPE) {
            content = appDelegate.modeMap.availableActions;
        }
        [collectionView setContent:content];

        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:1]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0]];
        [self addSubview:collectionView];
        
        bordersView = [[TTModeMenuBordersView alloc] init];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:bordersView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:bordersView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:bordersView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0]];
        [self addSubview:bordersView positioned:NSWindowAbove relativeTo:collectionView];
        
        [self registerAsObserver];
    }
    return self;
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedActionChangeMenu"
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
        [collectionView setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        if (appDelegate.modeMap.openedActionChangeMenu) {
            [appDelegate.modeMap setOpenedActionChangeMenu:NO];
        }
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedActionChangeMenu))]) {
//        [self setCollectionContent];
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
