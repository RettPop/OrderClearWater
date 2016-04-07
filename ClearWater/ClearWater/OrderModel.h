//
//  OrderModel.h
//  ClearWater
//
//  Created by Rett Pop on 2016-04-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderModel : NSObject

-(NSInteger)clearWater;
-(NSInteger)fluoridedWater;
-(NSInteger)iondinatedWater;
-(void)orderClearWater:(NSUInteger)amount;
-(void)orderFluoridedWater:(NSUInteger)amount;
-(void)orderIonidedWater:(NSUInteger)amount;

@property (strong, nonatomic) NSString *clientCode;
@property (strong, nonatomic) NSString *addressCity;
@property (strong, nonatomic) NSString *addressStreet;
@property (strong, nonatomic) NSString *addressHouse;
@property (strong, nonatomic) NSString *addressApt;
@property (strong, nonatomic) NSString *addressContactPhone;
@property (strong, nonatomic) NSString *addressContactName;
@property (strong, nonatomic) NSString *scheduleTime;
@property (strong, nonatomic) NSString *scheduleDate;
@property (strong, nonatomic) NSNumber *contentClearWater;
@property (strong, nonatomic) NSNumber *contentFluorided;
@property (strong, nonatomic) NSNumber *contentIodinated;
@property (strong, nonatomic) NSString *confirmSMS;
@property (strong, nonatomic) NSString *confirmPhone;
@property (strong, nonatomic) NSString *confirmEmail;
@property (strong, nonatomic) NSString *orderComments;

@end
