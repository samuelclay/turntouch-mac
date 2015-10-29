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
#import "RHPreferences.h"
#import "NSDate+TimeAgo.h"

#define CORNER_RADIUS 8.0f
const NSInteger SETTINGS_ICON_SIZE = 16;

@implementation TTTitleBarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        title = [NSImage imageNamed:@"title"];
        [title setSize:NSMakeSize(100, 12)];
        
        settingsButton = [[TTSettingsButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
        [self buildSettingsMenu:YES];
        [settingsButton setTarget:self];
        [settingsButton setMenu:settingsMenu];
        [self addSubview:settingsButton];
        
        [self setupTitleAttributes];
        [self registerAsObserver];
    }
    return self;
}

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"batteryPct"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"lastActionDate"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
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
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"batteryPct"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"lastActionDate"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"pairedDevicesCount"];
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
    NSPoint titlePoint = NSMakePoint(NSMidX(self.bounds)-(title.size.width/2),
                                     NSMidY(self.bounds)-(title.size.height/2));
    [title drawInRect:NSMakeRect(titlePoint.x, titlePoint.y,
                                 title.size.width, title.size.height)];
}

- (void)drawSettings {
    NSPoint settingsPoint = NSMakePoint(NSMaxX(self.bounds) - SETTINGS_ICON_SIZE*3,
                                        NSMidY(self.bounds) - SETTINGS_ICON_SIZE/2);
    [settingsButton setFrame:NSMakeRect(settingsPoint.x, settingsPoint.y,
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
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}


- (void)setupTitleAttributes {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    batteryAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                          NSForegroundColorAttributeName: textColor,
                          NSShadowAttributeName: stringShadow
                          };
}

#pragma mark - Settings menu

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !isMenuVisible) return;

    NSMenuItem *menuItem;
    
    if (!settingsMenu) {
        settingsMenu = [[NSMenu alloc] initWithTitle:@"Menu"];
        [settingsMenu setDelegate:self];
        [settingsMenu setAutoenablesItems:NO];
    } else {
        [settingsMenu removeAllItems];
    }

    TTDeviceList *foundDevices = appDelegate.bluetoothMonitor.foundDevices;
    for (TTDevice *device in foundDevices) {
        if (device.peripheral.state == CBPeripheralStateDisconnected) continue;
        if (device.state != TTDeviceStateConnected && device.state != TTDeviceStateConnecting) continue;
        if (device.uuid || device.nickname) {
            menuItem = [[NSMenuItem alloc] initWithTitle:(device.nickname ? device.nickname : device.uuid.UUIDString)
                                                  action:@selector(openDevicesDialog:) keyEquivalent:@""];
            [menuItem setTarget:self];
            [settingsMenu addItem:menuItem];
        }

        NSString *batteryLevel = [NSString stringWithFormat:@"Battery level: %d%%",
                                  (int)device.batteryPct.intValue];
        menuItem = [[NSMenuItem alloc] initWithTitle:batteryLevel action:@selector(openDevicesDialog:) keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [menuItem setTarget:self];
        if (device.isPaired && device.batteryPct.intValue <= 0) {
            [menuItem setTitle:@"Connecting to remote..."];
            [menuItem setEnabled:NO];
        } else if (!device.isPaired) {
            [menuItem setTitle:@"Pairing with remote..."];
            [menuItem setEnabled:NO];
        }
        [settingsMenu addItem:menuItem];
        
        NSString *timeAgo = [device.lastActionDate timeAgo];
        NSString *lastAction = [NSString stringWithFormat:@"Last action: %@",
                                timeAgo];
        if (!timeAgo) {
            lastAction = @"Counting is difficult";
        }
        menuItem = [[NSMenuItem alloc] initWithTitle:lastAction action:nil keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [settingsMenu addItem:menuItem];

        [settingsMenu addItem:[NSMenuItem separatorItem]];
    }
    if (!foundDevices.count) {
        menuItem = [[NSMenuItem alloc] initWithTitle:@"No remotes connected" action:nil keyEquivalent:@""];
        [menuItem setEnabled:NO];
        [settingsMenu addItem:menuItem];
        
        [settingsMenu addItem:[NSMenuItem separatorItem]];
    }

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Add a new remote..."
                                          action:@selector(openPairingDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];

    [settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                          action:@selector(openSettingsDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Contact support"
                                          action:@selector(openSupportDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"About Turn Touch"
                                          action:@selector(openAboutDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];

    [settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Quit Turn Touch Remote"
                                          action:@selector(quit:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    NSString *imagePath = [NSString stringWithFormat:@"%@/icons/settings.png", [[NSBundle mainBundle] resourcePath]];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    [image setSize:NSMakeSize(SETTINGS_ICON_SIZE, SETTINGS_ICON_SIZE)];
    [menuItem setImage:image];
    [settingsMenu insertItem:menuItem atIndex:0];
}

#pragma mark - Menu Delegate

- (void)menuWillOpen:(NSMenu *)menu {
    isMenuVisible = YES;
    [self buildSettingsMenu:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    isMenuVisible = NO;
}

- (void)openSettingsDialog:(id)sender {
    [appDelegate showPreferences:@"settings"];
}

- (void)openPairingDialog:(id)sender {
    [appDelegate showPreferences:@"pairing"];
}

- (void)openAboutDialog:(id)sender {
    [appDelegate showPreferences:@"about"];
}

- (void)openSupportDialog:(id)sender {
    [appDelegate showPreferences:@"support"];
}

- (void)openDevicesDialog:(id)sender {
    [appDelegate showPreferences:@"devices"];
}

- (void)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:sender];
}

@end
