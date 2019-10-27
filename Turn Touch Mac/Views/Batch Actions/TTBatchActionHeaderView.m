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

@interface TTBatchActionHeaderView ()

@property (nonatomic, strong) NSDictionary *titleAttributes;
@property (nonatomic, strong) NSImage *modeImage;
@property (nonatomic, strong) TTDiamondView *diamondView;
@property (nonatomic, strong) TTChangeButtonView *deleteButton;
@property (nonatomic, strong) TTChangeButtonView *actionButton;
@property (nonatomic) BOOL isMenuVisible;
@property (nonatomic, strong) NSMenu *settingsMenu;
@property (nonatomic) BOOL isChangeActionVisible;

@end

@implementation TTBatchActionHeaderView

- (instancetype)initWithTempMode:(TTMode *)_mode {
    if (self = [super init]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.batchAction = nil;
        self.mode = _mode;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.isChangeActionVisible = NO;
        
        [self setupLabels];
        [self buildSettingsMenu:YES];
        [self registerAsObserver];
    }
    
    return self;
}

- (instancetype)initWithBatchAction:(TTAction *)_batchAction {
    if (self = [super init]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.batchAction = _batchAction;
        self.mode = self.batchAction.mode;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.isChangeActionVisible = NO;
        
        [self setupLabels];
        [self buildSettingsMenu:YES];
        [self registerAsObserver];
    }
    
    return self;
}

#pragma mark - KVO

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"batchActionChangeAction"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if (self.isChangeActionVisible && self.appDelegate.modeMap.batchActionChangeAction != self.batchAction) {
        self.isChangeActionVisible = NO;
        [self.appDelegate.panelController.backgroundView toggleBatchActionsChangeActionMenu:self.batchAction visible:NO];
    }
}

- (void)dealloc {
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"batchActionChangeAction"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Background
    [NSColorFromRGB(0xFCFCFC) set];
    NSRectFill(self.bounds);
    
    // Mode image
    NSString *imageFilename = [[self.mode class] imageName];
    self.modeImage = [NSImage imageNamed:imageFilename];
    
    [self.modeImage setSize:NSMakeSize(22, 22)];
    CGFloat offset = (NSHeight(self.frame)/2) - (self.modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(BATCH_ACTION_HEADER_MARGIN, offset);
    NSRect imageRect = NSMakeRect(imagePoint.x, imagePoint.y,
                                  self.modeImage.size.width, self.modeImage.size.height);
    [self.modeImage drawInRect:imageRect];
    
    // Mode name
    NSSize titleSize = [[[self.mode class] title] sizeWithAttributes:self.titleAttributes];
    NSPoint titlePoint = NSMakePoint(NSMaxX(imageRect) + BATCH_ACTION_HEADER_MARGIN,
                                     NSHeight(self.frame)/2 - floor(titleSize.height/2) + 1);
    
    [[[self.mode class] title] drawAtPoint:titlePoint withAttributes:self.titleAttributes];

    if (!self.batchAction) return;
    
    // Action diamond
    NSSize diamondSize = NSMakeSize(18 * 1.3, 18);
    NSPoint diamondPoint = NSMakePoint(NSMinX(self.frame) + BATCH_ACTION_HEADER_MARGIN + 116,
                                       NSMaxY(self.bounds)/2 - floor(diamondSize.height)/2);
    [self.diamondView setFrame:NSMakeRect(diamondPoint.x, diamondPoint.y, diamondSize.width, diamondSize.height)];

    // Action title
    NSString *actionName = [self.mode titleForAction:self.batchAction.actionName buttonMoment:BUTTON_MOMENT_PRESSUP];
    NSSize actionSize = [actionName sizeWithAttributes:self.titleAttributes];
    NSPoint actionPoint = NSMakePoint(NSMaxX(self.diamondView.frame) + 8,
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
    [actionName drawAtPoint:actionPoint withAttributes:self.titleAttributes];

    // Action dropdown button
    [NSGraphicsContext saveGraphicsState];
    if (self.actionButton) {
        [self.actionButton removeFromSuperview];
        self.actionButton = nil;
    }
    self.actionButton = [[TTChangeButtonView alloc] initWithFrame:NSMakeRect(NSMaxX(actionRect) - NSHeight(actionRect)*1.1,
                                                                        NSMinY(actionRect) - .5f,
                                                                        NSHeight(actionRect)*1.1 + 1.f,
                                                                        NSHeight(actionRect) + 1.f)];
    
    NSImage *chevron = [NSImage imageNamed:@"button_chevron"];
    if (self.isChangeActionVisible) {
        chevron = [NSImage imageNamed:@"button_chevron_x"];
    }
    [chevron setSize:NSMakeSize(13, 13)];
    [self.actionButton setImage:chevron];
    [self.actionButton setImagePosition:NSImageOnly];
    [self.actionButton setTitle:@""];
    [self.actionButton setUseAltStyle:NO];
    [self.actionButton setRightBorderRadius:cornerRadius];
    [self.actionButton setBezelStyle:NSRoundRectBezelStyle];
    [self.actionButton setAction:@selector(showBatchActionMenu:)];
    [self.actionButton setTarget:self];
    [self.actionButton setMenu:self.settingsMenu];
    [self.actionButton setBorderRadius:0.f];
    [self addSubview:self.actionButton];
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
    self.titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
    
    self.diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero];
    [self.diamondView setIgnoreSelectedMode:YES];
    [self.diamondView setIgnoreActiveMode:YES];
    [self.diamondView setOverrideActiveDirection:self.appDelegate.modeMap.inspectingModeDirection];
    [self addSubview:self.diamondView];
}

- (IBAction)deleteBatchAction:(id)sender {
    [self.appDelegate.modeMap removeBatchAction:self.batchAction.batchActionKey];
}

- (IBAction)changeAction:(id)sender {
    if (self.isChangeActionVisible) {
        self.isChangeActionVisible = NO;
    } else {
        self.appDelegate.modeMap.batchActionChangeAction = self.batchAction;
        self.isChangeActionVisible = YES;
    }
    
    [self.appDelegate.panelController.backgroundView toggleBatchActionsChangeActionMenu:self.batchAction visible:self.isChangeActionVisible];
    [self setNeedsDisplay:YES];
}

- (IBAction)showBatchActionMenu:(id)sender {
    if (self.isChangeActionVisible) {
        [self changeAction:sender];
    } else {
        [NSMenu popUpContextMenu:self.settingsMenu
                       withEvent:[NSApp currentEvent]
                         forView:sender];
    }
}

#pragma mark - Settings menu

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !self.isMenuVisible) return;
    
    NSMenuItem *menuItem;
    
    if (!self.settingsMenu) {
        self.settingsMenu = [[NSMenu alloc] initWithTitle:@"Action Menu"];
        [self.settingsMenu setDelegate:self];
        [self.settingsMenu setAutoenablesItems:NO];
    } else {
        [self.settingsMenu removeAllItems];
    }
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Change" action:@selector(changeAction:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    [self.settingsMenu addItem:[NSMenuItem separatorItem]];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Remove" action:@selector(deleteBatchAction:) keyEquivalent:@""];
    [menuItem setEnabled:YES];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
}

#pragma mark - Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    self.isMenuVisible = YES;
    [self buildSettingsMenu:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    self.isMenuVisible = NO;
}

@end
