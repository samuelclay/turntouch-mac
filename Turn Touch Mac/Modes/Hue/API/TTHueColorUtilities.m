//
//  TTHueColorUtilities.m
//  Turn Touch Mac
//
//  Color conversion utilities for Hue lights
//

#import "TTHueColorUtilities.h"

// Color point indices
static const NSInteger cptRED = 0;
static const NSInteger cptGREEN = 1;
static const NSInteger cptBLUE = 2;

@implementation TTHueColorUtilities

#pragma mark - Private Helpers

+ (NSArray<NSValue *> *)colorPointsForModel:(NSString *)model {
    NSMutableArray<NSValue *> *colorPoints = [NSMutableArray array];

    // Gamut A: Older Hue bulbs
    NSArray *gamutA = @[@"LLC001", @"LLC005", @"LLC006", @"LLC007", @"LLC011", @"LLC012", @"LLC013", @"LST001"];

    // Gamut B: Hue A19, BR30, GU10
    NSArray *gamutB = @[@"LCT001", @"LCT007", @"LCT002", @"LCT003", @"LCT010", @"LCT011", @"LCT012", @"LCT014", @"LCT015", @"LCT016"];

    // Gamut C: Hue Go, LightStrips Plus, newer bulbs
    NSArray *gamutC = @[@"LLC020", @"LST002", @"LCT024", @"LCA001", @"LCA002", @"LCA003"];

    if (model) {
        if ([gamutA containsObject:model]) {
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.703, 0.296)]];  // Red
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.214, 0.709)]];  // Green
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.139, 0.081)]];  // Blue
        } else if ([gamutB containsObject:model]) {
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.674, 0.322)]];  // Red
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.408, 0.517)]];  // Green
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.168, 0.041)]];  // Blue
        } else if ([gamutC containsObject:model]) {
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.692, 0.308)]];  // Red
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.17, 0.7)]];     // Green
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.153, 0.048)]];  // Blue
        } else {
            // Default: wide gamut triangle
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(1.0, 0.0)]];  // Red
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.0, 1.0)]];  // Green
            [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.0, 0.0)]];  // Blue
        }
    } else {
        // Default: wide gamut triangle
        [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(1.0, 0.0)]];  // Red
        [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.0, 1.0)]];  // Green
        [colorPoints addObject:[NSValue valueWithPoint:NSMakePoint(0.0, 0.0)]];  // Blue
    }

    return colorPoints;
}

+ (CGFloat)crossProductPoint1:(CGPoint)p1 point2:(CGPoint)p2 {
    return p1.x * p2.y - p1.y * p2.x;
}

+ (CGPoint)closestPointToPoint1:(CGPoint)A point2:(CGPoint)B point3:(CGPoint)P {
    CGPoint AP = CGPointMake(P.x - A.x, P.y - A.y);
    CGPoint AB = CGPointMake(B.x - A.x, B.y - A.y);
    CGFloat ab2 = AB.x * AB.x + AB.y * AB.y;
    CGFloat ap_ab = AP.x * AB.x + AP.y * AB.y;

    CGFloat t = ap_ab / ab2;

    if (t < 0.0) {
        t = 0.0;
    } else if (t > 1.0) {
        t = 1.0;
    }

    return CGPointMake(A.x + AB.x * t, A.y + AB.y * t);
}

+ (CGFloat)distanceBetweenPoint1:(CGPoint)p1 point2:(CGPoint)p2 {
    CGFloat dx = p1.x - p2.x;
    CGFloat dy = p1.y - p2.y;
    return sqrt(dx * dx + dy * dy);
}

+ (BOOL)checkPoint:(CGPoint)p inLampsReachWithColorPoints:(NSArray<NSValue *> *)colorPoints {
    CGPoint red = [colorPoints[cptRED] pointValue];
    CGPoint green = [colorPoints[cptGREEN] pointValue];
    CGPoint blue = [colorPoints[cptBLUE] pointValue];

    CGPoint v1 = CGPointMake(green.x - red.x, green.y - red.y);
    CGPoint v2 = CGPointMake(blue.x - red.x, blue.y - red.y);
    CGPoint q = CGPointMake(p.x - red.x, p.y - red.y);

    CGFloat s = [self crossProductPoint1:q point2:v2] / [self crossProductPoint1:v1 point2:v2];
    CGFloat t = [self crossProductPoint1:v1 point2:q] / [self crossProductPoint1:v1 point2:v2];

    return (s >= 0.0) && (t >= 0.0) && (s + t <= 1.0);
}

#pragma mark - Public Methods

