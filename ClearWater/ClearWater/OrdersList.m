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


@end
