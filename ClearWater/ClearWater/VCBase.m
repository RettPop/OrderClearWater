//
//  VCBase.m
//  ClearWater
//
//  Created by Rett Pop on 2016-05-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "VCBase.h"

@implementation VCBase

#pragma mark -
#pragma mark Activity indicator issues

-(void)showActivity
{
    DLog(@"");
    if( _activity ) {
        [self hideActivity];
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activity setCenter:self.view.center];
        [_activity startAnimating];
        
        _activityBG = [[UIView alloc] initWithFrame:[[self view] bounds]];
        [_activityBG setCenter:[[self view] center]];
        [_activityBG setBackgroundColor:[UIColor blackColor]];
        [_activityBG setAlpha:.7f];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:_activityBG];
        [[[UIApplication sharedApplication] keyWindow] addSubview:_activity];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:_activityBG];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:_activity];
        
        _activityText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_activityBG.bounds), 20.f)];
        [_activityText setText:@""];
        [_activityText setFont:[UIFont systemFontOfSize:15.f]];
        [_activityText setTextColor:[UIColor whiteColor]];
        [_activityText setTextAlignment:NSTextAlignmentCenter];
        [[[UIApplication sharedApplication] keyWindow]  addSubview:_activityText];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:_activityText];
        [_activityText setCenter:[_activityBG center]];
        [_activityText setFrame:CGRectOffset(_activityText.frame, 0.f, 30.f)];
        [[self navigationItem] setHidesBackButton:YES animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    });
}

-(void)changeActivityText:(NSString *)newText
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [_activityText setText:newText];
    });
}

-(void)hideActivity
{
    DLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if( _activityBG )
        {
            [_activityText removeFromSuperview];
            _activityText = nil;
            [_activityBG removeFromSuperview];
            _activityBG = nil;
            [_activity removeFromSuperview];
            _activity = nil;
            [[self navigationItem] setHidesBackButton:NO animated:YES];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
    });
}

#pragma mark -
#pragma mark Helpers
-(void)showError:(NSString *)message
{
    [self showError:message withCallback:nil];
}

-(void)showError:(NSString *)message withCallback:(void (^ __nullable)(void))callback
{
    [self showMessage:message withTitle:LOC(@"title.Error") withCallback:callback];
}

-(void)showMessage:(NSString *)message withTitle:(NSString *)title
{
    [self showMessage:message withTitle:title withCallback:nil];
}

-(void)showMessage:(NSString *)message withTitle:(NSString *)title withCallback:(void (^ __nullable)(void))callback
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"button.OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:callback];
}

@end
