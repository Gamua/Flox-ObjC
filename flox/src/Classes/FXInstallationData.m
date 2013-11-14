//
//  FXInstallationData.m
//  Flox
//
//  Created by Daniel Sperl on 31.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXInstallationData.h"
#import "FXUtils.h"

static NSString *const FXKeyInstallationID = @"installationID";
static NSString *const FXKeyGameSession    = @"gameSession";
static NSString *const FXKeyCurrentPlayer  = @"currentPlayer";
static NSString *const FXKeyAuthentication = @"authentication";

@implementation FXInstallationData
{
    NSString *_installationID;
    FXGameSession *_gameSession;
    FXAuthentication *_authentication;
    FXPlayer *_currentPlayer;
}

- (instancetype)init
{
    if ((self = [super init]))
        _installationID = [FXUtils randomUID];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _installationID = [decoder decodeObjectForKey:FXKeyInstallationID];
        _gameSession    = [decoder decodeObjectForKey:FXKeyGameSession];
        _currentPlayer  = [decoder decodeObjectForKey:FXKeyCurrentPlayer];
        _authentication = [decoder decodeObjectForKey:FXKeyAuthentication];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_installationID forKey:FXKeyInstallationID];
    [coder encodeObject:_gameSession    forKey:FXKeyGameSession];
    [coder encodeObject:_currentPlayer  forKey:FXKeyCurrentPlayer];
    [coder encodeObject:_authentication forKey:FXKeyAuthentication];
}

@end
