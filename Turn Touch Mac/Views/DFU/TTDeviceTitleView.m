//
//  TTDeviceTitleView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDeviceTitleView.h"
#import "NSDate+TimeAgo.h"

@interface TTDeviceTitleView ()

@property (nonatomic, strong) NSDictionary *titleAttributes;
@property (nonatomic, strong) NSDictionary *stateAttributes;
@property (nonatomic) CGSize textSize;
@property (nonatomic, strong) TTChangeButtonView *changeButton;
@property (nonatomic) NSInteger latestVersion;
@property (nonatomic) BOOL hoverActive;
@property (nonatomic, strong) NSButton *settingsButton;
@property (nonatomic) BOOL isMenuVisible;
@property (nonatomic, strong) NSMenu *settingsMenu;

@end

@implementation TTDeviceTitleView

- (instancetype)initWithDevice:(TTDevice *)_device {
    if (self = [super init]) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.device = _device;
        self.hoverActive = NO;

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.latestVersion = [[prefs objectForKey:@"TT:firmware:version"] integerValue];

        self.changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:[NSString stringWithFormat:@"Upgrade to v%ld", (long)self.latestVersion]];
        [self.changeButton setAction:@selector(beginUpgrade:)];
        [self.changeButton setTarget:self];
        [self addSubview:self.changeButton];
        
        self.settingsButton = [[TTSettingsButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
        [self buildSettingsMenu:YES];
        [self.settingsButton setTarget:self];
        [self.settingsButton setMenu:self.settingsMenu];
        [self addSubview:self.settingsButton];
        
        self.progress = [[NSProgressIndicator alloc] init];
        [self.progress setStyle:NSProgressIndicatorBarStyle];
        [self.progress setDisplayedWhenStopped:NO];
        [self.progress setUsesThreadedAnimation:YES];
        [self.progress setMinValue:0];
        [self.progress setMaxValue:100];
        [self addSubview:self.progress];
        
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
//    NSLog(@"Drawing %@: %@.", NSStringFromRect(self.frame), self.device);
    
    NSImage *remoteIcon;
    NSPoint imagePoint;
    remoteIcon = [NSImage imageNamed:@"remote_graphic"];
    [remoteIcon setSize:NSMakeSize(28, 28)];
    CGFloat offset = (NSHeight(self.frame)/2) - (remoteIcon.size.height/2);
    imagePoint = NSMakePoint(8, offset);

    if (self.hoverActive || self.isMenuVisible) {
        self.settingsButton.hidden = NO;
        CGFloat offsetY = (NSHeight(self.frame)/2) - (self.settingsButton.image.size.height/2);
        self.settingsButton.frame = NSMakeRect(0, offsetY, self.settingsButton.image.size.width*2.55, self.settingsButton.image.size.height);
    } else {
        self.settingsButton.hidden = YES;
        [remoteIcon drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                          remoteIcon.size.width, remoteIcon.size.height)];
    }
    
    NSSize titleSize = [self.device.nickname sizeWithAttributes:self.titleAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + remoteIcon.size.width + 12,
                                     (NSHeight(self.frame)/2) - (titleSize.height/2));
    [self.device.nickname drawAtPoint:titlePoint withAttributes:self.titleAttributes];
    
    NSString *buttonText = [self updateButtonTitle];
    NSSize buttonSize = [buttonText sizeWithAttributes:@{NSFontNameAttribute: [NSFont fontWithName:@"Effra" size:13]}];
    NSRect buttonFrame = NSMakeRect(NSWidth(self.frame) - buttonSize.width*1.25 - 12,
                                    8,
                                    buttonSize.width*1.25, NSHeight(self.frame) - 8*2);
    self.changeButton.frame = buttonFrame;
    
    self.progress.frame = buttonFrame;

    [self setChangeButtonTitle:buttonText];
    
    if (self.device.isFirmwareOld && !self.device.inDFU) {
        self.changeButton.hidden = NO;
    } else if (self.device.inDFU) {
        self.changeButton.hidden = YES;
    } else {
        NSSize stateSize = [self.device.stateLabel sizeWithAttributes:self.stateAttributes];
        NSPoint statePoint = NSMakePoint(NSMaxX(self.frame) - stateSize.width - 22,
                                         (NSHeight(self.frame)/2) - (stateSize.height/2));
        [self.device.stateLabel drawAtPoint:statePoint withAttributes:self.stateAttributes];
    }
    
    if (self.device.state == TTDeviceStateConnected) {
        self.alphaValue = 1.0;
    } else {
        self.alphaValue = 0.6f;
    }
}

- (void)drawBackground {
//    [NSColorFromRGB(0xAFAFAF) set];
//    NSRectFill(self.bounds);
}

- (void)setChangeButtonTitle:(NSString *)title {
    if (!title) return;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:title attributes:nil];
    [self.changeButton setAttributedTitle:attributedString];
}

