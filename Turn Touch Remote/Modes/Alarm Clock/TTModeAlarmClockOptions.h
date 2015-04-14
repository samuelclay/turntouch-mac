//
//  TTModeAlarmClockOptionsView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/13/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailView.h"
#import "TTDatePicker.h"

@interface TTModeAlarmClockOptions : TTOptionsDetailViewController <MLCalendarViewDelegate, NSDatePickerCellDelegate>

@property (nonatomic) IBOutlet NSBox *boxRepeatOptions;
@property (nonatomic) IBOutlet NSBox *boxOnetimeOptions;
@property (nonatomic) IBOutlet NSLayoutConstraint *boxRepeatConstraint;
@property (nonatomic) IBOutlet NSLayoutConstraint *boxOnetimeConstraint;
@property (nonatomic) IBOutlet NSSegmentedControl *segRepeatControl;
@property (nonatomic) IBOutlet NSSegmentedControl *segOnetimeControl;

@property (nonatomic) IBOutlet NSSegmentedControl *segRepeatDays;
@property (nonatomic) IBOutlet NSSlider *sliderRepeatTime;
@property (nonatomic) IBOutlet NSTextField *textRepeatTime;

@property (nonatomic) IBOutlet TTDatePicker *datePicker;

@property (nonatomic) IBOutlet NSSlider *sliderOnetimeTime;
@property (nonatomic) IBOutlet NSTextField *textOnetimeLabel;

@property (nonatomic) IBOutlet NSSlider *sliderAlarmVolume;
@property (nonatomic) IBOutlet NSTextField *textAlarmVolume;
@property (nonatomic) IBOutlet NSSlider *sliderAlarmDuration;
@property (nonatomic) IBOutlet NSTextField *textAlarmDuration;
@property (nonatomic) IBOutlet NSPopUpButton *dropdowniTunesSources;
@property (nonatomic) IBOutlet NSButton *checkboxShuffle;
@property (nonatomic) IBOutlet NSTextField *textTracksCount;
@property (nonatomic) IBOutlet NSButton *previewAlarmButton;

- (IBAction)changeSegRepeatControl:(id)sender;
- (IBAction)changeSegOnetimeControl:(id)sender;
- (IBAction)changeRepeatDays:(id)sender;
- (IBAction)changeRepeatTime:(id)sender;
- (IBAction)changeOnetimeDate:(id)sender;
- (IBAction)changeOnetimeTime:(id)sender;
- (IBAction)changeAlarmVolume:(id)sender;
- (IBAction)changeAlarmDuration:(id)sender;
- (IBAction)changeiTunesSource:(id)sender;
- (IBAction)changeShuffle:(id)sender;
- (IBAction)previewAlarm:(id)sender;

@end
