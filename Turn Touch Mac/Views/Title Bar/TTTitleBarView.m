//
//  TTTitleBarView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTitleBarView.h"
#import "TTBluetoothMonitor.h"
#import "TTDevice.h"
#import "NSDate+TimeAgo.h"
#import "TTSettingsPopoverController.h"

#define CORNER_RADIUS 8.0f
const NSInteger SETTINGS_ICON_SIZE = 16;

@interface TTTitleBarView () <NSPopoverDelegate>

@property (nonatomic, strong) NSImage *title;
@property (nonatomic, strong) NSButton *settingsButton;
@property (nonatomic) NSPopover *settingsPopover;
@property (nonatomic) TTSettingsPopoverController *settingsController;
@property (nonatomic) BOOL isMenuVisible;
@property (nonatomic, strong) NSMenu *settingsMenu;
@property (nonatomic, strong) NSDictionary *batteryAttributes;

@end

@implementation TTTitleBarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.title = [NSImage imageNamed:@"title"];
        [self.title setSize:NSMakeSize(100, 12)];
        
        self.settingsButton = [NSButton buttonWithImage:[NSImage imageNamed:@"settings"] target:self action:@selector(showSettings:)];
        self.settingsButton.bordered = NO;
        self.settingsButton.imageScaling = NSImageScaleProportionallyDown;
        self.settingsButton.accessibilityLabel = @"Settings";
        self.settingsButton.toolTip = @"Settings";
        [self addSubview:self.settingsButton];
        
        [self setupTitleAttributes];

    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawBackground];
    [self drawLabel];
    [self drawSettings];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self setNeedsDisplay:YES];
}

- (void)drawLabel {
    NSPoint titlePoint = NSMakePoint(NSMidX(self.bounds)-(self.title.size.width/2),
                                     NSMidY(self.bounds)-(self.title.size.height/2));
    [self.title drawInRect:NSMakeRect(titlePoint.x, titlePoint.y,
                                 self.title.size.width, self.title.size.height)];
}

- (void)drawSettings {
    NSPoint settingsPoint = NSMakePoint(NSMaxX(self.bounds) - SETTINGS_ICON_SIZE*3,
                                        NSMidY(self.bounds) - SETTINGS_ICON_SIZE/2);
    [self.settingsButton setFrame:NSMakeRect(settingsPoint.x, settingsPoint.y,
                                        SETTINGS_ICON_SIZE*3, SETTINGS_ICON_SIZE)];
}

- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], 0, 0);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)];
    
    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMaxY(contentRect))
         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect))];
    
    NSPoint topRightCorner = NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)
         controlPoint1:topRightCorner controlPoint2:topRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect))];
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect))];
    
    [path closePath];
    
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:[NSColor whiteColor]
                             endingColor:NSColorFromRGB(0xE7E7E7)];
    [aGradient drawInBezierPath:path angle:-90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [NSGraphicsContext restoreGraphicsState];
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX([path bounds]), NSMinY([path bounds]))];
    [line lineToPoint:NSMakePoint(NSMaxX([path bounds]), NSMinY([path bounds]))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xC2CBCE) set];
    [line stroke];
}


- (void)setupTitleAttributes {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    self.batteryAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                          NSForegroundColorAttributeName: textColor,
                          NSShadowAttributeName: stringShadow
                          };
}

#pragma mark - Settings popover

- (void)showSettings:(id)sender {
    if (self.settingsPopover.shown) { [self.settingsPopover close]; return; }
    if (!self.settingsController) self.settingsController = [[TTSettingsPopoverController alloc] init];
    // Rebuild the settings UI each time to reflect current devices and preferences.
    [self.settingsController loadView];
    self.settingsPopover = [[NSPopover alloc] init];
    self.settingsPopover.contentViewController = self.settingsController;
    self.settingsPopover.behavior = NSPopoverBehaviorTransient;
    self.settingsPopover.delegate = self;
    CGFloat height = MIN(600, self.window.screen.visibleFrame.size.height - 100);
    self.settingsPopover.contentSize = NSMakeSize(340, MAX(360, height));
    __weak typeof(self) weakSelf = self;
    self.settingsController.dismissHandler = ^{ [weakSelf.settingsPopover close]; };
    self.appDelegate.panelController.preventClosing = YES;
    [self.settingsPopover showRelativeToRect:self.settingsButton.bounds ofView:self.settingsButton preferredEdge:NSMinYEdge];
}

- (void)popoverDidClose:(NSNotification *)notification {
    self.appDelegate.panelController.preventClosing = NO;
    if (!NSApp.active) self.appDelegate.panelController.hasActivePanel = NO;
}

@end
