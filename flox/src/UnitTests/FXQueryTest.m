//
//  FXQueryTest.m
//  Flox
//
//  Created by Daniel Sperl on 01.12.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Flox.h"
#import "FXTest.h"
#import "FXQuery.h"
#import "CustomPlayer.h"
#import "CustomEntity.h"

@interface FXQueryTest : XCTestCase

@end

@implementation FXQueryTest

- (void)setUp
{
    [FXTest startFlox];
}

- (void)tearDown
{
    [FXTest stopFlox];
}

- (void)testConstraints
{
    NSString *dateString = @"2013-12-24T18:00:00.000Z";
    NSDate *date = [FXUtils dateFromString:dateString];
    NSString *name = @"mercedes";
    int age = 10;
    
    FXQuery *query = [CustomEntity queryWhere:@"name == ? AND (age < ? OR birthday < ?) AND age IN ?",
                 name, age, date, @[@5, @7, @9]];
    
    NSString *expected = [NSString stringWithFormat:
                          @"name == \"%@\" AND (age < %d OR birthday < \"%@\") AND age IN [5,7,9]",
                          name, age, dateString];
    
    NSLog(@"constraints: %@", query.constraints);
    
    XCTAssertEqualObjects(expected, query.constraints, @"constraints were built in the wrong way");
}

- (void)testFind
{
    FX_START_SYNC();
    
    [FXPlayer loginGuest]; // to get new ownership each time this test executes
    
    CustomEntity *e0 = [[CustomEntity alloc] initWithName:@"a" age:40];
    CustomEntity *e1 = [[CustomEntity alloc] initWithName:@"b" age:30];
    CustomEntity *e2 = [[CustomEntity alloc] initWithName:@"c" age:20];
    CustomEntity *e3 = [[CustomEntity alloc] initWithName:@"d" age:10];
    
    [e0 saveQueued];
    [e1 saveQueued];
    
    [FXUtils observeNextNotification:FXQueueProcessedNotification fromObject:nil
                          usingBlock:^(NSNotification *notification)
    {
        // doing it like that, 1 result will be from the cache,
        // the other will be loaded from the server.
        
        [Flox.service clearCache];
        [e2 saveQueued];
        [e3 saveQueued];
        
        FXQuery *query = [CustomEntity queryWhere:@"name > ? AND name < ?", @"a", @"d"];
        [query find:^(NSArray *entities, NSInteger httpStatus, NSError *error)
         {
             FX_ABORT_SYNC_ON_ERROR(error, @"could not execute query");
             
             XCTAssertEqual((int)entities.count, 2, @"returned wrong number of entities");
             
             entities = [entities sortedArrayUsingSelector:@selector(age)];
             
             CustomEntity *r0 = entities[0];
             CustomEntity *r1 = entities[1];
             
             XCTAssertEqualObjects(r0.id, e2.id, @"returned wrong entity");
             XCTAssertEqualObjects(r1.id, e1.id, @"returned wrong entity");
             
             FX_END_SYNC();
         }];
    }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testFindWithoutConstraints
{
    FX_START_SYNC();
    
    [FXPlayer loginGuest]; // to get new ownership each time this test executes
    
    CustomEntity *e0 = [[CustomEntity alloc] initWithName:@"a" age:10];
    CustomEntity *e1 = [[CustomEntity alloc] initWithName:@"b" age:20];
    
    [e0 saveQueued];
    [e1 saveQueued];
    
    FXQuery *query = [CustomEntity query];
    query.limit = 2;
    
    [query find:^(NSArray *entities, NSInteger httpStatus, NSError *error)
     {
         FX_ABORT_SYNC_ON_ERROR(error, @"could not execute query");
         XCTAssert(entities.count == 2, @"returned wrong number of entities");
         FX_END_SYNC();
     }];
    
    FX_WAIT_FOR_SYNC();
}

@end
