//
//  OrderModel.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "OrderModel.h"

@implementation OrderModel

-(NSInteger)clearWater
{
    return [_contentClearWater integerValue];
}
-(NSInteger)fluoridedWater
{
    return [_contentFluorided integerValue];
}

-(NSInteger)iondinatedWater
{
    return [_contentIodinated integerValue];
}

-(void)orderClearWater:(NSUInteger)amount
{
    _contentClearWater = [NSNumber numberWithUnsignedInteger:amount];
}
-(void)orderFluoridedWater:(NSUInteger)amount
{
    _contentFluorided = [NSNumber numberWithUnsignedInteger:amount];
}

-(void)orderIonidedWater:(NSUInteger)amount
{
    _contentIodinated = [NSNumber numberWithUnsignedInteger:amount];
}



@end
