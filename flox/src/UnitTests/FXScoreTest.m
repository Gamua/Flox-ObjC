//
//  FXScoreTest.m
//  Flox
//
//  Created by Daniel Sperl on 28.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FXTest.h"

static NSString *const FXTestLeaderboardID = @"default";

@interface FXScoreTest : XCTestCase

@end

@implementation FXScoreTest

- (void)setUp
{
    [super setUp];
    [FXTest startFlox];
}

- (void)tearDown
{
    [FXTest stopFlox];
    [super tearDown];
}

- (void)testSubmitAndReceive
{
    FX_START_SYNC();
    
    [Flox postScore:100 ofPlayer:@"Tony" toLeaderboard:FXTestLeaderboardID];
    [Flox loadScoresFromLeaderboard:FXTestLeaderboardID timeScope:FXTimeScopeThisWeek
                         onComplete:^(NSArray *scores, NSError *error)
    {
        FX_ABORT_SYNC_ON_ERROR(error, @"error loading scores");
        
        XCTAssert(scores.count > 0, @"didn't receive any score");
        NSInteger highscore = ((FXScore *)scores[0]).value;
        
        [Flox postScore:highscore+1 ofPlayer:@"Tony" toLeaderboard:FXTestLeaderboardID];
        [Flox postScore:highscore+1 ofPlayer:@"Tina" toLeaderboard:FXTestLeaderboardID];
        
        [Flox loadScoresFromLeaderboard:FXTestLeaderboardID timeScope:FXTimeScopeThisWeek
                             onComplete:^(NSArray *scores, NSError *error)
         {
             FX_ABORT_SYNC_ON_ERROR(error, @"error loading scores (part 2)");
             
             XCTAssert(scores.count >= 2, @"wrong number of scores returned");
             
             FXScore *score0 = scores[0];
             FXScore *score1 = scores[1];
             
             XCTAssertEqual(score0.value, score1.value, @"wrong scores");
             XCTAssertEqual(highscore, score0.value - 1, @"wrong score");
             
             XCTAssertNotNil(score0.date, @"empty date");
             XCTAssertEqual(2, (int)score0.country.length, @"invalid country code");
             XCTAssertNotNil(score0.playerID, @"empty player id");
             XCTAssert([score0.playerName isEqualToString:@"Tony"] ||
                       [score0.playerName isEqualToString:@"Tina"], @"wrong player name");

             FX_END_SYNC();
         }];
    }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testPlayerScores
{
    FX_START_SYNC();
    
    [FXPlayer loginGuest];
    FXPlayer *player1 = [FXPlayer current];
    [Flox postScore:100 ofPlayer:@"Thelma" toLeaderboard:FXTestLeaderboardID];
    
    [FXPlayer loginGuest];
    FXPlayer *player2 = [FXPlayer current];
    [Flox postScore:101 ofPlayer:@"Louise" toLeaderboard:FXTestLeaderboardID];
    
    NSArray *playerIDs = @[ player1.id, player2.id ];
    
    [Flox loadScoresFromLeaderboard:FXTestLeaderboardID playerIDs:playerIDs
                         onComplete:^(NSArray *scores, NSError *error)
    {
        FX_ABORT_SYNC_ON_ERROR(error, @"could not load scores");
        
        XCTAssertEqual(2, (int)scores.count, @"returned wrong number of scores");
        XCTAssertEqualObjects([scores[0] playerID], player2.id, @"wrong top score");
        XCTAssertEqualObjects([scores[1] playerID], player1.id, @"wrong 2nd score");
        
        FX_END_SYNC();
    }];
    
    FX_WAIT_FOR_SYNC();
}

@end