+ (NSColor *)colorFromXY:(CGPoint)xy forModel:(NSString *)model {
    NSArray<NSValue *> *colorPoints = [self colorPointsForModel:model];
    BOOL inReachOfLamps = [self checkPoint:xy inLampsReachWithColorPoints:colorPoints];

    if (!inReachOfLamps) {
        // The colour is out of reach - find the closest colour we can produce
        CGPoint pAB = [self closestPointToPoint1:[colorPoints[cptRED] pointValue]
                                          point2:[colorPoints[cptGREEN] pointValue]
                                          point3:xy];
        CGPoint pAC = [self closestPointToPoint1:[colorPoints[cptBLUE] pointValue]
                                          point2:[colorPoints[cptRED] pointValue]
                                          point3:xy];
        CGPoint pBC = [self closestPointToPoint1:[colorPoints[cptGREEN] pointValue]
                                          point2:[colorPoints[cptBLUE] pointValue]
                                          point3:xy];

        CGFloat dAB = [self distanceBetweenPoint1:xy point2:pAB];
        CGFloat dAC = [self distanceBetweenPoint1:xy point2:pAC];
        CGFloat dBC = [self distanceBetweenPoint1:xy point2:pBC];

        CGFloat lowest = dAB;
        CGPoint closestPoint = pAB;

        if (dAC < lowest) {
            lowest = dAC;
            closestPoint = pAC;
        }
        if (dBC < lowest) {
            closestPoint = pBC;
        }

        xy.x = closestPoint.x;
        xy.y = closestPoint.y;
    }

    CGFloat x = xy.x;
    CGFloat y = xy.y;
    CGFloat z = 1.0 - x - y;

    CGFloat Y = 1.0;
    CGFloat X = (Y / y) * x;
    CGFloat Z = (Y / y) * z;

    // sRGB D65 conversion
    CGFloat r = X * 1.656492 - Y * 0.354851 - Z * 0.255038;
    CGFloat g = -X * 0.707196 + Y * 1.655397 + Z * 0.036152;
    CGFloat b = X * 0.051713 - Y * 0.121364 + Z * 1.011530;

    if (r > b && r > g && r > 1.0) {
        g = g / r;
        b = b / r;
        r = 1.0;
    } else if (g > b && g > r && g > 1.0) {
        r = r / g;
        b = b / g;
        g = 1.0;
    } else if (b > r && b > g && b > 1.0) {
        r = r / b;
        g = g / b;
        b = 1.0;
    }

    // Apply gamma correction
    r = r <= 0.0031308 ? 12.92 * r : (1.0 + 0.055) * pow(r, 1.0 / 2.4) - 0.055;
    g = g <= 0.0031308 ? 12.92 * g : (1.0 + 0.055) * pow(g, 1.0 / 2.4) - 0.055;
    b = b <= 0.0031308 ? 12.92 * b : (1.0 + 0.055) * pow(b, 1.0 / 2.4) - 0.055;

    if (r > b && r > g) {
        if (r > 1.0) {
            g = g / r;
            b = b / r;
            r = 1.0;
        }
    } else if (g > b && g > r) {
        if (g > 1.0) {
            r = r / g;
            b = b / g;
            g = 1.0;
        }
    } else if (b > r && b > g) {
        if (b > 1.0) {
            r = r / b;
            g = g / b;
            b = 1.0;
        }
    }

    // Clamp values to valid range
    r = MAX(0, MIN(1, r));
    g = MAX(0, MIN(1, g));
    b = MAX(0, MIN(1, b));

    return [NSColor colorWithRed:r green:g blue:b alpha:1.0];
}

