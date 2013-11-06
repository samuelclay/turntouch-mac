//
//  TTBackgroundView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeMenuViewport.h"
#import "TTDiamondView.h"

#define ARROW_WIDTH 18
#define ARROW_HEIGHT 8

@class TTDiamondView;

@interface TTBackgroundView : NSView {
    NSInteger _arrowX;
}

@property (nonatomic, assign) NSInteger arrowX;
@property (nonatomic) IBOutlet TTModeMenuViewport *modeMenu;
@property (nonatomic) IBOutlet TTDiamondView *diamondView;

@end
