//
//  FXRestService.m
//  Flox
//
//  Created by Daniel Sperl on 08.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXUtils.h"
#import "FXRestService.h"
#import "FXURLConnection.h"
#import "FXPersistentQueue.h"
#import "Flox+Internal.h"
#import "NSJSONSerialization+String.h"
#import "NSString+Flox.h"

@implementation FXRestService
{
    NSURL *_url;
    NSString *_gameID;
    NSString *_gameKey;

    FXPersistentQueue *_queue;
    BOOL _processingQueue;
}

- (instancetype)initWithURL:(NSURL *)url gameID:(NSString *)gameID gameKey:(NSString *)gameKey
{
    if ((self = [super init]))
    {
        _url     = [url copy];
        _gameID  = [gameID copy];
        _gameKey = [gameKey copy];
        _queue   = [[FXPersistentQueue alloc] initWithName:gameID];
    }
    return self;
}

- (void)requestWithMethod:(NSString *)method path:(NSString *)path data:(NSDictionary *)data
           authentication:(id)authentication onComplete:(FXRequestCompleteBlock)completeBlock
{
    if ([method isEqualToString:FXHTTPMethodGet])
    {
        path = [path stringByAppendingQueryParameters:data];
        data = nil;
    }
    
    NSDictionary *floxHeader = @{
      @"sdk": @{
        @"type": @"objc",
        @"version": @"0.1" }, // TODO: add version
      @"player": @{
        @"id": @"unit-test-player-id", // TODO: add real player data
        @"authType": @"guest",
        @"authId": @"unit-test-auth-id",
        @"authToken": @"unit-test-auth-token"
      },
      @"gameKey": _gameKey,
      @"bodyCompression": @"none", // TODO: add compression
      @"dispatchTime": [FXUtils stringFromDate:[NSDate date]]
    };
    
    NSMutableDictionary *headers = [[NSMutableDictionary alloc] init];
    headers[@"Content-Type"] = @"application/json";
    headers[@"X-Flox"] = [NSJSONSerialization stringWithJSONObject:floxHeader];
    
    // TODO: add If-None-Match
    
    NSString *basePath = [NSString stringWithFormat:@"games/%@", _gameID];
    NSString *fullPath = [basePath stringByAppendingPathComponent:path];
    NSURL *fullURL = [[NSURL alloc] initWithString:fullPath relativeToURL:_url];
    
    NSError *jsonError;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:fullURL];
    request.allHTTPHeaderFields = headers;
    request.HTTPMethod = method;
    
    if (data)
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:data options:0 error:&jsonError];
    
    if (jsonError)
        completeBlock(nil, 0, jsonError);
    else
    {
        FXURLConnection *connection = [[FXURLConnection alloc] initWithRequest:request];
        
        [connection startWithBlock:^(NSData *bodyData, NSInteger httpStatus, NSError *error)
        {
            // TODO: in case of error, return result from cache
            
            if (error)
            {
                completeBlock(nil, httpStatus, error);
                return;
            }
            
            NSError *jsonError;
            NSDictionary *body = bodyData.length == 0 ? nil :
                [NSJSONSerialization JSONObjectWithData:bodyData options:0 error:&jsonError];
            
            if (jsonError)
            {
                completeBlock(nil, httpStatus, jsonError);
                return;
            }
            
            if (FXHTTPStatusIsSuccess(httpStatus))
            {
                if ([method isEqualToString:FXHTTPMethodGet])
                {
                    // TODO: check for NotModified
                    // TODO: add to cache
                }
                else if ([method isEqualToString:FXHTTPMethodPut])
                {
                    // TODO: update 'createdAt' and 'updatedAt'
                    // TODO: add to cache
                }
                else if ([method isEqualToString:FXHTTPMethodDelete])
                {
                    // TODO: remove from cache
                }
                
                completeBlock(body, httpStatus, nil);
            }
            else
            {
                NSError *error = [[NSError alloc] initWithDomain:@"FXRestService" code:httpStatus
                                                        userInfo:body];
                completeBlock(nil, httpStatus, error);
            }
        }];
    }
}

