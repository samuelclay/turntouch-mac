//
//  TTBatchActionHeaderView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTBatchActionHeaderView.h"

#define BATCH_ACTION_HEADER_MARGIN 13.f
#define BATCH_ACTION_HEADER_PADDING 4.f

@implementation TTBatchActionHeaderView

@synthesize mode;
@synthesize batchAction;

- (instancetype)initWithTempMode:(TTMode *)_mode {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        batchAction = nil;
        mode = _mode;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        isChangeActionVisible = NO;
        
        [self setupLabels];
        [self buildSettingsMenu:YES];
        [self registerAsObserver];
    }
    
    return self;
}

- (instancetype)initWithBatchAction:(TTAction *)_batchAction {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        batchAction = _batchAction;
        mode = batchAction.mode;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        isChangeActionVisible = NO;
        
        [self setupLabels];
        [self buildSettingsMenu:YES];
        [self registerAsObserver];
    }
    
    return self;
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"batchActionChangeAction"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if (isChangeActionVisible && appDelegate.modeMap.batchActionChangeAction != batchAction) {
        isChangeActionVisible = NO;
        [appDelegate.panelController.backgroundView toggleBatchActionsChangeActionMenu:batchAction visible:NO];
    }
}

- (void)dealloc {
    [appDelegate.modeMap removeObserver:self forKeyPath:@"batchActionChangeAction"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Background
    [NSColorFromRGB(0xFCFCFC) set];
    NSRectFill(self.bounds);
    
    // Mode image
    NSString *imageFilename = [[mode class] imageName];
    modeImage = [NSImage imageNamed:imageFilename];
    
    [modeImage setSize:NSMakeSize(22, 22)];
    CGFloat offset = (NSHeight(self.frame)/2) - (modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(BATCH_ACTION_HEADER_MARGIN, offset);
    NSRect imageRect = NSMakeRect(imagePoint.x, imagePoint.y,
                                  modeImage.size.width, modeImage.size.height);
    [modeImage drawInRect:imageRect];
    
    // Mode name
    NSSize titleSize = [[[mode class] title] sizeWithAttributes:titleAttributes];
    NSPoint titlePoint = NSMakePoint(NSMaxX(imageRect) + BATCH_ACTION_HEADER_MARGIN,
                                     NSHeight(self.frame)/2 - floor(titleSize.height/2) + 1);
    
    [[[mode class] title] drawAtPoint:titlePoint withAttributes:titleAttributes];

    if (!batchAction) return;
    
    // Action diamond
    NSSize diamondSize = NSMakeSize(18 * 1.3, 18);
    NSPoint diamondPoint = NSMakePoint(NSMinX(self.frame) + BATCH_ACTION_HEADER_MARGIN + 116,
                                       NSMaxY(self.bounds)/2 - floor(diamondSize.height)/2);
    [diamondView setFrame:NSMakeRect(diamondPoint.x, diamondPoint.y, diamondSize.width, diamondSize.height)];

    // Action title
    NSString *actionName = [mode titleForAction:batchAction.actionName buttonMoment:BUTTON_MOMENT_PRESSUP];
    NSSize actionSize = [actionName sizeWithAttributes:titleAttributes];
    NSPoint actionPoint = NSMakePoint(NSMaxX(diamondView.frame) + 8,
                                      NSHeight(self.frame)/2 - floor(actionSize.height/2) + 1);
    
    // Action dropdown
    NSBezierPath *actionPath = [NSBezierPath bezierPath];
    CGFloat xLeft = actionPoint.x - 42;
//    CGFloat xRight = deletePoint.x - BATCH_ACTION_HEADER_MARGIN*2;
    CGFloat xRight = NSMaxX(self.bounds) - BATCH_ACTION_HEADER_MARGIN;
    CGFloat yTop = NSMaxY(self.bounds) - BATCH_ACTION_HEADER_PADDING;
    CGFloat yBottom = NSMinY(self.bounds) + BATCH_ACTION_HEADER_PADDING;
    NSRect actionRect = NSInsetRect(NSMakeRect(xLeft, yBottom, xRight - xLeft, yTop - yBottom), 1, 1);
    CGFloat cornerRadius = NSHeight(actionRect)/2;
    [actionPath appendBezierPathWithRoundedRect:actionRect xRadius:cornerRadius yRadius:cornerRadius];
    [actionPath closePath];
    [NSColorFromRGB(0xC2CBCE) set];
    [actionPath setLineWidth:1];
    [actionPath stroke];
    
    // Fill background
    [NSColorFromRGB(0xFFFFFF) set];
    [actionPath fill];
    
    // Have to draw the action title after the background path is filled
    [actionName drawAtPoint:actionPoint withAttributes:titleAttributes];

    // Action dropdown button
    [NSGraphicsContext saveGraphicsState];
    if (actionButton) {
        [actionButton removeFromSuperview];
        actionButton = nil;
    }
    actionButton = [[TTChangeButtonView alloc] initWithFrame:NSMakeRect(NSMaxX(actionRect) - NSHeight(actionRect)*1.1,
                                                                        NSMinY(actionRect) - .5f,
                                                                        NSHeight(actionRect)*1.1 + 1.f,
                                                                        NSHeight(actionRect) + 1.f)];
    
    NSImage *chevron = [NSImage imageNamed:@"button_chevron"];
    if (isChangeActionVisible) {
        chevron = [NSImage imageNamed:@"button_chevron_x"];
    }
    [chevron setSize:NSMakeSize(13, 13)];
    [actionButton setImage:chevron];
    [actionButton setImagePosition:NSImageOnly];
    [actionButton setTitle:@""];
    [actionButton setUseAltStyle:NO];
    [actionButton setRightBorderRadius:cornerRadius];
    [actionButton setBezelStyle:NSRoundRectBezelStyle];
    [actionButton setAction:@selector(showBatchActionMenu:)];
    [actionButton setTarget:self];
    [actionButton setMenu:settingsMenu];
    [actionButton setBorderRadius:0.f];
    [self addSubview:actionButton];
    [NSGraphicsContext restoreGraphicsState];
    
    // Bottom border
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMinY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMinY(self.bounds))];
    [line setLineWidth:0.5];
    [NSColorFromRGB(0xC2CBCE) set];
    [line stroke];

    [line moveToPoint:NSMakePoint(NSMinX(self.bounds), NSMaxY(self.bounds))];
    [line lineToPoint:NSMakePoint(NSMaxX(self.bounds), NSMaxY(self.bounds))];
    [line stroke];
}

