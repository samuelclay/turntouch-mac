//
//  TTModeWemoOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeWemo.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeWemoOptions : TTOptionsDetailViewController <TTModeWemoDelegate>

@property (nonatomic, strong) TTModeWemo *modeWemo;

@end
