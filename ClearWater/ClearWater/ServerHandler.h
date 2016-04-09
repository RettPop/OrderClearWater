//
//  ServerHandler.h
//  ClearWater
//
//  Created by Rett Pop on 2016-04-08.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderModel.h"

@interface ServerHandler : NSObject<NSURLConnectionDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

+(instancetype)sharedInstance;
-(BOOL)sendOrder:(OrderModel *)order;


@end
