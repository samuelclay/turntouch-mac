//
//  TTModeNanoleafConnecting.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "TTModeNanoleaf.h"

@interface TTModeNanoleafConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeNanoleaf *modeNanoleaf;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString *)message;

@end
