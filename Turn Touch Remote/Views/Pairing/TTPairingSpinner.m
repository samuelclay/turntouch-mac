//
//  TTPairingSpinner.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/13/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTPairingSpinner.h"

@implementation TTPairingSpinner

- (void)awakeFromNib {
    NSLog(@"Initing spinner");
    spinnerBeginTime = CACurrentMediaTime();
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSLog(@"Drawing spinner");
    [super drawRect:dirtyRect];
    
    [self.layer removeAllAnimations];
    
    for (CALayer *layer in [self.layer.sublayers copy]) {
        [layer removeFromSuperlayer];
    }
    
    for (NSInteger i=0; i < 2; i+=1) {
        CALayer *circle = [CALayer layer];
        circle.frame = CGRectMake(0, 0, NSWidth(self.frame), NSHeight(self.frame));
        circle.backgroundColor = NSColorFromRGB(0x0000FF).CGColor;
        circle.anchorPoint = CGPointMake(0.5, 0.5);
        circle.opacity = 0.6;
        circle.cornerRadius = CGRectGetHeight(circle.bounds) * 0.5;
        circle.transform = CATransform3DMakeScale(0.0, 0.0, 0.0);
        
        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        anim.removedOnCompletion = NO;
        anim.repeatCount = HUGE_VALF;
        anim.duration = 2.0;
        anim.beginTime = spinnerBeginTime - (1.0 * i);
        anim.keyTimes = @[@(0.0), @(0.5), @(1.0)];
        
        anim.timingFunctions = @[
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]
                                 ];
        
        anim.values = @[
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 0.0)],
                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0, 0.0, 0.0)]
                        ];
        
        [self.layer addSublayer:circle];
        [circle addAnimation:anim forKey:@"transform"];
    }
}

@end
