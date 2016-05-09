//
//  TTModeHueBridge.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeHueBridge : TTOptionsDetailViewController <NSTableViewDataSource,NSTableViewDelegate>

@property (nonatomic, strong) TTModeHue *modeHue;

- (void)setBridges:(NSDictionary *)foundBridges;

@end
