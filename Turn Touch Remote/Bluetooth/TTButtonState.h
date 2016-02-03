//
//  TTButtonState.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTButtonState : NSObject

@property (nonatomic, readwrite) BOOL north;
@property (nonatomic, readwrite) BOOL east;
@property (nonatomic, readwrite) BOOL west;
@property (nonatomic, readwrite) BOOL south;
@property (nonatomic) NSInteger count;

- (BOOL)state:(NSInteger)i;
- (void)replaceState:(NSInteger)i withState:(BOOL)state;
- (BOOL)anyPressedDown;
- (BOOL)inMultitouch;
- (NSInteger)activatedCount;

@end
