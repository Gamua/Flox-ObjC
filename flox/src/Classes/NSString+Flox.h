//
//  NSString+Flox.h
//  Flox
//
//  Created by Daniel Sperl on 28.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

/// A category that adds misc helpers to the NSString class (utilized by Flox in different places).
@interface NSString (Flox)

/// Create an URL-safe representation of the string with the specified encoding.
- (instancetype)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

/// Create an URL-safe representation of the string with UTF-8 encoding.
- (instancetype)urlEncode;

/// Converts the dictionary into URL-parameters and appends them to the string.
- (instancetype)stringByAppendingQueryParameters:(NSDictionary *)parameters;

@end
