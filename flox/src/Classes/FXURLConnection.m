//
//  FXURLConnection.m
//  Flox
//
//  Created by Daniel Sperl on 17.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXURLConnection.h"

@implementation FXURLConnection
{
    NSURLConnection *_connection;
    NSInteger _responseStatus;
    NSMutableData *_responseData;
    FXURLConnectionCompleteBlock _onComplete;
}

- (instancetype)initWithRequest:(NSURLRequest *)request
{
    if ((self = [super init]))
    {
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self
                                              startImmediately:NO];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithRequest:nil];
}

- (void)startWithBlock:(FXURLConnectionCompleteBlock)completeBlock
{
    _onComplete = completeBlock;
    [_connection start];
}

- (void)cancel
{
    [_connection cancel];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    _responseData = [[NSMutableData alloc] init];
    _responseStatus = httpResponse.statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _onComplete(_responseData, _responseStatus, NULL);
    _onComplete = nil;
    _responseData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _onComplete(nil, _responseStatus, error);
    _onComplete = nil;
    _responseData = nil;
}

@end
