//
//  FXTestUtils.m
//  Flox
//
//  Created by Daniel Sperl on 18.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import "FXTest.h"

#if USE_PRODUCTION_SERVER

NSString *const FXTestBaseURL       = @"http://www.flox.cc/api/";
NSString *const FXTestGameID        = @"gamua-unit-tests";
NSString *const FXTestGameKey       = @"150a1bb6-b33d-4eb3-8848-23051f200359";

#else

#include "FloxTests-DevServer.h"

#endif

@implementation FXTest

+ (void)startFlox
{
    return [self startFloxWithAnalytics:NO];
}

+ (void)startFloxWithAnalytics
{
    return [self startFloxWithAnalytics:YES];
}

+ (void)startFloxWithAnalytics:(BOOL)reportAnalytics
{
    NSURL *baseURL = [NSURL URLWithString:FXTestBaseURL];
    
    [Flox setPrintLogs:NO];
    [Flox setReportAnalytics:reportAnalytics];
    [Flox startWithGameID:FXTestGameID key:FXTestGameKey version:[Flox version]
                  baseURL:baseURL];
    
    Flox.service.alwaysFail = NO;
}

+ (void)stopFlox
{
    [Flox stop];
}

@end