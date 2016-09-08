//
//  TTDeviceTitleView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDeviceTitleView.h"
#import "NSDate+TimeAgo.h"

@implementation TTDeviceTitleView

@synthesize device;
@synthesize progress;

- (instancetype)initWithDevice:(TTDevice *)_device {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        device = _device;
        hoverActive = NO;

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        latestVersion = [[prefs objectForKey:@"TT:firmware:version"] integerValue];

        changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:[NSString stringWithFormat:@"Upgrade to v%ld", (long)latestVersion]];
        [changeButton setAction:@selector(beginUpgrade:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
        
        settingsButton = [[TTSettingsButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
        [self buildSettingsMenu:YES];
        [settingsButton setTarget:self];
        [settingsButton setMenu:settingsMenu];
        [self addSubview:settingsButton];
        
        progress = [[NSProgressIndicator alloc] init];
        [progress setStyle:NSProgressIndicatorBarStyle];
        [progress setDisplayedWhenStopped:NO];
        [progress setUsesThreadedAnimation:YES];
        [progress setMinValue:0];
        [progress setMaxValue:100];
        [self addSubview:progress];
        
        [self setupTitleAttributes];
        [self createTrackingArea];
    }
    
    return self;
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

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self drawBackground];
//    NSLog(@"Drawing %@: %@.", NSStringFromRect(self.frame), device);
    
    NSImage *remoteIcon;
    NSPoint imagePoint;
    remoteIcon = [NSImage imageNamed:@"remote_graphic"];
    [remoteIcon setSize:NSMakeSize(28, 28)];
    CGFloat offset = (NSHeight(self.frame)/2) - (remoteIcon.size.height/2);
    imagePoint = NSMakePoint(8, offset);

    if (hoverActive || isMenuVisible) {
        settingsButton.hidden = NO;
        CGFloat offsetY = (NSHeight(self.frame)/2) - (settingsButton.image.size.height/2);
        settingsButton.frame = NSMakeRect(0, offsetY, settingsButton.image.size.width*2.55, settingsButton.image.size.height);
    } else {
        settingsButton.hidden = YES;
        [remoteIcon drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                          remoteIcon.size.width, remoteIcon.size.height)];
    }
    
    NSSize titleSize = [device.nickname sizeWithAttributes:titleAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + remoteIcon.size.width + 12,
                                     (NSHeight(self.frame)/2) - (titleSize.height/2));
    [device.nickname drawAtPoint:titlePoint withAttributes:titleAttributes];
    
    NSString *buttonText = [self updateButtonTitle];
    NSSize buttonSize = [buttonText sizeWithAttributes:@{NSFontNameAttribute: [NSFont fontWithName:@"Effra" size:13]}];
    NSRect buttonFrame = NSMakeRect(NSWidth(self.frame) - buttonSize.width*1.25 - 12,
                                    8,
                                    buttonSize.width*1.25, NSHeight(self.frame) - 8*2);
    changeButton.frame = buttonFrame;
    
    progress.frame = buttonFrame;

    [self setChangeButtonTitle:buttonText];
    
    if (device.isFirmwareOld) {
        changeButton.hidden = NO;
    } else {
        changeButton.hidden = YES;
        NSSize stateSize = [device.stateLabel sizeWithAttributes:stateAttributes];
        NSPoint statePoint = NSMakePoint(NSMaxX(self.frame) - stateSize.width - 22,
                                         (NSHeight(self.frame)/2) - (stateSize.height/2));
        [device.stateLabel drawAtPoint:statePoint withAttributes:stateAttributes];
    }
}

- (void)drawBackground {
//    [NSColorFromRGB(0xAFAFAF) set];
//    NSRectFill(self.bounds);
}

- (void)setChangeButtonTitle:(NSString *)title {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:title attributes:nil];
    [changeButton setAttributedTitle:attributedString];
}

- (void)setupTitleAttributes {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x808AA0);
    if (device.state == TTDeviceStateConnected) {
        textColor = NSColorFromRGB(0x404A60);
    }
    
    titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow
                        };
    textSize = [device.nickname sizeWithAttributes:titleAttributes];
    
    textColor = NSColorFromRGB(0x808AA0);
    stateAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow
                        };
}

- (void)beginUpgrade:(id)sender {
    NSLog(@"Begin upgrade: %@", device);
    
    device.inDFU = YES;
    [changeButton setHidden:YES];
    [progress setIndeterminate:YES];
    [progress startAnimation:nil];
    [appDelegate.panelController.backgroundView.deviceTitlesView performDFU:device];
}

- (NSString *)updateButtonTitle {
    NSString *buttonText;
    if (device.isFirmwareOld) {
        buttonText = [NSString stringWithFormat:@"Upgrade to v%ld", (long)latestVersion];
        [changeButton setUseAltStyle:NO];
        [changeButton setEnabled:YES];
    } else {
        buttonText = [NSString stringWithFormat:@"All set with v%ld", (long)device.firmwareVersion];
        [changeButton setUseAltStyle:YES];
        [changeButton setEnabled:NO];
    }
    return buttonText;
}

- (void)disableUpgrade {
    [changeButton setEnabled:NO];
    if (!self.device.isFirmwareOld) return;
    [changeButton setTitle:@"Waiting..."];
}

- (void)enableUpgrade {
    if (device.isFirmwareOld) {
        [changeButton setEnabled:YES];
    }
    NSString *buttonText = [self updateButtonTitle];
    [changeButton setTitle:buttonText];
}

- (void)startIndeterminateProgress {
    [progress setIndeterminate:NO];
    [progress startAnimation:nil];
    changeButton.hidden = YES;
}

- (void)setProgressPercentage:(CGFloat)percentage {
    [progress setIndeterminate:NO];
    [progress startAnimation:nil];
    [progress setDoubleValue:percentage];
    changeButton.hidden = YES;
}

#pragma mark - Mouse

- (void)mouseEntered:(NSEvent *)theEvent {
    hoverActive = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    
    hoverActive = NO;
    [self setNeedsDisplay:YES];
}


#pragma mark - Settings menu

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !isMenuVisible) return;
    
    NSMenuItem *menuItem;
    
    if (!settingsMenu) {
        settingsMenu = [[NSMenu alloc] initWithTitle:@"Remote Menu"];
        [settingsMenu setDelegate:self];
        [settingsMenu setAutoenablesItems:NO];
    } else {
        [settingsMenu removeAllItems];
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

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Rename this remote"
                                          action:@selector(openSettingsDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    [settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Forget this remote"
                                          action:@selector(forgetDevice:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    NSImage *image = [NSImage imageNamed:@"settings"];
    [image setSize:NSMakeSize(18, 18)];
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
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_DEVICES];
}

- (void)forgetDevice:(id)sender {
    [appDelegate.bluetoothMonitor forgetDevice:device];
}

- (void)openDevicesDialog:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_DEVICES];
}

@end
