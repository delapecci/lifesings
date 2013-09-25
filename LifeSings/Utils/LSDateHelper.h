//
//  LSDateHelper.h
//  LifeSings
//
//  Created by lichong on 13-7-12.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSDateHelper : NSObject

/**
 * 获取两个日期之间的天数差别
 */
+ (NSInteger)daysDiffBetweenDate:(NSDate *)expectedEarlierDate andDate:(NSDate *)expectedFutureDate;

/**
 * 转换指定日期为不带时间不分的日期
 */
+ (NSDate *)dateWithoutTime:(NSDate *)dateWithTime;

+ (NSDate *)rollDays:(NSInteger)offset fromDate:(NSDate *)date;

@end
