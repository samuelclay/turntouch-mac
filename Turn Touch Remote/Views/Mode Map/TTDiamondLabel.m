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
@synthesize isHud;

- (id)initWithFrame:(NSRect)frame inDirection:(TTModeDirection)direction {
    frame = NSInsetRect(frame, 0, -1 * PADDING);

    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        labelDirection = direction;
        diamondMode = appDelegate.modeMap.selectedMode;
        iconView = [[NSImageView alloc] init];
        
        [self addSubview:iconView];
        
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
    
    [self drawLabel];
    [self drawIcon];
    
    // Draw border, used for debugging
//    NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRect:self.bounds];
//    [textViewSurround setLineWidth:1];
//    [[NSColor redColor] set];
//    [textViewSurround stroke];
}

- (void)drawLabel {
    NSString *directionLabel;
    
    directionLabel = [diamondMode titleInDirection:labelDirection buttonMoment:BUTTON_MOMENT_PRESSUP];
    NSSize labelSize = [directionLabel sizeWithAttributes:labelAttributes];
    NSInteger iconOffset = 0;
    if (isHud) {
        iconOffset = MIN(NSWidth(self.bounds), NSHeight(self.bounds))/16;
    }
    [directionLabel drawAtPoint:NSMakePoint(NSWidth(self.bounds)/2 - labelSize.width/2,
                                            NSHeight(self.bounds)/2 - labelSize.height/(140/50.f) - iconOffset)
                 withAttributes:labelAttributes];
}

- (void)drawIcon {
    if (!isHud) return;
    
    NSRect iconFrame = self.bounds;
    iconFrame.origin.y += MIN(NSWidth(self.bounds), NSHeight(self.bounds))/8;
    [iconView setFrame:iconFrame];

    NSString *imageFilename = [diamondMode imageNameInDirection:labelDirection];
    NSString *imagePath = [NSString stringWithFormat:@"%@/actions/%@", [[NSBundle mainBundle] resourcePath], imageFilename];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    NSInteger iconSize = round(MAX(CGRectGetHeight(iconFrame), CGRectGetWidth(iconFrame)) / 10);
    [image setSize:NSMakeSize(iconSize, iconSize)];
    [iconView setImage:image];
    
}

- (void)setMode:(TTMode *)mode {
    diamondMode = mode;
}

- (void)setupLabels {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    BOOL hovering = appDelegate.modeMap.hoverModeDirection == labelDirection;
    BOOL selected = appDelegate.modeMap.inspectingModeDirection == labelDirection;
    NSColor *textColor = (hovering || selected) ? NSColorFromRGB(0x303AA0) : NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    if (!isHud) {
        NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 56);
        NSShadow *stringShadow = [[NSShadow alloc] init];
        stringShadow.shadowColor = [NSColor whiteColor];
        stringShadow.shadowOffset = NSMakeSize(0, -1);
        stringShadow.shadowBlurRadius = 0;
        labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:(interactive ? 13 : fontSize)],
                            NSForegroundColorAttributeName: textColor,
                            NSShadowAttributeName: stringShadow,
                            NSParagraphStyleAttributeName: style
                            };
    } else {
        NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 96);
        labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:(interactive ? 13 : fontSize)],
                            NSForegroundColorAttributeName: textColor,
                            NSParagraphStyleAttributeName: style
                            };
    }
}

@end
