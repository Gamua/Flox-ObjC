//
//  FXAuthentication.h
//  Flox
//
//  Created by Daniel Sperl on 13.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

/// This class stores information about how the current player was authenticated.
@interface FXAuthentication : NSObject <NSCoding>

/// Create an Authentication instance with the given parameters.
- (instancetype)initWithPlayerID:(NSString *)playerID type:(NSString *)authType
                              id:(NSString *)authID token:(NSString *)authToken;

/// The player ID of the authenticated player.
@property (nonatomic, readonly) NSString *playerID;

/// The authentication type, which is one of the 'FXAuthType...' constants.
@property (nonatomic, readonly) NSString *type;

/// The authentication ID, which is the id of the player in the authentication realm
/// (e.g. a Facebook user ID).
@property (nonatomic, readonly) NSString *id;

/// The token that identifies the session within the authentication realm.
@property (nonatomic, readonly) NSString *token;

@end
