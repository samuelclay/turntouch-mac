//
//  TTModeAlarmClockOptionsView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 5/13/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeAlarmClockOptions.h"

@implementation TTModeAlarmClockOptions

@synthesize boxOnetimeOptions;
@synthesize boxRepeatOptions;
@synthesize boxOnetimeConstraint;
@synthesize boxRepeatConstraint;
@synthesize segOnetimeControl;
@synthesize segRepeatControl;

@synthesize segRepeatDays;
@synthesize sliderRepeatTime;
@synthesize textRepeatTime;

NSUInteger const kRepeatHeight = 88;
NSUInteger const kOnetimeHeight = 68;
NSString *const kRepeatAlarmEnabled = @"repeatAlarmEnabled";
NSString *const kOnetimeAlarmEnabled = @"onetimeAlarmEnabled";
NSString *const kRepeatAlarmDays = @"repeatAlarmDays";
NSString *const kRepeatAlarmTime = @"repeatAlarmTime";

- (void)awakeFromNib {
    [super awakeFromNib];
    
    BOOL repeatAlarmEnabled = [[NSAppDelegate.modeMap modeOptionValue:kRepeatAlarmEnabled] boolValue];
    BOOL onetimeAlarmEnabled = [[NSAppDelegate.modeMap modeOptionValue:kOnetimeAlarmEnabled] boolValue];
    NSInteger repeatAlarmTime = [[NSAppDelegate.modeMap modeOptionValue:kRepeatAlarmTime] integerValue];
    id days = [NSAppDelegate.modeMap modeOptionValue:kRepeatAlarmDays];
    NSArray *repeatDays = (NSArray *)days;
    
    [boxOnetimeConstraint     setConstant:onetimeAlarmEnabled ? kOnetimeHeight : 0];
    [boxOnetimeOptions      setAlphaValue:onetimeAlarmEnabled ? 1 : 0];
    [segOnetimeControl setSelectedSegment:onetimeAlarmEnabled ? 0 : 1];

    [boxRepeatConstraint     setConstant:repeatAlarmEnabled ? kRepeatHeight : 0];
    [boxRepeatOptions      setAlphaValue:repeatAlarmEnabled ? 1 : 0];
    [segRepeatControl setSelectedSegment:repeatAlarmEnabled ? 0 : 1];
    
    int i = 0;
    for (NSNumber *dayNumber in repeatDays) {
        BOOL dayOn = [dayNumber boolValue];
        [segRepeatDays setSelected:dayOn forSegment:i];
        i++;
    }
    
    [sliderRepeatTime setIntegerValue:repeatAlarmTime];
    [self updateRepeatAlarmLabel];

}

#pragma mark - Drawing controls

- (IBAction)changeSegOnetimeControl:(id)sender {
    [self animateBlock:^{
        if (segOnetimeControl.selectedSegment == 1) {
            [boxOnetimeConstraint animator].constant = 0;
            [boxOnetimeOptions animator].alphaValue = 0;
            [NSAppDelegate.modeMap changeModeOption:kOnetimeAlarmEnabled to:[NSNumber numberWithBool:NO]];
        } else {
            [boxOnetimeConstraint animator].constant = kOnetimeHeight;
            [boxOnetimeOptions animator].alphaValue = 1;
            [NSAppDelegate.modeMap changeModeOption:kOnetimeAlarmEnabled to:[NSNumber numberWithBool:YES]];
        }
    }];

}

- (IBAction)changeSegRepeatControl:(id)sender {
    [self animateBlock:^{
        if (segRepeatControl.selectedSegment == 1) {
            [boxRepeatConstraint animator].constant = 0;
            [boxRepeatOptions animator].alphaValue = 0;
            [NSAppDelegate.modeMap changeModeOption:kRepeatAlarmEnabled to:[NSNumber numberWithBool:NO]];
        } else {
            [boxRepeatConstraint animator].constant = kRepeatHeight;
            [boxRepeatOptions animator].alphaValue = 1;
            [NSAppDelegate.modeMap changeModeOption:kRepeatAlarmEnabled to:[NSNumber numberWithBool:YES]];
        }
    }];
}

- (IBAction)changeRepeatDays:(id)sender {
    NSUInteger i = 0;
    NSMutableArray *selectedDays = [[NSMutableArray alloc] init];
    while (i < segRepeatDays.segmentCount) {
        [selectedDays addObject:[NSNumber numberWithBool:[segRepeatDays isSelectedForSegment:i]]];
        i++;
    }
    [NSAppDelegate.modeMap changeModeOption:kRepeatAlarmDays to:selectedDays];
    [self updateRepeatAlarmLabel];
}

- (IBAction)changeRepeatTime:(id)sender {
    NSInteger alarmTime = [sliderRepeatTime integerValue];
    [NSAppDelegate.modeMap changeModeOption:kRepeatAlarmTime to:[NSNumber numberWithInteger:alarmTime]];
    [self updateRepeatAlarmLabel];
}

- (void)updateRepeatAlarmLabel {
    NSInteger repeatAlarmTime = [[NSAppDelegate.modeMap modeOptionValue:kRepeatAlarmTime] integerValue];
    id days = [NSAppDelegate.modeMap modeOptionValue:kRepeatAlarmDays];
    NSArray *repeatDays = (NSArray *)days;
    NSInteger selectedDays = 0;
    NSInteger i = 0;
    while (i < [repeatDays count]) {
        if ([[repeatDays objectAtIndex:i] boolValue]) {
            selectedDays++;
        }
        i++;
    }
    
    NSString *label = [NSString stringWithFormat:@"%ld, %ld %@ a week", (long)repeatAlarmTime, (long)selectedDays, selectedDays == 1 ? @"day" : @"days"];
    [textRepeatTime setStringValue:label];
}

@end
