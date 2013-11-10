//
//  FXGameSession.m
//  Flox
//
//  Created by Daniel Sperl on 31.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXGameSession.h"
#import "FXCommon.h"
#import "FXUtils.h"
#import "FXCapabilities.h"
#import "Flox_Internal.h"

static NSString *const FXKeyGameVersion = @"gameVersion";
static NSString *const FXKeyFirstStartTime = @"firstStartTime";
static NSString *const FXKeyStartTime = @"startTime";
static NSString *const FXKeyLog = @"log";
static NSString *const FXKeyDuration = @"duration";

@implementation FXGameSession
{
    NSString *_gameVersion;
    NSDate *_firstStartTime;
    NSDate *_startTime;
    NSMutableArray *_log;
    NSInteger _duration;
    NSTimer *_timer;
    NSMutableDictionary *_analyticsData;
}

- (instancetype)init
{
    [NSException raise:FXExceptionInvalidOperation format:@"invalid init call"];
    return nil;
}

- (instancetype)initWithGameID:(NSString *)gameID gameVersion:(NSString *)gameVersion
                installationID:(NSString *)installationID reportAnalytics:(BOOL)reportAnalytics
               previousSession:(FXGameSession *)previousSession
{
    if ((self = [super init]))
    {
        _firstStartTime = previousSession ? previousSession.firstStartTime : [NSDate date];
        _log = [NSMutableArray array];
        _duration = 0;
        
        if (reportAnalytics)
        {
            CGSize resolution = [FXCapabilities screenResolution];
            NSString *resolutionString = [NSString stringWithFormat:@"%dx%d",
                                          (int)resolution.width, (int)resolution.height];
            
            _analyticsData = [[NSMutableDictionary alloc] init];
            _analyticsData[@"installationId"] = installationID;
            _analyticsData[@"gameVersion"] = gameVersion;
            _analyticsData[@"languageCode"] = [FXCapabilities language];
            _analyticsData[@"deviceInfo"] = @{
                @"version": [FXCapabilities deviceVersion],
                @"resolution": resolutionString,
                @"os": [FXCapabilities osVersion],
            };
            
            if (previousSession)
            {
                [previousSession pause];
                _analyticsData[@"firstStartTime"] = [FXUtils stringFromDate:_firstStartTime];
                _analyticsData[@"lastStartTime"]  = [FXUtils stringFromDate:previousSession.startTime];
                _analyticsData[@"lastDuration"] = @(previousSession.duration);
                _analyticsData[@"lastLog"] = previousSession->_log;
            }
        }
    }
    return self;
}

- (void)start
{
    if (!_startTime) _startTime = [NSDate date];
    if (_analyticsData)
    {
        _analyticsData[@"startTime"] = [FXUtils stringFromDate:_startTime];
        [[Flox service] requestQueuedWithMethod:FXHTTPMethodPost path:@".analytics" data:_analyticsData];
        _analyticsData = nil;
    }
    
    if (!_timer)
         _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                                                 selector:@selector(advanceTime:)
                                                 userInfo:nil repeats:YES];
}

- (void)pause
{
    [_timer invalidate];
    _timer = nil;
}

- (void)advanceTime:(NSTimer *)timer
{
    _duration += round(timer.timeInterval);
}

- (void)logInfo:(NSString *)message
{
    [self addLogEntryWithType:@"info" entry:@{ @"message": message }];
}

- (void)logWarning:(NSString *)message
{
    [self addLogEntryWithType:@"warning" entry:@{ @"message": message }];
}

- (void)logError:(NSString *)name message:(NSString *)message stacktrace:(NSString *)stacktrace
{
    [self addLogEntryWithType:@"error" entry:@{
        @"name": name,
        @"message": message,
        @"stacktrace": stacktrace ? stacktrace : [NSNull null]
    }];
}

- (void)logEvent:(NSString *)name properties:(NSDictionary *)properties
{
    [self addLogEntryWithType:@"event" entry:@{
        @"name": name,
        @"properties": properties ? properties : [NSNull null]
    }];
}

- (void)addLogEntryWithType:(NSString *)type entry:(NSDictionary *)entry
{
    NSMutableDictionary *mutableEntry = [[NSMutableDictionary alloc] initWithDictionary:entry];
    mutableEntry[@"type"] = type;
    mutableEntry[@"time"] = [FXUtils stringFromDate:[NSDate date]];
    [_log addObject:mutableEntry];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if ((self = [super init]))
    {
        _gameVersion = [decoder decodeObjectForKey:FXKeyGameVersion];
        _firstStartTime = [decoder decodeObjectForKey:FXKeyFirstStartTime];
        _startTime = [decoder decodeObjectForKey:FXKeyStartTime];
        _log = [decoder decodeObjectForKey:FXKeyLog];
        _duration = [decoder decodeIntForKey:FXKeyDuration];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_gameVersion forKey:FXKeyGameVersion];
    [coder encodeObject:_firstStartTime forKey:FXKeyFirstStartTime];
    [coder encodeObject:_startTime forKey:FXKeyStartTime];
    [coder encodeObject:_log forKey:FXKeyLog];
    [coder encodeInt:(int)_duration forKey:FXKeyDuration];
}

@end
