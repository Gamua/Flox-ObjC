//
//  FXEntity.m
//  Flox
//
//  Created by Daniel Sperl on 06.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import <objc/runtime.h>

#import "Flox_Internal.h"
#import "FXEntity_Internal.h"
#import "FXCommon.h"
#import "FXUtils.h"

static NSString *const NSDateType = @"@\"NSDate\"";

@implementation FXEntity
{
    NSString *_id;
    NSString *_ownerId;
    NSString *_publicAccess;
    NSDate *_createdAt;
    NSDate *_updatedAt;
}

@synthesize ownerID = _ownerId; // server side naming scheme

- (instancetype)initWithID:(NSString *)entityID
{
    return [self initWithID:entityID dictionary:nil];
}

- (instancetype)init
{
    return [self initWithID:[FXUtils randomUID]];
}

#pragma region - request methods

- (void)save:(FXEntityRequestCompleteBlock)onComplete
{
    NSString *path = [FXEntity urlForType:self.type id:self.id];
    [Flox.service requestWithMethod:FXHTTPMethodPut path:path data:[self encodeToDictionary]
                         onComplete:^(id body, NSInteger httpStatus, NSError *error)
     {
         if (!error)
         {
             // createdAt and updatedAt are always set by server.
             _createdAt = [FXUtils dateFromString:body[@"createdAt"]];
             _updatedAt = [FXUtils dateFromString:body[@"updatedAt"]];
         }
         
         onComplete(self, httpStatus, error);
     }];
}

- (void)saveQueued
{
    FXRestService *service = Flox.service;
    NSString *path = [FXEntity urlForType:self.type id:self.id];
    
    [service requestQueuedWithMethod:FXHTTPMethodPut path:path data:[self encodeToDictionary]];
    
    // TODO: update 'createdAt' and 'updatedAt' from server data.
}

- (void)refresh:(FXEntityRequestCompleteBlock)onComplete
{
    NSString *path = [FXEntity urlForType:self.type id:self.id];
    [Flox.service requestWithMethod:FXHTTPMethodGet path:path data:nil
                         onComplete:^(id body, NSInteger httpStatus, NSError *error)
     {
         if (!error)
             [FXEntity refreshEntity:self fromDictionary:body];
         
         onComplete(self, httpStatus, error);
     }];
}

- (void)destroy:(FXEntityRequestCompleteBlock)onComplete
{
    [[self class] destroyByID:self.id
                   onComplete:^(id entity, NSInteger httpStatus, NSError *error)
    {
        onComplete(self, httpStatus, error);
    }];
}

- (void)destroyQueued
{
    [[self class] destroyQueuedByID:self.id];
}

+ (void)loadByID:(NSString *)entityID onComplete:(FXEntityRequestCompleteBlock)onComplete
{
    if (self == [FXEntity class])
        [NSException raise:FXExceptionInvalidOperation
                    format:@"This method must be called on a specific subclass of FXEntity."];
    
    NSString *path = [self urlForType:self.type id:entityID];
    
    [Flox.service requestWithMethod:FXHTTPMethodGet path:path data:nil
                         onComplete:^(id body, NSInteger httpStatus, NSError *error)
    {
        FXEntity *entity = nil;
        if (!error) entity = [[self alloc] initWithID:entityID dictionary:body];
        onComplete(entity, httpStatus, error);
    }];
}

+ (void)destroyByID:(NSString *)entityID onComplete:(FXEntityRequestCompleteBlock)onComplete
{
    if (self == [FXEntity class])
        [NSException raise:FXExceptionInvalidOperation
                    format:@"This method must be called on a specific subclass of FXEntity."];
    
    NSString *path = [self urlForType:self.type id:entityID];
    
    [Flox.service requestWithMethod:FXHTTPMethodDelete path:path data:nil
                         onComplete:^(id body, NSInteger httpStatus, NSError *error)
    {
        onComplete(nil, httpStatus, error);
    }];
}

+ (void)destroyQueuedByID:(NSString *)entityID
{
    if (self == [FXEntity class])
        [NSException raise:FXExceptionInvalidOperation
                    format:@"This method must be called on a specific subclass of FXEntity."];
    
    NSString *path = [self urlForType:self.type id:entityID];
    [Flox.service requestQueuedWithMethod:FXHTTPMethodDelete path:path data:nil];
}

#pragma region - helpers

