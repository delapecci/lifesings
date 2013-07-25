//
//  BWDayTableViewCell.m
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//

#import "LSMyDayTableViewCell.h"
#import "UIColor+FlatUI.h"
#import "UISlider+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "LSManagedObjectContextHelper.h"
#import "LSDateHelper.h"
#import "UIImage+FlatUI.h"

#import <QuartzCore/QuartzCore.h>

#define VALUE_MAX 32

@implementation LSMyDayTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    }
    return self;
}

- (void)configureWithMyDay:(LSMyDay *)myDay {
    if (myDay == nil)
        return;
    _myDay = myDay;
    self.smileSlider.value = myDay.smileValue;
    self.dateLabel.text = [[self dateFormatter] stringFromDate:myDay.date];
    UIImage *thumbImg = [UIImage imageWithImage:[UIImage imageNamed:@"music2"] scaledToSize:CGSizeMake(24, 24)] ;
    UIImage *thumbImgHighlighted = [UIImage imageWithImage:[UIImage imageNamed:@"music"] scaledToSize:CGSizeMake(24, 24)] ;
    [self.smileSlider setThumbImage:thumbImg forState:UIControlStateNormal];
    [self.smileSlider setThumbImage:thumbImgHighlighted forState:UIControlStateHighlighted];
    
    UIImage *progressImage = [[UIImage imageWithColor:[UIColor whiteColor]
                                         cornerRadius:.0f]
                              imageWithMinimumSize:CGSizeMake(10, 5)];
    UIImage *trackImage = [[UIImage imageWithColor:[UIColor blackColor]
                                      cornerRadius:.0f]
                           imageWithMinimumSize:CGSizeMake(10, 5)];
    
    [self.smileSlider setMinimumTrackImage:progressImage forState:UIControlStateNormal];
    [self.smileSlider setMaximumTrackImage:trackImage forState:UIControlStateNormal];
    
//    [self.smileSlider configureFlatSliderWithTrackColor:[UIColor blackColor]
//                                          progressColor:[UIColor whiteColor]
//                                       thumbColorNormal:[UIColor clearColor]
//                                  thumbColorHighlighted:[UIColor clearColor]
//                                           cornerRadius:0.0];
//    self.smileSlider.layer.borderWidth = .5f;
//    self.smileSlider.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [self.smileSlider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventTouchUpInside];

    NSDate *currentDate = [NSDate date];
    NSInteger diffDays = [LSDateHelper daysDiffBetweenDate:myDay.date andDate:currentDate];
    
    if (diffDays < 3) {
        self.dateLabel.font = [UIFont flatFontOfSize:25];
    }
    if (diffDays == 0) {
        self.dateLabel.textColor = [UIColor emerlandColor];
        self.dateLabel.text = @"今天";
    } else if (diffDays == 1) {
        self.dateLabel.textColor = [UIColor greenSeaColor];
        self.dateLabel.text = @"昨天";
    } else if (diffDays == 2) {
        self.dateLabel.textColor = [UIColor greenSeaColor];
        self.dateLabel.text = @"前天";
    } else {
        self.dateLabel.font = [UIFont flatFontOfSize:15];
        self.dateLabel.textColor = [UIColor darkTextColor];
        self.smileSlider.userInteractionEnabled = NO;
    }
}

#pragma mark - Events handler
-(void)changeSlider:(id)sender {
    UISlider *slider=(UISlider *)sender;
    float sliderValue=(float)(slider.value );
    //NSLog(@"sliderValue = %f",sliderValue);
    
    LSMyDay *toSaveLSMyDay = self.myDay;
    toSaveLSMyDay.smileValue = sliderValue;
    toSaveLSMyDay.lastModifiedDate = [NSDate date];
    
    // save LSMyDay
    NSError *error;
	if (![[LSManagedObjectContextHelper getDefaultMOC] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
}

#pragma mark - static initialize
// A date formatter for the creation date.
- (NSDateFormatter *)dateFormatter
{
    return [[self class] dateFormatter];
}


static NSDateFormatter *sDateFormatter = nil;

+ (NSDateFormatter *)dateFormatter
{
	if (sDateFormatter == nil) {
		sDateFormatter = [[NSDateFormatter alloc] init];
		[sDateFormatter setDateFormat:@"M月d日"];
	}
    return sDateFormatter;
}


@end
