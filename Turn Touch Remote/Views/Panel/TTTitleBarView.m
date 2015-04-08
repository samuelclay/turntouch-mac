//
//  TTTitleBarView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/9/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTTitleBarView.h"
#import "TTBluetoothMonitor.h"

#define CORNER_RADIUS 8.0f

@implementation TTTitleBarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        title = [NSImage imageNamed:@"title"];
        [title setSize:NSMakeSize(100, 12)];
        
        settings = [NSImage imageNamed:@"settings"];
        [settings setSize:NSMakeSize(16, 16)];
        
        [self setupTitleAttributes];
        [self registerAsObserver];
    }
    return self;
}

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"batteryPct"
                                      options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(batteryPct))]) {
        [self setNeedsDisplay:YES];
    }
}

- (void)dealloc {

}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self drawBackground];
    [self drawLabel];
    [self drawBatteryPct];
    [self drawSettings];
}

- (void)setFrame:(NSRect)frameRect {
    [super setFrame:frameRect];
    [self drawBackground];
    [self drawLabel];
}

- (void)drawLabel {
    NSPoint titlePoint = NSMakePoint(NSMidX(self.bounds)-(title.size.width/2),
                                     NSMidY(self.bounds)-(title.size.height/2));
    [title drawInRect:NSMakeRect(titlePoint.x, titlePoint.y,
                                 title.size.width, title.size.height)];
}

- (void)drawBatteryPct {
    if (!appDelegate.bluetoothMonitor.batteryPct) return;
    NSString *batteryPct = [NSString stringWithFormat:@"%@%%", appDelegate.bluetoothMonitor.batteryPct];
    NSSize batterySize = [batteryPct sizeWithAttributes:batteryAttributes];
    NSPoint batteryPoint = NSMakePoint(NSMinX(self.bounds) + 16,
                                       NSMidY(self.bounds) - batterySize.height/2 + 1);

    [batteryPct drawInRect:NSMakeRect(batteryPoint.x, batteryPoint.y, batterySize.width, batterySize.height)
            withAttributes:batteryAttributes];
}

- (void)drawSettings {
    NSPoint settingsPoint = NSMakePoint(NSMaxX(self.bounds) - settings.size.width - 16,
                                        NSMidY(self.bounds) - settings.size.height/2 + 1);
    [settings drawInRect:NSMakeRect(settingsPoint.x, settingsPoint.y,
                                    settings.size.width, settings.size.height)];
}

- (void)drawBackground {
    NSRect contentRect = NSInsetRect([self bounds], 0, 0);
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)];
    
    NSPoint topLeftCorner = NSMakePoint(NSMinX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMinX(contentRect) + CORNER_RADIUS, NSMaxY(contentRect))
         controlPoint1:topLeftCorner controlPoint2:topLeftCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect) - CORNER_RADIUS, NSMaxY(contentRect))];
    
    NSPoint topRightCorner = NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect));
    [path curveToPoint:NSMakePoint(NSMaxX(contentRect), NSMaxY(contentRect) - CORNER_RADIUS)
         controlPoint1:topRightCorner controlPoint2:topRightCorner];
    
    [path lineToPoint:NSMakePoint(NSMaxX(contentRect), NSMinY(contentRect))];
    [path lineToPoint:NSMakePoint(NSMinX(contentRect), NSMinY(contentRect))];
    
    [path closePath];
    
    NSGradient* aGradient = [[NSGradient alloc]
                             initWithStartingColor:[NSColor whiteColor]
                             endingColor:NSColorFromRGB(0xE7E7E7)];
    [aGradient drawInBezierPath:path angle:-90];
    
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath *clip = [NSBezierPath bezierPathWithRect:[self bounds]];
    [clip appendBezierPath:path];
    [clip addClip];
    
    [NSGraphicsContext restoreGraphicsState];
    
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMinX([path bounds]), NSMinY([path bounds]))];
    [line lineToPoint:NSMakePoint(NSMaxX([path bounds]), NSMinY([path bounds]))];
    [line setLineWidth:1.0];
    [NSColorFromRGB(0xD0D0D0) set];
    [line stroke];
}


- (void)setupTitleAttributes {
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    batteryAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                          NSForegroundColorAttributeName: textColor,
                          NSShadowAttributeName: stringShadow
                          };
}

@end
