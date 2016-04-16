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

@interface OrdersList ()
{
    NSArray *_orders;
    OrdersManager *_ordersManager;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnCreateOrder;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

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
    if( [_orders count] < 1 ) {
        [self showMessage:LOC(@"text.NoOrderAvailable") withTitle:LOC(@"title.MainScreen")];
    }
}

-(void)showMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:LOC(@"button.OK") style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
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
    [[cell textLabel] setText:[oneOrder scheduleDateStr]];
    NSString *orderContent = [NSString stringWithFormat:@"%@(%li), %@(%li), %@(%li)",
                              LOC(@"cellText.ClearWater"), (long)[oneOrder clearWater],
                              LOC(@"cellText.FluoridedWater"), (long)[oneOrder fluoridedWater],
                              LOC(@"cellText.IodinatedWater"), (long)[oneOrder iondinatedWater]];
    [[cell detailTextLabel] setText:orderContent];

    NSComparisonResult result = [[oneOrder scheduleDate] compare:[NSDate date]];
    BOOL orderIsActive = (result == NSOrderedDescending || result == NSOrderedSame);
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

@end
