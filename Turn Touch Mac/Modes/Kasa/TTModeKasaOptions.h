//
//  TTModeKasaOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasa.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeKasaOptions : TTOptionsDetailViewController <TTModeKasaDelegate>

@property (nonatomic, strong) TTModeKasa *modeKasa;

@end
