//
//  FXPersistentStoreTest.m
//  Flox
//
//  Created by Daniel Sperl on 29.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FXPersistentStore.h"
#import "FXTest.h"

NSString *const FXStoreName = @"store-name";

@interface FXPersistentStoreTest : XCTestCase

@end

@implementation FXPersistentStoreTest

- (void)setUp
{
    FXPersistentStore *store = [[FXPersistentStore alloc] initWithName:FXStoreName];
    [store removeAllObjects];
    [store save];
}

- (void)testAddAndRemoveObjects
{
    FX_START_SYNC();
    
    FXPersistentStore *store = [[FXPersistentStore alloc] initWithName:FXStoreName];
    
    NSDictionary *object0 = @{ @"string": @"hugo", @"number": @0 };
    NSDictionary *object1 = @{ @"string": @"tina", @"number": @1 };
    
    [store setObject:object0 forKey:@"object0"];
    XCTAssert([store containsKey:@"object0"], @"object not found in store");
    XCTAssertFalse([store containsKey:@"object1"], @"object mistakenly found in store");
    XCTAssertFalse([store containsKey:@"object2"], @"object mistakenly found in store");
    
    [store setObject:object1 forKey:@"object1"];
    XCTAssert([store containsKey:@"object0"], @"object not found in store");
    XCTAssert([store containsKey:@"object1"], @"object not found in store");
    XCTAssertFalse([store containsKey:@"object2"], @"object mistakenly found in store");
    
    [store loadObjectForKey:@"object0" onComplete:^(id object)
     {
         XCTAssertNotNil(object, @"object not retrieved from store");
         XCTAssertEqualObjects(object, object0, @"found wrong object in store");
     }];
    
    [store loadObjectForKey:@"object1" onComplete:^(id object)
     {
         XCTAssertNotNil(object, @"object not retrieved from store");
         XCTAssertEqualObjects(object, object1, @"found wrong object in store");
     }];
    
    [store loadObjectForKey:@"object2" onComplete:^(id object)
     {
         XCTAssertNil(object, @"object mistakenly retrieved from store");
     }];
    
    [store removeObjectForKey:@"object0"];
    
    XCTAssertFalse([store containsKey:@"object0"], @"object mistakenly found in store");
    
    [store loadObjectForKey:@"object0" onComplete:^(id object)
     {
         XCTAssertNil(object, @"object mistakenly retrieved from store");
     }];
    
    [store removeAllObjects];
    
    XCTAssertFalse([store containsKey:@"object1"], @"object not removed from store");

    [store loadObjectForKey:@"object1" onComplete:^(id object)
     {
         XCTAssertNil(object, @"object mistakenly retrieved from store");
         FX_END_SYNC();
     }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testPersistency
{
    FX_START_SYNC();
    
    FXPersistentStore *store = [[FXPersistentStore alloc] initWithName:FXStoreName];
    
    NSDictionary *object0 = @{ @"string": @"hugo", @"number": @0 };
    NSDictionary *object1 = @{ @"string": @"tina", @"number": @1 };
    
    [store setObject:object0 forKey:@"object0"];
    [store setObject:object1 forKey:@"object1"];
    
    [store save];
    
    store = [[FXPersistentStore alloc] initWithName:FXStoreName];
    
    XCTAssert([store containsKey:@"object0"]);
    XCTAssert([store containsKey:@"object1"]);
    
    [store loadObjectForKey:@"object1" onComplete:^(id object)
     {
         XCTAssertNotNil(object, @"object not retrieved from store");
         XCTAssertEqualObjects(object, object1, @"found wrong object in store");
         
         FX_END_SYNC();
     }];
    
    FX_END_SYNC();
}

@end
