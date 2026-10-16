//
//  TTHueColorUtilities.h
//  Turn Touch Mac
//
//  Color conversion utilities for Hue lights
//  Adapted from SwiftyHue's Utilities and iOS HueColorUtilities.swift
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "TTHueModels.h"

NS_ASSUME_NONNULL_BEGIN

/// Utilities for converting between NSColor and Hue's CIE 1931 XY color space
@interface TTHueColorUtilities : NSObject

#pragma mark - Color Conversion

/// Generates the color for the given XY values.
/// When the exact values cannot be represented, it will return the closest match.
/// @param xy The xy point of the color in CIE 1931 color space
/// @param model Model ID of the lamp (e.g., "LCT001"). Used to calculate the color gamut.
/// @return The NSColor representation
+ (NSColor *)colorFromXY:(CGPoint)xy forModel:(nullable NSString *)model;

/// Generates a point with x and y value that represents the given color
/// @param color The NSColor to convert
/// @param model Model ID of the lamp (e.g., "LCT001"). Used to calculate the color gamut.
/// @return The xy color point in CIE 1931 color space
+ (CGPoint)calculateXYFromColor:(NSColor *)color forModel:(nullable NSString *)model;

/// Generates a TTHueXY object with x and y value that represents the given color
/// @param color The NSColor to convert
/// @param model Model ID of the lamp (e.g., "LCT001"). Used to calculate the color gamut.
/// @return The TTHueXY object
+ (TTHueXY *)calculateHueXYFromColor:(NSColor *)color forModel:(nullable NSString *)model;

#pragma mark - Brightness Conversion

/// Convert brightness from API v1 scale (0-254) to API v2 scale (0.0-100.0)
+ (double)brightnessV1ToV2:(NSInteger)v1Brightness;

/// Convert brightness from API v2 scale (0.0-100.0) to API v1 scale (0-254)
+ (NSInteger)brightnessV2ToV1:(double)v2Brightness;

#pragma mark - HSB to XY Conversion

/// Convert hue from API v1 scale (0-65535) to xy color space
/// @param hue Hue value in API v1 scale (0-65535)
/// @param saturation Saturation value (0-254)
/// @param brightness Brightness value (0-254)
/// @param model Model ID of the lamp
/// @return xy point in CIE 1931 color space
+ (CGPoint)xyFromHue:(NSInteger)hue
          saturation:(NSInteger)saturation
          brightness:(NSInteger)brightness
               model:(nullable NSString *)model;

@end

#pragma mark - Color Presets

/// Predefined colors used by Turn Touch scenes
@interface TTHueColorPresets : NSObject

+ (NSColor *)earlyEvening;
+ (NSColor *)lateEveningMain;
+ (NSColor *)lateEveningAccent;
+ (NSColor *)morningMain;
+ (NSColor *)midnightOilBlue;
+ (NSColor *)midnightOilTeal;

@end

NS_ASSUME_NONNULL_END
