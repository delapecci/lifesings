//
//  UISlider+FlatUI.m
//  FlatUI
//
//  Created by Jack Flintermann on 5/3/13.
//  Copyright (c) 2013 Jack Flintermann. All rights reserved.
//

#import "UISlider+FlatUI.h"
#import "UIImage+FlatUI.h"

@implementation UISlider (FlatUI)

- (void) configureFlatSliderWithTrackColor:(UIColor *)trackColor
                             progressColor:(UIColor *)progressColor
                                thumbColor:(UIColor *)thumbColor {
    
    [self configureFlatSliderWithTrackColor:trackColor
                              progressColor:progressColor
                           thumbColorNormal:thumbColor
                      thumbColorHighlighted:thumbColor
                               cornerRadius:5.0];
}

- (void) configureFlatSliderWithTrackColor:(UIColor *)trackColor
                             progressColor:(UIColor *)progressColor
                          thumbColorNormal:(UIColor *)normalThumbColor
                     thumbColorHighlighted:(UIColor *)highlightedThumbColor
                              cornerRadius:(float)cornerRadius
{
    
    UIImage *progressImage = [[UIImage imageWithColor:progressColor
                               //andStrokeColor:trackColor andStrokeWidth:1.0f
                                         cornerRadius:cornerRadius]
                              imageWithMinimumSize:CGSizeMake(10, 10)];
    UIImage *trackImage = [[UIImage imageWithColor:trackColor
                            //andStrokeColor:trackColor andStrokeWidth:1.0f
                                      cornerRadius:cornerRadius]
                           imageWithMinimumSize:CGSizeMake(10, 10)];
    
    [self setMinimumTrackImage:progressImage forState:UIControlStateNormal];
    [self setMaximumTrackImage:trackImage forState:UIControlStateNormal];
    
    float normalThumbWidth = 24;
    if ([normalThumbColor isEqual:[UIColor clearColor]]) {
        normalThumbWidth = 14;
    }
    UIImage *normalSliderImage = [UIImage circularImageWithColor:normalThumbColor size:CGSizeMake(normalThumbWidth, normalThumbWidth)];
    [self setThumbImage:normalSliderImage forState:UIControlStateNormal];
    
    UIImage *highlighedSliderImage = [UIImage circularImageWithColor:highlightedThumbColor size:CGSizeMake(normalThumbWidth, normalThumbWidth)];
    [self setThumbImage:highlighedSliderImage forState:UIControlStateHighlighted];
}

@end
