//
//  TTDFUDeviceView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/5/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDFUDeviceView.h"

#define UPLOAD_BUTTON_WIDTH 64

@implementation TTDFUDeviceView

- (instancetype)initWithDevice:(TTDevice *)_device {
    if (self = [super init]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        device = _device;

        changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:@"upgrade"];
        [changeButton setAction:@selector(beginUpgrade:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];

        [self setupTitleAttributes];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    NSLog(@"Drawing %@: %@.", NSStringFromRect(self.frame), device);
    NSString *imagePath = [NSString stringWithFormat:@"%@/icons/remote_graphic.png", [[NSBundle mainBundle] resourcePath]];
    NSImage *remoteIcon = [[NSImage alloc] initWithContentsOfFile:imagePath];
    
    [remoteIcon setSize:NSMakeSize(32, 32)];
    CGFloat offset = (NSHeight(self.frame)/2) - (remoteIcon.size.height/2);
    NSPoint imagePoint = NSMakePoint(8, offset);
    [remoteIcon drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                      remoteIcon.size.width, remoteIcon.size.height)];
    
    NSSize titleSize = [device.nickname sizeWithAttributes:titleAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + remoteIcon.size.width + 12,
                                     (NSHeight(self.frame)/2) - (titleSize.height/2));
    [device.nickname drawAtPoint:titlePoint withAttributes:titleAttributes];
    
    NSRect buttonFrame = NSMakeRect(NSWidth(self.frame) - UPLOAD_BUTTON_WIDTH - 12,
                                    8,
                                    UPLOAD_BUTTON_WIDTH, NSHeight(self.frame) - 8*2);
    changeButton.frame = buttonFrame;
    [self setChangeButtonTitle:@"upgrade"];
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
}

@end