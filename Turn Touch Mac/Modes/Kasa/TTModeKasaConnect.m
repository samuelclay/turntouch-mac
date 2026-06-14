//
//  TTModeKasaConnect.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright © 2026 Turn Touch. All rights reserved.
//

#import "TTModeKasaConnect.h"

@implementation TTModeKasaConnect

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)clickAuthButton:(id)sender {
    [self.modeKasa beginConnectingToKasa];
}

@end
