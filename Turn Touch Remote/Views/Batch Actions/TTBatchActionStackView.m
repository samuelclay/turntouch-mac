//
//  TTBatchActionStackView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/20/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTBatchActionStackView.h"
#import "TTBatchActionHeaderView.h"

@implementation TTBatchActionStackView

@synthesize tempMode;

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self setWantsLayer:YES];
        [self setHuggingPriority:NSLayoutPriorityDefaultHigh
                  forOrientation:NSLayoutConstraintOrientationVertical];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [self setAlignment:NSLayoutAttributeCenterX];
        [self setSpacing:0];

        [self assembleViews];
        
//        [self registerAsObserver];
    }
    
    return self;
}

//#pragma mark - KVO
//
//- (void)registerAsObserver {
//    [appDelegate.modeMap addObserver:self forKeyPath:@"tempModeName"
//                             options:0 context:nil];
//}
//
//- (void) observeValueForKeyPath:(NSString*)keyPath
//                       ofObject:(id)object
//                         change:(NSDictionary*)change
//                        context:(void*)context {
//    if ([keyPath isEqual:NSStringFromSelector(@selector(tempModeName))]) {
////        [self assembleViews];
//    }
//}
//
//- (void)dealloc {
//    [appDelegate.modeMap removeObserver:self forKeyPath:@"tempModeName"];
//}
//
#pragma mark - Drawing

- (void)assembleViews {
    NSLog(@"assembleViews: %@", appDelegate.modeMap.tempModeName);
    NSMutableArray *views = [NSMutableArray array];
    TTBatchActionHeaderView *tempHeaderView;
    
    if (appDelegate.modeMap.tempModeName) {
        tempHeaderView = [[TTBatchActionHeaderView alloc] initWithMode:appDelegate.modeMap.tempModeName];
        [views addObject:tempHeaderView];
    }
    
    [self setViews:views inGravity:NSStackViewGravityTop];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