+ (CGPoint)calculateXYFromColor:(NSColor *)color forModel:(NSString *)model {
    // Convert to RGB color space first
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    if (!rgbColor) {
        rgbColor = [NSColor colorWithRed:1 green:1 blue:1 alpha:1];
    }

    CGFloat red = rgbColor.redComponent;
    CGFloat green = rgbColor.greenComponent;
    CGFloat blue = rgbColor.blueComponent;

    // Apply gamma correction
    CGFloat r = (red > 0.04045) ? pow((red + 0.055) / 1.055, 2.4) : (red / 12.92);
    CGFloat g = (green > 0.04045) ? pow((green + 0.055) / 1.055, 2.4) : (green / 12.92);
    CGFloat b = (blue > 0.04045) ? pow((blue + 0.055) / 1.055, 2.4) : (blue / 12.92);

    // Wide gamut conversion D65
    CGFloat X = r * 0.664511 + g * 0.154324 + b * 0.162028;
    CGFloat Y = r * 0.283881 + g * 0.668433 + b * 0.047685;
    CGFloat Z = r * 0.000088 + g * 0.072310 + b * 0.986039;

    CGFloat cx = X / (X + Y + Z);
    CGFloat cy = Y / (X + Y + Z);

    if (isnan(cx)) cx = 0.0;
    if (isnan(cy)) cy = 0.0;

    // Check if the given XY value is within the colour reach of our lamps
    CGPoint xyPoint = CGPointMake(cx, cy);
    NSArray<NSValue *> *colorPoints = [self colorPointsForModel:model];
    BOOL inReachOfLamps = [self checkPoint:xyPoint inLampsReachWithColorPoints:colorPoints];

    if (!inReachOfLamps) {
        // The colour is out of reach - find the closest colour we can produce
        CGPoint pAB = [self closestPointToPoint1:[colorPoints[cptRED] pointValue]
                                          point2:[colorPoints[cptGREEN] pointValue]
                                          point3:xyPoint];
        CGPoint pAC = [self closestPointToPoint1:[colorPoints[cptBLUE] pointValue]
                                          point2:[colorPoints[cptRED] pointValue]
                                          point3:xyPoint];
        CGPoint pBC = [self closestPointToPoint1:[colorPoints[cptGREEN] pointValue]
                                          point2:[colorPoints[cptBLUE] pointValue]
                                          point3:xyPoint];

        CGFloat dAB = [self distanceBetweenPoint1:xyPoint point2:pAB];
        CGFloat dAC = [self distanceBetweenPoint1:xyPoint point2:pAC];
        CGFloat dBC = [self distanceBetweenPoint1:xyPoint point2:pBC];

        CGFloat lowest = dAB;
        CGPoint closestPoint = pAB;

        if (dAC < lowest) {
            lowest = dAC;
            closestPoint = pAC;
        }
        if (dBC < lowest) {
            closestPoint = pBC;
        }

        cx = closestPoint.x;
        cy = closestPoint.y;
    }

    return CGPointMake(cx, cy);
}

+ (TTHueXY *)calculateHueXYFromColor:(NSColor *)color forModel:(NSString *)model {
    CGPoint point = [self calculateXYFromColor:color forModel:model];
    TTHueXY *xy = [[TTHueXY alloc] init];
    xy.x = point.x;
    xy.y = point.y;
    return xy;
}

+ (double)brightnessV1ToV2:(NSInteger)v1Brightness {
    return (double)v1Brightness / 254.0 * 100.0;
}

+ (NSInteger)brightnessV2ToV1:(double)v2Brightness {
    return (NSInteger)(v2Brightness / 100.0 * 254.0);
}

+ (CGPoint)xyFromHue:(NSInteger)hue
          saturation:(NSInteger)saturation
          brightness:(NSInteger)brightness
               model:(NSString *)model {
    CGFloat h = (CGFloat)hue / 65535.0;
    CGFloat s = (CGFloat)saturation / 254.0;
    CGFloat b = (CGFloat)brightness / 254.0;

    NSColor *color = [NSColor colorWithHue:h saturation:s brightness:b alpha:1.0];
    return [self calculateXYFromColor:color forModel:model];
}

@end

#pragma mark - TTHueColorPresets

@implementation TTHueColorPresets

+ (NSColor *)earlyEvening {
    return [NSColor colorWithRed:0xEB/255.0 green:0xCE/255.0 blue:0x92/255.0 alpha:1.0];  // #EBCE92
}

+ (NSColor *)lateEveningMain {
    return [NSColor colorWithRed:0x5F/255.0 green:0x4C/255.0 blue:0x24/255.0 alpha:1.0];  // #5F4C24
}

+ (NSColor *)lateEveningAccent {
    return [NSColor colorWithRed:0x85/255.0 green:0x38/255.0 blue:0xCD/255.0 alpha:1.0];  // #8538CD
}

+ (NSColor *)morningMain {
    return [NSColor colorWithRed:0x91/255.0 green:0x4C/255.0 blue:0x10/255.0 alpha:1.0];  // #914C10
}

+ (NSColor *)midnightOilBlue {
    return [NSColor colorWithRed:0x0F/255.0 green:0x38/255.0 blue:0xC8/255.0 alpha:1.0];  // #0F38C8
}

+ (NSColor *)midnightOilTeal {
    return [NSColor colorWithRed:0x0E/255.0 green:0x9C/255.0 blue:0xC8/255.0 alpha:1.0];  // #0E9CC8
}

@end
