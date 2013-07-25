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
@end
