//
//  FXPlayerTest.m
//  Flox
//
//  Created by Daniel Sperl on 14.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Flox.h"
#import "FXTest.h"
#import "CustomPlayer.h"
#import "CustomEntity.h"

@interface FXPlayerTest : XCTestCase

@end

@implementation FXPlayerTest

- (void)setUp
{
    Flox.playerClass = [CustomPlayer class];
    [FXTest startFlox];
    [FXPlayer loginGuest];
}

- (void)tearDown
{
    [FXTest stopFlox];
}

- (void)testType
{
    FXPlayer *player = [[CustomPlayer alloc] init];
    XCTAssertEqualObjects(player.type, @".player", @"wrong player type returned");
}

- (void)testPlayerClassMustExtendPlayer
{
    [FXTest stopFlox];
    XCTAssertThrows(Flox.playerClass = [CustomEntity class], @"could assign non-FXPlayer class");
}

- (void)testGuestLogin
{
    FXPlayer *defaultGuest = [FXPlayer current];
    XCTAssertNotNil(defaultGuest, @"no default guest created");
    XCTAssertNotNil(defaultGuest.id, @"missing player id");
    XCTAssertEqualObjects(defaultGuest.type, @".player", @"wrong player type");
    XCTAssertEqualObjects(defaultGuest.authType, FXAuthTypeGuest, @"wrong auth type of guest");
    
    [FXPlayer loginGuest];
    FXPlayer *newGuest = [FXPlayer current];
    XCTAssertNotEqualObjects(newGuest.id, defaultGuest.id, @"guest login did not work");
}

- (void)testLoginCustomPlayer
{
    CustomPlayer *customPlayer = [CustomPlayer current];
    XCTAssertNotNil(customPlayer, @"could not retrieve current custom player");
    XCTAssert([customPlayer isMemberOfClass:[CustomPlayer class]]);
    XCTAssertEqual([FXPlayer current], customPlayer, @"standard [FXPlayer current] did not work");
    
    [Flox stop];
    [FXTest startFlox];
    
    XCTAssertEqualObjects(customPlayer.id, [FXPlayer current].id, @"guest did not survive restart");
}

- (void)testLoginWithKey
{
    FX_START_SYNC();
    
    CustomPlayer *guest = [CustomPlayer current];
    NSString *key = [NSString stringWithFormat:@"SECRET - %@", [FXUtils randomUID]];
    NSString *guestID = guest.id;
    
    [CustomPlayer loginWithKey:key onComplete:^(id player, NSInteger httpStatus, NSError *error)
    {
        FX_ABORT_SYNC_ON_ERROR(error, @"login with key did not work");
        
        XCTAssertEqualObjects([player id], guestID, @"login did not convert guest to key player");
        XCTAssertEqualObjects([CustomPlayer current].id, guestID, @"current player not set");
        XCTAssertEqualObjects(FXAuthTypeKey, [player authType], @"wrong auth type");
        
        [CustomPlayer loginGuest];
        
        XCTAssertNotEqualObjects([FXPlayer current].id, guestID,
                                 @"new guest login did not remove previous player");
        
        [CustomPlayer loginWithKey:key onComplete:^(id player, NSInteger httpStatus, NSError *error)
        {
            FX_ABORT_SYNC_ON_ERROR(error, @"re-login with key did not work");
            
            XCTAssertEqualObjects([player id], guestID, @"login did not convert guest to key player");
            XCTAssertEqualObjects([CustomPlayer current].id, guestID, @"current player not set");

            FX_END_SYNC();
        }];
    }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testLoginWithEmail
{
    FX_START_SYNC();
    
    FXPlayer *guest = [FXPlayer current];
    
    NSString *email = [NSString stringWithFormat:@"%@@incognitek.com", [FXUtils randomUID]];
    [CustomPlayer loginWithEmail:email onComplete:^(id player, NSInteger httpStatus, NSError *error)
    {
        // the first e-mail login should work right away.
        FX_ABORT_SYNC_ON_ERROR(error, @"could not login with email");
        
        XCTAssertEqualObjects([player id], guest.id, @"guest login not upgrade to email login");
        
        // For the API, this test is enough. Activation is a server responsibility.
        FX_END_SYNC();
    }];
    
    FX_WAIT_FOR_SYNC();
}

@end
