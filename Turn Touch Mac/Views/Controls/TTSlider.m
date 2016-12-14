//
//  TTSlider.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/14/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTSlider.h"
#import "TTSliderCell.h"

@implementation TTSlider

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if( ![self.cell isKindOfClass:[TTSliderCell class]] ) {
        TTSliderCell *cell = [[TTSliderCell alloc] init];
        [self setCell:cell];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)setNeedsDisplayInRect:(NSRect)invalidRect{
    [super setNeedsDisplayInRect:[self bounds]];
}

@end
