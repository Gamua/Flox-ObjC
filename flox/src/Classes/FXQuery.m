//
//  FXQuery.m
//  Flox
//
//  Created by Daniel Sperl on 01.12.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import "FXQuery.h"
#import "Flox_Internal.h"
#import "FXUtils.h"
#import "FXCommon.h"
#import "FXRestService.h"
#import "FXEntity_Internal.h"
#import "NSJSONSerialization+String.h"

#define TYPE_IS(x)  [type isEqualToString:x]

typedef void (^FXLoadEntityBlock)(int position, NSString *id, NSString *eTag);
typedef void (^FXAddEntityBlock)(int position, FXEntity *entity);

// --- class implementation ------------------------------------------------------------------------

@implementation FXQuery

- (instancetype)initWithClass:(Class)entityClass;
{
    if ((self = [super init]))
    {
        if (![entityClass isSubclassOfClass:[FXEntity class]])
             [NSException raise:FXExceptionInvalidOperation
                         format:@"The entity class must extend 'FXEntity'"];
        
        _entityClass = entityClass;
        _constraints = @"";
        _offset = 0;
        _limit = 50;
    }
    return self;
}

- (void)where:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [self where:format arguments:args];
    va_end(args);
}

- (void)where:(NSString *)format arguments:(va_list)args
{
    if (!format)
        [NSException raise:FXExceptionInvalidOperation format:@"format must not be nil"];
    
    NSMutableString *constraints  = [format mutableCopy];
    NSDictionary *typeDescription = [FXUtils describeClass:_entityClass];
    NSMutableArray *typeEncodings = [NSMutableArray array];
    
    NSError *error = NULL;
    NSRegularExpression *regex =
        [NSRegularExpression regularExpressionWithPattern:@"(\\w+)\\s*(\\W{1,2}|in)\\s*\\?"
                                options:NSRegularExpressionCaseInsensitive error:&error];
    
    [regex enumerateMatchesInString:format options:0 range:NSMakeRange(0, [format length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop)
    {
        NSRange keyRange = [match rangeAtIndex:1];
        NSRange opRange  = [match rangeAtIndex:2];
        NSString *key = [@"_" stringByAppendingString:[format substringWithRange:keyRange]];
        NSString *op  = [[format substringWithRange:opRange] lowercaseString];
        NSString *type = [typeDescription valueForKey:key];
        
        if ([op isEqualToString:@"in"])
            [typeEncodings addObject:@"@\"NSArray\""];
        else if (type)
            [typeEncodings addObject:type];
        else
            [NSException raise:FXExceptionInvalidOperation format:@"member not found: %@", key];
    }];
    
    for (NSString *type in typeEncodings)
    {
        id value;
        NSRange markerRange = [constraints rangeOfString:@"?"];
        NSString *replacement;
        
        // int, char, unsigned char, short, unsigned short, bool
        if (TYPE_IS(@"i") || TYPE_IS(@"c") || TYPE_IS(@"C") || TYPE_IS(@"s") || TYPE_IS(@"S") ||
            TYPE_IS(@"B"))
        {
            int arg = va_arg(args, int);
            value = @(arg);
        }
        else if (TYPE_IS(@"l")) { long arg = va_arg(args, long); value = @(arg); }
        else if (TYPE_IS(@"L")) { unsigned long arg = va_arg(args, unsigned long); value = @(arg); }
        else if (TYPE_IS(@"q")) { long long arg = va_arg(args, long long); value = @(arg); }
        else if (TYPE_IS(@"Q")) { unsigned long long arg = va_arg(args, unsigned long long); value = @(arg); }
        else if (TYPE_IS(@"f") || TYPE_IS(@"d")) { double arg = va_arg(args, double); value = @(arg); }
        else if ([type rangeOfString:@"@\"NS"].location == 0) { id arg = va_arg(args, id); value = arg; }
        else [NSException raise:FXExceptionInvalidOperation format:@"unknown type '%@'", type];
        
        if (!value || [value isKindOfClass:[NSNull class]])
            replacement = @"null";
        else if ([value isKindOfClass:[NSNumber class]])
            replacement = [value description];
        else if ([value isKindOfClass:[NSString class]])
            replacement = [NSString stringWithFormat:@"\"%@\"", value];
        else if ([value isKindOfClass:[NSArray class]])
            replacement = [NSJSONSerialization stringWithJSONObject:value];
        else if ([value isKindOfClass:[NSDate class]])
            replacement = [NSString stringWithFormat:@"\"%@\"", [FXUtils stringFromDate:value]];
        else [NSException raise:FXExceptionInvalidOperation format:@"invalid type '%@'", type];
        
        [constraints replaceCharactersInRange:markerRange withString:replacement];
    }
    
    _constraints = constraints;
}

- (void)find:(FXQueryCompleteBlock)onComplete
{
    __block NSMutableArray *entities = [NSMutableArray array];
    __block BOOL abort = NO;
    __block int numLoaded = 0;
    __block int numResults = 0;
    
    FXAddEntityBlock addEntity = ^(int position, FXEntity *entity)
    {
        entities[position] = entity;
        ++numLoaded;
        
        if (numLoaded == numResults && !abort)
            onComplete(entities, FXHTTPStatusOk, nil);
    };
    
    FXLoadEntityBlock loadEntity = ^(int position, NSString *entityID, NSString *eTag)
    {
        [_entityClass loadFromCacheByID:entityID eTag:eTag onComplete:^(id entity)
         {
             if (entity) addEntity(position, entity);
             else [_entityClass loadByID:entityID
                              onComplete:^(id entity, NSInteger httpStatus, NSError *error)
                   {
                       if (error)
                       {
                           if (!abort)
                           {
                               abort = YES;
                               onComplete(nil, httpStatus, error);
                           }
                       }
                       else addEntity(position, entity);
                   }];
         }];
    };
    
    NSString *path = [@"entities/" stringByAppendingString:[_entityClass type]];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @(_offset), @"offset",
                          @(_limit), @"limit",
                          _constraints, @"where",
                          _orderBy, @"orderBy", nil];
    
    [[Flox service] requestWithMethod:FXHTTPMethodPost path:path data:data
                           onComplete:^(id body, NSInteger httpStatus, NSError *error)
    {
        if (error) onComplete(nil, httpStatus, error);
        else
        {
            NSArray *results = (NSArray *)body;
            numResults = (int)results.count;
            
            if (numResults)
            {
                for (int i=0; i<numResults; ++i)
                {
                    NSDictionary *result = results[i];
                    entities[i] = [NSNull null];
                    loadEntity(i, result[@"id"], result[@"eTag"]);
                }
            }
            else onComplete([NSArray array], httpStatus, error);
        }
    }];
}

@end
