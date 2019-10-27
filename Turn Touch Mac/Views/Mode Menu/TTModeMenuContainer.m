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

@interface TTModeMenuContainer ()

@property (nonatomic) TTMenuType menuType;
@property (nonatomic, strong) NSScrollView *scrollView;

@end

@implementation TTModeMenuContainer

- (id)initWithType:(TTMenuType)_menuType {
    self = [super init];
    if (self) {
        self.menuType = _menuType;
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.collectionView = [[TTModeMenuCollectionView alloc] init];
        [self.collectionView setItemPrototype:[TTModeMenuItem new]];
        [self setCollectionContent];

        
        self.scrollView = [[NSScrollView alloc] init];
        self.scrollView.borderType = NSNoBorder;
        self.scrollView.hasVerticalScroller = NO;
        self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.scrollView
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0 constant:0.0]];
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.scrollView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0 constant:0.0]];
        [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.scrollView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0 constant:0.0]];
        [self.scrollView setDocumentView:self.collectionView];
        

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0]];
        [self addSubview:self.scrollView];
        
        self.bordersView = [[TTModeMenuBordersView alloc] init];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bordersView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bordersView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bordersView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0 constant:0]];
        [self addSubview:self.bordersView];
        
        [self registerAsObserver];
    }
    return self;
}

- (void)dealloc {
    TTModeMap *modeMap = self.appDelegate.modeMap;
    
    [modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
    [modeMap removeObserver:self forKeyPath:@"openedModeChangeMenu"];
    [modeMap removeObserver:self forKeyPath:@"openedActionChangeMenu"];
    [modeMap removeObserver:self forKeyPath:@"openedAddActionChangeMenu"];
    [modeMap removeObserver:self forKeyPath:@"openedChangeActionMenu"];
    [modeMap removeObserver:self forKeyPath:@"availableActions"];
    [modeMap removeObserver:self forKeyPath:@"tempModeName"];
}

#pragma mark - KVO

- (void)registerAsObserver {
    TTModeMap *modeMap = self.appDelegate.modeMap;
    
    [modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
    [modeMap addObserver:self forKeyPath:@"openedActionChangeMenu"
                             options:0 context:nil];
    [modeMap addObserver:self forKeyPath:@"openedAddActionChangeMenu"
                             options:0 context:nil];
    [modeMap addObserver:self forKeyPath:@"openedChangeActionMenu"
                             options:0 context:nil];
    [modeMap addObserver:self forKeyPath:@"availableActions"
                             options:0 context:nil];
    [modeMap addObserver:self forKeyPath:@"tempModeName"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    TTModeMap *modeMap = self.appDelegate.modeMap;
    
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        if (modeMap.inspectingModeDirection != NO_DIRECTION &&
            modeMap.openedModeChangeMenu) {
            [modeMap setOpenedModeChangeMenu:NO];
        }
        
        [self.collectionView setNeedsDisplay:YES];
        [self scrollToInspectingDirection];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        if (modeMap.openedActionChangeMenu) {
            [modeMap setOpenedActionChangeMenu:NO];
        }
        if (modeMap.openedAddActionChangeMenu) {
            [modeMap setOpenedAddActionChangeMenu:NO];
        }
        if (modeMap.openedChangeActionMenu) {
            [modeMap setOpenedChangeActionMenu:NO];
        }
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedActionChangeMenu))]) {
        [self setCollectionContent];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedAddActionChangeMenu))]) {
        [self setCollectionContent];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(openedChangeActionMenu))]) {
        [self setCollectionContent];
        [self scrollToInspectingDirection];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(availableActions))]) {
        [self setCollectionContent];
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(tempModeName))]) {
        [self setCollectionContent];
        [self scrollToInspectingDirection];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self.bordersView setBorderStyle:self.menuType];

    if (self.menuType == ADD_MODE_MENU_TYPE || self.menuType == ADD_ACTION_MENU_TYPE) {
        if (self.appDelegate.modeMap.openedAddActionChangeMenu) {
            // Active
            [self.bordersView setHideBorder:NO];
            [self.bordersView setHideShadow:NO];
        } else if (self.appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) {
            // Only mode active (no actions selected)
            [self.bordersView setHideBorder:YES];
            [self.bordersView setHideShadow:YES];
        } else {
            // Inspecting action, not active yet
            [self.bordersView setHideBorder:NO];
            [self.bordersView setHideShadow:YES];
        }
    } else if (self.menuType == ACTION_MENU_TYPE &&
        [self.appDelegate.modeMap.selectedMode hideActionMenu] &&
        self.appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) {
        [self.bordersView setHideShadow:NO];
        [self.bordersView setHideBorder:YES];
    } else {
        [self.bordersView setHideShadow:NO];
        [self.bordersView setHideBorder:NO];
    }
    [self.bordersView setNeedsDisplay:YES];
    [self.collectionView setNeedsDisplay:YES];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

    if (self.menuType == MODE_MENU_TYPE) {
        [[self.collectionView animator] setAlphaValue:self.appDelegate.modeMap.openedModeChangeMenu ? 1.0 : 0];
    } else if (self.menuType == ACTION_MENU_TYPE) {
        [[self.collectionView animator] setAlphaValue:self.appDelegate.modeMap.openedActionChangeMenu ? 1.0 : 0];
    } else if (self.menuType == ADD_MODE_MENU_TYPE || self.menuType == ADD_ACTION_MENU_TYPE) {
        [[self.collectionView animator] setAlphaValue:self.appDelegate.modeMap.openedAddActionChangeMenu ? 1.0 : 0];
    } else if (self.menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
        [[self.collectionView animator] setAlphaValue:self.appDelegate.modeMap.openedChangeActionMenu ? 1.0 : 0];
    }
    
    [NSAnimationContext endGrouping];
}

