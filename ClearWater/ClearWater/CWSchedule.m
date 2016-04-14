//
//  CWSchedule.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-10.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "CWSchedule.h"

@implementation CWSchedule

+(NSArray *)deliveryPeriods
{
    return @[@"9.00-18.00",
             @"7.00-21.00",
             @"7.00-10.00",
             @"8.00-11.00",
             @"9.00-12.00",
             @"10.00-13.00",
             @"11.00-14.00",
             @"12.00-15.00",
             @"13.00-16.00",
             @"14.00-17.00",
             @"15.00-18.00",
             @"16.00-19.00",
             @"17.00-20.00",
             @"18.00-21.00"];
}

+(NSArray *)deliveryDates
{
    // returns array of dates to month forward excluding Sundays beginning from tomorrow
    
#define DAYS_AMOUNT 30
#define SEC_IN_DAY 60*60*24
#define WEEKDAY_SATURDAY 7
#define WEEKDAY_SUNDAY 1
    
    NSMutableArray *days = [NSMutableArray arrayWithCapacity:DAYS_AMOUNT];
    NSDate *date = [NSDate date]; // beginning from tomorrow
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    // removing time
    NSDateComponents *comps = [calendar components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    date = [calendar dateFromComponents:comps];

    // running forward through the days and add them to array
    NSInteger cntDays = 0;
    while (cntDays < DAYS_AMOUNT)
    {
        date = [date dateByAddingTimeInterval:SEC_IN_DAY];
        NSDateComponents *dcomp = [calendar components:NSCalendarUnitWeekday fromDate:date];
        if( WEEKDAY_SUNDAY == [dcomp weekday] ) {
            continue;
        }
        
        [days addObject:date];
        cntDays++;
    }

    return days;
}

@end
