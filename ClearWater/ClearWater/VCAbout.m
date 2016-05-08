//
//  VCAbout.m
//  ClearWater
//
//  Created by Rett Pop on 2016-05-08.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "VCAbout.h"

typedef enum : NSUInteger {
    SECTION_GENERAL,
} TABLE_SECTIONS;

typedef enum : NSUInteger {
    GENERAL_SERVICE_SITE,
    GENERAL_APP_VERSION,
} SectionsItems;

@interface VCAbout()
@property (strong, nonatomic) IBOutlet UITextView *textAbout;
@property (strong, nonatomic) IBOutlet UILabel *lblServiceSite;
@property (strong, nonatomic) IBOutlet UILabel *lblAppVersion;

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
    switch (indexPath.section)
    {
        case SECTION_GENERAL:
        {
            switch (indexPath.row)
            {
                case GENERAL_SERVICE_SITE:
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kURLServiceSite]];
                    break;
                    
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
}

@end
