//
//  FXUtils.m
//  Flox
//
//  Created by Daniel Sperl on 28.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXUtils.h"

@implementation FXUtils

+ (NSString *)randomUIDWithLength:(NSInteger)length
{
    static const char* CHARS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    static const int NUM_CHARS = 62;
    
    NSMutableString* string = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++)
        [string appendFormat:@"%C", (unichar)(CHARS[arc4random_uniform(NUM_CHARS)])];
    
    return string;
}

+ (NSString *)randomUID
{
    return [self randomUIDWithLength:16];
}

+ (NSString *)pathForResource:(NSString *)fileName inDirectory:(NSSearchPathDirectory)directory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [basePath stringByAppendingPathComponent:fileName];
}

+ (NSDate *)dateFromString:(NSString *)string
{
    return [self.dateFormatter dateFromString:string];
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    return [self.dateFormatter stringFromDate:date];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    }
    
    return dateFormatter;
}

@end
