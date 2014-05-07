//
//  TTModeMenuItemView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuContainer.h"
#import "TTModeMenuItemView.h"

#define IMAGE_SIZE 16.0f

@implementation TTModeMenuItemView

@synthesize modeName;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        hoverActive = NO;
        mouseDownActive = NO;
        
        [self registerAsObserver];
        [self createTrackingArea];
    }
    return self;
}

- (void)setModeName:(NSString *)_modeName {
    modeName = _modeName;
    modeClass = NSClassFromString(modeName);
}

#pragma mark - KVO

- (void)registerAsObserver {
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
    if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))] ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self setupTitleAttributes];
    [self drawBackground];
    
    modeImage = [NSImage imageNamed:[modeClass imageName]];
    [modeImage setSize:NSMakeSize(IMAGE_SIZE, IMAGE_SIZE)];
    CGFloat offset = (NSHeight(self.frame)/2) - (modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(offset, offset + 1);
    NSRect imageRect = NSMakeRect(imagePoint.x, imagePoint.y,
                                  modeImage.size.width, modeImage.size.height);
    [modeImage drawInRect:imageRect];
    
    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    NSPoint titlePoint = NSMakePoint(NSMaxX(imageRect) + 12,
                                     NSHeight(self.frame)/2 - titleSize.height/2 + 2);
    
    [modeTitle drawAtPoint:titlePoint withAttributes:modeAttributes];
}


- (void)setupTitleAttributes {
    modeTitle = [[modeClass title] uppercaseString];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = (hoverActive && [appDelegate.modeMap.selectedMode class] != modeClass) ? NSColorFromRGB(0x404A60) :
    [appDelegate.modeMap.selectedMode class] == modeClass ?
    NSColorFromRGB(0x404A60) : NSColorFromRGB(0x808388);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

- (void)drawBackground {
    if ([appDelegate.modeMap.selectedMode class] == modeClass) {
        // #E3EDF6
        [NSColorFromRGB(0xE3EDF6) set];
    } else if (mouseDownActive) {
        [NSColorFromRGB(0xF6F6F9) set];
    } else {
        [NSColorFromRGB(0xFBFBFD) set];
    }
    NSRectFill(self.bounds);
}

- (void)updateTrackingAreas {
    [self createTrackingArea];
}

- (void)createTrackingArea {
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }

    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    
    hoverActive = YES;
    [self setNeedsDisplay:YES];
    [appDelegate.panelController.backgroundView.modeMenu setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];
    
    hoverActive = NO;
    mouseDownActive = NO;
    [self setNeedsDisplay:YES];
    [appDelegate.panelController.backgroundView.modeMenu setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    mouseDownActive = YES;
    [self drawBackground];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (!mouseDownActive) {
        [self drawBackground];
        [self setNeedsDisplay:YES];
        return;
    }
    mouseDownActive = NO;
    
    NSPoint clickPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL inside = NSPointInRect(clickPoint, self.bounds);
    if (!inside) {
        [self drawBackground];
        [self setNeedsDisplay:YES];
        return;
    }
    
    [appDelegate.modeMap reset];
    
    if ([appDelegate.modeMap.selectedMode class] != modeClass) {
        [appDelegate.modeMap changeDirection:appDelegate.modeMap.selectedModeDirection
                                      toMode:modeName];
    }
}

@end
