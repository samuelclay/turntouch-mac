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

#define CORNER_RADIUS 8.0f
const NSInteger SETTINGS_ICON_SIZE = 16;

@interface TTTitleBarView ()

@property (nonatomic, strong) NSImage *title;
@property (nonatomic, strong) TTSettingsButton *settingsButton;
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
        
        self.settingsButton = [[TTSettingsButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
        [self buildSettingsMenu:YES];
        [self.settingsButton setTarget:self];
        [self.settingsButton setMenu:self.settingsMenu];
        [self addSubview:self.settingsButton];
        
        [self setupTitleAttributes];
        [self registerAsObserver];
    }
    return self;
}

- (void)registerAsObserver {
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"batteryPct"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"lastActionDate"
                                      options:0 context:nil];
    [self.appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"pairedDevicesCount"
                                      options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(batteryPct))]) {
        [self buildSettingsMenu:NO];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(lastActionDate))]) {
        [self buildSettingsMenu:NO];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(pairedDevicesCount))]) {
        [self buildSettingsMenu:NO];
    }
}

- (void)dealloc {
    [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"batteryPct"];
    [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"lastActionDate"];
    [self.appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
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

#pragma mark - Settings menu

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !self.isMenuVisible) return;

    NSMenuItem *menuItem;
    
    if (!self.settingsMenu) {
        self.settingsMenu = [[NSMenu alloc] initWithTitle:@"Menu"];
        [self.settingsMenu setDelegate:self];
        [self.settingsMenu setAutoenablesItems:NO];
    } else {
        [self.settingsMenu removeAllItems];
    }

    TTDeviceList *foundDevices = self.appDelegate.bluetoothMonitor.foundDevices;
    for (TTDevice *device in foundDevices) {
        if (device.peripheral.state == CBPeripheralStateDisconnected) continue;
        if (device.state != TTDeviceStateConnected && device.state != TTDeviceStateConnecting) continue;
        if (device.uuid || device.nickname) {
            menuItem = [[NSMenuItem alloc] initWithTitle:(device.nickname ? device.nickname : device.uuid)
                                                  action:@selector(openDevicesDialog:) keyEquivalent:@""];
            [menuItem setTarget:self];
            [self.settingsMenu addItem:menuItem];
        }

        NSString *batteryLevel = [NSString stringWithFormat:@"Battery Level: %d%%",
                                  (int)device.batteryPct.intValue];
        menuItem = [[NSMenuItem alloc] initWithTitle:batteryLevel action:@selector(openDevicesDialog:) keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [menuItem setTarget:self];
        if (device.isPaired && device.batteryPct.intValue <= 0) {
            [menuItem setTitle:@"Connecting to Remote..."];
            [menuItem setEnabled:NO];
        } else if (!device.isPaired) {
            [menuItem setTitle:@"Pairing with Remote..."];
            [menuItem setEnabled:NO];
        }
        [self.settingsMenu addItem:menuItem];
        
        NSString *timeAgo = [device.lastActionDate timeAgo];
        NSString *lastAction = [NSString stringWithFormat:@"Last Action: %@",
                                timeAgo];
        if (!timeAgo) {
            lastAction = @"Counting is Difficult";
        }
        menuItem = [[NSMenuItem alloc] initWithTitle:lastAction action:nil keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [self.settingsMenu addItem:menuItem];

        [self.settingsMenu addItem:[NSMenuItem separatorItem]];
    }
    if (!foundDevices.count) {
        menuItem = [[NSMenuItem alloc] initWithTitle:@"No Remotes Connected" action:nil keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [self.settingsMenu addItem:menuItem];
        
        [self.settingsMenu addItem:[NSMenuItem separatorItem]];
    }

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Add a New Remote..."
                                          action:@selector(openPairingDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];

    [self.settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                          action:@selector(openSettingsDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Devices"
                                          action:@selector(openDevicesDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"How It Works"
                                          action:@selector(openFTUXDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"About Turn Touch"
                                          action:@selector(openAboutDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];

    [self.settingsMenu addItem:[NSMenuItem separatorItem]];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Submit an Idea..."
                                          action:@selector(openSupportIdea:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Ask a Question..."
                                          action:@selector(openSupportQuestion:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Troubleshoot a Problem..."
                                          action:@selector(openSupportProblem:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Share Photos and Praise..."
                                          action:@selector(openSupportPraise:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    [self.settingsMenu addItem:[NSMenuItem separatorItem]];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Turn Touch Remote"
                                          action:@selector(quit:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    NSImage *image = [NSImage imageNamed:@"settings"];
    [image setSize:NSMakeSize(SETTINGS_ICON_SIZE, SETTINGS_ICON_SIZE)];
    [menuItem setImage:image];
    [self.settingsMenu insertItem:menuItem atIndex:0];
}

#pragma mark - Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    self.isMenuVisible = YES;
    [self buildSettingsMenu:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    self.isMenuVisible = NO;
}

- (void)openDevicesDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_DEVICES];
}

- (void)openPairingDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_PAIRING];
}

- (void)openFTUXDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_FTUX];
}

- (void)openAboutDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_ABOUT];
}

- (void)openSupportDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_SUPPORT];
}

- (void)openSupportIdea:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://forum.turntouch.com/c/ideas"]];
}

- (void)openSupportQuestion:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://forum.turntouch.com/c/questions"]];
}

- (void)openSupportProblem:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://forum.turntouch.com/c/problems"]];
}

- (void)openSupportPraise:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://forum.turntouch.com/c/praise"]];
}

- (void)openSettingsDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_SETTINGS];
}

- (void)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}

@end
