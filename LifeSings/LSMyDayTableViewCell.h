//
//  BWDayTableViewCell.h
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMyDay.h"
#import "SWTableViewCell.h"
#pragma mark - 音符滑块变化事件协议
@protocol SmileSliderChangedDelegate <NSObject>
@required
- (void)onSliderValueChanged:(int)newVal;

@optional

@end

#pragma mark -
@class LSMyDayTableViewCell;
@protocol VoiceMemoDelegate <NSObject>
@required
- (void)recordVoiceMemoForCell:(LSMyDayTableViewCell *)cell;

@optional
- (void)playVoiceMemoForCell:(LSMyDayTableViewCell *)cell;

@end

@interface LSMyDayTableViewCell : SWTableViewCell
@property (nonatomic, readonly) LSMyDay *myDay;
@property (nonatomic) id delegate;
@property (nonatomic) UISlider *smileSlider;
@property (nonatomic) UILabel *dateLabel;

- (void)configureWithMyDay:(LSMyDay *)myDay;
- (NSString *)voiceMemoFilePath;

@end
