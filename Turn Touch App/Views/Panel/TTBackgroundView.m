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
#define TITLE_BAR_HEIGHT 38.0f
#define MODE_TABS_HEIGHT 92.0f
#define MODE_TITLE_HEIGHT 64.0f
#define MODE_MENU_HEIGHT 128.0f
#define DIAMOND_SIZE 100.0f

#pragma mark -

@implementation TTBackgroundView

@synthesize arrowX = _arrowX;
@synthesize titleBarView = _titleBarView;
@synthesize modeTabs = _modeTabs;
@synthesize modeTitle = _modeTitle;
@synthesize modeMenu = _modeMenu;
@synthesize diamondView = _diamondView;
@synthesize diamondLabels = _diamondLabels;
@synthesize optionsView = _optionsView;

#pragma mark -

- (void)awakeFromNib {
    appDelegate = [NSApp delegate];
    
    NSRect modeOptionsFrame = self.frame;
    modeOptionsFrame.size.height = 40;
    modeOptionsFrame.origin.y = NSMinY(self.frame);
    _optionsView = [[TTOptionsView alloc] initWithFrame:modeOptionsFrame];
//    [_optionsView setAutoresizingMask:NSViewMinYMargin];
    [self addSubview:_optionsView];
    
    
    CGFloat centerHeight = DIAMOND_SIZE*2.5;
    // +1 X offset for panel width fudge
    NSRect diamondRect = NSMakeRect(NSWidth(self.frame) / 2 - (DIAMOND_SIZE * 1.3 / 2) + 1,
                                    centerHeight / 2 - DIAMOND_SIZE / 2 + NSHeight(modeOptionsFrame),
                                    DIAMOND_SIZE * 1.3, DIAMOND_SIZE);
    NSRect labelRect = NSMakeRect(0, NSHeight(modeOptionsFrame), NSWidth(self.bounds), centerHeight);
    _diamondLabels = [[TTDiamondLabels alloc] initWithFrame:labelRect diamondRect:diamondRect];
    [_diamondLabels drawLabels];
//    [_diamondLabels setAutoresizingMask:NSViewMinYMargin];
    [self addSubview:_diamondLabels];

    _diamondView = [[TTDiamondView alloc] initWithFrame:labelRect interactive:YES];
    [_diamondView setIgnoreSelectedMode:YES];
    [_diamondView setShowOutline:YES];
    [_diamondView setInteractive:YES];
//    [_diamondView setAutoresizingMask:NSViewMinYMargin];
    [self addSubview:_diamondView];
    
    _modeMenu = [[TTModeMenuContainer alloc] initWithFrame:CGRectZero];
    [_modeMenu setItemPrototype:[TTModeMenuItem new]];
    [_modeMenu setContent:appDelegate.modeMap.availableModes];
    NSRect modeMenuFrame = self.frame;
    modeMenuFrame.origin.y = NSMaxY(labelRect);
    modeMenuFrame.size.height = _modeMenu.frame.size.height;
    [_modeTitle setFrame:modeMenuFrame];
//    [_modeMenu setAutoresizingMask:NSViewMinYMargin];
    [self addSubview:_modeMenu];
    
    NSRect modeTitleFrame = self.frame;
    modeTitleFrame.size.height = MODE_TITLE_HEIGHT;
    modeTitleFrame.origin.y = NSMaxY(modeMenuFrame);
    _modeTitle = [[TTModeTitleView alloc] initWithFrame:modeTitleFrame];
    [self addSubview:_modeTitle];
    NSLog(@"Title frame: %@", NSStringFromRect(_modeTitle.frame));

    NSRect modeTabsFrame = self.frame;
    modeTabsFrame.size.height = MODE_TABS_HEIGHT;
    modeTabsFrame.origin.y = NSMaxY(modeTitleFrame);
    _modeTabs = [[TTModeTabsContainer alloc] initWithFrame:modeTabsFrame];
    [self addSubview:_modeTabs];
    
    NSRect titleBarFrame = self.frame;
    titleBarFrame.size.height = TITLE_BAR_HEIGHT;
    titleBarFrame.origin.y = NSMaxY(modeTabsFrame);
    _titleBarView = [[TTTitleBarView alloc] initWithFrame:titleBarFrame];
    [self addSubview:_titleBarView];
    
    [self registerAsObserver];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"openedModeChangeMenu"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(openedModeChangeMenu))]) {
        [self toggleModeMenuFrame];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    //    NSLog(@"Drawing background: %@", NSStringFromRect(dirtyRect));
    NSRect contentRect = NSInsetRect(self.frame, LINE_THICKNESS, LINE_THICKNESS);
    NSBezierPath *path = [NSBezierPath bezierPath];

    [path moveToPoint:NSMakePoint(_arrowX - ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(_arrowX, NSMaxY(contentRect))];
    [path lineToPoint:NSMakePoint(_arrowX + ARROW_WIDTH / 2, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect) - ARROW_HEIGHT)];
    [path closePath];
    
    [[NSColor colorWithDeviceWhite:1 alpha:FILL_OPACITY] setFill];
    [path fill];
    
    [path setLineWidth:LINE_THICKNESS * 2];
    [[NSColor whiteColor] setStroke];
    [path stroke];
    
}

- (void)toggleModeMenuFrame {
    NSRect windowFrame = appDelegate.panelController.window.frame;
    NSRect menuFrame = _modeMenu.frame;
    if (appDelegate.modeMap.openedModeChangeMenu) {
//        menuFrame.size.height = MODE_MENU_HEIGHT;
        windowFrame.size.height += MODE_MENU_HEIGHT;
        windowFrame.origin.y -= MODE_MENU_HEIGHT;
    } else {
//        menuFrame.size.height = 1;
        windowFrame.size.height -= MODE_MENU_HEIGHT;
        windowFrame.origin.y += MODE_MENU_HEIGHT;
    }
//    [[_modeMenu animator] setFrame:menuFrame];
    
    [[appDelegate.panelController.window animator] setFrame:windowFrame display:YES animate:YES];
}

- (void)resetPosition {
    [appDelegate.modeMap reset];
}

- (void)viewDidMoveToWindow {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

#pragma mark -
#pragma mark Public accessors

- (void)setArrowX:(NSInteger)value {
    _arrowX = value;
    [self setNeedsDisplay:YES];
}

@end
