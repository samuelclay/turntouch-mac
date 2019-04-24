//
//  TTModeMenuItemView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuContainer.h"
#import "TTModeMenuItemView.h"

#define IMAGE_SIZE 16.0f

@interface TTModeMenuItemView ()

@property (nonatomic) TTMenuType menuType;
@property (nonatomic) NSString *privateModeName;
@property (nonatomic, strong) TTMode *activeMode;
@property (nonatomic, strong) Class modeClass;
@property (nonatomic, strong) NSString *modeTitle;
@property (nonatomic, strong) NSImage *modeImage;
@property (nonatomic, strong) NSDictionary *modeAttributes;
@property (nonatomic) CGSize textSize;

@property (nonatomic) BOOL hoverActive;
@property (nonatomic) BOOL mouseDownActive;

@end

@implementation TTModeMenuItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.hoverActive = NO;
        self.mouseDownActive = NO;
        
        [self registerAsObserver];
        [self createTrackingArea];
    }
    return self;
}

- (NSString *)modeName {
    return self.privateModeName;
}

- (void)setModeName:(NSString *)_modeName {
    self.privateModeName = _modeName;
    self.modeClass = NSClassFromString(self.modeName);
    self.menuType = MODE_MENU_TYPE;
}

- (void)setActionName:(NSString *)_actionName {
    self.privateModeName = _actionName;
    self.activeMode = self.appDelegate.modeMap.selectedMode;
    self.menuType = ACTION_MENU_TYPE;
}

- (void)setAddModeName:(NSDictionary *)_modeName {
    self.privateModeName = [_modeName objectForKey:@"id"];
    self.modeClass = NSClassFromString(self.modeName);
    self.menuType = ADD_MODE_MENU_TYPE;
}

- (void)setAddActionName:(NSDictionary *)_actionName {
    self.privateModeName = [_actionName objectForKey:@"id"];
    self.activeMode = self.appDelegate.modeMap.tempMode;
    self.menuType = ADD_ACTION_MENU_TYPE;
}

- (void)setChangeActionName:(NSDictionary *)_actionName {
    self.privateModeName = [_actionName objectForKey:@"id"];
    self.activeMode = self.appDelegate.modeMap.batchActionChangeAction.mode;
    self.menuType = CHANGE_BATCH_ACTION_MENU_TYPE;
}

- (void)dealloc {
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self setupTitleAttributes];
    [self drawBackground];
    
    if (self.menuType == MODE_MENU_TYPE || self.menuType == ADD_MODE_MENU_TYPE) {
        [self drawMode];
    } else if (self.menuType == ACTION_MENU_TYPE || self.menuType == ADD_ACTION_MENU_TYPE || self.menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
        [self drawAction];
    }
}

