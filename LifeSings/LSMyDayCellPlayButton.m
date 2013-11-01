//
// @file $FILE_NAME
// Created by lichong on 13-10-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LSMyDayCellPlayButton.h"


@implementation LSMyDayCellPlayButton {

}

-(void)drawRect:(CGRect)rect{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();

    //Sizes
    CGFloat buttonWidth = CGRectGetWidth(self.bounds)*.80;
    CGFloat buttonHeight = CGRectGetHeight(self.bounds)*.21;
    CGFloat xOffset = CGRectGetWidth(self.bounds)*.10;
    CGFloat yOffset = CGRectGetHeight(self.bounds)*.12;
    CGFloat cornerRadius = 1.0;

    //// Color Declarations
    UIColor*  buttonColor = [self buttonColorForState:self.state];
    UIColor*  shadowColor = [self shadowColorForState:self.state];

    //// Shadow Declarations
    CGSize shadowOffset = CGSizeMake(0.0, 1.0);
    CGFloat shadowBlurRadius = 0;

    //// Top Bun Drawing
    CGFloat pathWidth = MIN(buttonWidth, buttonHeight);
    if ([self isSelected]) {
        UIBezierPath* stopImgPath = [UIBezierPath bezierPathWithRect:
                CGRectMake((CGRectGetWidth(self.bounds) - pathWidth)/2,
                        (CGRectGetHeight(self.bounds) - pathWidth)/2, pathWidth, pathWidth)];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadowColor.CGColor);
        [buttonColor setFill];
        [stopImgPath fill];
        CGContextRestoreGState(context);
    } else {
        UIBezierPath* playImgPath = [UIBezierPath bezierPath];
        [playImgPath moveToPoint:CGPointMake((CGRectGetWidth(self.bounds) - pathWidth)/2,
                (CGRectGetHeight(self.bounds) - pathWidth)/2)];
        [playImgPath addLineToPoint:CGPointMake((CGRectGetWidth(self.bounds) - pathWidth)/2,
                (CGRectGetHeight(self.bounds) + pathWidth)/2)];
        [playImgPath addLineToPoint:CGPointMake((CGRectGetWidth(self.bounds) + pathWidth)/2,
                (CGRectGetHeight(self.bounds))/2)];
        [playImgPath closePath];
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadowColor.CGColor);
        [buttonColor setFill];
        [playImgPath fill];
        CGContextRestoreGState(context);
    }

}
@end