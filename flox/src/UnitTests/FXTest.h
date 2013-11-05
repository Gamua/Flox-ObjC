//
//  FXTestUtils.h
//  Flox
//
//  Created by Daniel Sperl on 18.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FXCommon.h"
#import "Flox+Internal.h"

#define USE_PRODUCTION_SERVER      1

FX_EXTERN NSString *const FXTestBaseURL;
FX_EXTERN NSString *const FXTestGameID;
FX_EXTERN NSString *const FXTestGameKey;

/// Set the flag for a block completion handler
#define FX_START_SYNC()     __block BOOL waitingForBlock = YES

/// Set the flag to stop the loop
#define FX_END_SYNC()       waitingForBlock = NO

/// Wait and loop until flag is set
#define FX_WAIT_FOR_SYNC()  FX_WAIT_WHILE(waitingForBlock)

/// Wait for condition to be NO/false in blocks and asynchronous calls
#define FX_WAIT_WHILE(condition)                                                            \
    do                                                                                      \
    {                                                                                       \
        while(condition)                                                                    \
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode                        \
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
    } while(0)

/// Check for error; if there is one, fail with a certain message, end sync, and call 'return'.
#define FX_ABORT_SYNC_ON_ERROR(error, msg)                                                  \
    if (error)                                                                              \
    {                                                                                       \
        XCTFail(@"%@ - error: %@", msg, error);                                             \
        waitingForBlock = NO;                                                               \
        return;                                                                             \
    }

@interface FXTest : NSObject

+ (void)startFlox;
+ (void)stopFlox;

@end