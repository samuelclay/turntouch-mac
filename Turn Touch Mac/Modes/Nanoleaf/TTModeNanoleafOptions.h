//
//  TTModeNanoleafOptions.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleaf.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeNanoleafOptions : TTOptionsDetailViewController
<TTModeNanoleafDelegate>

@property (nonatomic, strong) TTModeNanoleaf *modeNanoleaf;

@end
