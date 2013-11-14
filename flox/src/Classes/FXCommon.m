//
//  FXCommon.m
//  Flox
//
//  Created by Daniel Sperl on 16.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXCommon.h"

NSString *const FXExceptionAbstractClass        = @"AbstractClass";
NSString *const FXExceptionIndexOutOfBounds     = @"IndexOutOfBounds";
NSString *const FXExceptionInvalidOperation     = @"InvalidOperation";
NSString *const FXExceptionFileNotFound         = @"FileNotFound";
NSString *const FXExceptionFileInvalid          = @"FileInvalid";
NSString *const FXExceptionDataInvalid          = @"DataInvalid";
NSString *const FXExceptionOperationFailed      = @"OperationFailed";

NSString *const FXAccessNone      = @"";
NSString *const FXAccessRead      = @"r";
NSString *const FXAccessReadWrite = @"rw";

NSString *const FXHTTPMethodGet     = @"GET";
NSString *const FXHTTPMethodPut     = @"PUT";
NSString *const FXHTTPMethodPost    = @"POST";
NSString *const FXHTTPMethodDelete  = @"DELETE";

NSString *const FXAuthTypeGuest  = @"guest";
NSString *const FXAuthTypeKey    = @"key";
NSString *const FXAuthTypeEmail  = @"email";

NSString *const FXQueueProcessedNotification = @"FXQueueProcessed";

BOOL FXHTTPStatusIsSuccess(NSInteger status)
{
    return status > 0 && status < 400;
}

BOOL FXHTTPStatusIsTransientError(NSInteger status)
{
    return status == FXHTTPStatusUnknown || status == FXHTTPStatusServiceUnavailable;
}

NSString *FXTimeScopeToString(FXTimeScope timeScope)
{
    switch (timeScope)
    {
        case FXTimeScopeToday:    return @"today";    break;
        case FXTimeScopeThisWeek: return @"thisWeek"; break;
        default:                  return @"allTime";  break;
    }
}
