//
//  TTModeNanoleafConnected.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleafConnected.h"
#import "TTModeNanoleaf.h"

@interface TTModeNanoleafConnected ()

@property (nonatomic, weak) IBOutlet NSTextField *effectsLabel;

@end

@implementation TTModeNanoleafConnected

- (void)viewDidLoad {
    [super viewDidLoad];
    [self countEffects];
}

- (IBAction)selectOtherDevice:(id)sender {
    [self.modeNanoleaf findDevices];
}

- (void)countEffects {
    NSString *name = [TTModeNanoleaf deviceName] ?: @"Nanoleaf";
    NSInteger effectCount = [TTModeNanoleaf cachedEffects].count;
    NSString *effectStr = effectCount == 1 ? @"1 effect" : [NSString stringWithFormat:@"%ld effects", (long)effectCount];
    self.effectsLabel.stringValue = [NSString stringWithFormat:@"%@ - %@", name, effectStr];
}

@end
