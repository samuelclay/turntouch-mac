//
//  TTChangeButtonCell.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TTChangeButtonCell : NSButtonCell

@property (nonatomic, readwrite) BOOL mouseDown;
@property (nonatomic) CGFloat borderRadius;

@end
