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

NSUInteger const kRepeatHeight = 88;
NSUInteger const kOnetimeHeight = 68;
NSString *const kRepeatAlarmEnabled = @"repeatAlarmEnabled";
NSString *const kOnetimeAlarmEnabled = @"onetimeAlarmEnabled";

- (void)awakeFromNib {
    [super awakeFromNib];
    
    BOOL repeatAlarmEnabled = [[appDelegate.modeMap modeOptionValue:kRepeatAlarmEnabled] boolValue];
    BOOL onetimeAlarmEnabled = [[appDelegate.modeMap modeOptionValue:kOnetimeAlarmEnabled] boolValue];
    
    [boxOnetimeConstraint     setConstant:onetimeAlarmEnabled ? kOnetimeHeight : 0];
    [boxOnetimeOptions      setAlphaValue:onetimeAlarmEnabled ? 1 : 0];
    [segOnetimeControl setSelectedSegment:onetimeAlarmEnabled ? 0 : 1];

    [boxRepeatConstraint     setConstant:repeatAlarmEnabled ? kRepeatHeight : 0];
    [boxRepeatOptions      setAlphaValue:repeatAlarmEnabled ? 1 : 0];
    [segRepeatControl setSelectedSegment:repeatAlarmEnabled ? 0 : 1];
}

#pragma mark - Drawing controls

- (void)changeSegOnetimeControl:(id)sender {
    [self animateBlock:^{
        if (segOnetimeControl.selectedSegment == 1) {
            [boxOnetimeConstraint animator].constant = 0;
            [boxOnetimeOptions animator].alphaValue = 0;
            [appDelegate.modeMap changeModeOption:kOnetimeAlarmEnabled to:[NSNumber numberWithBool:NO]];
        } else {
            [boxOnetimeConstraint animator].constant = kOnetimeHeight;
            [boxOnetimeOptions animator].alphaValue = 1;
            [appDelegate.modeMap changeModeOption:kOnetimeAlarmEnabled to:[NSNumber numberWithBool:YES]];
        }
    }];

}

- (void)changeSegRepeatControl:(id)sender {
    [self animateBlock:^{
        if (segRepeatControl.selectedSegment == 1) {
            [boxRepeatConstraint animator].constant = 0;
            [boxRepeatOptions animator].alphaValue = 0;
            [appDelegate.modeMap changeModeOption:kRepeatAlarmEnabled to:[NSNumber numberWithBool:NO]];
        } else {
            [boxRepeatConstraint animator].constant = kRepeatHeight;
            [boxRepeatOptions animator].alphaValue = 1;
            [appDelegate.modeMap changeModeOption:kRepeatAlarmEnabled to:[NSNumber numberWithBool:YES]];
        }
    }];
}

@end
