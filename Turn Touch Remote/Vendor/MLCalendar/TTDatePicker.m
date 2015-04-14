//
//  TTDatePicker.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTDatePicker.h"
#import "MLCalendarView.h"

@implementation TTDatePicker

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (BOOL)becomeFirstResponder {
    if (isOpen) {
//        isOpen = NO;
//        [self resignFirstResponder];
    } else {
        isOpen = YES;
        [self showCalendar];
    }
    
    return NO;
}

- (void)createCalendarPopover {
    NSPopover* myPopover = self.calendarPopover;
    if(!myPopover) {
        myPopover = [[NSPopover alloc] init];
        self.calendarView = [[MLCalendarView alloc] init];
        self.calendarView.delegate = (id<MLCalendarViewDelegate>)self.delegate;
        myPopover.contentViewController = self.calendarView;
        myPopover.appearance = (NSPopoverAppearance)[NSAppearance appearanceNamed:NSAppearanceNameAqua];
        myPopover.animates = YES;
        myPopover.behavior = NSPopoverBehaviorTransient;
        myPopover.delegate = self;
    }
    self.calendarPopover = myPopover;
}

- (void)showCalendar {
    [self createCalendarPopover];
    NSDate* date = self.dateValue;
    self.calendarView.date = date;
    self.calendarView.selectedDate = date;
    NSRect cellRect = [self bounds];
    [self.calendarPopover showRelativeToRect:cellRect ofView:self preferredEdge:NSMaxYEdge];
}

- (void)popoverWillClose:(NSNotification *)notification {
    isOpen = NO;
    [self resignFirstResponder];
    
    if([self.calendarView.delegate respondsToSelector:@selector(didSelectDate:)]) {
        [self.calendarView.delegate didSelectDate:self.calendarView.selectedDate];
    }
}


@end