- (void)drawBorder {
    if ([self.appDelegate.modeMap.selectedMode hideActionMenu] &&
        !self.appDelegate.modeMap.inspectingModeDirection) {
        return;
    }
    
    // Top border
    BOOL open = self.appDelegate.modeMap.openedModeChangeMenu;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds) + (open ? 0 : 12), NSMinY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds) - (open ? 0 : 12), NSMinY(self.bounds))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xC2CBCE) set];
    [line stroke];
    
    // Bottom border
    if (open) {
        NSBezierPath *line = [NSBezierPath bezierPath];
        [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
        [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
        [line setLineWidth:1.0];
        [NSColorFromRGB(0xC2CBCE) set];
        [line stroke];
    }
}

- (void)toggleScrollbar:(BOOL)visible {
    self.scrollView.hasVerticalScroller = visible;
    [self.scrollView setNeedsDisplay:YES];
}

- (void)setCollectionContent {
    NSArray *content;
    if (self.menuType == ADD_MODE_MENU_TYPE && self.appDelegate.modeMap.tempModeName) {
        self.menuType = ADD_ACTION_MENU_TYPE;
    }
    if (self.menuType == ADD_ACTION_MENU_TYPE && !self.appDelegate.modeMap.tempModeName) {
        self.menuType = ADD_MODE_MENU_TYPE;
    }
    
    if (self.menuType == MODE_MENU_TYPE) {
        content = self.appDelegate.modeMap.availableModes;
    } else if (self.menuType == ACTION_MENU_TYPE) {
        content = self.appDelegate.modeMap.availableActions;
    } else if (self.menuType == ADD_MODE_MENU_TYPE) {
        content = self.appDelegate.modeMap.availableAddModes;
    } else if (self.menuType == ADD_ACTION_MENU_TYPE) {
        content = self.appDelegate.modeMap.availableAddActions;
    } else if (self.menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
        content = self.appDelegate.modeMap.availableAddActions;
    }
    
    [self.collectionView setContent:content withMenuType:self.menuType];
}

- (void)scrollToInspectingDirection {
    if (self.appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) return;
    
    NSInteger index = 0;
    if (self.menuType == MODE_MENU_TYPE) {
        NSString *modeName = NSStringFromClass([self.appDelegate.modeMap.selectedMode class]);
        index = [self.collectionView.content indexOfObject:modeName];
    } else if (self.menuType == ACTION_MENU_TYPE) {
        NSString *actionName = [self.appDelegate.modeMap.selectedMode
                                actionNameInDirection:self.appDelegate.modeMap.inspectingModeDirection];
        index = [self.collectionView.content indexOfObject:actionName];
    } else if (self.menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
        NSArray *batchActions = [self.appDelegate.modeMap selectedModeBatchActions:self.appDelegate.modeMap.inspectingModeDirection];
        for (TTAction *batchAction in batchActions) {
            if ([batchAction.batchActionKey isEqualToString:self.appDelegate.modeMap.batchActionChangeAction.batchActionKey]) {
                NSString *actionName = self.appDelegate.modeMap.batchActionChangeAction.actionName;
                for (NSInteger i=0; i < self.collectionView.content.count; i++) {
                    if ([[[self.collectionView.content objectAtIndex:i] objectForKey:@"id"] isEqualToString:actionName]) {
                        index = i;
                    }
                }
                if (index) break;
            }
        }
    }

    if (index != NSNotFound && index >= 0) {
        CGRect rect = [self.collectionView frameForItemAtIndex:index];
        [self scrollToPosition:rect.origin.y];
    }
    
}

- (void)scrollToPosition:(float)yCoord {
    NSClipView* clipView = [self.scrollView contentView];
    
    if (yCoord < clipView.bounds.origin.y + (clipView.bounds.size.height - 2) &&
        yCoord > clipView.bounds.origin.y) return;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.35];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    NSPoint newOrigin = [clipView bounds].origin;
    newOrigin.y = yCoord - 2;
    [[clipView animator] setBoundsOrigin:newOrigin];
    [self.scrollView reflectScrolledClipView:[self.scrollView contentView]];
    [NSAnimationContext endGrouping];
}

@end
