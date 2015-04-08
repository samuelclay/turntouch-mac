//
//  TTTitleBarView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTitleBarView.h"
#import "TTBluetoothMonitor.h"

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
        
        [self makeSettingsMenu];
        [self setupTitleAttributes];
        [self registerAsObserver];
    }
    return self;
}

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"batteryPct"
                                      options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(batteryPct))]) {
        [self setNeedsDisplay:YES];
    }
}

- (void)dealloc {

}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawBackground];
    [self drawLabel];
    [self drawBatteryPct];
    [self drawSettings];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self drawBackground];
    [self drawLabel];
}

- (void)drawLabel {
    NSPoint titlePoint = NSMakePoint(NSMidX(self.bounds)-(title.size.width/2),
                                     NSMidY(self.bounds)-(title.size.height/2));
    [title drawInRect:NSMakeRect(titlePoint.x, titlePoint.y,
                                 title.size.width, title.size.height)];
}

- (void)drawBatteryPct {
    if (!appDelegate.bluetoothMonitor.batteryPct) return;
    NSString *batteryPct = [NSString stringWithFormat:@"%@%%", appDelegate.bluetoothMonitor.batteryPct];
    NSSize batterySize = [batteryPct sizeWithAttributes:batteryAttributes];
    NSPoint batteryPoint = NSMakePoint(NSMinX(self.bounds) + 16,
                                       NSMidY(self.bounds) - batterySize.height/2 + 1);

    [batteryPct drawInRect:NSMakeRect(batteryPoint.x, batteryPoint.y, batterySize.width, batterySize.height)
            withAttributes:batteryAttributes];
}

- (void)drawSettings {
    NSPoint settingsPoint = NSMakePoint(NSMaxX(self.bounds) - SETTINGS_ICON_SIZE*3,
                                        NSMidY(self.bounds) - SETTINGS_ICON_SIZE/2 + 1);
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

- (void)makeSettingsMenu {
    settingsMenu = [[NSMenu alloc] initWithTitle:@"Menu"];
    [settingsMenu setDelegate:self];
    [settingsMenu setAutoenablesItems:YES];
    
    NSMenuItem *menuItemSettings = [[NSMenuItem alloc] initWithTitle:@"Settings..."
                                                              action:@selector(openSettingsDialog:)
                                                       keyEquivalent:@""];
    [menuItemSettings setEnabled:YES];
    [menuItemSettings setTarget:self];
    [settingsMenu addItem:menuItemSettings];
    
    NSMenuItem *menuItemSeparator = [NSMenuItem separatorItem];
    [settingsMenu addItem:menuItemSeparator];
    NSMenuItem *menuItemAbout = [[NSMenuItem alloc] initWithTitle:@"About Turn Touch"
                                                           action:@selector(openAboutDialog:)
                                                    keyEquivalent:@""];
    [menuItemAbout setEnabled:YES];
    [menuItemAbout setTarget:self];
    [settingsMenu addItem:menuItemAbout];
    
    
    NSMenuItem *menuItemQuit = [[NSMenuItem alloc] initWithTitle:@"Quit Turn Touch"
                                                          action:@selector(quit:)
                                                   keyEquivalent:@""];
    [menuItemQuit setEnabled:YES];
    [menuItemQuit setTarget:self];
    [settingsMenu addItem:menuItemQuit];
    
    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    NSImage *image = [NSImage imageNamed:@"settings"];
    [image setSize:NSMakeSize(SETTINGS_ICON_SIZE, SETTINGS_ICON_SIZE)];
    [menuItem setImage:image];
    [settingsMenu insertItem:menuItem atIndex:0];
    
    settingsButton = [[TTSettingsButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
    [settingsButton setTarget:self];
    [settingsButton setMenu:settingsMenu];
    [self addSubview:settingsButton];
}

#pragma mark - Menu Delegate

- (void)openSettingsDialog:(id)sender {
    NSLog(@"Open settings");
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return YES;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    return YES;
}
@end
