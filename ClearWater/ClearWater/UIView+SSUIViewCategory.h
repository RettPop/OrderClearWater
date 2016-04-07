//
//  UIView+SSUIViewCategory.h
//  PayControl
//
//  Created by Rett Pop on 11.04.13.
//  Copyright (c) 2013 SapiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SSUIViewCategory)
-(void)changeSizeWidthDelta:(CGFloat)widthDelta heightDelta:(CGFloat)heightDelta;
-(void)changeFrameXDelta:(CGFloat)xDelta yDelta:(CGFloat)yDelta;
-(void)setSizeWidth:(CGFloat)newWidth newHeight:(CGFloat)newHeight;
-(void)setNewWidth:(CGFloat)newWidth;
-(void)setNewHeight:(CGFloat)newHeight;
-(void)setFrameX:(CGFloat)newX andY:(CGFloat)newY;
-(void)setFrameX:(CGFloat)newX;
-(void)setFrameY:(CGFloat)newY;
-(void)alignBottomsWithMasterView:(UIView*)master;
-(void)alignHorizontalsWithMasterView:(UIView*)master;
-(void)alignVerticalsWithMasterView:(UIView*)master;
-(void)borderWithColor:(UIColor *)color borderWidth:(CGFloat)borderWidth;
-(void)setWidthFromMasterView:(UIView*)master;
-(void)setHeightFromMasterView:(UIView*)master;
@end
