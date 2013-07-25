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

@end
