//
//  TTHUDView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/4/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeHUDView.h"
#import <CoreImage/CoreImage.h>

@implementation TTModeHUDView

const CGFloat kPaddingPct = .7f;
const NSInteger kImageMargin = 32;
const NSInteger kImageSize = 54;
const NSInteger kImageTextMargin = 12;

@synthesize isTeaser;
@synthesize gradientView;
@synthesize teaserGradientView;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    diamondLabels = [[TTDiamondLabels alloc] initWithInteractive:NO isHud:YES];
    isTeaser = NO;
    teaserGradientView = [[NSImageView alloc] init];
    gradientView = [[NSImageView alloc] init];
    
    [self drawMapBackground];
    [self addSubview:teaserGradientView];
    [self addSubview:gradientView];
    [self addSubview:diamondLabels];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
//    NSRect mapFrame = [self mapFrame];
//    NSLog(@"Draw mode: %d / %@", isTeaser, NSStringFromRect(mapFrame));
    
    [self drawMap];
    [self drawLabelBackgrounds];
    [self drawLabels];
    
    [diamondLabels setNeedsDisplay:YES];
}

- (NSRect)mapFrame:(BOOL)rotated {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    CGFloat widthPadding = (screen.frame.size.width * kPaddingPct) / 2;
    CGFloat width = screen.frame.size.width - widthPadding*2;
    CGFloat height = width;
    CGFloat actionHeight = NSHeight(screen.frame) / 4;
    CGFloat heightPadding = (NSHeight(screen.frame) - height + actionHeight) / 2;
    
    if (rotated) {
        return NSMakeRect(widthPadding + width/1.414/2/2, heightPadding + height/1.414/2/2, width/1.414, height/1.414);
    } else {
        return NSMakeRect(widthPadding, heightPadding, width, height);
    }
}

- (void)drawMapBackground {
    NSRect mapFrame = [self mapFrame:NO];
    [gradientView setFrame:mapFrame];
    [teaserGradientView setFrame:mapFrame];
    NSRect diamondFrame = mapFrame;
    diamondFrame.origin = CGPointZero;
    
    NSBezierPath *diamond = [NSBezierPath bezierPathWithRoundedRect:diamondFrame
                                                            xRadius:48.0
                                                            yRadius:48.0];
    
    NSBezierPath *diamondBorder1 = [NSBezierPath bezierPath];
    [diamondBorder1 moveToPoint:NSMakePoint(0, diamondFrame.size.height/2)];
    [diamondBorder1 lineToPoint:NSMakePoint(diamondFrame.size.width, diamondFrame.size.height/2)];
    [diamondBorder1 setLineWidth:1.f];
    
    NSBezierPath *diamondBorder2 = [NSBezierPath bezierPath];
    [diamondBorder2 moveToPoint:NSMakePoint(diamondFrame.size.width/2, 0)];
    [diamondBorder2 lineToPoint:NSMakePoint(diamondFrame.size.width/2, diamondFrame.size.height)];
    [diamondBorder2 setLineWidth:1.f];
    
    NSAffineTransform *rotation = [NSAffineTransform transform];
    [rotation translateXBy:diamondFrame.size.width/2 yBy:0];
    [rotation rotateByDegrees:45.f];
    [rotation scaleBy:1/1.414f];
    [diamond transformUsingAffineTransform:rotation];
    [diamondBorder1 transformUsingAffineTransform:rotation];
    [diamondBorder2 transformUsingAffineTransform:rotation];
    
    NSColor *diamondColor = NSColorFromRGB(0xF1F1F2);
    NSColor *borderColor = NSColorFromRGB(0x57585F);
    CGFloat alpha = 0.6f;
    NSColor *teaserDiamondColor = NSColorFromRGBAlpha(0xF1F1F2, alpha);
    NSColor *teaserBorderColor = NSColorFromRGBAlpha(0x57585F, alpha);

    NSImage *teaserGradientImage = [[NSImage alloc] initWithSize:mapFrame.size];
    [teaserGradientImage lockFocus];
    [teaserDiamondColor set];
    [diamond fill];
    [teaserBorderColor set];
    [diamondBorder1 stroke];
    [diamondBorder2 stroke];
    [teaserGradientImage unlockFocus];
    [teaserGradientView setImage:teaserGradientImage];

    NSImage *gradientImage = [[NSImage alloc] initWithSize:mapFrame.size];
    [gradientImage lockFocus];
    [diamondColor set];
    [diamond fill];
    [borderColor set];
    [diamondBorder1 stroke];
    [diamondBorder2 stroke];
    [gradientImage unlockFocus];
    [gradientView setImage:gradientImage];
}

