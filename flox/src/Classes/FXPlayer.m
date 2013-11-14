//
//  FXPlayer.m
//  Flox
//
//  Created by Daniel Sperl on 12.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import "FXPlayer.h"
#import "Flox_Internal.h"
#import "FXEntity_Internal.h"

@implementation FXPlayer
{
    NSString *_authType;
    NSString *_authId;
}

@synthesize authID = _authId; // server side naming scheme

- (instancetype)init
{
    if ((self = [super init]))
    {
        self.ownerID = self.id;
        self.publicAccess = FXAccessRead;
        
        _authType = nil;
        _authId   = nil;
    }
    
    return self;
}

+ (void)loginWithAuthType:(NSString *)authType authID:(NSString *)authID
                authToken:(NSString *)authToken onComplete:(FXPlayerLoginCompleteBlock)completeBlock
{
    [Flox checkStarted];
    
    if (!authID)    authID    = @"";
    if (!authToken) authToken = @"";
    
    FXPlayerLoginCompleteBlock onAuthenticated = ^(id player, NSInteger httpStatus, NSError *error)
    {
        // TODO: [Flox clearCache];
        
        Flox.currentPlayer = player;
        Flox.authentication = [[FXAuthentication alloc] initWithPlayerID:[player id]
                                           type:authType id:authID token:authToken];
        
        completeBlock(player, httpStatus, error);
    };
    
    FXRequestCompleteBlock onRequestComplete = ^(id body, NSInteger httpStatus, NSError *error)
    {
        if (error) completeBlock(nil, httpStatus, error);
        else
        {
            FXPlayer *player = [[Flox.playerClass alloc] initWithID:body[@"id"]
                                                         dictionary:body[@"entity"]];
            onAuthenticated(player, httpStatus, error);
        }
    };
    
    if ([authType isEqualToString:FXAuthTypeGuest])
    {
        FXPlayer *player = [[Flox.playerClass alloc] init];
        player->_authId = [authID copy];
        player->_authType = [authType copy];
        
        // todo: check http status
        onAuthenticated(player, 200, nil);
    }
    else
    {
        NSString *guestID = [[self.current authType] isEqualToString:FXAuthTypeGuest] ?
                             [self.current id] : nil;
        
        NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                                  authType, @"authType", authID, @"authId", authToken, @"authToken",
                                  guestID, @"id", nil];
        
        [Flox.service requestWithMethod:FXHTTPMethodPost path:@"authenticate" data:authData
                             onComplete:onRequestComplete];
    }
}

+ (void)loginWithEmail:(NSString *)email onComplete:(FXPlayerLoginCompleteBlock)block
{
    [self loginWithAuthType:FXAuthTypeEmail authID:email authToken:Flox.installationID
                 onComplete:block];
}

+ (void)loginWithKey:(NSString *)key onComplete:(FXPlayerLoginCompleteBlock)block
{
    [self loginWithAuthType:FXAuthTypeKey authID:key authToken:nil onComplete:block];
}

+ (void)loginGuest
{
    [self loginWithAuthType:FXAuthTypeGuest authID:nil authToken:nil
                 onComplete:^(id player, NSInteger httpStatus, NSError *error) {}];
}

+ (NSString *)type
{
    return @".player";
}

+ (instancetype)current
{
    FXPlayer *currentPlayer = Flox.currentPlayer;
    
    if ([currentPlayer isKindOfClass:self]) return currentPlayer;
    else return nil;
}

@end