+ (NSString *)urlForType:(NSString *)type id:(NSString *)id
{
    return [NSString stringWithFormat:@"entities/%@/%@", type, id];
}

+ (NSString *)type
{
    return NSStringFromClass(self);
}

+ (void)refreshEntity:(FXEntity *)entity fromDictionary:(NSDictionary *)dictionary
{
    NSDictionary *ivars = [self describeClass:[entity class]];
    
    for(id key in dictionary)
    {
        NSString *name = [@"_" stringByAppendingString:key];
        NSString *type = ivars[name];
        id value = dictionary[key];
        
        // dates are encoded in our xs:DateTime format
        if ([type isEqualToString:NSDateType])
            value = [FXUtils dateFromString:value];
        
        [entity setValue:value forKey:name];
    }
}

+ (NSDictionary *)describeClass:(Class)class
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSStringEncoding utf8 = NSUTF8StringEncoding;
    unsigned int count;
    
    do
    {
        Ivar* ivars = class_copyIvarList(class, &count);
        
        for (int i = 0; i < count; ++i)
        {
            Ivar ivar = ivars[i];
            NSString *name = [NSString stringWithCString:ivar_getName(ivar) encoding:utf8];
            NSString *type = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:utf8];
            dictionary[name] = type;
        }
        
        free(ivars);
        class = [class superclass];
    }
    while (class != [NSObject class]);
    
    return dictionary;
}

#pragma region - properties

- (void)setId:(NSString *)entityID
{
    static NSCharacterSet *set = nil;
    
    if (!set)
    {
        set = [[NSCharacterSet characterSetWithCharactersInString:
                @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_"] invertedSet];
    }
    
    if ([entityID rangeOfCharacterFromSet:set].location != NSNotFound)
        [NSException raise:FXExceptionInvalidOperation
                    format:@"Invalid id: use only alphanumeric characters, '-' and '_'."];
    else
        _id = [entityID copy];
}

- (NSString *)type
{
    return [[self class] type];
}

- (NSString *)description
{
    NSString *createdAt = [FXUtils stringFromDate:_createdAt];
    NSString *updatedAt = [FXUtils stringFromDate:_updatedAt];
    
    return [NSString stringWithFormat:
            @"Entity type='%@' id='%@' createdAt='%@' updatedAt='%@' ownerId='%@'",
            self.type, _id, createdAt, updatedAt, _ownerId];
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    return [self initWithDictionary:[decoder decodeObject]];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self encodeToDictionary]];
}

@end

// --- Internal class implementation ---------------------------------------------------------------

@implementation FXEntity (Internal)

- (instancetype)initWithID:(NSString *)entityID dictionary:(NSDictionary *)dictionary
{
    #ifdef DEBUG
    if ([self isMemberOfClass:[FXEntity class]])
    {
        [NSException raise:FXExceptionAbstractClass
                    format:@"Attempting to initialize abstract class FXEntity."];
        return nil;
    }
    #endif
    
    if ((self = [super init]))
    {
        _id = [entityID copy];
        _ownerId = nil; // TODO: Player.current.id
        _createdAt = [NSDate date];
        _updatedAt = [NSDate date];
        _publicAccess = FXAccessNone;

        if (dictionary)
        {
            NSDictionary *ivars = [FXEntity describeClass:[self class]];
            
            for(id key in dictionary)
            {
                NSString *name = [@"_" stringByAppendingString:key];
                NSString *type = ivars[name];
                id value = dictionary[key];
                
                // dates are encoded in our xs:DateTime format
                if ([type isEqualToString:NSDateType])
                    value = [FXUtils dateFromString:value];
                
                [self setValue:value forKey:name];
            }
        }
    }
    
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    return [self initWithID:nil dictionary:dictionary];
}

- (NSDictionary *)encodeToDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSDictionary *ivars = [FXEntity describeClass:[self class]];

    for (NSString *name in ivars)
    {
        if (name.length > 1 && [name characterAtIndex:0] == '_' && [name characterAtIndex:1] != '_')
        {
            id value = [self valueForKey:name];
            if (value)
            {
                // dates are encoded in our xs:DateTime format
                if ([ivars[name] isEqualToString:NSDateType])
                    value = [FXUtils stringFromDate:value];
                
                dictionary[[name substringFromIndex:1]] = value;
            }
        }
    }
    
    return dictionary;
}

@end
