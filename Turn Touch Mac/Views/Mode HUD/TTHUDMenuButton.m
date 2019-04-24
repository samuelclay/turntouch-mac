//
//  TTHUDMenuButton.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTHUDMenuButton.h"
#import <objc/objc-runtime.h>

@interface TTHUDMenuButton ()

@end

@implementation TTHUDMenuButton

- (instancetype)init {
    if (self = [super init]) {
        // Shouldn't re-assign this; if this breaks, connect it in the xib.
//        self.imageView = [[NSImageView alloc] init];
//
//        [self addSubview:self.imageView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    NSColor *textColor = NSColorFromRGB(0xF0F0F0);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSLeftTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:28],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style
                                      };
    [self.title drawInRect:NSInsetRect(self.frame, 40, 40) withAttributes:labelAttributes];
}

- (void)setImage:(NSImage *)image {
    [self.imageView setImage:image];
}

@end
