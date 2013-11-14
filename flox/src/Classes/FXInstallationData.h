//
//  FXInstallationData.h
//  Flox
//
//  Created by Daniel Sperl on 31.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>
#import "FXGameSession.h"
#import "FXPlayer.h"
#import "FXAuthentication.h"

/// The FXInstallationData class stores information related to the lifetime of an application
/// installation.
@interface FXInstallationData : NSObject <NSCoding>

/// Returns a unique identifier for the installation. When the app is deleted an re-installed,
/// the id will change.
@property (nonatomic, copy) NSString *installationID;

/// The current game session / analytics object.
@property (nonatomic, strong) FXGameSession *gameSession;

/// The current local player.
@property (nonatomic, strong) FXPlayer *currentPlayer;

/// The current authentication object.
@property (nonatomic, strong) FXAuthentication *authentication;

@end
