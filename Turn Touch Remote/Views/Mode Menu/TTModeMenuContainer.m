//
//  TTModeMenuContainer.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <ApplicationServices/ApplicationServices.h>
#import <QuartzCore/QuartzCore.h>
#import "TTModeMenuContainer.h"
#import "TTBackgroundView.h"
#import "TTModeMenuItem.h"

@implementation TTModeMenuContainer

@synthesize collectionView;
@synthesize bordersView;

- (id)initWithType:(TTMenuType)_menuType {
    self = [super init];
    if (self) {
        menuType = _menuType;
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        collectionView = [[TTModeMenuCollectionView alloc] init];
        [collectionView setItemPrototype:[TTModeMenuItem new]];
        [self setCollectionContent];

        
        scrollView = [[NSScrollView alloc] init];
        scrollView.borderType = NSNoBorder;
        scrollView.hasVerticalScroller = NO;
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0 constant:0.0]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0 constant:0.0]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:collectionView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0 constant:0.0]];
        [scrollView setDocumentView:collectionView];
        

        [self addConstraint:[NSLayoutConstraint constraintWithItem:scrollView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:scrollView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:scrollView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0]];
        [self addSubview:scrollView];
        
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
        [self addSubview:bordersView];
        
        [self registerAsObserver];
    }
    return self;
}

- (void)dealloc {
    [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"openedModeChangeMenu"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"openedActionChangeMenu"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"openedAddActionChangeMenu"];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedActionChangeMenu"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedAddActionChangeMenu"
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
        [self scrollToInspectingDirection];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        if (appDelegate.modeMap.openedActionChangeMenu) {
            [appDelegate.modeMap setOpenedActionChangeMenu:NO];
        }
        if (appDelegate.modeMap.openedAddActionChangeMenu) {
            [appDelegate.modeMap setOpenedAddActionChangeMenu:NO];
        }
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedActionChangeMenu))]) {
        [self setCollectionContent];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedAddActionChangeMenu))]) {
        [self setCollectionContent];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [bordersView setBorderStyle:menuType];

    if (menuType == ADD_MODE_MENU_TYPE || menuType == ADD_ACTION_MENU_TYPE) {
        if (appDelegate.modeMap.openedAddActionChangeMenu) {
            // Active
            [bordersView setHideBorder:NO];
            [bordersView setHideShadow:NO];
        } else if (appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) {
            // Only mode active (no actions selected)
            [bordersView setHideBorder:YES];
            [bordersView setHideShadow:YES];
        } else {
            // Inspecting action, not active yet
            [bordersView setHideBorder:NO];
            [bordersView setHideShadow:YES];
        }
    } else if (menuType == ACTION_MENU_TYPE &&
        [appDelegate.modeMap.selectedMode hideActionMenu] &&
        appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) {
        [bordersView setHideShadow:NO];
        [bordersView setHideBorder:YES];
    } else {
        [bordersView setHideShadow:NO];
        [bordersView setHideBorder:NO];
    }
    [bordersView setNeedsDisplay:YES];
    [collectionView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    if (menuType == MODE_MENU_TYPE) {
        [[collectionView animator] setAlphaValue:appDelegate.modeMap.openedModeChangeMenu ? 1.0 : 0];
    } else if (menuType == ACTION_MENU_TYPE) {
        [[collectionView animator] setAlphaValue:appDelegate.modeMap.openedActionChangeMenu ? 1.0 : 0];
    } else if (menuType == ADD_MODE_MENU_TYPE || menuType == ADD_ACTION_MENU_TYPE) {
        [[collectionView animator] setAlphaValue:appDelegate.modeMap.openedAddActionChangeMenu ? 1.0 : 0];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)drawBorder {
    if ([appDelegate.modeMap.selectedMode hideActionMenu] &&
        !appDelegate.modeMap.inspectingModeDirection) {
        return;
    }
    
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

- (void)toggleScrollbar:(BOOL)visible {
    scrollView.hasVerticalScroller = visible;
    [scrollView setNeedsDisplay:YES];
}

- (void)setCollectionContent {
    NSArray *content;
    if (menuType == MODE_MENU_TYPE) {
        content = appDelegate.modeMap.availableModes;
    } else if (menuType == ACTION_MENU_TYPE) {
        content = appDelegate.modeMap.availableActions;
    } else if (menuType == ADD_MODE_MENU_TYPE) {
        content = appDelegate.modeMap.availableAddModes;
    } else if (menuType == ADD_ACTION_MENU_TYPE) {
        content = appDelegate.modeMap.availableAddActions;
    }
    
    [collectionView setContent:content withMenuType:menuType];
}

- (void)scrollToInspectingDirection {
    if (appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) return;
    
    NSInteger index = 0;
    if (menuType == MODE_MENU_TYPE) {
        NSString *modeName = NSStringFromClass([appDelegate.modeMap.selectedMode class]);
        index = [collectionView.content indexOfObject:modeName];
    } else if (menuType == ACTION_MENU_TYPE) {
        NSString *actionName = [appDelegate.modeMap.selectedMode
                                actionNameInDirection:appDelegate.modeMap.inspectingModeDirection];
        index = [collectionView.content indexOfObject:actionName];
    }

    if (index >= 0) {
        CGRect rect = [collectionView frameForItemAtIndex:index];
        [self scrollToPosition:rect.origin.y];
    }
    
}

- (void)scrollToPosition:(float)yCoord {
    NSClipView* clipView = [scrollView contentView];
    
    if (yCoord < clipView.bounds.origin.y + (clipView.bounds.size.height - 2) &&
        yCoord > clipView.bounds.origin.y) return;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.35];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.y = yCoord - 2;
    [[clipView animator] setBoundsOrigin:newOrigin];
    [scrollView reflectScrolledClipView:[scrollView contentView]];
    [NSAnimationContext endGrouping];
}

@end