- (void)drawLabelBackgrounds {
    for (NSNumber *directionNumber in @[[NSNumber numberWithInteger:NORTH],
                                        [NSNumber numberWithInteger:EAST],
                                        [NSNumber numberWithInteger:WEST],
                                        [NSNumber numberWithInteger:SOUTH]]) {
        TTModeDirection direction = (TTModeDirection)[directionNumber integerValue];
        NSBezierPath *ellipse = [NSBezierPath bezierPathWithRoundedRect:[self labelFrame:direction]
                                                                xRadius:28.0
                                                                yRadius:28.0];
        CGFloat alpha = 0.99f;
        NSColor *labelColor = NSColorFromRGBAlpha(0xF1F1F2, alpha);
        if (titleMode != [appDelegate.modeMap modeInDirection:direction]) {
            alpha = 0.6f;
            labelColor = NSColorFromRGBAlpha(0xF1F1F2, alpha);
        }
        [labelColor setFill];
        [ellipse fill];
    }
}

- (NSRect)labelFrame:(TTModeDirection)direction {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSRect mapFrame = [self mapFrame:NO];
    NSString *directionModeTitle = [[[appDelegate.modeMap modeInDirection:direction] class] title];
    NSSize titleSize = [directionModeTitle sizeWithAttributes:modeAttributes];
    CGFloat width = titleSize.width + kImageSize + kImageMargin*2 + kImageTextMargin;
    CGFloat height = titleSize.height + kImageMargin;
    CGFloat x = 0;
    CGFloat y = 0;
    switch (direction) {
        case NORTH:
            x = (NSWidth(screen.frame) - width)/2;
            y = mapFrame.origin.y + mapFrame.size.height + 8;
            break;
        case EAST:
            x = mapFrame.origin.x + NSWidth(mapFrame) + 24;
            y = mapFrame.origin.y + NSHeight(mapFrame)/2 - height/2;
            break;
        case WEST:
            x = mapFrame.origin.x - width - 24;
            y = mapFrame.origin.y + NSHeight(mapFrame)/2 - height/2;
            break;
        case SOUTH:
            x = (NSWidth(screen.frame) - width)/2;
            y = mapFrame.origin.y - height - 8;
            break;
            
        default:
            break;
    }
    
    return NSMakeRect(x,
                      y,
                      width,
                      height);
}

- (void)drawLabels {
    for (TTMode *directionMode in @[appDelegate.modeMap.northMode,
                                        appDelegate.modeMap.eastMode,
                                        appDelegate.modeMap.westMode,
                                        appDelegate.modeMap.southMode]) {
        TTModeDirection direction = [directionMode modeDirection];
        NSDictionary *attributes = modeAttributes;
        CGFloat imageAlpha = 1.0f;
        if (titleMode != [appDelegate.modeMap modeInDirection:direction]) {
            attributes = inactiveModeAttributes;
            imageAlpha = 0.9f;
        }
        NSRect frame = [self labelFrame:direction];

        // Used to debug label frame
//        NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:frame];
//        [textViewSurround setLineWidth:1];
//        [[NSColor redColor] set];
//        [textViewSurround stroke];
        
        TTMode *directionMode = [appDelegate.modeMap modeInDirection:direction];
        modeImage = [NSImage imageNamed:[[directionMode class] imageName]];
        [modeImage setSize:NSMakeSize(kImageSize, kImageSize)];
                
        CGFloat offset = (NSHeight(frame)/2) - (modeImage.size.height/2);
        NSPoint imagePoint = NSMakePoint(frame.origin.x + kImageMargin, frame.origin.y + offset);
        [modeImage drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                         modeImage.size.width, modeImage.size.height)
                     fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:imageAlpha];
        
        NSString *directionModeTitle = [[directionMode class] title];
        NSSize titleSize = [directionModeTitle sizeWithAttributes:attributes];
//        NSLog(@"Mode HUD: %@ - %@ / %@", directionModeTitle, NSStringFromSize(titleSize), NSStringFromRect(frame));
        NSRect textFrame = frame;
        textFrame.origin.x += modeImage.size.width + kImageMargin + kImageTextMargin;
        textFrame.origin.y += kImageMargin/2 - titleSize.height/2;
        [directionModeTitle drawInRect:textFrame withAttributes:attributes];
    }
}

- (void)drawMap {
    [diamondLabels setMode:titleMode];
    NSRect mapFrame = [self mapFrame:NO];
    [diamondLabels setFrame:mapFrame];
    
    
    // Debug for map frame
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:mapFrame];
//    [textViewSurround setLineWidth:10];
//    [[NSColor redColor] set];
//    [textViewSurround stroke];
}

- (void)setupTitleAttributes {
    [self setupTitleAttributes:appDelegate.modeMap.selectedMode];
}

- (void)setupTitleAttributes:(TTMode *)mode {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 72);
    titleMode = mode;
    modeTitle = [[titleMode class] title];
    NSColor *textColor = NSColorFromRGB(0x57585F);
    CGFloat alpha = 0.99f;

    NSColor *inactiveTextColor = NSColorFromRGBAlpha(0x57585F, alpha);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                       NSForegroundColorAttributeName: textColor
                       };
    inactiveModeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:fontSize],
                               NSForegroundColorAttributeName: inactiveTextColor
                               };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

@end
