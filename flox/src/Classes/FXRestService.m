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
#import "FXPersistentStore.h"
#import "Flox_Internal.h"
#import "NSJSONSerialization+String.h"
#import "NSString+Flox.h"

@implementation FXRestService
{
    NSURL *_url;
    NSString *_gameID;
    NSString *_gameKey;

    FXPersistentQueue *_queue;
    FXPersistentStore *_cache;
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
        _cache   = [[FXPersistentStore alloc] initWithName:gameID];
    }
    return self;
}

- (void)requestWithMethod:(NSString *)method path:(NSString *)path data:(NSDictionary *)data
           authentication:(FXAuthentication *)authentication
               onComplete:(FXRequestCompleteBlock)completeBlock
{
    if ([method isEqualToString:FXHTTPMethodGet])
    {
        path = [path stringByAppendingQueryParameters:data];
        data = nil;
    }
    
    if (!authentication)
        authentication = Flox.authentication;
    
    NSDictionary *floxHeader = @{
      @"sdk": @{
        @"type": @"objc",
        @"version": [Flox version] },
      @"player": @{
        @"id":        authentication.playerID,
        @"authType":  authentication.type,
        @"authId":    authentication.id,
        @"authToken": authentication.token
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
    // might change before we're in the notification observer!
    FXAuthentication *auth = Flox.authentication;
    
    if ([self processQueue])
    {
        [FXUtils observeNextNotification:FXQueueProcessedNotification fromObject:self
                              usingBlock:^(NSNotification *notification)
        {
            NSDictionary *userInfo = notification.userInfo;
            
            BOOL success = [userInfo[@"success"] boolValue];
            NSInteger httpStatus = [userInfo[@"httpStatus"] integerValue];
            NSError *error = userInfo[@"error"];
            
            if (success)
                [self requestWithMethod:method path:path data:data authentication:auth
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
        [self requestWithMethod:method path:path data:data authentication:auth
                     onComplete:completeBlock];
    }
}

- (void)requestQueuedWithMethod:(NSString *)method path:(NSString *)path data:(NSDictionary *)data
{
    FXAuthentication *auth = [Flox authentication];
    
    if ([method isEqualToString:FXHTTPMethodPut])
    {
        // TODO: save data to cache
        // TODO: filter redundant queue contents
    }
    
    [_queue enqueueObject:@{ @"method": method, @"path": path,
                             @"data": data, @"authentication": auth }];
    [self processQueue];
}

- (BOOL)processQueue
{
    if (_processingQueue)
        return YES;
    
    if (_queue.count)
    {
        _processingQueue = YES;
        
        [_queue loadHead:^(NSDictionary *head)
         {
             if (head)
             {
                 NSString *method       = head[@"method"];
                 NSString *path         = head[@"path"];
                 NSDictionary *data     = head[@"data"];
                 FXAuthentication *auth = head[@"authentication"];
                 
                 [self requestWithMethod:method path:path data:data authentication:auth
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
                 
                 // file could not be loaded -> we continue with the next element
                 [_queue removeHead];
                 [self processQueue];
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
