//
//  TTModeNanoleafPushlink.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"

@class TTModeNanoleaf;

@interface TTModeNanoleafPushlink : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeNanoleaf *modeNanoleaf;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progressView;
@property (nonatomic, strong) IBOutlet NSTextField *deviceNameLabel;

- (void)setProgress:(NSNumber *)progressPercentage;

@end
