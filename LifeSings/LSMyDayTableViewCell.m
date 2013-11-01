//
//  BWDayTableViewCell.m
//  TaggedLocations
//
//  Created by lichong on 13-7-3.
//  Copyright (c) 2013年 Apple Inc. All rights reserved.
//
#include "Log-Prefix.pch"
#import "LSMyDayTableViewCell.h"
#import "UIColor+FlatUI.h"
#import "UISlider+FlatUI.h"
#import "UINavigationBar+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "LSManagedObjectContextHelper.h"
#import "LSDateHelper.h"
#import "UIImage+FlatUI.h"
#import "SoundManager.h"
#import "LSMyDayCellButton.h"
#import "LSMyDayCellPlayButton.h"

#import <QuartzCore/QuartzCore.h>

#define VALUE_MAX 32

@implementation LSMyDayTableViewCell {
    UIButton *_recordVoiceButton;
    UIButton *_playVoiceButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier containingTableView:(UITableView *)containingTableView leftUtilityButtons:(NSArray *)leftUtilityButtons rightUtilityButtons:(NSArray *)rightUtilityButtons {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier containingTableView:containingTableView leftUtilityButtons:leftUtilityButtons rightUtilityButtons:rightUtilityButtons];
    if (self) {
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.dateLabel.backgroundColor = [UIColor clearColor];
        self.dateLabel.adjustsFontSizeToFitWidth = YES;
        self.dateLabel.numberOfLines = 2;
        [self.contentView addSubview:self.dateLabel];
        self.smileSlider = [[UISlider alloc]initWithFrame:CGRectZero];
        self.smileSlider.minimumValue = 1;
        self.smileSlider.maximumValue = 32;
        self.smileSlider.continuous = YES;
        [self.contentView addSubview:self.smileSlider];
        
        [self setBackgroundColor:[UIColor cloudsColor]];
        self.contentView.backgroundColor = [UIColor cloudsColor];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //CGFloat marginX = 10.0;
    // default frame as nib
    self.dateLabel.frame = CGRectMake(10.0f, 2.0f,
                                      100.0f, self.frame.size.height);
    self.smileSlider.frame = CGRectMake(116.0f, 2.0f,
                                        196.0f, self.frame.size.height);
    
//    NSLayoutConstraint *dateLabelWidthConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:100.0f];
//    NSLayoutConstraint *dateLabelLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.dateLabel.superview attribute: NSLayoutAttributeLeading multiplier:1 constant:10.0f];
//    NSLayoutConstraint *dateLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dateLabel.superview attribute:NSLayoutAttributeTop multiplier:1 constant:4.0f];
//    NSLayoutConstraint *dateLabelBottomConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.dateLabel.superview attribute:NSLayoutAttributeBottom multiplier:1 constant:2.0f];
//    NSLayoutConstraint *dateLabelTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.smileSlider attribute:NSLayoutAttributeLeading multiplier:1.0f constant:10.0f];
//    
//    [self.contentView addConstraint:dateLabelWidthConstraint];
//    [self.contentView addConstraint:dateLabelLeadingConstraint];
//    [self.contentView addConstraint:dateLabelTopConstraint];
//    [self.contentView addConstraint:dateLabelBottomConstraint];
//    [self.contentView addConstraint:dateLabelTrailingConstraint];

//    NSLayoutConstraint *sliderLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.smileSlider attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.dateLabel attribute:NSLayoutAttributeTrailing multiplier:1 constant:10.0f];
//    NSLayoutConstraint *sliderTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.smileSlider attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.smileSlider.superview attribute:NSLayoutAttributeTrailing multiplier:1 constant:10.0f];
//    NSLayoutConstraint *sliderCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.smileSlider attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.smileSlider.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
//    [self.contentView addConstraint:sliderCenterYConstraint];
//    [self.contentView addConstraint:sliderLeadingConstraint];
//    [self.contentView addConstraint:sliderTrailingConstraint];
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
    [self.smileSlider addTarget:self action:@selector(changeSlider:) forControlEvents:UIControlEventValueChanged];
    [self.smileSlider addTarget:self action:@selector(saveSlider:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];

    NSDate *currentDate = [NSDate date];
    NSInteger diffDays = [LSDateHelper daysDiffBetweenDate:myDay.date andDate:currentDate];
    DDLogInfo(@"diffDays=%d", diffDays);
    if (diffDays < 3) {
        NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
        // 中文环境时，设置字体更大
        if ([language isEqualToString:@"zh-Hans"] || [language isEqualToString:@"zh-Hant"])
            self.dateLabel.font = [UIFont flatFontOfSize:25];
        else
            self.dateLabel.font = [UIFont flatFontOfSize:21];
        self.smileSlider.userInteractionEnabled = YES;

        if ([self.rightUtilityButtons count] <= 1) {
            LSMyDayCellButton *button = [[LSMyDayCellButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
            [button setButtonNormalColor:[UIColor colorWithRed:1.0f green:102/255 blue:102/255 alpha:1.0f]];
            [button setButtonHighlightedColor:[UIColor grayColor]];
            button.backgroundColor = [UIColor silverColor];
            [button addTarget:self action:@selector(recordVoice:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
            _recordVoiceButton = button;
            [self addRightUtilityButtonWithPredefined:button];
        }
    } else {
        self.smileSlider.userInteractionEnabled = NO;
    }
    if (self.myDay.voiceMemoName != nil && ![self.myDay.voiceMemoName isEqualToString:@""]) {
        if ([self.rightUtilityButtons count] <= 1) {
            /*
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            //button.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1.0];
            [button setImage:[UIImage imageNamed:@"play" ] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"stop" ] forState:UIControlStateSelected]; */
            LSMyDayCellPlayButton *button = [[LSMyDayCellPlayButton alloc] init];
            button.backgroundColor = [UIColor silverColor];
            [button setButtonNormalColor:[UIColor greenSeaColor]];
            [button setButtonHighlightedColor:[UIColor grayColor]];
            [button setButtonColor:[UIColor colorWithRed:1.0f green:102/255 blue:102/255 alpha:1.0f]
                          forState:UIControlStateSelected];
            [button addTarget:self action:@selector(togglePlayVoice:)
             forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
            _playVoiceButton = button;
            [self addRightUtilityButtonWithPredefined:button];
        }

        // 预先准备声音
        [[SoundManager sharedManager] prepareToPlayWithSound:[self voiceMemoFilePath]];
    }
    
    if (diffDays == 0) {
        self.dateLabel.textColor = [UIColor emerlandColor];
        self.dateLabel.text = NSLocalizedString( @"Today", nil);
    } else if (diffDays == 1) {
        self.dateLabel.textColor = [UIColor greenSeaColor];
        self.dateLabel.text = NSLocalizedString( @"Yesterday", nil);
    } else if (diffDays == 2) {
        self.dateLabel.textColor = [UIColor greenSeaColor];
        self.dateLabel.text = NSLocalizedString( @"DayBeforeYesterday", nil);
    } else {
        self.dateLabel.font = [UIFont flatFontOfSize:19];
        self.dateLabel.textColor = [UIColor darkTextColor];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(stopPlayVoice:)
                                                 name:SoundDidFinishPlayingNotification
                                               object:nil];
}

#pragma mark - Events handler
- (void)recordVoice:(id)sender
{
    [(self.delegate) recordVoiceMemoForCell:self];
}

- (void)togglePlayVoice:(id)sender {
    UIButton *playButton = (UIButton *)sender;
    // 播放语音
    if (playButton.selected) {
        playButton.selected = NO;
        [[SoundManager sharedManager] stopMusic:NO];
    } else {
        playButton.selected = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopPlayVoice:)
                                                     name:SoundDidFinishPlayingNotification
                                                   object:nil];

        Float32 volume;
        UInt32 dataSize = sizeof(Float32);
        AudioSessionGetProperty (
                kAudioSessionProperty_CurrentHardwareOutputVolume,
                &dataSize,
                &volume
        );
        //NSLog(@"Volume Level : %f",volume);
        [SoundManager sharedManager].musicVolume = volume;
        [[SoundManager sharedManager] playMusic:[self voiceMemoFilePath] looping:NO fadeIn:NO];
        _recordVoiceButton.enabled = NO;
    }
}

-(void)saveSlider:(id)sender {
    UISlider *slider=(UISlider *)sender;
    int sliderValue=(int)(slider.value );
    //DDLogVerbose(@"sliderValue = %f",sliderValue);
    
    LSMyDay *toSaveLSMyDay = self.myDay;
    toSaveLSMyDay.smileValue = sliderValue;
    toSaveLSMyDay.lastModifiedDate = [NSDate date];
    
    //save LSMyDay
    //FIXME: 怎样才能准确的，在slider滑动结束时保存数据？
    NSError *error;
	if (![[LSManagedObjectContextHelper getDefaultMOC] save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}

}
-(void)changeSlider:(id)sender {
    UISlider *slider=(UISlider *)sender;
    int sliderValue=(int)(slider.value );
    //DDLogVerbose(@"sliderValue = %f",sliderValue);
    
    if ([self.delegate respondsToSelector:@selector(onSliderValueChanged:)]) {
        [self.delegate onSliderValueChanged:sliderValue];
    }
}

#pragma mark - 播放语音消息监听
- (void)stopPlayVoice:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:SoundDidFinishPlayingNotification
                                               object:nil];
    _playVoiceButton.selected = NO; // 恢复播放按钮
    _recordVoiceButton.enabled = YES;
}

#pragma mark - static initialize
// A date formatter for the creation date.
- (NSDateFormatter *)dateFormatter
{
    return [[self class] dateFormatter];
}

- (NSString *)voiceMemoFilePath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyyMMdd"];
    NSString *voiceMemoFileName = [NSString stringWithFormat:@"%@.caf", [formatter stringFromDate:_myDay.date]];
    // 弹出录音提示
    NSString *voiceMemoPath = [NSString stringWithFormat:@"%@/Documents/%@",
                                                         NSHomeDirectory(), voiceMemoFileName];
    return voiceMemoPath;
}

static NSDateFormatter *sDateFormatter = nil;

+ (NSDateFormatter *)dateFormatter
{
	if (sDateFormatter == nil) {
		sDateFormatter = [[NSDateFormatter alloc] init];
		[sDateFormatter setDateFormat:NSLocalizedString(@"DateFormatStr", nil)];
	}
    return sDateFormatter;
}

@end
