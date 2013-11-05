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
static NSString *const FXKeyGameSession = @"gameSession";

@implementation FXInstallationData
{
    NSString *_installationID;
    FXGameSession *_gameSession;
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
        _gameSession = [decoder decodeObjectForKey:FXKeyGameSession];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_installationID forKey:FXKeyInstallationID];
    [coder encodeObject:_gameSession forKey:FXKeyGameSession];
}

@end
