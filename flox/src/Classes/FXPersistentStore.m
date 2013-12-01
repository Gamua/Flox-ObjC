//
//  FXPersistentStore.m
//  Flox
//
//  Created by Daniel Sperl on 29.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import "FXPersistentStore.h"
#import "FXUtils.h"

static NSString *const FXStoreDirectory = @"flox/store";
static dispatch_queue_t ioQueue = NULL;

@implementation FXPersistentStore
{
    NSString *_name;
    NSMutableDictionary *_index;
}

- (instancetype)initWithName:(NSString *)name
{
    if ((self = [super init]))
    {
        _name  = [name copy];
        _index = [self loadIndex];
        
        if (!ioQueue)
            ioQueue = dispatch_queue_create("com.gamua.flox.FXPersistentStore", NULL);
        
        dispatch_async(ioQueue, ^
        {
            // create storage directory
            NSString *path = [FXUtils pathForResource:FXStoreDirectory inDirectory:NSCachesDirectory];
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                       attributes:nil error:nil];
        });
    }
    return self;
}

- (void)setObject:(id)object forKey:(NSString *)key
{
    [self setObject:object forKey:key withMetaData:nil];
}

- (void)setObject:(id)object forKey:(NSString *)key withMetaData:(NSDictionary *)metaData
{
    NSString *name = [FXUtils randomUID];
    NSString *oldName = _index[key][@"name"];
    NSDictionary *indexData = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                               name, @"name", metaData, @"meta", nil];
    _index[key] = indexData;
    
    // If the object already exists we delete it and save 'value' under a new name.
    // This avoids problems if only one of the two files (index and object) can be saved.
    
    if (oldName)
        dispatch_async(ioQueue, ^
        {
            NSString *path = [self pathForResource:oldName];
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        });

    dispatch_async(ioQueue, ^
    {
        NSString *path = [self pathForResource:name];
        [NSKeyedArchiver archiveRootObject:object toFile:path];
    });
}

- (void)loadObjectForKey:(NSString *)key onComplete:(FXPersistentStoreLoadBlock)block
{
    NSString *name = _index[key][@"name"];
    
    if (name)
    {
        dispatch_queue_t origQueue = dispatch_get_current_queue();
        dispatch_async(ioQueue, ^
        {
            NSString *path = [self pathForResource:name];
            id object = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            
            // file may be corrupted -- delete it
            if (!object) [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
            
            dispatch_async(origQueue, ^{ block(object); });
       });
    }
    else block(nil);
}

- (void)removeObjectForKey:(NSString *)key
{
    NSDictionary *indexData = _index[key];
    
    if (indexData)
    {
        [_index removeObjectForKey:key];
        
        dispatch_async(ioQueue, ^
        {
            NSString *path = [self pathForResource:indexData[@"name"]];
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        });
    }
}

- (void)removeAllObjects
{
    for (NSString *key in [_index allKeys])
        [self removeObjectForKey:key];
}

- (BOOL)containsKey:(NSString *)key
{
    return _index[key] != nil;
}

- (NSDictionary *)metaDataForKey:(NSString *)key
{
    return _index[key][@"meta"];
}

- (void)save
{
    [self saveIndex];
    dispatch_sync(ioQueue, ^{});
}

// utility methods

- (NSMutableDictionary *)loadIndex
{
    NSMutableDictionary *index = [NSMutableDictionary dictionaryWithContentsOfFile:[self indexPath]];
    
    if (!index)
        index = [NSMutableDictionary dictionary];
    
    return index;
}

- (void)saveIndex
{
    [_index writeToFile:[self indexPath] atomically:YES];
}

- (NSString *)indexPath
{
    return [self pathForResource:_name];
}

- (NSString *)pathForResource:(NSString *)filename
{
    NSString *path = [FXStoreDirectory stringByAppendingPathComponent:filename];
    return [FXUtils pathForResource:path inDirectory:NSCachesDirectory];
}

@end
