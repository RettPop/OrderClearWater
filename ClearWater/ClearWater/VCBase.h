//
//  VCBase.h
//  ClearWater
//
//  Created by Rett Pop on 2016-05-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCBase : UIViewController
{
    UIActivityIndicatorView *_activity;
    UIView *_activityBG;
    UILabel *_activityText;
}

-(void)showActivity;
-(void)changeActivityText:(NSString *)newText;
-(void)hideActivity;
-(void)showError:(NSString *)message;
-(void)showMessage:(NSString *)message withTitle:(NSString *)title;
-(void)showMessage:(NSString *)message withTitle:(NSString *)title withCallback:(void (^ __nullable)(void))callback;
-(void)showError:(NSString *)message withCallback:(void (^ __nullable)(void))callback;
-(void)customizeItems;

@end
