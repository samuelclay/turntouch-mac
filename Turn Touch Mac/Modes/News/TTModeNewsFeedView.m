//
//  TTModeNewsFeedView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 9/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNewsFeedView.h"

@implementation TTModeNewsFeedView
@synthesize feed;

- (id)initWithFeed:(TTNewsBlurFeed *)_feed inFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        self.feed = _feed;
        [self loadFeed];
    }
    
    return self;
}

- (void)loadFeed {
    titleLabel = [[NSTextField alloc] init];
    titleLabel.stringValue = feed.feedTitle;
    titleLabel.bordered = NO;
    titleLabel.backgroundColor = [NSColor clearColor];
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    titleLabel.font = [NSFont fontWithName:@"Helvetica-Bold" size:21.0];
    [titleLabel.cell setBackgroundStyle:NSBackgroundStyleRaised];
    if ([feed.faviconTextColor class] != [NSNull class] && feed.faviconTextColor) {
        BOOL lightText = [feed.faviconTextColor isEqualToString:@"white"];
//        NSColor *fadeColor = [self faviconColor:feed.faviconFade];
//        NSColor *borderColor = [self faviconColor:feed.faviconBorder];
        
        titleLabel.textColor = lightText ? NSColorFromRGB(0xFFFFFF) : NSColorFromRGB(0x000000);
//        titleLabel.shadowColor = lightText ? borderColor : fadeColor;
    } else {
        titleLabel.textColor = NSColorFromRGB(0xFFFFFF);
//        titleLabel.shadowColor = UIColorFromFixedRGB(NEWSBLUR_BLACK_COLOR);
    }
    
    titleImageView = [[NSImageView alloc] init];
    [titleLabel addSubview:titleImageView];
    [self loadFavicon];
    
    [self addSubview:titleLabel];
    [self addSubview:titleImageView];
}

- (void)loadFavicon {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, (unsigned long)NULL), ^{
        NSImage *image = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:feed.faviconUrl]]];
        titleImageView.image = image;
    });
}

- (NSColor *)faviconColor:(NSString *)colorString {
    if ([colorString class] == [NSNull class] || !colorString || !colorString.length) {
        colorString = @"505050";
    }
    unsigned int color = 0;
    NSScanner *scanner = [NSScanner scannerWithString:colorString];
    [scanner scanHexInt:&color];
    
    return NSColorFromRGB(color);
}

- (void)makeGradientView:(CGRect)rect startColor:(NSString *)start endColor:(NSString *)end borderColor:(NSString *)borderColor {
    if ([start class] == [NSNull class] || !start || !start.length) {
        start = @"505050";
    }
    if ([end class] == [NSNull class] || !end || !end.length) {
        end = @"303030";
    }

    NSGradient* gradient = [[NSGradient alloc]
                            initWithStartingColor:[self faviconColor:start]
                            endingColor:[self faviconColor:end]];
    [gradient drawInRect:rect angle:-90];
    
    
    NSBezierPath *border = [NSBezierPath bezierPath];
    [border moveToPoint:NSMakePoint(NSMinX([self bounds]), NSMinY([self bounds]))];
    [border lineToPoint:NSMakePoint(NSMaxX([self bounds]), NSMinY([self bounds]))];
    [border moveToPoint:NSMakePoint(NSMinX([self bounds]), NSMaxY([self bounds]))];
    [border lineToPoint:NSMakePoint(NSMaxX([self bounds]), NSMaxY([self bounds]))];
    [border setLineWidth:1.0];
    [[self faviconColor:borderColor] set];
    [border stroke];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    titleLabel.frame = CGRectMake(NSHeight(self.bounds)+12, 1, NSWidth(self.bounds)-64, NSHeight(self.bounds)-12);
    titleImageView.frame = CGRectMake(12, 6, NSHeight(self.bounds)-12, NSHeight(self.bounds)-12);
    titleImageView.image.size = titleImageView.frame.size;
    [self makeGradientView:self.bounds
                startColor:feed.faviconFade
                  endColor:feed.faviconColor
               borderColor:feed.faviconBorder];
    
}


@end
