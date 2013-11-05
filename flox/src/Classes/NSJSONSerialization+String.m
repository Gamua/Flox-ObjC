//
//  NSJSONSerialization+String.m
//  Flox
//
//  Created by Daniel Sperl on 17.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "NSJSONSerialization+String.h"

@implementation NSJSONSerialization (String)

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)stringWithJSONObject:(id)obj
{
    return [self stringWithJSONObject:obj options:0 error:NULL];
}

@end
