//
//  TTNewsBlurUtilities.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/9/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTNewsBlurUtilities.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation TTNewsBlurUtilities

+ (NSString *)md5:(NSString *)string {
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)formatLongDateFromTimestamp:(NSInteger)timestamp {
    if (!timestamp) timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(double)timestamp];
    
    static NSCalendar *calendar = nil;
    static NSDateFormatter *todayFormatter = nil;
    static NSDateFormatter *otherFormatter = nil;
    
    if (!calendar || !todayFormatter || !otherFormatter) {
        calendar = [NSCalendar currentCalendar];
        
        todayFormatter = [NSDateFormatter new];
        todayFormatter.dateStyle = NSDateFormatterNoStyle;
        todayFormatter.timeStyle = NSDateFormatterShortStyle;
        
        otherFormatter = [NSDateFormatter new];
        otherFormatter.dateStyle = NSDateFormatterLongStyle;
        otherFormatter.timeStyle = NSDateFormatterShortStyle;
        otherFormatter.doesRelativeDateFormatting = YES;
    }
    
    return [otherFormatter stringFromDate:date];
    
    
    
    
    
    /*
     static NSDateFormatter *dateFormatter = nil;
     static NSDateFormatter *todayFormatter = nil;
     static NSDateFormatter *yesterdayFormatter = nil;
     static NSDateFormatter *formatterPeriod = nil;
     
     NSDate *today = [NSDate date];
     NSDateComponents *components = [[NSCalendar currentCalendar]
     components:NSIntegerMax
     fromDate:today];
     [components setHour:0];
     [components setMinute:0];
     [components setSecond:0];
     NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
     NSDate *yesterday = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:midnight];
     
     if (!dateFormatter || !todayFormatter || !yesterdayFormatter || !formatterPeriod) {
     dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"EEEE, MMMM d'Sth', y h:mm"];
     todayFormatter = [[NSDateFormatter alloc] init];
     [todayFormatter setDateFormat:@"'Today', MMMM d'Sth' h:mm"];
     yesterdayFormatter = [[NSDateFormatter alloc] init];
     [yesterdayFormatter setDateFormat:@"'Yesterday', MMMM d'Sth' h:mm"];
     formatterPeriod = [[NSDateFormatter alloc] init];
     [formatterPeriod setDateFormat:@"a"];
     }
     
     NSString *dateString;
     if ([date compare:midnight] == NSOrderedDescending) {
     dateString = [NSString stringWithFormat:@"%@%@",
     [todayFormatter stringFromDate:date],
     [[formatterPeriod stringFromDate:date] lowercaseString]];
     } else if ([date compare:yesterday] == NSOrderedDescending) {
     dateString = [NSString stringWithFormat:@"%@%@",
     [yesterdayFormatter stringFromDate:date],
     [[formatterPeriod stringFromDate:date] lowercaseString]];
     } else {
     dateString = [NSString stringWithFormat:@"%@%@",
     [dateFormatter stringFromDate:date],
     [[formatterPeriod stringFromDate:date] lowercaseString]];
     }
     dateString = [dateString stringByReplacingOccurrencesOfString:@"Sth"
     withString:[Utilities suffixForDayInDate:date]];
     
     return dateString;
     */
}

+ (NSString *)formatShortDateFromTimestamp:(NSInteger)timestamp {
    if (!timestamp) timestamp = [[NSDate date] timeIntervalSince1970];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:(double)timestamp];
    
    static NSCalendar *calendar = nil;
    static NSDateFormatter *todayFormatter = nil;
    static NSDateFormatter *otherFormatter = nil;
    
    if (!calendar || !todayFormatter || !otherFormatter) {
        calendar = [NSCalendar currentCalendar];
        
        todayFormatter = [NSDateFormatter new];
        todayFormatter.dateStyle = NSDateFormatterNoStyle;
        todayFormatter.timeStyle = NSDateFormatterShortStyle;
        
        otherFormatter = [NSDateFormatter new];
        otherFormatter.dateStyle = NSDateFormatterMediumStyle;
        otherFormatter.timeStyle = NSDateFormatterShortStyle;
        otherFormatter.doesRelativeDateFormatting = YES;
    }
    
    if ([calendar isDateInToday:date]) {
        return [todayFormatter stringFromDate:date];
    } else {
        return [otherFormatter stringFromDate:date];
    }
    
    /*
     static NSDateFormatter *dateFormatter = nil;
     static NSDateFormatter *todayFormatter = nil;
     static NSDateFormatter *yesterdayFormatter = nil;
     static NSDateFormatter *formatterPeriod = nil;
     
     NSDate *today = [NSDate date];
     NSDateComponents *components = [[NSCalendar currentCalendar]
     components:NSIntegerMax
     fromDate:today];
     [components setHour:0];
     [components setMinute:0];
     [components setSecond:0];
     NSDate *midnight = [[NSCalendar currentCalendar] dateFromComponents:components];
     NSDate *yesterday = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:midnight];
     
     if (!dateFormatter || !todayFormatter || !yesterdayFormatter || !formatterPeriod) {
     dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"dd LLL y, h:mm"];
     todayFormatter = [[NSDateFormatter alloc] init];
     [todayFormatter setDateFormat:@"h:mm"];
     yesterdayFormatter = [[NSDateFormatter alloc] init];
     [yesterdayFormatter setDateFormat:@"'Yesterday', h:mm"];
     formatterPeriod = [[NSDateFormatter alloc] init];
     [formatterPeriod setDateFormat:@"a"];
     }
     
     NSString *dateString;
     if ([date compare:midnight] == NSOrderedDescending) {
     dateString = [NSString stringWithFormat:@"%@%@",
     [todayFormatter stringFromDate:date],
     [[formatterPeriod stringFromDate:date] lowercaseString]];
     } else if ([date compare:yesterday] == NSOrderedDescending) {
     dateString = [NSString stringWithFormat:@"%@%@",
     [yesterdayFormatter stringFromDate:date],
     [[formatterPeriod stringFromDate:date] lowercaseString]];
     } else {
     dateString = [NSString stringWithFormat:@"%@%@",
     [dateFormatter stringFromDate:date],
     [[formatterPeriod stringFromDate:date] lowercaseString]];
     }
     
     return dateString;
     */
}

/*
 + (NSString *)suffixForDayInDate:(NSDate *)date {
 NSInteger day = [[[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]
 components:NSCalendarUnitDay fromDate:date] day];
 if (day == 11 || day == 12 || day == 13) {
 return @"th";
 } else if (day % 10 == 1) {
 return @"st";
 } else if (day % 10 == 2) {
 return @"nd";
 } else if (day % 10 == 3) {
 return @"rd";
 } else {
 return @"th";
 }
 }
 */


@end
