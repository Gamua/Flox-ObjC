//
//  Flox.h
//  Flox
//
//  Created by Daniel Sperl on 02.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

#import "FXScore.h"
#import "FXUtils.h"
#import "FXCommon.h"

typedef void (^FXScoresLoadedBlock)(NSArray *scores, NSError *error);

/** ------------------------------------------------------------------------------------------------

 The main class used to interact with the Flox cloud service.

 Do not instantiate this class, but instead use the provided static methods.
 Right at the beginning, you have to initialize Flox:

    [Flox startWithGameID:@"my-game-id" key:@"my-game-key" version:@"1.0"];
 
 **Logs**
 
 You can use Flox to log important information at run-time. By browsing through your logs,
 you will be able to understand what has happened in a specific session -- a great help in
 case of an error.
 
    [Flox logInfo:@"Player %@ lost a life", player.id];
    [Flox logWarning:@"Something fishy is going on!"];
    [Flox logError:@"CorruptData" error:error];
 
 **Events**
 
 Events are displayed separately in the online interface. They are a great way to get
 feedback about the usage of a game.
 Use a limited set of strings for event names and property values, though. Otherwise,
 the visualization of the data in the online interface will become useless quickly.

    [Flox logEvent:@"GameStarted"];
    [Flox logEvent:@"MenuNavigation" properties:@{ @"from": @"MainMenu", @"to": @"SettingsMenu" }];
 
 **Leaderboards**
 
 Sending and receiving scores is straight-forward. First, you have to set up
 a leaderboard in the online interface; the ID of the leaderboard is then used to identify
 it on the client. When retrieving scores, you can choose between different 'TimeScopes'.

    [Flox postScore:999 ofPlayer:@"Mike" toLeaderboard:@"default"];
    [Flox loadScoresFromLeaderboard:@"default" timeScope:FXTimeScopeAllTime
                         onComplete:^(NSArray *scores, NSError *error)
     {
         NSLog(@"received %d scores", (int)scores.count);
     }];
 
------------------------------------------------------------------------------------------------- */

@interface Flox : NSObject

/// --------------------------------
/// @name Starting and Stopping Flox
/// --------------------------------

/// Start Flox with a certain game ID and key. Use the 'gameVersion' parameter to link the
/// collected analytics to a certain game version.
+ (void)startWithGameID:(NSString *)gameID key:(NSString *)gameKey version:(NSString *)gameVersion;

/// Start Flox with a certain game ID and key.
+ (void)startWithGameID:(NSString *)gameID key:(NSString *)gameKey;

/// Stop the Flox session. You don't have to do this manually in most cases.
+ (void)stop;

/// ------------------
/// @name Leaderboards
/// ------------------

/// Posts a score to a certain leaderboard. Beware that only the top score of a player will
/// appear on the leaderboard.
///
/// If the device is offline when you call this method, the score will be cached and
/// is sent the next time it is online.
+ (void)postScore:(NSInteger)score ofPlayer:(NSString *)playerName
    toLeaderboard:(NSString *)leaderboardID;

/// Loads the scores (instances of `FXScore`) of a certain leaderboard from the server.
/// At the moment, you get a maximum of 200 scores per leaderboard and time scope.
/// Each player will be in the list only once.
///
/// Note that when the server cannot be reached (e.g. because the player is offline - the 'error'
/// parameter will tell you more), the 'scores' parameter will contain the scores that Flox
/// cached from the last request (if available).
+ (void)loadScoresFromLeaderboard:(NSString *)leaderboardID timeScope:(FXTimeScope)timeScope
                       onComplete:(FXScoresLoadedBlock)block;

/// -------------
/// @name Logging
/// -------------

/// Adds a log of type 'info'.
+ (void)logInfo:(NSString *)format, ...;

/// Adds a log of type 'warning'.
+ (void)logWarning:(NSString *)format, ...;

/// Adds a log of type 'error'. Use 'name' to identify the error later and 'message' for
/// additional information.
+ (void)logError:(NSString *)name message:(NSString *)format, ...;

/// Adds a log of type 'error'. Use 'name' to identify the error later and 'exception' for
/// stack trace information.
+ (void)logError:(NSString *)name exception:(NSException *)exception;

/// Adds a log of type 'error'. Use 'name' to identify the error later and 'error' for
/// additional information.
+ (void)logError:(NSString *)name error:(NSError *)error;

/// Adds a log of type 'event'. Events are displayed separately in the online interface.
/// Limit yourself to a predefined set of strings!
+ (void)logEvent:(NSString *)name;

/// Adds a log of type 'event'. Events are displayed separately in the online interface.
/// The 'properties' dictionary will be visualized through diagrams.
/// Limit yourself to a predefined set of strings!
+ (void)logEvent:(NSString *)name properties:(NSDictionary *)properties;

/// ----------
/// @name Misc
/// ----------

/// Starts processing the request queue. The request queue is mainly used by the 'queued'
/// variants of the Entity access methods. Normally, you don't have to call this method
/// manually: it will be processed whenever you make a request on the server or add
/// something to the queue. */
+ (void)processQueue;

/// Saves all locally cached data to disk (entity cache, http service queue).
+ (void)saveLocalData;

/// --------------
/// @name Settings
/// --------------

/// The current version of the Flox library.
+ (NSString *)version;

/// Returns a unique identifier for the installation, i.e. when the
/// app is deleted or the Flash cookies are lost, the id will change. */
+ (NSString *)installationID;

/// Indicates if log methods should write their output to the console. (Default: YES)
+ (void)setPrintLogs:(BOOL)print;

/// Indicates if log methods should write their output to the console.
+ (BOOL)printLogs;

/// Indicates if analytics reports should be sent to the server. (Default: YES)
+ (void)setReportAnalytics:(BOOL)reportAnalytics;

/// Indicates if analytics reports should be sent to the server.
+ (BOOL)reportAnalytics;

@end
