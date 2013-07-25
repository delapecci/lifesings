//
//  BWDayTableViewCell.h
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMyDay.h"
@class LSMyDay;
@interface LSMyDayTableViewCell : UITableViewCell
@property (nonatomic, readonly) LSMyDay *myDay;
@property (nonatomic, weak) IBOutlet UIViewController *delegate;
@property (weak, nonatomic) IBOutlet UISlider *smileSlider;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

- (void)configureWithMyDay:(LSMyDay *)myDay;

@end
