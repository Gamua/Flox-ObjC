//
//  FXCommon.h
//  Flox
//
//  Created by Daniel Sperl on 16.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
    #define FX_EXTERN extern "C" __attribute__((visibility ("default")))
#else
    #define FX_EXTERN extern __attribute__((visibility ("default")))
#endif

FX_EXTERN NSString *const FXExceptionAbstractClass;
FX_EXTERN NSString *const FXExceptionIndexOutOfBounds;
FX_EXTERN NSString *const FXExceptionInvalidOperation;
FX_EXTERN NSString *const FXExceptionFileNotFound;
FX_EXTERN NSString *const FXExceptionFileInvalid;
FX_EXTERN NSString *const FXExceptionDataInvalid;
FX_EXTERN NSString *const FXExceptionOperationFailed;

FX_EXTERN NSString *const FXHTTPMethodGet;
FX_EXTERN NSString *const FXHTTPMethodPut;
FX_EXTERN NSString *const FXHTTPMethodPost;
FX_EXTERN NSString *const FXHTTPMethodDelete;

FX_EXTERN NSString *const FXAccessNone;
FX_EXTERN NSString *const FXAccessRead;
FX_EXTERN NSString *const FXAccessReadWrite;

FX_EXTERN NSString *const FXQueueProcessedNotification;

/// FXHTTPStatus describes the HTTP status codes that are used by the Flox server.
typedef NS_ENUM(NSInteger, FXHTTPStatus)
{
    FXHTTPStatusUnknown             = 0,
    FXHTTPStatusOk                  = 200,
    FXHTTPStatusAccepted            = 202,
    FXHTTPStatusNoContent           = 204,
    FXHTTPStatusNotModified         = 304,
    FXHTTPStatusBadRequest          = 400,
    FXHTTPStatusForbidden           = 403,
    FXHTTPStatusNotFound            = 404,
    FXHTTPStatusPreconditionFailed  = 412,
    FXHTTPStatusTooManyRequests     = 429,
    FXHTTPStatusInternalServerError = 500,
    FXHTTPStatusNotImplemented      = 501,
    FXHTTPStatusServiceUnavailable  = 503
};

/// Indicates if a status code depicts a success or a failure.
BOOL FXHTTPStatusIsSuccess(FXHTTPStatus status);

/// Indicates if an error might go away if the request is tried again
/// (i.e. the server was not reachable or there was a network error).
BOOL FXHTTPStatusIsTransientError(FXHTTPStatus status);

/// FXTimeScope describes leaderboard time ranges.
typedef NS_ENUM(NSInteger, FXTimeScope)
{
    FXTimeScopeToday,
    FXTimeScopeThisWeek,
    FXTimeScopeAllTime
};

/// Converts a TimeScope enum value into a human-readable string.
NSString *FXTimeScopeToString(FXTimeScope timeScope);
