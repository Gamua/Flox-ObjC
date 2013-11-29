//
//  Flox.m
//  Flox
//
//  Created by Daniel Sperl on 02.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <UIKit/UIKit.h>

#import "Flox.h"
#import "Flox_Internal.h"
#import "FXRestService.h"
#import "FXCommon.h"
#import "FXUtils.h"
#import "FXInstallationData.h"
#import "NSJSONSerialization+String.h"

static const double FXMaxSessionInterruptionTime = 15.0 * 60.0;

static NSString *gameID;
static NSString *gameKey;
static NSString *gameVersion;
static FXRestService *restService;
static FXInstallationData *installationData;
static BOOL printLogs = YES;
static BOOL reportAnalytics = YES;
static NSDate *deactivatedAt = nil;
static Class playerClass = nil;

// --- C functions ---------------------------------------------------------------------------------

static void FXLog(NSString *format, ...)
{
    if (printLogs)
    {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        
        NSLog(@"%@", message);
    }
}

// --- class implementation ------------------------------------------------------------------------

@implementation Flox

- (instancetype)init
{
    [NSException raise:FXExceptionAbstractClass
                format:@"Attempting to initialize abstract class Flox."];
    return nil;
}

+ (void)startWithGameID:(NSString *)gameID key:(NSString *)gameKey version:(NSString *)gameVersion
{
    NSURL *baseURL = [NSURL URLWithString:@"https://www.flox.cc/api/"];
    [self startWithGameID:gameID key:gameKey version:gameVersion baseURL:baseURL];
}

+ (void)startWithGameID:(NSString *)gameID key:(NSString *)gameKey
{
    [self startWithGameID:gameID key:gameKey version:@"1.0"];
}

+ (void)stop
{
    if ([self isStarted])
    {
        [self.session pause];
        [self observeApplicationNotifications:NO];
        [self saveLocalData];
        
        gameID = gameKey = gameVersion = nil;
        restService = nil;
    }
}

#pragma mark - leaderboards

+ (void)postScore:(NSInteger)score ofPlayer:(NSString *)playerName
    toLeaderboard:(NSString *)leaderboardID
{
    [self checkStarted];
    
    NSString *path = [@"leaderboards/" stringByAppendingString:leaderboardID];
    NSDictionary *data = @{
        @"playerName": playerName,
        @"value": @(score)
    };
    
    [restService requestQueuedWithMethod:FXHTTPMethodPost path:path data:data];
}

+ (void)loadScoresFromLeaderboard:(NSString *)leaderboardID timeScope:(FXTimeScope)timeScope
                       onComplete:(FXScoresLoadedBlock)block
{
    [self checkStarted];
    
    NSString *path = [@"leaderboards/" stringByAppendingString:leaderboardID];
    NSDictionary *data = @{ @"t": FXTimeScopeToString(timeScope) };
    
    [restService requestWithMethod:FXHTTPMethodGet path:path data:data
                        onComplete:^(id body, NSInteger httpStatus, NSError *error)
    {
        block([self createScoreArray:body], error);
    }];
}

+ (NSArray *)createScoreArray:(NSArray *)rawScores
{
    if (!rawScores) return nil;
    else
    {
        NSMutableArray *scores = [NSMutableArray array];
        for (NSDictionary *rawScore in rawScores)
        {
            NSString *playerID   = rawScore[@"playerId"];
            NSString *playerName = rawScore[@"playerName"];
            NSString *country    = rawScore[@"country"];
            NSDate *date         = [FXUtils dateFromString:rawScore[@"createdAt"]];
            NSInteger value      = [rawScore[@"value"] integerValue];
            
            FXScore *score = [[FXScore alloc] initWithPlayerID:playerID name:playerName value:value
                                                          date:date country:country];
            [scores addObject:score];
        }
        return scores;
    }
}

#pragma mark - logging

+ (void)logInfo:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    FXLog(@"[Info] %@", message);
    [self.session logInfo:message];
}

+ (void)logWarning:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    FXLog(@"[Warning] %@", message);
    [self.session logWarning:message];
}

+ (void)logError:(NSString *)name message:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    FXLog(@"[Error] %@ - %@", name, message);
    [self.session logError:name message:message stacktrace:nil];
}

+ (void)logError:(NSString *)name exception:(NSException *)exception
{
    NSString *message = [NSString stringWithFormat:@"[Error] %@ - name: '%@', reason: '%@'",
                         name, exception.name, exception.reason];
    
    if (exception.userInfo)
        message = [message stringByAppendingFormat:@", userInfo: %@",
                   [NSJSONSerialization stringWithJSONObject:exception.userInfo]];
    
    FXLog(@"%@", message);
    [self.session logError:name message:message stacktrace:exception.callStackSymbols.description];
}

+ (void)logError:(NSString *)name error:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"[Error] %@ - domain: '%@', code: '%d'",
                         name, error.domain, (int)error.code];
    
    if (error.userInfo)
        message = [message stringByAppendingFormat:@", userInfo: %@",
                   [NSJSONSerialization stringWithJSONObject:error.userInfo]];
    
    FXLog(@"%@", message);
    [self.session logError:name message:message stacktrace:nil];
}

+ (void)logEvent:(NSString *)name
{
    FXLog(@"[Event] %@", name);
    [self.session logEvent:name properties:nil];
}

