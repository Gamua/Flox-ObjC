//
//  FXAuthentication.m
//  Flox
//
//  Created by Daniel Sperl on 13.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import "FXAuthentication.h"

static NSString *const FXKeyPlayerID = @"playerID";
static NSString *const FXKeyType     = @"type";
static NSString *const FXKeyID       = @"id";
static NSString *const FXKeyToken    = @"token";

@implementation FXAuthentication

- (instancetype)initWithPlayerID:(NSString *)playerID type:(NSString *)authType
                              id:(NSString *)authID token:(NSString *)authToken
{
    if ((self = [super init]))
    {
        _playerID = [playerID copy];
        _type = [authType copy];
        _id = [authID copy];
        _token = [authToken copy];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _playerID = [decoder decodeObjectForKey:FXKeyPlayerID];
        _type     = [decoder decodeObjectForKey:FXKeyType];
        _id       = [decoder decodeObjectForKey:FXKeyID];
        _token    = [decoder decodeObjectForKey:FXKeyToken];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_playerID forKey:FXKeyPlayerID];
    [coder encodeObject:_type     forKey:FXKeyType];
    [coder encodeObject:_id       forKey:FXKeyID];
    [coder encodeObject:_token    forKey:FXKeyToken];
}

@end
