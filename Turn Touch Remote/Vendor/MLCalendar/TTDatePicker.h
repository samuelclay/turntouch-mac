//
//  TTDatePicker.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLCalendarView.h"

@interface TTDatePicker : NSDatePicker <NSPopoverDelegate> {
    BOOL isOpen;
}

@property (nonatomic, strong) IBOutlet NSPopover *calendarPopover;
@property (nonatomic, strong) IBOutlet MLCalendarView *calendarView;

@end
