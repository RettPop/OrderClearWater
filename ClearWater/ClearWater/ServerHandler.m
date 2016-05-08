//
//  ServerHandler.m
//  ClearWater
//
//  Created by Rett Pop on 2016-04-08.
//  Copyright © 2016 SapiSoft. All rights reserved.
//

#import "ServerHandler.h"

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
    return YES;
    NSString *orderAsParams = [self POSTParamsToString:[order valuesDict]];
    NSMutableURLRequest *uploadReq = [self prepReqestWithParams:orderAsParams];
    [uploadReq setURL:[NSURL URLWithString:kURLNewOrder]];
    
    NSMutableData *respData = [[NSMutableData alloc] init];
    NSHTTPURLResponse *resp = [self sendRequest:uploadReq dataStorage:respData];
    return [self checkHTTPResponse:resp withData:respData];
}

-(NSHTTPURLResponse *)sendRequest:(NSURLRequest *)request dataStorage:(NSMutableData *)dataStorage
{
    DLog(@"Request header:\n{%@}", [request allHTTPHeaderFields]);
    NSString *logStr = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
    DLog(@"Request body length: %lu, content:\n{%@}", (unsigned long)[[request HTTPBody] length], logStr);
    logStr = nil;
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSHTTPURLResponse *urlResp = nil;
    NSError *err = nil;
    
    NSData *respData = [self sendSynchronousRequest:request
                                            session:session
                                  returningResponse:&urlResp
                                              error:&err];
    if( respData )
    {
        DLog(@"Response header:\n{%@}", urlResp);
        NSSTring *respDataStr = [[NSString alloc] initWithData:respData encoding:NSUTF8StringEncoding];
        DLog(@"Response body:\n{%@}", respDataStr);

        // fill target data with received data if needed
        if( dataStorage ) {
            [dataStorage setData:respData];
        }
    }

    return urlResp;
}

// little changed code copypizded from https://forums.developer.apple.com/thread/11519
-(NSData *)sendSynchronousRequest:(NSURLRequest *)request
                          session:(NSURLSession *)session
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr
{

    // make ansyncronous actions synchronously
    __block NSData *result = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    
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
                     }]
     resume];
    
    // wait for 5 seconds
    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)));
    
    return result;  
}

-(BOOL)checkHTTPResponse:(NSHTTPURLResponse *)response withData:(NSData *)data
{
    if( !response ) {
        return NO;
    }
    
    //response whould contain HTTP_OK200 and body should contain one of "OK", "MAIL", "POST" strings.
    
    BOOL isOK = FALSE;

    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if(   [dataString localizedCaseInsensitiveContainsString:@"OK"]
       || [dataString localizedCaseInsensitiveContainsString:@"MAIL"]
       || [dataString localizedCaseInsensitiveContainsString:@"POST"] )
    {
        // to simplify condition above
        if( [response statusCode] == 200 ) {
            isOK = YES;
        }
    }
    
    DLog(@"Response is %@", isOK ? @"OK" : @"BAD");
    return isOK;
}

-(void)URLSession:(NSURLSession *)session
             task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
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
    NSString *serviceURL = kURLNewOrder;
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
