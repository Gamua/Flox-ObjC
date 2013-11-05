//
//  NSJSONSerialization+String.h
//  Flox
//
//  Created by Daniel Sperl on 17.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

/// A category that simplifies working with JSON strings.
@interface NSJSONSerialization (String)

/// Returns a JSON String from a Foundation object.
+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

/// Returns a JSON String from a Foundation object.
+ (NSString *)stringWithJSONObject:(id)obj;

@end
