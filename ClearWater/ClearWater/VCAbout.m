//
//  VCAbout.m
//  ClearWater
//
//  Created by Rett Pop on 2016-05-08.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "VCAbout.h"
#import <Crashlytics/Crashlytics.h>

typedef enum : NSUInteger {
    SECTION_GENERAL,
} TABLE_SECTIONS;

typedef enum : NSUInteger {
    GENERAL_SERVICE_SITE,
    GENERAL_APP_VERSION,
    GENERAL_FEEDBACK,
} SectionsItems;

@interface VCAbout()
@property (strong, nonatomic) IBOutlet UITextView *textAbout;
@property (strong, nonatomic) IBOutlet UILabel *lblServiceSite;
@property (strong, nonatomic) IBOutlet UILabel *lblAppVersion;
@property (strong, nonatomic) IBOutlet UILabel *lblFeedback;

@end

@implementation VCAbout
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self customizeControls];
}

-(void)customizeControls
{
    [_textAbout setText:LOC(@"text.Disclaimer")];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
    NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
    
    [_lblAppVersion setText:[NSString stringWithFormat:@"%@ v.%@(%@)", bundleName, version, build]];

    [_lblServiceSite setText:LOC(@"text.ServiceSite")];
    [_lblFeedback setText:LOC(@"text.SendFeedback")];
    [[self navigationItem] setTitle:LOC(@"title.AboutScreen")];
}

#pragma mark -
#pragma mark UITableView delegate

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section)
    {
        case SECTION_GENERAL:
            title = LOC(@"title.section.General");
            break;
            
        default:
            break;
    }
    
    return title;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( SECTION_GENERAL == indexPath.section )
    {
        switch (indexPath.row)
        {
            case GENERAL_SERVICE_SITE:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kURLServiceSite]];
                break;
            case GENERAL_FEEDBACK:
            {
                if (![MFMailComposeViewController canSendMail])
                {
                    DLog(@"Mail services are not available.");
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"title.MailServiceIsNotAvailable")
                                                                                   message:LOC(@"text.MailServiceIsNotAvailable")
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"button.OK")
                                                              style:UIAlertActionStyleDefault
                                                            handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                    return;
                }
                
                MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
                mailVC.mailComposeDelegate = self;
                
                NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
                NSString *version = infoDictionary[@"CFBundleShortVersionString"];
                NSString *build = infoDictionary[(NSString*)kCFBundleVersionKey];
                NSString *bundleName = infoDictionary[(NSString *)kCFBundleNameKey];
                NSString *subj = [NSString stringWithFormat:@"%@ %@ v.%@(%@)", LOC(@"mail.FeedbackOn"), bundleName, version, build];

                [Answers logCustomEventWithName:@"Sending feedback" customAttributes:@{@"Subj":subj}];

                [mailVC setToRecipients:@[@"clearwater@sapisoft.com"]];
                [mailVC setSubject:subj];
                [mailVC setMessageBody:LOC(@"mail.Hi") isHTML:NO];
                [self presentViewController:mailVC animated:YES completion:nil];
            }
            default:
                break;
        }
    }
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if( error ) {
        [Answers logCustomEventWithName:@"Error sending feedback"
                   customAttributes:@{@"Error":[error description]}];
    }
    else {
        [Answers logCustomEventWithName:@"Feedback sent"
                       customAttributes:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
