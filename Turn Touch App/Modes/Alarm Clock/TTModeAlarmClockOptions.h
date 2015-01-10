//
//  TTModeAlarmClockOptionsView.h
//  Turn Touch App
//
//  Created by Samuel Clay on 5/13/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailView.h"

@interface TTModeAlarmClockOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSBox *boxRepeatOptions;
@property (nonatomic) IBOutlet NSBox *boxOnetimeOptions;
@property (nonatomic) IBOutlet NSLayoutConstraint *boxRepeatConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *boxOnetimeConstraint;
@property (nonatomic) IBOutlet NSSegmentedControl *segRepeatControl;
@property (nonatomic) IBOutlet NSSegmentedControl *segOnetimeControl;

- (IBAction)changeSegRepeatControl:(id)sender;
- (IBAction)changeSegOnetimeControl:(id)sender;

@end