- (void)setupLabels {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
    
    diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero];
    [diamondView setIgnoreSelectedMode:YES];
    [diamondView setIgnoreActiveMode:YES];
    [diamondView setOverrideActiveDirection:appDelegate.modeMap.inspectingModeDirection];
    [self addSubview:diamondView];
}

- (IBAction)deleteBatchAction:(id)sender {
    [appDelegate.modeMap removeBatchAction:batchAction.batchActionKey];
}

- (IBAction)changeAction:(id)sender {
    if (isChangeActionVisible) {
        isChangeActionVisible = NO;
    } else {
        appDelegate.modeMap.batchActionChangeAction = self.batchAction;
        isChangeActionVisible = YES;
    }
    
    [appDelegate.panelController.backgroundView toggleBatchActionsChangeActionMenu:batchAction visible:isChangeActionVisible];
    [self setNeedsDisplay:YES];
}

- (IBAction)showBatchActionMenu:(id)sender {
    if (isChangeActionVisible) {
        [self changeAction:sender];
    } else {
        [NSMenu popUpContextMenu:settingsMenu
                       withEvent:[NSApp currentEvent]
                         forView:sender];
    }
}

#pragma mark - Settings menu

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !isMenuVisible) return;
    
    NSMenuItem *menuItem;
    
    if (!settingsMenu) {
        settingsMenu = [[NSMenu alloc] initWithTitle:@"Action Menu"];
        [settingsMenu setDelegate:self];
        [settingsMenu setAutoenablesItems:NO];
    } else {
        [settingsMenu removeAllItems];
    }
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Change" action:@selector(changeAction:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    [settingsMenu addItem:[NSMenuItem separatorItem]];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Remove" action:@selector(deleteBatchAction:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
}

#pragma mark - Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self buildSettingsMenu:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
}

@end
