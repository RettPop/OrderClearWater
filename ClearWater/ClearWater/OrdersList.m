//
//  OrdersList.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-15.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "OrdersList.h"
#import "OrdersManager.h"
#import "OrderModel.h"
#import "VCEditOrder.h"
#import "WebKit/WKWebView.h"
#import "WebKit/WKWebViewConfiguration.h"
#import "WebKit/WKPreferences.h"
#import "WebKit/WKNavigationAction.h"
#import <Crashlytics/Crashlytics.h>

typedef enum : NSUInteger {
    APPSCREEN_ORDERS = 1,
    APPSCREEN_CALLBACK,
    APPSCREEN_ABOUT,
} APPSCREEN;

@interface OrdersList ()
{
    NSArray *_orders;
    OrdersManager *_ordersManager;

    NSString *_callbackPhone;
    void (^_callbackBlock)(BOOL);
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCreateOrder;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UITabBarItem *baritmOrders;
@property (strong, nonatomic) IBOutlet UITabBarItem *baritmAbout;
@property (strong, nonatomic) IBOutlet UITabBarItem *baritmContacts;

@end

@implementation OrdersList

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationItem] setTitle:LOC(@"title.MainScreen")];
    [_btnCreateOrder setTitle:LOC(@"button.AddNew")];
    
    // customise back button
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LOC(@"button.Back") style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    _ordersManager = [OrdersManager new];
    _orders = [_ordersManager ordersList];
    [_tableView reloadData];
}

