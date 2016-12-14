//
//  TTModeNestOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNest.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeNestOptions : TTOptionsDetailViewController <TTModeNestDelegate>

@property (nonatomic, strong) TTModeNest *modeNest;

@end
