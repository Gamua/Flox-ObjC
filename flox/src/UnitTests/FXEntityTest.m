//
//  FXEntityTest.m
//  Flox
//
//  Created by Daniel Sperl on 06.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FXEntity_Internal.h"
#import "FXUtils.h"
#import "FXTest.h"
#import "CustomEntity.h"

@interface FXEntityTest : XCTestCase

@end

@implementation FXEntityTest

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

- (void)testType
{
    XCTAssertEqualObjects(@"CustomEntity", [CustomEntity type], @"wrong entity type (via class)");
    
    CustomEntity *entity = [[CustomEntity alloc] init];
    XCTAssertEqualObjects(@"CustomEntity", entity.type, @"wrong entity type (via instance)");
}

- (void)testDictionarySerialization
{
    CustomEntity *entity = [[CustomEntity alloc] initWithName:@"hugo" age:16];
    entity.data = @{ @"value": @(100) };
    
    NSDictionary *dict = [entity encodeToDictionary];
    
    XCTAssertEqualObjects(dict[@"createdAt"], [FXUtils stringFromDate:entity.createdAt],
                          @"date was not serialized as string");
    XCTAssertEqualObjects(dict[@"updatedAt"], [FXUtils stringFromDate:entity.updatedAt],
                          @"date was not serialized as string");
    XCTAssertEqualObjects(dict[@"birthday"], [FXUtils stringFromDate:entity.birthday],
                          @"date was not serialized as string");

    CustomEntity *copy = [[CustomEntity alloc] initWithDictionary:dict];
    
    NSDate *origDate = entity.birthday;
    NSDate *restoredDate = copy.birthday;
    double dateDiff = [origDate timeIntervalSinceDate:restoredDate];
    
    XCTAssert(fabs(dateDiff) < 0.01, @"date was not restored correctly");
    XCTAssertNil(copy.list, @"nil property was not correctly encoded");
    XCTAssertEqualObjects(@(100), copy.data[@"value"], @"dictionary was not correctly encoded");
    XCTAssertEqualObjects(entity.name, copy.name, @"string was not correctly encoded");
    XCTAssertEqualObjects(entity.publicAccess, copy.publicAccess, @"empty string was not correctly encoded");
    XCTAssertEqual(entity.age, copy.age, @"integer was not correctly encoded");
    
    entity.list = @[ @"one", @"two" ];
    copy = [[CustomEntity alloc] initWithDictionary:[entity encodeToDictionary]];
    
    XCTAssertEqual(entity.list.count, copy.list.count, @"array was not correctly encoded");
    XCTAssertEqualObjects(entity.list[0], copy.list[0], @"array element was not correctly encoded");
}

- (void)testCoding
{
    CustomEntity *entity = [[CustomEntity alloc] initWithName:@"hugo" age:16];
    entity.data = @{ @"value": @(100) };
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:entity];
    id copy = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqualObjects([copy class], [entity class], @"archiver could not restore class");
    
    CustomEntity *entityCopy = (CustomEntity *)copy;
    
    XCTAssertEqualObjects(entity.data[@"value"], entityCopy.data[@"value"], @"archiving did not work");
}

- (void)testSaveAndLoad
{
    FX_START_SYNC();
    
    CustomEntity *origEntity = [[CustomEntity alloc] initWithName:@"hugo" age:16];
    
    [origEntity save:^(id entity, NSInteger httpStatus, NSError *error)
    {
        FX_ABORT_SYNC_ON_ERROR(error, @"could not save entity");
        
        [CustomEntity loadByID:origEntity.id
                    onComplete:^(id entity, NSInteger httpStatus, NSError *error)
        {
            FX_ABORT_SYNC_ON_ERROR(error, @"could not load entity");
            
            XCTAssertEqualObjects([origEntity id], [entity id], @"loaded wrong entity");
            XCTAssertEqual([origEntity class], [entity class], @"loaded wrong type of entity");
            
            FX_END_SYNC();
        }];
    }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testSaveQueued
{
    FX_START_SYNC();
    
    CustomEntity *origEntity = [[CustomEntity alloc] initWithName:@"herta" age:17];
    [origEntity saveQueued];
    
    [FXUtils observeNextNotification:FXQueueProcessedNotification fromObject:nil
                          usingBlock:^(NSNotification *notification)
    {
        BOOL success = [notification.userInfo[@"success"] boolValue];
        XCTAssert(success, @"request queue was not processed successfully");
        
        [CustomEntity loadByID:origEntity.id
                    onComplete:^(id entity, NSInteger httpStatus, NSError *error)
        {
            FX_ABORT_SYNC_ON_ERROR(error, @"could not load entity");
            
            XCTAssertEqualObjects([origEntity id], [entity id], @"loaded wrong entity");
            XCTAssertEqual([origEntity class], [entity class], @"loaded wrong type of entity");
            
            FX_END_SYNC();
        }];
    }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testRefresh
{
    FX_START_SYNC();
    
    CustomEntity *origEntity = [[CustomEntity alloc] initWithName:@"hanna" age:18];
    [origEntity save:^(id entity, NSInteger httpStatus, NSError *error)
    {
        FX_ABORT_SYNC_ON_ERROR(error, @"could not save entity");
        
        [CustomEntity loadByID:origEntity.id
                    onComplete:^(id entity, NSInteger httpStatus, NSError *error)
        {
            FX_ABORT_SYNC_ON_ERROR(error, @"could not load entity");
            
            origEntity.age += 1;
            [origEntity saveQueued];
            
            [entity refresh:^(id entity, NSInteger httpStatus, NSError *error)
            {
                FX_ABORT_SYNC_ON_ERROR(error, @"could not refresh entity");
                
                XCTAssertEqual(origEntity.age, [entity age], @"refresh did not update property");
                FX_END_SYNC();
            }];
        }];
    }];
    
    FX_WAIT_FOR_SYNC();
}

- (void)testDestroy
{
    FX_START_SYNC();
    
    CustomEntity *origEntity = [[CustomEntity alloc] initWithName:@"hilde" age:19];
    [origEntity saveQueued];
    [origEntity destroy:^(id entity, NSInteger httpStatus, NSError *error)
    {
        FX_ABORT_SYNC_ON_ERROR(error, @"could not destroy entity");
        
        [CustomEntity loadByID:origEntity.id
                    onComplete:^(id entity, NSInteger httpStatus, NSError *error)
        {
            XCTAssertNotNil(error, @"could load entity that should have been deleted");
            FX_END_SYNC();
        }];
    }];

    FX_WAIT_FOR_SYNC();
}

@end