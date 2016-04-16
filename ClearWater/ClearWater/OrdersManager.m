//
//  OrdersManager.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-14.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "OrdersManager.h"
#import "OrderModel.h"

@interface OrdersManager()
{
    NSMutableArray *_orders;
}

@end


@implementation OrdersManager

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        _orders = [NSMutableArray arrayWithArray:[self restoreOrders]];
    }
    
    return self;
}

-(OrderModel *)lastOrder
{
    OrderModel *newOrder = nil;
    if( [_orders lastObject] ) {
        newOrder = [[OrderModel alloc] initWithOrder:[_orders lastObject]];
    }
    return newOrder;
}

-(NSArray *)activeOrdersList
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[_orders count]];
    NSDate *today = [NSDate date];
    
    for (OrderModel *oneOrder in _orders)
    {
        NSComparisonResult result = [[oneOrder scheduleDate] compare:today];
        if( result == NSOrderedAscending || result == NSOrderedSame) {
            [arr addObject:oneOrder];
        }
    }
    
    return arr;
}

-(NSArray *)ordersList
{
    return [NSArray arrayWithArray:_orders];
}

-(void)addNewOrder:(OrderModel *)newOrder
{
    [_orders addObject:newOrder];
    [self storeOrders:_orders];
}

-(void)storeOrders:(NSArray *)orders
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:[orders count]];
    for (OrderModel *oneOrder in orders) {
        [dataArray addObject:[NSKeyedArchiver archivedDataWithRootObject:oneOrder]];
    }
    [def setObject:dataArray forKey:kUserDefsKeyOrders];
    dataArray = nil;
}

-(NSArray *)restoreOrders
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSArray *dataArray = [def valueForKey:kUserDefsKeyOrders];
    NSMutableArray *orders = [NSMutableArray new];
    if( dataArray )
    {
        for (NSData *oneData in dataArray) {
            [orders addObject:[NSKeyedUnarchiver unarchiveObjectWithData:oneData]];
        }
    }
    
    return orders;
}

-(void)removeOrder:(OrderModel *)order
{
    [_orders removeObject:order];
    [self storeOrders:_orders];
}

@end
