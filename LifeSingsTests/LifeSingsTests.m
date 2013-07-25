//
//  LifeSingsTests.m
//  LifeSingsTests
//
//  Created by lichong on 13-7-11.
//  Copyright (c) 2013年 Li Chong. All rights reserved.
//

#import "LifeSingsTests.h"
#import "LSDateHelper.h"

@implementation LifeSingsTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSDate *currentDate = [NSDate date];
    NSDate *oneYearAgoDate = [NSDate dateWithTimeIntervalSinceReferenceDate:409968000l];
    NSInteger diffDays = [LSDateHelper daysDiffBetweenDate:currentDate andDate:oneYearAgoDate];
    NSLog(@"diffDays=%d", diffDays);
    //STFail(@"Unit tests are not implemented yet in LifeSingsTests");
}

@end
