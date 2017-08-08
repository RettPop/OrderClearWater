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
-(void)changeActivityText:(NSString *_Nullable)newText;
-(void)hideActivity;
-(void)showError:(NSString *_Nullable)message;
-(void)showMessage:(NSString *_Nullable)message withTitle:(NSString *_Nullable)title;
-(void)showMessage:(NSString *_Nullable)message withTitle:(NSString *_Nullable)title withCallback:(void (^ __nullable)(void))callback;
-(void)showError:(NSString *_Nullable)message withCallback:(void (^ __nullable)(void))callback;
-(void)customizeItems;

@end