+ (void)logEvent:(NSString *)name properties:(NSDictionary *)properties
{
    FXLog(@"[Event] %@ - %@", name, [NSJSONSerialization stringWithJSONObject:properties]);
    [self.session logEvent:name properties:properties];
}

#pragma mark - session management

+ (void)startNewGameSession
{
    installationData.gameSession = [[FXGameSession alloc] initWithGameID:gameID
        gameVersion:gameVersion installationID:self.installationID reportAnalytics:reportAnalytics
                               previousSession:self.session];
    
    [installationData.gameSession start];
}

+ (void)observeApplicationNotifications:(BOOL)enable
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center removeObserver:self name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [center removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    if (enable)
    {
        [center addObserver:self selector:@selector(onDeactivate)
                       name:UIApplicationDidEnterBackgroundNotification object:nil];
        [center addObserver:self selector:@selector(onActivate)
                       name:UIApplicationWillEnterForegroundNotification object:nil];
    }
}

+ (void)onActivate
{
    double interruptionLength = [[NSDate date] timeIntervalSinceDate:deactivatedAt];
    
    if (interruptionLength > FXMaxSessionInterruptionTime)
    {
        [self startNewGameSession];
        [self logInfo:@"Game activated (long interruption - starting new Flox session)"];
    }
    else
    {
        [self processQueue];
        [self.session start];
        [self logInfo:@"Game activated (short interruption - continuing Flox session)"];
    }
}

+ (void)onDeactivate
{
    deactivatedAt = [NSDate date];
    [self logInfo:@"Game deactivated"];
    [self.session pause];
    [self saveLocalData];
}

+ (FXGameSession *)session
{
    return installationData.gameSession;
}

#pragma mark - misc

+ (void)processQueue
{
    [self checkStarted];
    [restService processQueue];
}

+ (BOOL)isStarted
{
    return restService != nil;
}

+ (NSString *)version
{
    return @"0.1";
}

+ (NSString *)installationID
{
    [self checkStarted];
    return installationData.installationID;
}

+ (void)setPrintLogs:(BOOL)value
{
    printLogs = value;
}

+ (BOOL)printLogs
{
    return printLogs;
}

+ (void)setReportAnalytics:(BOOL)value
{
    reportAnalytics = value;
}

+ (BOOL)reportAnalytics
{
    return reportAnalytics;
}

+ (void)setPlayerClass:(Class)aClass
{
    if ([self isStarted])
        [NSException raise:FXExceptionInvalidOperation
                    format:@"The Player class needs to be set BEFORE starting Flox"];
    else if (!aClass)
        [NSException raise:FXExceptionInvalidOperation
                    format:@"The Player class must not be 'nil'"];
    else if (![aClass isSubclassOfClass:[FXPlayer class]])
        [NSException raise:FXExceptionInvalidOperation
                    format:@"The Player class must extend 'FXPlayer'"];
    
    playerClass = aClass;
}

+ (Class)playerClass
{
    return playerClass;
}

+ (NSString *)pathForInstallationData
{
    // TODO: check if gameID is valid string for file ...
    
    NSString *floxDirectory = @"flox";
    NSString *filename = [NSString stringWithFormat:@"installation-%@", gameID];
    NSString *path = [floxDirectory stringByAppendingPathComponent:filename];
    return [FXUtils pathForResource:path inDirectory:NSLibraryDirectory];
}

+ (void)saveLocalData
{
    [self checkStarted];
    [restService save];
    [NSKeyedArchiver archiveRootObject:installationData toFile:[self pathForInstallationData]];
}

@end

// --- Internal class implementation ---------------------------------------------------------------

@implementation Flox (Internal)

+ (void)startWithGameID:(NSString *)aGameID key:(NSString *)aGameKey
                version:(NSString *)aGameVersion baseURL:(NSURL *)anURL
{
    if ([self isStarted])
        [NSException raise:FXExceptionInvalidOperation format:@"Flox is already initialized"];
    
    if (!playerClass)
        playerClass = [FXPlayer class];
    
    gameID      = [aGameID copy];
    gameKey     = [aGameKey copy];
    gameVersion = [aGameVersion copy];
    restService = [[FXRestService alloc] initWithURL:anURL gameID:gameID gameKey:gameKey];
    installationData = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForInstallationData]];
    
    if (!installationData)
        installationData = [[FXInstallationData alloc] init];
    
    if (!self.currentPlayer)
        [FXPlayer loginGuest];
    
    [self observeApplicationNotifications:YES];
    [self startNewGameSession];
    [self logInfo:@"Game started"];
}

+ (FXRestService *)service
{
    [self checkStarted];
    return restService;
}

+ (void)checkStarted
{
    if (![self isStarted])
        [NSException raise:FXExceptionInvalidOperation
                    format:@"Call [Flox start...]' before using any other method."];
}

+ (FXPlayer *)currentPlayer
{
    return installationData.currentPlayer;
}

+ (void)setCurrentPlayer:(FXPlayer *)player
{
    installationData.currentPlayer = player;
}

+ (FXAuthentication *)authentication
{
    return installationData.authentication;
}

+ (void)setAuthentication:(FXAuthentication *)authentication
{
    installationData.authentication = authentication;
}

@end
