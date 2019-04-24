//
//  TTDiamondLabel.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTDiamondLabel.h"

#define PADDING 0

@interface TTDiamondLabel ()

@property (nonatomic) TTModeDirection labelDirection;
@property (nonatomic, strong) NSDictionary *labelAttributes;
@property (nonatomic, strong) TTMode *diamondMode;
@property (nonatomic, strong) NSImageView *iconView;

@end

@implementation TTDiamondLabel

- (id)initWithFrame:(NSRect)frame inDirection:(TTModeDirection)direction {
    frame = NSInsetRect(frame, 0, -1 * PADDING);

    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.labelDirection = direction;
        self.diamondMode = self.appDelegate.modeMap.selectedMode;
        self.iconView = [[NSImageView alloc] init];
        
        [self addSubview:self.iconView];
        
        [self registerAsObserver];
    }
    return self;
}

#pragma mark - KVO

- (void)dealloc {
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"hoverModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"activeModeDirection"];
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"selectedModeDirection"];
}

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"hoverModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        self.diamondMode = self.appDelegate.modeMap.selectedMode;
    }
    
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))] ||
        [keyPath isEqual:NSStringFromSelector(@selector(hoverModeDirection))]      ||
        [keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))]     ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]   ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setupLabels];
        if (self.interactive) {
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
    
    directionLabel = [self.diamondMode titleInDirection:self.labelDirection buttonMoment:BUTTON_MOMENT_PRESSUP];
    NSSize labelSize = [directionLabel sizeWithAttributes:self.labelAttributes];
    NSInteger iconOffset = 0;
    if (self.isHud) {
        iconOffset = MIN(NSWidth(self.bounds), NSHeight(self.bounds))/16;
    }
    [directionLabel drawAtPoint:NSMakePoint(NSWidth(self.bounds)/2 - labelSize.width/2,
                                            NSHeight(self.bounds)/2 - labelSize.height/(140/50.f) - iconOffset)
                 withAttributes:self.labelAttributes];
}

- (void)drawIcon {
    if (!self.isHud) return;
    
    NSRect iconFrame = self.bounds;
    iconFrame.origin.y += MIN(NSWidth(self.bounds), NSHeight(self.bounds))/8;
    [self.iconView setFrame:iconFrame];

    NSString *imageFilename = [self.diamondMode imageNameInDirection:self.labelDirection];
    NSImage *image = [NSImage imageNamed:imageFilename];
    NSInteger iconSize = round(MAX(CGRectGetHeight(iconFrame), CGRectGetWidth(iconFrame)) / 10);
    [image setSize:NSMakeSize(iconSize, iconSize)];
    [self.iconView setImage:image];
    
}

- (void)setMode:(TTMode *)mode {
    self.diamondMode = mode;
}

- (void)setupLabels {
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    BOOL hovering = self.appDelegate.modeMap.hoverModeDirection == self.labelDirection;
    BOOL selected = self.appDelegate.modeMap.inspectingModeDirection == self.labelDirection;
    if (!self.interactive) {
        selected = NO;
        hovering = NO;
    }
    
    NSColor *textColor = (hovering || selected) ? NSColorFromRGB(0x303AA0) : NSColorFromRGB(0x404A60);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    if (!self.isHud) {
        NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 56);
        NSShadow *stringShadow = [[NSShadow alloc] init];
        stringShadow.shadowColor = [NSColor whiteColor];
        stringShadow.shadowOffset = NSMakeSize(0, -1);
        stringShadow.shadowBlurRadius = 0;
        self.labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:(self.interactive ? 13 : fontSize)],
                            NSForegroundColorAttributeName: textColor,
                            NSShadowAttributeName: stringShadow,
                            NSParagraphStyleAttributeName: style
                            };
    } else {
        NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 96);
        self.labelAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:(self.interactive ? 13 : fontSize)],
                            NSForegroundColorAttributeName: textColor,
                            NSParagraphStyleAttributeName: style
                            };
    }
}

@end
