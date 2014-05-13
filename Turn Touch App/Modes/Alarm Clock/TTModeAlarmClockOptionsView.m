//
//  TTModeAlarmClockOptionsView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/13/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeAlarmClockOptionsView.h"

@implementation TTModeAlarmClockOptionsView

@synthesize boxOnetimeOptions;
@synthesize boxRepeatOptions;
@synthesize boxOnetimeConstraint;
@synthesize boxRepeatConstraint;
@synthesize segOnetimeControl;
@synthesize segRepeatControl;

- (void)awakeFromNib {
    [super awakeFromNib];
    appDelegate = [NSApp delegate];
    
}

#pragma mark - Drawing controls

- (void)changeSegOnetimeControl:(id)sender {
    [self animateBlock:^{
        if (boxOnetimeConstraint.constant) {
            [boxOnetimeConstraint animator].constant = 0;
            [boxOnetimeOptions animator].alphaValue = 0;
        } else {
            [boxOnetimeConstraint animator].constant = 68;
            [boxOnetimeOptions animator].alphaValue = 1;
        }
    }];

}

- (void)changeSegRepeatControl:(id)sender {
    [self animateBlock:^{
        if (boxRepeatConstraint.constant) {
            [boxRepeatConstraint animator].constant = 0;
            [boxRepeatOptions animator].alphaValue = 0;
        } else {
            [boxRepeatConstraint animator].constant = 88;
            [boxRepeatOptions animator].alphaValue = 1;
        }
    }];
}

@end