- (void)requestWithMethod:(NSString *)method path:(NSString *)path data:(NSDictionary *)data
               onComplete:(FXRequestCompleteBlock)completeBlock
{
    if ([self processQueue])
    {
        __block id observer = nil;
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

        observer = [center addObserverForName:FXQueueProcessedNotification object:nil queue:nil
                                   usingBlock:^(NSNotification *notification)
        {
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center removeObserver:observer];
            
            NSDictionary *userInfo = notification.userInfo;
            
            BOOL success = [userInfo[@"success"] boolValue];
            NSInteger httpStatus = [userInfo[@"httpStatus"] integerValue];
            NSError *error = userInfo[@"error"];
            
            if (success)
                [self requestWithMethod:method path:path data:data authentication:nil
                             onComplete:completeBlock];
            else
            {
                // TODO: try to get body from cache
                completeBlock(nil, httpStatus, error);
            }
        }];
    }
    else
    {
        [self requestWithMethod:method path:path data:data authentication:nil
                     onComplete:completeBlock];
    }
}

- (void)requestQueuedWithMethod:(NSString *)method path:(NSString *)path data:(NSDictionary *)data
{
    if ([method isEqualToString:FXHTTPMethodPut])
    {
        // TODO: save data to cache
        // TODO: filter redundant queue contents
    }
    
    [_queue enqueueObject:@{ @"method": method, @"path": path, @"data": data }];
    [self processQueue];
}

- (BOOL)processQueue
{
    if (_processingQueue) return YES;
    
    if (_queue.count)
    {
        _processingQueue = YES;
        
        [_queue loadHead:^(NSDictionary *head)
         {
             if (head)
             {
                 NSString *method   = head[@"method"];
                 NSString *path     = head[@"path"];
                 NSDictionary *data = head[@"data"];
                 
                 [self requestWithMethod:method path:path data:data authentication:nil
                              onComplete:^(NSObject *body, NSInteger httpStatus, NSError *error)
                  {
                      _processingQueue = NO;
                      
                      if (!error)
                      {
                          [_queue removeHead];
                          [self processQueue];
                      }
                      else
                      {
                          if (FXHTTPStatusIsTransientError(httpStatus))
                          {
                              // server did not answer or is not available! we stop queue processing.
                              [Flox logInfo:@"Flox server not reachable (device probably offline). "
                                             "HttpStatus: %d", (int)httpStatus];
                              
                              [self postQueueProcessedNotificationWithHttpStatus:httpStatus error:error];
                          }
                          else
                          {
                              // server answered, but there was a logic error -> no retry
                              [Flox logWarning:@"Flox service request queue failed: %@, httpStatus: %d",
                                               [error description], (int)httpStatus];
                              
                              [_queue removeHead];
                              [self processQueue];
                          }
                      }
                  }];
             }
             else
             {
                 _processingQueue = NO;
                 [self postQueueProcessedNotificationWithHttpStatus:200 error:nil];
             }
         }];
    }
    else
    {
        [self postQueueProcessedNotificationWithHttpStatus:200 error:nil];
    }

    return _processingQueue;
}

- (void)postQueueProcessedNotificationWithHttpStatus:(NSInteger)httpStatus error:(NSError *)error
{
    BOOL success = FXHTTPStatusIsSuccess(httpStatus) || !FXHTTPStatusIsTransientError(httpStatus);
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    // by using 'initWithObjectsAndKeys' to create the dictionary, the error object won't be added
    // if it isn't there. (Adding 'NSNull' would make error checking weird.)
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
                              @(success), @"success",
                              @(httpStatus), @"httpStatus",
                              error, @"error", nil];
  
    [nc postNotificationName:FXQueueProcessedNotification object:self userInfo:userInfo];
}

- (void)save
{
    [_queue save];
}

- (void)clearQueue
{
    [_queue removeAllObjects];
}

@end
