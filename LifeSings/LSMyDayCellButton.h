//
// @file $FILE_NAME
// Created by lichong on 13-10-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface LSMyDayCellButton : UIButton
@property (nonatomic,strong) UIColor * buttonNormalColor;
@property (nonatomic,strong) UIColor * buttonHighlightedColor;
@property (nonatomic) UIColor *buttonSelectedColor;

@property (nonatomic,strong) UIColor * shadowNormalColor;
@property (nonatomic,strong) UIColor * shadowHighlightedColor;

-(UIColor *)buttonColorForState:(UIControlState)state;
-(void)setButtonColor:(UIColor *)color forState:(UIControlState)state;

-(UIColor *)shadowColorForState:(UIControlState)state;
-(void)setShadowColor:(UIColor *)color forState:(UIControlState)state;
@end