- (void)setupTitleAttributes {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x808AA0);
    if (self.device.state == TTDeviceStateConnected) {
        textColor = NSColorFromRGB(0x404A60);
    }
    
    self.titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow
                        };
    self.textSize = [self.device.nickname sizeWithAttributes:self.titleAttributes];
    
    textColor = NSColorFromRGB(0x808AA0);
    self.stateAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow
                        };
}

- (void)beginUpgrade:(id)sender {
    NSLog(@"Begin upgrade: %@", self.device);
    
    self.device.inDFU = YES;
    [self.progress setIndeterminate:YES];
    [self.progress startAnimation:nil];
    [self.appDelegate.panelController.backgroundView.deviceTitlesView performDFU:self.device];
    self.changeButton.hidden = YES;
}

- (NSString *)updateButtonTitle {
    NSString *buttonText;
    if (self.device.isFirmwareOld) {
        buttonText = [NSString stringWithFormat:@"Upgrade to v%ld", (long)self.latestVersion];
        [self.changeButton setUseAltStyle:NO];
        [self.changeButton setEnabled:YES];
    } else {
//        buttonText = [NSString stringWithFormat:@"All set with v%ld", (long)self.device.firmwareVersion];
//        [self.changeButton setUseAltStyle:YES];
//        [self.changeButton setEnabled:NO];
        self.changeButton.hidden = YES;
    }
    return buttonText;
}

- (void)disableUpgrade {
    [self.changeButton setEnabled:NO];
    if (!self.device.isFirmwareOld) return;
    [self.changeButton setTitle:@"Waiting..."];
}

- (void)enableUpgrade {
    if (self.device.isFirmwareOld) {
        [self.changeButton setEnabled:YES];
    }
    NSString *buttonText = [self updateButtonTitle];
    [self.changeButton setTitle:buttonText];
}

- (void)startIndeterminateProgress {
    [self.progress setIndeterminate:NO];
    [self.progress startAnimation:nil];
    self.changeButton.hidden = YES;
}

- (void)setProgressPercentage:(CGFloat)percentage {
    [self.progress setIndeterminate:NO];
    [self.progress startAnimation:nil];
    [self.progress setDoubleValue:percentage];
    self.changeButton.hidden = YES;
}

#pragma mark - Mouse

- (void)mouseEntered:(NSEvent *)theEvent {
    self.hoverActive = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    
    self.hoverActive = NO;
    [self setNeedsDisplay:YES];
}


#pragma mark - Settings menu

- (void)buildSettingsMenu:(BOOL)force {
    if (!force && !self.isMenuVisible) return;
    
    NSMenuItem *menuItem;
    
    if (!self.settingsMenu) {
        self.settingsMenu = [[NSMenu alloc] initWithTitle:@"Remote Menu"];
        [self.settingsMenu setDelegate:self];
        [self.settingsMenu setAutoenablesItems:NO];
    } else {
        [self.settingsMenu removeAllItems];
    }
    
    NSString *batteryLevel = [NSString stringWithFormat:@"Battery level: %d%%",
                              (int)self.device.batteryPct.intValue];
    menuItem = [[NSMenuItem alloc] initWithTitle:batteryLevel action:@selector(openDevicesDialog:) keyEquivalent:@""];
    [menuItem setEnabled:NO];
    [menuItem setTarget:self];
    if (self.device.isPaired && self.device.batteryPct.intValue <= 0) {
        [menuItem setTitle:@"Connecting to remote..."];
        [menuItem setEnabled:NO];
    } else if (!self.device.isPaired) {
        [menuItem setTitle:@"Pairing with remote..."];
        [menuItem setEnabled:NO];
    }
    [self.settingsMenu addItem:menuItem];
    NSString *timeAgo = [self.device.lastActionDate timeAgo];
    NSString *lastAction = [NSString stringWithFormat:@"Last action: %@",
                            timeAgo];
    if (!timeAgo) {
        lastAction = @"Counting is difficult";
    }
    menuItem = [[NSMenuItem alloc] initWithTitle:lastAction action:nil keyEquivalent:@""];
    [menuItem setEnabled:NO];
    [self.settingsMenu addItem:menuItem];

    [self.settingsMenu addItem:[NSMenuItem separatorItem]];

    menuItem = [[NSMenuItem alloc] initWithTitle:@"Rename this remote"
                                          action:@selector(openDevicesDialog:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    [self.settingsMenu addItem:[NSMenuItem separatorItem]];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"Forget this remote"
                                          action:@selector(forgetDevice:)
                                   keyEquivalent:@""];
    [menuItem setTarget:self];
    [self.settingsMenu addItem:menuItem];
    
    menuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    NSImage *image = [NSImage imageNamed:@"settings"];
    [image setSize:NSMakeSize(18, 18)];
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

- (void)openSettingsDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_SETTINGS];
}

- (void)forgetDevice:(id)sender {
    [self.appDelegate.bluetoothMonitor forgetDevice:self.device];
}

- (void)openDevicesDialog:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_DEVICES];
}

@end
