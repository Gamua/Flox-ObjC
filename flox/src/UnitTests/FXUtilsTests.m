//
//  UtilsTests.m
//  Flox
//
//  Created by Daniel Sperl on 08.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FXUtils.h"
#import "FXEntity.h"
#import "FXScore.h"

@interface FXUtilsTests : XCTestCase

@end

@implementation FXUtilsTests

- (void)testRandomUID
{
    for (NSUInteger i=0; i<32; ++i)
    {
        NSString *string = [FXUtils randomUIDWithLength:i];
        XCTAssertEqual(i, string.length, @"wrong random string length");
    }
}

- (void)testStringFromDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = 2013;
    dateComponents.month = 10;
    dateComponents.day = 8;
    dateComponents.hour = 14;
    dateComponents.minute = 36;
    dateComponents.second = 2;
    dateComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:60*60];
    
    NSDate *date = [calendar dateFromComponents:dateComponents];
    NSString *xmlDate = [FXUtils stringFromDate:date];
    NSString *expectedXmlDate = @"2013-10-08T13:36:02.000Z";
    
    XCTAssertEqualObjects(xmlDate, expectedXmlDate, @"date not formatted correctly");
    
    NSDate *laterDate = [NSDate dateWithTimeInterval:0.123 sinceDate:date];
    xmlDate = [FXUtils stringFromDate:laterDate];
    expectedXmlDate = @"2013-10-08T13:36:02.123Z";
    
    XCTAssertEqualObjects(xmlDate, expectedXmlDate, @"date not formatted correctly");
}

@end
