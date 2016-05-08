//
//  OrderModel.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-07.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "OrderModel.h"

@implementation OrderModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    encObj(_orderID);
    encObj(_clientCode);
    encObj(_addressCity);
    encObj(_addressStreet);
    encObj(_addressHouse);
    encObj(_addressApt);
    encObj(_addressContactPhone);
    encObj(_addressContactName);
    encObj(_scheduleTime);
    encObj(_scheduleDate);
    encObj(_contentClearWater);
    encObj(_contentFluorided);
    encObj(_contentIodinated);
    encObj(_confirmSMS);
    encObj(_confirmPhone);
    encObj(_confirmEmail);
    encObj(_orderComments);
    encObj(_dateSent);
    encObj(_dateCreated);
    encObj(_dateConfirmed);
    encBool(_delivered);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if( self )
    {
        decObj(_orderID);
        // backward compatibility
        if( !_orderID || [_orderID length] == 0 )
        {
            _orderID = [[NSUUID UUID] UUIDString];
        }
        decObj(_clientCode);
        decObj(_addressCity);
        decObj(_addressStreet);
        decObj(_addressHouse);
        decObj(_addressApt);
        decObj(_addressContactPhone);
        decObj(_addressContactName);
        decObj(_scheduleTime);
        decObj(_scheduleDate);
        decObj(_contentClearWater);
        decObj(_contentFluorided);
        decObj(_contentIodinated);
        decObj(_confirmSMS);
        decObj(_confirmPhone);
        decObj(_confirmEmail);
        decObj(_orderComments);
        decObj(_dateSent);
        decObj(_dateCreated);
        decObj(_dateConfirmed);
        decBool(_delivered);
    }
    
    return self;
}


-(instancetype)init
{
    self = [super init];
    if( self )
    {
        _orderID = [[NSUUID UUID] UUIDString];
        _clientCode = @"";
        _addressCity = @"";
        _addressStreet = @"";
        _addressHouse = @"";
        _addressApt = @"";
        _addressContactPhone = @"";
        _addressContactName = @"";
        _scheduleTime = @"";
        _scheduleDate = nil;
        _contentClearWater = @0;
        _contentFluorided = @0;
        _contentIodinated = @0;
        _confirmSMS = @"";
        _confirmPhone = @"";
        _confirmEmail = @"";
        _orderComments = @"";
        _dateSent = nil;
        _dateCreated = [NSDate date];
        _dateConfirmed = nil;
        _delivered = NO;
    }
    
    return self;
}

-(id)initWithOrder:(OrderModel *)order
{
    self = [self init];
    if( self )
    {
        _clientCode = [order clientCode];
        _addressCity = [order addressCity];
        _addressStreet = [order addressStreet];
        _addressHouse = [order addressHouse];
        _addressApt = [order addressApt];
        _addressContactPhone = [order addressContactPhone];
        _addressContactName =  [order addressContactName];
        _scheduleTime =  [order scheduleTime];
        _contentClearWater = @([order clearWater]);
        _contentFluorided = @([order fluoridedWater]);
        _contentIodinated = @([order iondinatedWater]);
        _confirmSMS =  [order confirmSMS];
        _confirmPhone = [order confirmPhone];
        _confirmEmail = [order confirmEmail];
        _orderComments = [order orderComments];
        _dateCreated = [NSDate date];
    }
    
    return self;
}

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

-(NSDictionary *)valuesDict
{
    NSDictionary *params = @{@"orcode" : [self clientCode],
                             @"orcity" : [self addressCity],
                             @"orstrit" : [self addressStreet],
                             @"orhouse" : [self addressHouse],
                             @"oroffice" : [self addressApt],
                             @"orname" : [self addressContactName],
                             @"ortel" : [self addressContactPhone],
                             @"ordate" : [self scheduleDateStr],
                             @"ortime" : [self scheduleTime],
                             @"orcw" : [self contentClearWater],
                             @"orcwf" : [self contentFluorided],
                             @"orcwi" : [self contentIodinated],
                             @"orconfsms" : [self confirmSMS],
                             @"orconfemail" : [self confirmEmail],
                             @"orconftel" : [self confirmPhone],
                             @"orcomm" : [self orderComments]};
    return params;
}

-(NSString *)scheduleDateStr
{
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:kDateFormat];
    return [form stringFromDate:_scheduleDate];
}

-(void)markSent
{
    if( !_dateSent ) {
        _dateSent = [NSDate date];
    }
}

-(void)markConfirmed
{
    _dateConfirmed = [NSDate date];
}

-(void)markDelivered
{
    _delivered = YES;
}

-(void)markNotConfirmed
{
    _dateConfirmed = nil;
}

-(void)markNotDelivered
{
    _delivered = NO;
}


@end
