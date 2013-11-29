//
//  FXPersistentStore.h
//  Flox
//
//  Created by Daniel Sperl on 29.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

typedef void (^FXPersistentStoreLoadBlock)(id object);

/// A data store that persists its contents on the disk.
@interface FXPersistentStore : NSObject

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a persistent store with a certain name. If the name was already used in a
/// previous session, the existing store is restored.
- (instancetype)initWithName:(NSString *)name;

/// -------------
/// @name Methods
/// -------------

/// Adds an object with a certain key.
- (void)setObject:(id)object forKey:(NSString *)key;

/// Adds an object with a certain key.
/// You can optionally add meta data that is stored in the index file.
- (void)setObject:(id)object forKey:(NSString *)key withMetaData:(NSDictionary *)metaData;

/// Asynchronously loads the object that was stored with the given key.
/// If the object is not found, the callback will be executed with a `nil` value.
- (void)loadObjectForKey:(NSString *)key onComplete:(FXPersistentStoreLoadBlock)block;

/// Removes an object with a certain key.
- (void)removeObjectForKey:(NSString *)key;

/// Removes all elements from the store.
- (void)removeAllObjects;

/// Indicates if an object was stored with a certain key.
- (BOOL)containsKey:(NSString *)key;

/// Retrieve specific meta data from a certain object.
- (NSDictionary *)metaDataForKey:(NSString *)key;

/// Saves the current state of the store to the disk.
/// This method blocks until saving is completed.
- (void)save;

/// ----------------
/// @name Properties
/// ----------------

@property (nonatomic, readonly) NSString *name;

@end