-(void)customizeItems
{
    [_baritmOrders setTitle:LOC(@"title.Home")];
    [_baritmContacts setTitle:LOC(@"title.Callback")];
    [_baritmAbout setTitle:LOC(@"title.About")];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
 
#pragma mark -
#pragma mark UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_orders count];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define kFontActiveOrderCellTitle [UIFont systemFontOfSize:15.f weight:UIFontWeightBold]
#define kFontInactiveOrderCellTitle [UIFont systemFontOfSize:15.f weight:UIFontWeightRegular]

    NSString *cellID = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if( !cell )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    OrderModel *oneOrder = [_orders objectAtIndex:indexPath.row];
    NSString *cellTitle = [NSString stringWithFormat:@"%@ %@", [oneOrder scheduleDateStr], [oneOrder scheduleTime]];
    [[cell textLabel] setText:cellTitle];
    NSString *orderContent = [NSString stringWithFormat:@"%@(%li), %@(%li), %@(%li)",
                              LOC(@"cellText.ClearWater"), (long)[oneOrder clearWater],
                              LOC(@"cellText.FluoridedWater"), (long)[oneOrder fluoridedWater],
                              LOC(@"cellText.IodinatedWater"), (long)[oneOrder iondinatedWater]];
    [[cell detailTextLabel] setText:orderContent];

    NSComparisonResult result = [[oneOrder scheduleDate] compare:[NSDate date]];
    BOOL orderIsActive = (result == NSOrderedDescending || result == NSOrderedSame);
    if( [oneOrder delivered] ) {
        orderIsActive = NO;
    }
   [[cell textLabel] setFont:orderIsActive ? kFontActiveOrderCellTitle : kFontInactiveOrderCellTitle];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewRowAction *actionConfirm = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LOC(@"button.Confirm") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        OrderModel *oneOrder = [_orders objectAtIndex:[indexPath row]];
//        [oneOrder markConfirmed];
//    }];
//    
//    UITableViewRowAction *actionDeliver = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LOC(@"button.Delivered") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        OrderModel *oneOrder = [_orders objectAtIndex:[indexPath row]];
//        [oneOrder markDelivered];
//    }];
//    
//    UITableViewRowAction *actionDelete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LOC(@"button.Delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        OrderModel *oneOrder = [_orders objectAtIndex:[indexPath row]];
//        [oneOrder markConfirmed];
//    }];
//
//    return @[actionConfirm, actionDeliver, actionDelete];
//}
//
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if( editingStyle == UITableViewCellEditingStyleDelete )
    {
        // theoretically we can not gain here while not History or Favorites table is active due canEditRowAtIndexPath condition
        OrderModel *oneOrder = [_orders objectAtIndex:[indexPath row]];
        [_ordersManager removeOrder:oneOrder];
        _orders = [_ordersManager ordersList];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
#define kFontDetailedLableTitle [UIFont systemFontOfSize:10.f weight:UIFontWeightRegular]
    [[cell detailTextLabel] setFont:kFontDetailedLableTitle];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VCEditOrder *vc = [[[self navigationController] storyboard] instantiateViewControllerWithIdentifier:@"VCEditOrder"];
    [vc displayOrder:[_orders objectAtIndex:[indexPath row]]];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    UIViewController *vc = nil;
    switch ([item tag]) {
        case APPSCREEN_CALLBACK:
            [self confirmCallbackRequest];
            [tabBar setSelectedItem:[[tabBar items] firstObject]];
            break;
        case APPSCREEN_ABOUT:
            vc = [[[self navigationController] storyboard] instantiateViewControllerWithIdentifier:@"VCAbout"];
            [self.navigationController pushViewController:vc animated:YES];
            [tabBar setSelectedItem:[[tabBar items] firstObject]];
            break;
            
        default:
            break;
    }
}

-(void)confirmCallbackRequest
{
    // display alert view with text field to input phone for callback
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:LOC(@"title.CallbackRequest") message:LOC(@"text.ConfirmCallbackRequest") preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField setKeyboardType:UIKeyboardTypePhonePad];
        [textField setPlaceholder:LOC(@"placeholder.PhoneNumber")];
    }];
    
    UIAlertAction *newAction = [UIAlertAction actionWithTitle:LOC(@"button.Cancel") style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:newAction];
    
    newAction = [UIAlertAction actionWithTitle:LOC(@"button.OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *phone = [[[alert textFields] firstObject] text];
        if( [phone length] > 0 ) {
            [self requestPhoneback:phone];
        }
    }];
    
    [alert addAction:newAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark Callback request
-(void)requestPhoneback:(NSSTring *)phone
{
    [self showActivity];
    [self requestCallbackForPhone:phone callback:^(BOOL result)
    {
        SYNC_BLOCK_START
            [self hideActivity];
            if( result ) {
                [self showMessage:LOC(@"message.CallbackWasRequested") withTitle:LOC(@"title.Success")];
            }
            else {
                [self showError:LOC(@"message.ErrorSendingCallbackRequest")];
            }
        SYNC_BLOCK_END
    }];
}

-(void)requestCallbackForPhone:(NSString *)phone callback:(void (^)(BOOL result))callback
{
    DLog(@"Sending call request for %@ to %@", phone, kURLCallback);
    // request callback view ajax post form on the customer's web page.
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    WKPreferences *prefs = [[WKPreferences alloc] init];
    [prefs setJavaScriptEnabled:YES];
    [prefs setJavaScriptCanOpenWindowsAutomatically:NO];
    [conf setPreferences:prefs];
    
    _callbackBlock = callback;
    
    WKWebView *_webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:conf];
    [_webView setNavigationDelegate:self];
    [_webView setAllowsBackForwardNavigationGestures:NO];
    [_webView setAllowsLinkPreview:NO];
    [[self view] addSubview:_webView];
    
    _callbackPhone = phone;
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kURLCallback]];
    [req setValue:@"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [req setValue:@"http://www.clearwater.ua/mobile/" forHTTPHeaderField: @"Referer"];
    [_webView loadRequest:req];
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"Navigation error appeared: %@", [error description]);
    _callbackBlock(NO);
    [webView removeFromSuperview];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    DLog(@"Page downloaded");
    
    [Answers logCustomEventWithName:@"Request callback"
                   customAttributes:nil];
    
    NSString *js = [NSString stringWithFormat:@"document.getElementById('form_models_CallForm_telephone').value = '%@';", _callbackPhone];
    
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable someID, NSError * _Nullable error) {
        DLog(@"Phone numbers was set");
        if( error ) {
            DLog(@"JS error appeared while setting phone number: %@", [error description]);
            [Answers logCustomEventWithName:@"Error while callback request"
                           customAttributes:@{@"Stage":@"Setting phone", @"JS Error":[error description]}];

        }
    }];
    
    js = @"for(i=0;i<document.forms['call-widget-form'].elements.length;i++) {if( document.forms['call-widget-form'].elements.item(i).type == \"submit\" ) { document.forms['call-widget-form'].elements.item(i).click(); } ;}";
    [webView evaluateJavaScript:js completionHandler:^(id _Nullable someID, NSError * _Nullable error)
    {
        DLog(@"Submit was simulated");
        
        if( error ) {
            DLog(@"JS error appeared while simulating submit: %@", [error description]);
            [Answers logCustomEventWithName:@"Error while callback request"
                           customAttributes:@{@"Stage":@"Submitting form", @"JS Error":[error description]}];
        }
        [webView removeFromSuperview];
        _callbackBlock(nil == error);
    }];
}

@end
