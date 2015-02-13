//
//  TTGradientView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 2/11/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//
//  Based on work by Seb Jachec

#import <Cocoa/Cocoa.h>

@interface TTGradientView : NSView

@property (strong) void(^drawBlock)();
@property (strong) void(^baseDrawBlock)();

@property (readonly, getter = image) NSImage *image;

/**
 * Initialises a view with a solid color
 *
 * @param frameRect Frame for view
 * @param theColor The color to draw/fill the view with
 */
- (id)initWithFrame:(NSRect)frameRect Color:(NSColor*)theColor;


- (id)initWithFrame:(NSRect)frameRect Gradient:(NSGradient*)theGradient inBezier:(NSBezierPath *)bezierPath;

/**
 * Initialises a view with a radial gradient
 *
 * @param frameRect Frame for view
 * @param theGradient The gradient to draw
 * @param theCenter The relative center point of the gradient
 */
- (id)initWithFrame:(NSRect)frameRect Gradient:(NSGradient*)theGradient RelativeCenterPosition:(NSPoint)theCenter;

/**
 * Initialises a view with a linear gradient
 *
 * @param frameRect Frame for view
 * @param theGradient The gradient to draw
 * @param theAngle The angle at which to draw the gradient
 */
- (id)initWithFrame:(NSRect)frameRect Gradient:(NSGradient*)theGradient Angle:(int)theAngle;


- (void)fadeToDrawBlock:(void (^)(void))newDrawBlock withDuration:(CGFloat)animDuration;

/**
 * Fade the view's contents to a new gradient, using the default duration of 0.25s
 */
- (void)fadeToDrawBlock:(void (^)(void))newDrawBlock;


/**
 * @return An NSImage of the same size as the view, containing its contents
 */
- (NSImage *)image;

@end