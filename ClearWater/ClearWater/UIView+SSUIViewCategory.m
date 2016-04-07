//
//  UIView+SSUIViewCategory.m
//  PayControl
//
//  Created by Rett Pop on 11.04.13.
//  Copyright (c) 2013 SapiSoft. All rights reserved.
//

#import "UIView+SSUIViewCategory.h"
#import "QuartzCore/QuartzCore.h"

@implementation UIView (SSUIViewCategory)

-(void)changeSizeWidthDelta:(CGFloat)widthDelta heightDelta:(CGFloat)heightDelta
{
    [self setSizeWidth:CGRectGetWidth(self.frame) + widthDelta newHeight:CGRectGetHeight(self.frame) + heightDelta];
}

-(void)changeFrameXDelta:(CGFloat)xDelta yDelta:(CGFloat)yDelta;
{
    self.frame = CGRectMake(self.frame.origin.x + xDelta,
                            self.frame.origin.y + yDelta,
                            self.frame.size.width,
                            self.frame.size.height);
}

-(void)setSizeWidth:(CGFloat)newWidth newHeight:(CGFloat)newHeight
{
    self.frame = CGRectMake(CGRectGetMinX(self.frame),
                            CGRectGetMinY(self.frame),
                            newWidth,
                            newHeight);
}

-(void)setNewWidth:(CGFloat)newWidth
{
    [self setSizeWidth:newWidth newHeight:self.bounds.size.height];
}

-(void)setNewHeight:(CGFloat)newHeight
{
    [self setSizeWidth:self.bounds.size.width newHeight:newHeight];
}

-(void)setWidthFromMasterView:(UIView*)master
{
    [self setNewWidth:CGRectGetWidth([master bounds])];
}

-(void)setHeightFromMasterView:(UIView*)master
{
    [self setNewHeight:CGRectGetHeight([master bounds])];
}


-(void)setFrameX:(CGFloat)newX andY:(CGFloat)newY
{
    self.frame = CGRectMake(newX,
                            newY,
                            CGRectGetWidth(self.frame),
                            CGRectGetHeight(self.frame));
}

-(void)setFrameX:(CGFloat)newX
{
    [self setFrameX:newX andY:CGRectGetMinY(self.frame)];
}

-(void)setFrameY:(CGFloat)newY
{
    [self setFrameX:CGRectGetMinX(self.frame) andY:newY];
}

-(void)alignBottomsWithMasterView:(UIView*)master
{
    //    CGPoint newXY = CGPointMake(CGRectGetMinX(master.frame), master.frame.origin.y + master.frame.size.height - CGRectGetHeight(self.frame) - 50 );
    CGPoint newXY = CGPointMake(CGRectGetMinX(master.frame),
                                master.frame.size.height - master.frame.origin.y - CGRectGetHeight(self.frame));
    [self setFrameX:newXY.x andY:newXY.y];
}

-(void)alignVerticalsWithMasterView:(UIView*)master
{
    self.center = CGPointMake(CGRectGetMidX(master.frame), CGRectGetMidY(self.frame));
}

-(void)alignHorizontalsWithMasterView:(UIView*)master
{
    self.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(master.frame));
}

-(void)borderWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = color.CGColor;
}

@end
