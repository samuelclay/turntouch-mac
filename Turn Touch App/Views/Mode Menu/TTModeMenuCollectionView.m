//
//  TTModeMenuCollectionView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/6/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeMenuCollectionView.h"

@implementation TTModeMenuCollectionView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self setMaxNumberOfColumns:2];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSLog(@"Drawing collection view: %@", NSStringFromRect(self.frame));
    // Drawing code here.
}


- (void)setContent:(NSArray *)content {
    [super setContent:content];
    
    //    NSRect frame = self.frame;
    //    frame.size.height = ceil((float)[content count] / 2.0f) * MENU_ITEM_HEIGHT;
    //    self.frame = frame;
}

@end
