//
//  TTChangeButtonView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTChangeButtonCell.h"

@interface TTChangeButtonView : NSButton {
    TTChangeButtonCell *cell;
}

@property (nonatomic) CGFloat borderRadius;

@end