- (void)drawMode {
    NSString *imageFilename = [self.modeClass imageName];
    self.modeImage = [NSImage imageNamed:imageFilename];
    [self.modeImage setSize:NSMakeSize(IMAGE_SIZE, IMAGE_SIZE)];
    CGFloat offset = (NSHeight(self.frame)/2) - (self.modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(offset, offset + 1);
    NSRect imageRect = NSMakeRect(imagePoint.x, imagePoint.y,
                                  self.modeImage.size.width, self.modeImage.size.height);
    [self.modeImage drawInRect:imageRect];
    
    NSSize titleSize = [self.modeTitle sizeWithAttributes:self.modeAttributes];
    NSPoint titlePoint = NSMakePoint(NSMaxX(imageRect) + 12,
                                     NSHeight(self.frame)/2 - titleSize.height/2 + 2);
    
    [self.modeTitle drawAtPoint:titlePoint withAttributes:self.modeAttributes];
}

- (void)drawAction {
    NSString *imageFilename = [self.activeMode imageNameForAction:self.modeName];
    self.modeImage = [NSImage imageNamed:imageFilename];

    [self.modeImage setSize:NSMakeSize(IMAGE_SIZE, IMAGE_SIZE)];
    CGFloat offset = (NSHeight(self.frame)/2) - (self.modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(offset, offset + 1);
    NSRect imageRect = NSMakeRect(imagePoint.x, imagePoint.y,
                                  self.modeImage.size.width, self.modeImage.size.height);
    [self.modeImage drawInRect:imageRect];
    
    NSSize titleSize = [self.modeTitle sizeWithAttributes:self.modeAttributes];
    NSPoint titlePoint = NSMakePoint(NSMaxX(imageRect) + 12,
                                     NSHeight(self.frame)/2 - titleSize.height/2 + 2);
    
    [self.modeTitle drawAtPoint:titlePoint withAttributes:self.modeAttributes];
}

- (void)setupTitleAttributes {
    if (self.menuType == MODE_MENU_TYPE || self.menuType == ADD_MODE_MENU_TYPE) {
        self.modeTitle = [[self.modeClass title] uppercaseString];
    } else if (self.menuType == ACTION_MENU_TYPE || self.menuType == ADD_ACTION_MENU_TYPE || self.menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
        self.modeTitle = [[self.activeMode titleForAction:self.modeName buttonMoment:BUTTON_MOMENT_PRESSUP] uppercaseString];
    }

    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = (self.hoverActive && ![self isHighlighted]) ? NSColorFromRGB(0x404A60) :
    [self isHighlighted] ?
    NSColorFromRGB(0x404A60) : NSColorFromRGB(0x808388);
    self.modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    self.textSize = [self.modeTitle sizeWithAttributes:self.modeAttributes];
}

- (BOOL)isHighlighted {
    BOOL highlighted = NO;
    if (self.menuType == ACTION_MENU_TYPE) {
        highlighted = [[self.activeMode actionNameInDirection:self.appDelegate.modeMap.inspectingModeDirection]
                       isEqualToString:self.modeName];
    } else if (self.menuType == MODE_MENU_TYPE) {
        highlighted = [self.appDelegate.modeMap.selectedMode class] == self.modeClass;
    } else if (self.menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
        highlighted = [self.appDelegate.modeMap.batchActionChangeAction.actionName isEqualToString:self.modeName];
    }
    return highlighted;
}

- (void)drawBackground {
    if (![NSGraphicsContext currentContext]) return;
    if ([self isHighlighted]) {
        // #E3EDF6
        [NSColorFromRGB(0xE3EDF6) set];
    } else if (self.mouseDownActive) {
        [NSColorFromRGB(0xF6F6F9) set];
    } else {
        [NSColorFromRGB(0xFBFBFD) set];
    }
    NSRectFill(self.bounds);
}

- (void)updateTrackingAreas {
    [self createTrackingArea];
}

- (void)createTrackingArea {
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }

    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    
    self.hoverActive = YES;
    [self setNeedsDisplay:YES];
    [self.appDelegate.panelController.backgroundView.modeMenu setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    
    self.hoverActive = NO;
    self.mouseDownActive = NO;
    [self setNeedsDisplay:YES];
    [self.appDelegate.panelController.backgroundView.modeMenu setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    self.mouseDownActive = YES;
    [self drawBackground];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (!self.mouseDownActive) {
        [self drawBackground];
        [self setNeedsDisplay:YES];
        return;
    }
    self.mouseDownActive = NO;
    
    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL inside = NSPointInRect(clickPoint, self.bounds);
    if (!inside) {
        [self drawBackground];
        [self setNeedsDisplay:YES];
        return;
    }
    
    if (self.menuType == MODE_MENU_TYPE) {
        [self.appDelegate.modeMap changeDirection:self.appDelegate.modeMap.selectedModeDirection
                                      toMode:self.modeName];
    } else if (self.menuType == ACTION_MENU_TYPE) {
        [self.appDelegate.modeMap changeDirection:self.appDelegate.modeMap.inspectingModeDirection
                                    toAction:self.modeName];
        [self.appDelegate.panelController.backgroundView setNeedsDisplay:YES];
        [self.appDelegate.panelController.backgroundView.modeMenu.collectionView setNeedsDisplay:YES];
        [self.appDelegate.modeMap setInspectingModeDirection:self.appDelegate.modeMap.inspectingModeDirection];
        [self.appDelegate.modeMap setOpenedActionChangeMenu:NO];
    } else if (self.menuType == ADD_MODE_MENU_TYPE) {
        [self.appDelegate.modeMap setTempModeName:self.modeName];
        [self.appDelegate.panelController.backgroundView adjustBatchActionsHeight:YES];
    } else if (self.menuType == ADD_ACTION_MENU_TYPE) {
        [self.appDelegate.modeMap addBatchAction:self.modeName];
        [self.appDelegate.panelController.backgroundView.addActionButtonView hideAddActionMenu:nil];
    } else if (self.menuType == CHANGE_BATCH_ACTION_MENU_TYPE) {
        [self.appDelegate.modeMap changeBatchAction:self.appDelegate.modeMap.batchActionChangeAction.batchActionKey toAction:self.modeName];
        [self.appDelegate.panelController.backgroundView adjustBatchActionsHeight:YES];
    }
}

@end
