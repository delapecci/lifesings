//
// @file $FILE_NAME
// Created by lichong on 13-10-22.
// Copyright (c) 2013 Li Chong. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LSMyDayCellButton.h"


@implementation LSMyDayCellButton {

}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setButtonNormalColor:[[UIColor whiteColor] colorWithAlphaComponent:0.9f]];
        [self setButtonHighlightedColor:[UIColor colorWithRed:139.0/255.0
                                                            green:135.0/255.0
                                                             blue:136.0/255.0
                                                            alpha:0.9f]];
        [self setShadowNormalColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
        [self setShadowHighlightedColor:[[UIColor blackColor] colorWithAlphaComponent:0.2f]];
    }
    return self;
}

-(UIColor *)buttonColorForState:(UIControlState)state{
    UIColor * color;
    switch (state) {
        case UIControlStateNormal:
            color = self.buttonNormalColor;
            break;
        case UIControlStateHighlighted:
            color = self.buttonHighlightedColor;
            break;
        case UIControlStateSelected:
            color = self.buttonSelectedColor;
            break;
        case UIControlStateDisabled:
            color = [UIColor darkGrayColor];    // FIXME: 暂时固定一种颜色
            break;
        default:
            break;
    }
    return color;
}

-(void)setButtonColor:(UIColor *)color forState:(UIControlState)state{
    switch (state) {
        case UIControlStateNormal:
            [self setButtonNormalColor:color];
            break;
        case UIControlStateHighlighted:
            [self setButtonHighlightedColor:color];
            break;
        case UIControlStateSelected:
            [self setButtonSelectedColor:color];
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
}

-(UIColor *)shadowColorForState:(UIControlState)state{
    UIColor * color;
    switch (state) {
        case UIControlStateNormal:
            color = self.shadowNormalColor;
            break;
        case UIControlStateHighlighted:
            color = self.shadowHighlightedColor;
            break;
        // FIXME: 暂时固定一种颜色
        case UIControlStateSelected:
            color = self.shadowHighlightedColor;
            break;
        case UIControlStateDisabled:
            color = self.shadowHighlightedColor;
            break;
        default:
            break;
    }
    return color;
}

-(void)setShadowColor:(UIColor *)color forState:(UIControlState)state{
    switch (state) {
        case UIControlStateNormal:
            [self setShadowNormalColor:color];
            break;
        case UIControlStateHighlighted:
            [self setShadowHighlightedColor:color];
            break;
        default:
            break;
    }
    [self setNeedsDisplay];
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
    UIColor* shadow =  shadowColor;
    CGSize shadowOffset = CGSizeMake(0.0, 1.0);
    CGFloat shadowBlurRadius = 0;

    //// Top Bun Drawing
    CGFloat pathWidth = MIN(buttonWidth, buttonHeight);
    UIBezierPath* recordImgPath = [UIBezierPath bezierPathWithOvalInRect:
            CGRectMake((CGRectGetWidth(self.bounds) - pathWidth)/2,
            (CGRectGetHeight(self.bounds) - pathWidth)/2, pathWidth, pathWidth)];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [buttonColor setFill];
    [recordImgPath fill];
    CGContextRestoreGState(context);

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    [self setNeedsDisplay];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}
@end