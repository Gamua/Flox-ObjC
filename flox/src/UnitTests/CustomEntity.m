//
//  CustomEntity.m
//  Flox
//
//  Created by Daniel Sperl on 06.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import "CustomEntity.h"

@implementation CustomEntity

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age
{
    if ((self = [super init]))
    {
        _name = [name copy];
        _age = age;
        _data = [NSDictionary dictionary];
        _birthday = [NSDate date];
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithName:@"unknown" age:0];
}

@end
