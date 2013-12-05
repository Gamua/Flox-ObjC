//
//  FXEntity_Internal.h
//  Flox
//
//  Created by Daniel Sperl on 10.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import "FXEntity.h"

typedef void (^FXEntityLoadedFromCacheBlock)(id entity);

@interface FXEntity (Internal)

- (instancetype)initWithID:(NSString *)entityID dictionary:(NSDictionary *)dictionary;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)encodeToDictionary;

+ (void)loadFromCacheByID:(NSString *)entityID eTag:(NSString *)eTag
               onComplete:(FXEntityLoadedFromCacheBlock)onComplete;

@end
