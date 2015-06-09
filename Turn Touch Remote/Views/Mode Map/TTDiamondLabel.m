//
//  TTDiamondLabel.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabel.h"

#define PADDING 0

@implementation TTDiamondLabel

@synthesize interactive;

- (id)initWithFrame:(NSRect)frame inDirection:(TTModeDirection)direction {
    frame = NSInsetRect(frame, 0, -1 * PADDING);

    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        labelDirection = direction;
        diamondMode = appDelegate.modeMap.selectedMode;

        [self setupLabels];
        [self registerAsObserver];
    }
    return self;
}

#pragma mark - KVO

- (void)dealloc {
    [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"hoverModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
    [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedMode"];
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"hoverModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        diamondMode = appDelegate.modeMap.selectedMode;
    }
    
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))] ||
        [keyPath isEqual:NSStringFromSelector(@selector(hoverModeDirection))]      ||
        [keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]     ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]   ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setupLabels];
        if (interactive) {
            [self.superview setNeedsDisplay:YES];
        }
    }
}

#pragma mark - Drawing

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
	NSString *directionLabel;

    directionLabel = [diamondMode titleInDirection:labelDirection];
    NSSize labelSize = [directionLabel sizeWithAttributes:labelAttributes];
    [directionLabel drawAtPoint:NSMakePoint(NSWidth(self.bounds)/2 - labelSize.width/2, NSHeight(self.bounds)/2 - labelSize.height/(140/50.f)) withAttributes:labelAttributes];

    // Draw border, used for debugging
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:self.bounds];
//    [textViewSurround setLineWidth:1];
//    [[NSColor redColor] set];
//    [textViewSurround stroke];
}

- (void)setMode:(TTMode *)mode {
    diamondMode = mode;
}

- (void)setupLabels {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 56);
    BOOL hovering = appDelegate.modeMap.hoverModeDirection == labelDirection;
    BOOL selected = appDelegate.modeMap.inspectingModeDirection == labelDirection;
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = (hovering || selected) ? NSColorFromRGB(0x303AA0) : NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:(interactive ? 13 : fontSize)],
                        NSForegroundColorAttributeName: textColor,
                        NSShadowAttributeName: stringShadow,
                        NSParagraphStyleAttributeName: style
                        };
}

@end
