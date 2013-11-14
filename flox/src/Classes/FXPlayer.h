//
//  FXPlayer.h
//  Flox
//
//  Created by Daniel Sperl on 12.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import "FXEntity.h"
#import "FXCommon.h"

typedef void (^FXPlayerLoginCompleteBlock)(id player, NSInteger httpStatus, NSError *error);

/** ------------------------------------------------------------------------------------------------
 
 An Entity that contains information about a Flox Player. The class also contains static
 methods for Player login and logout.

 Do not create player instances yourself; instead, always use the player objects returned by
 `[FXPlayer current]`. A guest player is created automatically for your on first start
 (as a guest player).
 
 The current player is automatically persisted, i.e. when you close and restart your game,
 the same player will be logged in automatically.

 In many games, you'll want to use a custom player subclass, so that you can add custom properties.
 To do that, register your player class before starting Flox.
 
    [Flox setPlayerClass:[CustomPlayer class]];
 
 When you've done that, you can get your player anytime with this code:
 
    [CustomPlayer current];
 
------------------------------------------------------------------------------------------------- */
@interface FXPlayer : FXEntity

/// Log in a player with the given authentication information.
///
/// Flox requires that there's always a player logged in. Thus, there is no 'logout'
/// method. If you want to remove the reference to the current player, just call
/// another of the 'login...'-methods.
///
/// @param authType:    The type of authentication you want to use.
/// @param authID:      The id of the player in its authentication system.
/// @param authToken:   The token you received from the player's authentication system.
/// @param onComplete:  The block that will be executed when the login is complete.
+ (void)loginWithAuthType:(NSString *)authType authID:(NSString *)authID
                authToken:(NSString *)authToken onComplete:(FXPlayerLoginCompleteBlock)block;

/// Log in a player with his email address.
///
/// - If this is the first time this email address is used, the current guest player
///   will be converted into a player with auth-type "EMAIL".
/// - When the player tries to log in with the same address on another device,
///   he will get an e-mail with a confirmation link, and the login will fail until the
///   player clicks on that link.
///
/// In case of an error, the HTTP status tells you if a confirmation mail was sent:
/// `FXHTTPStatusForbidden` means that the mail was sent; `FXHTTPStatusTooManyRequests`
/// means that a mail has already been sent within the last 15 minutes.
///
/// @param email:      The e-mail address of the player trying to log in.
/// @param onComplete: The block that will be called when the login is complete.
+ (void)loginWithEmail:(NSString *)email onComplete:(FXPlayerLoginCompleteBlock)block;

/// Log in a player with just a single 'key' string. The typical use-case of this
/// authentication is to combine Flox with other APIs that have their own user database
/// (e.g. Facebook & GameCenter, etc).
+ (void)loginWithKey:(NSString *)key onComplete:(FXPlayerLoginCompleteBlock)block;

/// Logs the current player out and creates a new guest player.
/// `[FXPlayer current]` will immediately reference that player.
+ (void)loginGuest;

/// The current local player.
+ (instancetype)current;

/// ----------------
/// @name Properties
/// ----------------

/// The type of authentication the player used to log in.
@property (nonatomic, readonly) NSString *authType;

/// The main identifier of the player's authentication system.
@property (nonatomic, readonly) NSString *authID;

@end
