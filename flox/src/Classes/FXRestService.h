//
//  FXRestService.h
//  Flox
//
//  Created by Daniel Sperl on 08.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>
#import "FXURLConnection.h"

typedef void (^FXRequestCompleteBlock)(id body, NSInteger httpStatus, NSError *error);
typedef void (^FXLoadedFromCacheBlock)(id body);

/// A class that makes it easy to communicate with the Flox server via a REST protocol.
@interface FXRestService : NSObject <NSURLConnectionDataDelegate>

/// --------------------
/// @name Initialization
/// --------------------

/// Initialize an instance with the base URL of the Flox service. The instance can be used
/// to make requests concerning a certain game.
- (instancetype)initWithURL:(NSURL *)url gameID:(NSString *)gameID gameKey:(NSString *)gameKey;

/// -------------
/// @name Methods
/// -------------

/// Makes an asynchronous HTTP request at the server. Before doing that, it will always
/// process the request queue. If that fails with a non-transient error, this request
/// will fail as well.
///
/// @param method The HTTP method used for the request (Provided by the `FXHTTPMethod-` constants).
/// @param path   The path of the resource relative to the root (!) of the game.
/// @param data   The data that will be sent as JSON-encoded body or as URL parameters
///               (depending on the http method).
/// @param onComplete The callback block that will be executed when the request has finished.
- (void)requestWithMethod:(NSString *)method path:(NSString *)path data:(NSDictionary *)data
               onComplete:(FXRequestCompleteBlock)completeBlock;

/// Adds an asynchronous HTTP request to a queue and immediately starts to process the queue.
- (void)requestQueuedWithMethod:(NSString *)method path:(NSString *)path data:(NSDictionary *)data;

/// Processes the request queue, executing requests in the order they were recorded.
/// If the server cannot be reached, processing stops and is retried later; if a request
/// produces an error, it is discarded.
/// @return true if the queue is currently being processed. */
- (BOOL)processQueue;

/// Clears the persistent queue.
- (void)clearQueue;

/// Clears all data from the cache.
- (void)clearCache;

/// Saves request queue and cache index to the disk.
- (void)save;

/// Loads an object from the cache. If you pass a non-nil `eTag`, the cached object must match
/// the eTag to be returned.
- (void)loadFromCache:(NSString *)path data:(NSDictionary *)data eTag:(NSString *)eTag
           onComplete:(FXLoadedFromCacheBlock)block;

/// ----------------
/// @name Properties
/// ----------------

/// The URL pointing to the Flox REST API.
@property (nonatomic, readonly) NSURL *url;

/// The unique ID of the game.
@property (nonatomic, readonly) NSString *gameID;

/// The key that identifies the game.
@property (nonatomic, readonly) NSString *gameKey;

/// If enabled, all requests will fail. Useful mainly for unit testing.
@property (nonatomic, assign) BOOL alwaysFail;

@end
