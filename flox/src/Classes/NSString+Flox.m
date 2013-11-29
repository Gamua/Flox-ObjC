//
//  NSString+Flox.m
//  Flox
//
//  Created by Daniel Sperl on 28.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "NSString+Flox.h"

@implementation NSString (Flox)

- (instancetype)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (NSString *)CFBridgingRelease(
        CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self,
                                                NULL, CFSTR("!*'\"();:@&=+$,/?%#[]% "),
                                                CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (instancetype)urlEncode
{
    return [self urlEncodeUsingEncoding:NSUTF8StringEncoding];
}

- (instancetype)stringByAppendingQueryParameters:(NSDictionary *)parameters
{
    if (!parameters || [parameters count] == 0)
        return self;
    
    NSMutableArray *elements = [[NSMutableArray alloc] init];
    NSMutableString *uriString = [NSMutableString stringWithFormat:@"%@?", self];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         if ([obj isKindOfClass:[NSArray class]])
         {
             for (id object in obj)
                 [elements addObject:[NSString stringWithFormat:@"%@=%@",
                     [[key description] urlEncode], [[object description] urlEncode]]];
         }
         else
         {
             [elements addObject:[NSString stringWithFormat:@"%@=%@",
                 [[key description] urlEncode], [[obj description] urlEncode]]];
         }
     }];
    
    [uriString appendString:[elements componentsJoinedByString:@"&"]];
    return uriString;
}

@end
