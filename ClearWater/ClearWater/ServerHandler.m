//
//  ServerHandler.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-08.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "ServerHandler.h"

//#define SERVER_URL @"http://www.clearwater.ua/order/_system/jsorder.php"
#define SERVER_URL @"https://requestb.in/xzbobgxz"

@implementation ServerHandler

+(instancetype)sharedInstance
{
    static ServerHandler* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(BOOL)sendOrder:(OrderModel *)order
{
    NSString *orderAsParams = [self POSTParamsToString:[order valuesDict]];
    NSMutableURLRequest *uploadReq = [self prepReqestWithParams:orderAsParams];
    [uploadReq setURL:[NSURL URLWithString:SERVER_URL]];
    
    NSHTTPURLResponse *resp = [self sendRequest:uploadReq];
    return [self checkHTTPResponse:resp];
}

-(NSHTTPURLResponse *)sendRequest:(NSURLRequest *)request dataStorage:(NSMutableData *)dataStorage
{
    NSHTTPURLResponse *urlResp = nil;
    NSError *err = nil;
    DLog(@"Request header:\n{%@}", [request allHTTPHeaderFields]);
    NSString *logStr = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    DLog(@"Request body length: %lu, content:\n{%@}", (unsigned long)[[request HTTPBody] length], logStr);
    logStr = nil;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSData *respData = [self sendSynchronousRequest:request session:session returningResponse:&urlResp error:&err];
    DLog(@"Response header:\n{%@}", urlResp);
    NSSTring *respDataStr = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
    DLog(@"Response body:\n{%@}", respDataStr);

    // fill target data with received data if needed
    if( dataStorage ) {
        [dataStorage setData:respData];
    }

    return urlResp;
}

// little changed code copypizded from https://forums.developer.apple.com/thread/11519
-(NSData *)sendSynchronousRequest:(NSURLRequest *)request
                          session:(NSURLSession *)session
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr {
    dispatch_semaphore_t    sem;
    __block NSData *        result;
    
    result = nil;
    
    sem = dispatch_semaphore_create(0);
    
    [[session dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         if (errorPtr != NULL) {
                                             *errorPtr = error;
                                         }
                                         if (responsePtr != NULL) {
                                             *responsePtr = response;
                                         }  
                                         if (error == nil) {  
                                             result = data;  
                                         }  
                                         dispatch_semaphore_signal(sem);  
                                     }] resume];  
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);  
    
    return result;  
}

-(BOOL)checkHTTPResponse:(NSHTTPURLResponse *)response
{
    BOOL isOK = ([response statusCode] == 200);
    
    DLog(@"Response is %@", isOK ? @"OK" : @"BAD");
    return isOK;
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
}

-(NSHTTPURLResponse *)sendRequest:(NSURLRequest *)request
{
    return [self sendRequest:request dataStorage:nil];
}


-(NSMutableURLRequest *)prepReqestWithParams:(NSString *)withParams
{
    NSString *serviceURL = SERVER_URL;
    NSMutableURLRequest *newReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serviceURL]
                                                          cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                      timeoutInterval:60];
    
    [newReq setHTTPMethod:@"POST"];
    [newReq setHTTPBody:[withParams dataUsingEncoding:NSUTF8StringEncoding]];
    
    return newReq;
}

-(NSString *)POSTParamsToString:(NSDictionary *)params
{
    NSMutableString *strParams = [NSMutableString string];
    for (NSString *oneKey in [params allKeys])
    {
        if([strParams length] > 0) {
            [strParams appendString:@"&"];
        }
        [strParams appendString:[NSString stringWithFormat:@"%@=%@", oneKey, [params valueForKey:oneKey]]];
    }
    
    return strParams;
}

@end
