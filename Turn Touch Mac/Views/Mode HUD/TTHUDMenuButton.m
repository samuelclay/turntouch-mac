//
//  TTHUDMenuButton.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTHUDMenuButton.h"
#import <objc/objc-runtime.h>

@implementation TTHUDMenuButton

@synthesize title;
@synthesize image;

- (instancetype)init {
    if (self = [super init]) {
        imageView = [[NSImageView alloc] init];
        
        [self addSubview:imageView];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setTitle:(NSString *)_title {
    title = _title;
    NSColor *textColor = NSColorFromRGB(0xF0F0F0);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSLeftTextAlignment];
    NSDictionary *labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:28],
                                      NSForegroundColorAttributeName: textColor,
                                      NSParagraphStyleAttributeName: style
                                      };
    [title drawInRect:NSInsetRect(self.frame, 40, 40) withAttributes:labelAttributes];
}

- (void)setImage:(NSImage *)_image {
    [imageView setImage:_image];
}

@end
