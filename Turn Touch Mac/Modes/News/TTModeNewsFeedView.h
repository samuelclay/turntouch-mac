//
//  TTModeNewsFeedView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 9/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTNewsBlurFeed.h"

@interface TTModeNewsFeedView : NSView

@property (nonatomic) TTNewsBlurFeed *feed;

- (id)initWithFeed:(TTNewsBlurFeed *)feed inFrame:(NSRect)frameRect;

@end
