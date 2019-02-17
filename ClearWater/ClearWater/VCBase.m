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

- (void)viewDidLoad
{
    [self customizeItems];
}

-(void)customizeItems
{
    // stub
}

-(void)showActivity
{
    DLog(@"");
    if( _activity ) {
        [self hideActivity];
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self->_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self->_activity setCenter:self.view.center];
        [self->_activity startAnimating];
        
        self->_activityBG = [[UIView alloc] initWithFrame:[[self view] bounds]];
        [self->_activityBG setCenter:[[self view] center]];
        [self->_activityBG setBackgroundColor:[UIColor blackColor]];
        [self->_activityBG setAlpha:.7f];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self->_activityBG];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self->_activity];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self->_activityBG];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self->_activity];
        
        self->_activityText = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self->_activityBG.bounds), 20.f)];
        [self->_activityText setText:@""];
        [self->_activityText setFont:[UIFont systemFontOfSize:15.f]];
        [self->_activityText setTextColor:[UIColor whiteColor]];
        [self->_activityText setTextAlignment:NSTextAlignmentCenter];
        [[[UIApplication sharedApplication] keyWindow]  addSubview:self->_activityText];
        [[[UIApplication sharedApplication] keyWindow] bringSubviewToFront:self->_activityText];
        [self->_activityText setCenter:[self->_activityBG center]];
        [self->_activityText setFrame:CGRectOffset(self->_activityText.frame, 0.f, 30.f)];
        [[self navigationItem] setHidesBackButton:YES animated:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    });
}

-(void)changeActivityText:(NSString *)newText
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self->_activityText setText:newText];
    });
}

-(void)hideActivity
{
    DLog(@"");
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if( self->_activityBG )
        {
            [self->_activityText removeFromSuperview];
            self->_activityText = nil;
            [self->_activityBG removeFromSuperview];
            self->_activityBG = nil;
            [self->_activity removeFromSuperview];
            self->_activity = nil;
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
