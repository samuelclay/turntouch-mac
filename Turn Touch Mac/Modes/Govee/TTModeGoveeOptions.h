//
//  TTModeGoveeOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeGovee.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeGoveeOptions : TTOptionsDetailViewController <TTModeGoveeDelegate>

@property (nonatomic, strong) TTModeGovee *modeGovee;

@end
