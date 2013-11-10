//
//  FXPersistentQueue.h
//  Flox
//
//  Created by Daniel Sperl on 25.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

typedef void (^FXPersistentQueueLoadHeadBlock)(NSDictionary *head);

/// A queue that uses plist files to persist its contents.
@interface FXPersistentQueue : NSObject

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a persistent queue with a certain name. If the name was already used in a
/// previous session, the existing queue is restored.
- (instancetype)initWithName:(NSString *)name;

/// -------------
/// @name Methods
/// -------------

/// Inserts an object at the beginning of the queue.
- (void)enqueueObject:(NSDictionary *)object;

/// Inserts an object at the beginning of the queue.
/// You can optionally add meta data that is stored in the index file.
- (void)enqueueObject:(NSDictionary *)object withMetaData:(NSDictionary *)metaData;

/// Asynchronously loads the object at the head of the queue.
/// If the queue is empty, the callback will be executed with a `nil` value.
- (void)loadHead:(FXPersistentQueueLoadHeadBlock)block;

/// Removes all elements from the queue.
- (void)removeAllObjects;

/// Removes the head of the queue, without loading it.
- (void)removeHead;

/// Saves the current state of the queue to the disk.
/// This method blocks until saving is completed.
- (void)save;

// TODO: add 'filter'

/// ----------------
/// @name Properties
/// ----------------

/// The number of elements in the queue.
@property (nonatomic, readonly) NSInteger count;

/// The unique name that identifies the queue.
@property (nonatomic, readonly) NSString *name;

@end
