//
//  FXURLConnectionTests.m
//  Flox
//
//  Created by Daniel Sperl on 17.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FXTest.h"
#import "FXURLConnection.h"

@interface FXURLConnectionTests : XCTestCase

@end

@implementation FXURLConnectionTests

- (void)testGetRequest
{
    FX_START_SYNC();
    
    NSURL *url = [NSURL URLWithString:@"http://www.flox.cc/api"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    FXURLConnection *connection = [[FXURLConnection alloc] initWithRequest:request];
    
    [connection startWithBlock:^(NSData *body, NSInteger httpStatus, NSError *error)
    {
        XCTAssertNil(error, @"request returned error: %@", error);
        
        NSError *jsonError;
        id object = [NSJSONSerialization JSONObjectWithData:body options:0 error:&jsonError];

        XCTAssertNil(jsonError, @"status request returned invalid json: %@", jsonError);
        XCTAssert([object isKindOfClass:[NSDictionary class]], @"request returned wrong data type");
        
        NSDictionary *result = (NSDictionary *)object;
        
        XCTAssertEqualObjects(result[@"status"], @"ok", @"request returned wrong status");
        
        FX_END_SYNC();
    }];
    
    FX_WAIT_FOR_SYNC();
}

@end
