//
//  LSDateHelper.m
//  LifeSings
//
//  Created by lichong on 13-7-12.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import "LSDateHelper.h"

@implementation LSDateHelper
+ (NSInteger)daysDiffBetweenDate:(NSDate *)expectedEarlierDate andDate:(NSDate *)expectedFutureDate
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    unsigned int unitFlags = NSDayCalendarUnit;
    NSDateComponents *diffComps = [currentCalendar components:unitFlags fromDate:expectedEarlierDate toDate:expectedFutureDate options:0];
    
    return [diffComps day];
}

+ (NSDate *)dateWithoutTime:(NSDate *)dateWithTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:dateWithTime];
    NSDate *todayDateWithoutTime = [calendar dateFromComponents:components];
    return todayDateWithoutTime;
}

+ (NSDate *)rollDays:(NSInteger)offset fromDate:(NSDate *)date {
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *rollDaysComponents = [[NSDateComponents alloc] init];
    rollDaysComponents.day = offset;
    return [currentCalendar dateByAddingComponents:rollDaysComponents toDate:date options:0];
}
+ (NSInteger)yearOfDate:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear fromDate:date];
    return comps.year;
}
@end
