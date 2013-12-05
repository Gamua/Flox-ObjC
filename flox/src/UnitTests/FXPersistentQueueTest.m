//
//  FXPersistentQueueTest.m
//  Flox
//
//  Created by Daniel Sperl on 28.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FXPersistentQueue.h"
#import "FXTest.h"

NSString *const FXQueueName = @"queue-name";

@interface FXPersistentQueueTest : XCTestCase

@end

@implementation FXPersistentQueueTest

- (void)setUp
{
    FXPersistentQueue *queue = [[FXPersistentQueue alloc] initWithName:FXQueueName];
    [queue removeAllObjects];
    [queue save];
}

- (void)testEnqueueAndDequeue
{
    FX_START_SYNC();
    
    FXPersistentQueue *queue = [[FXPersistentQueue alloc] initWithName:FXQueueName];
    
    NSDictionary *object0 = @{ @"string": @"hugo", @"number": @0 };
    NSDictionary *object1 = @{ @"string": @"tina", @"number": @1 };
    NSDictionary *object2 = @{ @"string": @"anna", @"number": @2 };
    
    [queue enqueueObject:object0];
    [queue enqueueObject:object1];
    [queue enqueueObject:object2];
    
    XCTAssertEqual(3, (int)queue.count, @"wrong queue count");
    
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object0, @"wrong head of queue");
     }];
    
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object0, @"wrong head of queue");
     }];
    
    [queue removeHead];
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object1, @"wrong head of queue");
     }];
    
    XCTAssertEqual(2, (int)queue.count, @"wrong queue count");
    
    [queue enqueueObject:object0];
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object1, @"wrong head of queue");
     }];
    
    XCTAssertEqual(3, (int)queue.count, @"wrong queue count");
    
    [queue removeHead];
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object2, @"wrong head of queue");
     }];

    [queue removeHead];
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object0, @"wrong head of queue");
     }];

    [queue removeHead];
    [queue loadHead:^(id head)
     {
         XCTAssertNil(head, @"queue should be empty, but contained head");
         FX_END_SYNC();
     }];

    XCTAssertEqual(0, (int)queue.count, @"wrong queue count");
    
    FX_WAIT_FOR_SYNC();
}

- (void)testPersistency
{
    FX_START_SYNC();
    
    FXPersistentQueue *queue = [[FXPersistentQueue alloc] initWithName:FXQueueName];
    
    NSDictionary *object0 = @{ @"string": @"hugo", @"number": @0 };
    NSDictionary *object1 = @{ @"string": @"tina", @"number": @1 };
    
    [queue enqueueObject:object0];
    [queue enqueueObject:object1];
    [queue save];
    
    queue = [[FXPersistentQueue alloc] initWithName:FXQueueName];
    
    XCTAssertEqual(2, (int)queue.count, @"wrong queue length");
    
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object0, @"wrong head of queue");
     }];
    
    [queue removeHead];
    [queue loadHead:^(id head)
     {
         XCTAssertEqualObjects(head, object1, @"wrong head of queue");
     }];
    
    [queue removeHead];
    [queue loadHead:^(id head)
     {
         XCTAssertNil(head, @"queue should be empty, but contained head");
         FX_END_SYNC();
     }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testRemoveAllObjects
{
    FXPersistentQueue *queue = [[FXPersistentQueue alloc] initWithName:FXQueueName];
    
    NSDictionary *object0 = @{ @"string": @"hugo", @"number": @0 };
    NSDictionary *object1 = @{ @"string": @"tina", @"number": @1 };
    
    [queue enqueueObject:object0];
    [queue enqueueObject:object1];
    [queue removeAllObjects];
    
    XCTAssertEqual(0, (int)queue.count, @"wrong queue count");
}

@end
