//
//  NSObject+Flox.m
//  Flox
//
//  Created by Daniel Sperl on 05.12.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import "NSObject+Flox.h"

@implementation NSObject (Flox)

- (BOOL)hasValue
{
    return self != [NSNull null];
}

@end
