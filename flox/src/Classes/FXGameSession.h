//
//  FXGameSession.h
//  Flox
//
//  Created by Daniel Sperl on 31.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

/// A Game Session contains the Analytics data of one game.
@interface FXGameSession : NSObject <NSCoding>

/// --------------------
/// @name Initialization
/// --------------------

/// Initialize a session with certain properties, coonnecting it to a previous session.
- (instancetype)initWithGameID:(NSString *)gameID gameVersion:(NSString *)gameVersion
                installationID:(NSString *)installationID reportAnalytics:(BOOL)reportAnalytics
               previousSession:(FXGameSession *)previousSession;

/// -------------
/// @name Methods
/// -------------

/// Starts the session.
/// The first time a session is started, analytics data will be sent to the server.
- (void)start;

/// Stops the session timer. Called when the app moves into the background.
- (void)pause;

- (void)logInfo:(NSString *)message;
- (void)logWarning:(NSString *)message;
- (void)logError:(NSString *)name message:(NSString *)message stacktrace:(NSString *)stacktrace;
- (void)logEvent:(NSString *)name properties:(NSDictionary *)properties;

/// ----------------
/// @name Properties
/// ----------------

/// The exact time the session was started.
@property (nonatomic, readonly) NSDate *startTime;

/// The time the very first session was started on this device.
@property (nonatomic, readonly) NSDate *firstStartTime;

/// The duration of the session in seconds.
@property (nonatomic, readonly) NSInteger duration;

@end
