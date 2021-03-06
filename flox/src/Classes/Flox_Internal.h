//
//  Flox+Internal.h
//  Flox
//
//  Created by Daniel Sperl on 08.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "Flox.h"
#import "FXAuthentication.h"
#import "FXRestService.h"
#import "FXPlayer.h"

@interface Flox (Internal)

/// Starts Flox with a specific base URL.
+ (void)startWithGameID:(NSString *)gameID key:(NSString *)gameKey version:(NSString *)gameVersion
                baseURL:(NSURL *)baseURL;

/// Returns the rest service class that is used for all client-server communication.
+ (FXRestService *)service;

/// The current local player, stored persistently.
+ (FXPlayer *)currentPlayer;
+ (void)setCurrentPlayer:(FXPlayer *)player;

/// The current authentication object, stored persistently.
+ (FXAuthentication *)authentication;
+ (void)setAuthentication:(FXAuthentication *)authentication;

/// Indicates if one of the "start" methods has already been called on Flox.
+ (void)checkStarted;

@end
