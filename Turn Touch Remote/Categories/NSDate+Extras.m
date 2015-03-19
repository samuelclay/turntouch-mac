//
//  TTDate+Extras.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/22/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "NSDate+Extras.h"

@implementation NSDate (Extra)

#pragma mark - Date Helpers

+ (NSDate *)midnightToday {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    NSDate *midnightOfToday = [cal dateFromComponents:comps];
    
    return midnightOfToday;
}

@end
