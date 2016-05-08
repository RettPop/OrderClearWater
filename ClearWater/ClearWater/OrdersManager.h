//
//  OrdersManager.h
//  ClearWater
//
//  Created by Rett Pop on 2016-04-14.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderModel.h"

@interface OrdersManager : NSObject

-(OrderModel *)lastOrder;
-(void)addNewOrder:(OrderModel *)newOrder;
-(NSArray *)activeOrdersList;
-(NSArray *)ordersList;
-(void)removeOrder:(OrderModel *)order;
-(void)updateOrder:(OrderModel *)order;

@end
