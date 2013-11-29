//
//  FXPersistentQueue.m
//  Flox
//
//  Created by Daniel Sperl on 25.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXPersistentQueue.h"
#import "FXUtils.h"

static NSString *const FXQueueDirectory = @"flox/queue";
static dispatch_queue_t ioQueue = NULL;

@implementation FXPersistentQueue
{
    NSString *_name;
    NSMutableArray *_index;
}

- (instancetype)initWithName:(NSString *)name
{
    if ((self = [super init]))
    {
        _name  = [name copy];
        _index = [self loadIndex];
        
        if (!ioQueue)
             ioQueue = dispatch_queue_create("com.gamua.flox.FXPersistentQueue", NULL);
        
        dispatch_async(ioQueue, ^
        {
            // create storage directory
            NSString *path = [FXUtils pathForResource:FXQueueDirectory inDirectory:NSLibraryDirectory];
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                                       attributes:nil error:nil];
        });
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithName:@"default"];
}

- (void)enqueueObject:(id)object withMetaData:(NSDictionary *)metaData
{
    NSString *name = [FXUtils randomUID];
    NSDictionary *indexData = [[NSDictionary alloc] initWithObjectsAndKeys:
                               name, @"name", metaData, @"meta", nil];
    [_index insertObject:indexData atIndex:0];
    
    dispatch_async(ioQueue, ^
    {
        NSString *path = [self pathForResource:name];
        [NSKeyedArchiver archiveRootObject:object toFile:path];
    });
}

- (void)enqueueObject:(id)object
{
    [self enqueueObject:object withMetaData:nil];
}

- (void)loadHead:(FXPersistentQueueLoadHeadBlock)block
{
    NSString *name = [_index lastObject][@"name"];
    
    dispatch_queue_t origQueue = dispatch_get_current_queue();
    dispatch_async(ioQueue, ^
    {
        NSString *path = [self pathForResource:name];
        id head = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // file may be corrupted -- delete it
        if (!head) [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        
        dispatch_async(origQueue, ^{ block(head); });
    });
}

- (void)removeHead
{
    if (_index.count)
    {
        NSString *name = [_index lastObject][@"name"];
        [_index removeLastObject];
        
        dispatch_async(ioQueue, ^
        {
            NSString *path = [self pathForResource:name];
            [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
        });
    }
}

- (void)removeAllObjects
{
    while (self.count) [self removeHead];
}

- (void)save
{
    [self saveIndex];
    dispatch_sync(ioQueue, ^{});
}

- (NSInteger)count
{
    return [_index count];
}

// utility methods

- (NSMutableArray *)loadIndex
{
    NSMutableArray *index = [NSMutableArray arrayWithContentsOfFile:[self indexPath]];
    
    if (!index)
        index = [NSMutableArray array];
    
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
    NSString *path = [FXQueueDirectory stringByAppendingPathComponent:filename];
    return [FXUtils pathForResource:path inDirectory:NSLibraryDirectory];
}

@end
