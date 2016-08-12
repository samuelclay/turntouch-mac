//
//  TTDeviceTitleView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDeviceTitleView.h"

@implementation TTDeviceTitleView

@synthesize device;
@synthesize progress;

- (instancetype)initWithDevice:(TTDevice *)_device {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        device = _device;

        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        latestVersion = [[prefs objectForKey:@"TT:firmware:version"] integerValue];

        changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:[NSString stringWithFormat:@"Upgrade to v%ld", (long)latestVersion]];
        [changeButton setAction:@selector(beginUpgrade:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
        
        progress = [[NSProgressIndicator alloc] init];
        [progress setStyle:NSProgressIndicatorBarStyle];
        [progress setDisplayedWhenStopped:NO];
        [progress setUsesThreadedAnimation:YES];
        [progress setMinValue:0];
        [progress setMaxValue:100];
        [self addSubview:progress];
        
        [self setupTitleAttributes];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self drawBackground];
//    NSLog(@"Drawing %@: %@.", NSStringFromRect(self.frame), device);
    NSImage *remoteIcon = [NSImage imageNamed:@"remote_graphic"];
    
    [remoteIcon setSize:NSMakeSize(32, 32)];
    CGFloat offset = (NSHeight(self.frame)/2) - (remoteIcon.size.height/2);
    NSPoint imagePoint = NSMakePoint(8, offset);
    [remoteIcon drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                      remoteIcon.size.width, remoteIcon.size.height)];
    
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
}

- (void)drawBackground {
    [NSColorFromRGB(0xEFEFE6) set];
    NSRectFill(self.bounds);
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
    NSColor *textColor = NSColorFromRGB(0x404A60);

    titleAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow
                        };
    textSize = [device.nickname sizeWithAttributes:titleAttributes];
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
        buttonText = [NSString stringWithFormat:@"All set with v%d", device.firmwareVersion];
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

@end
