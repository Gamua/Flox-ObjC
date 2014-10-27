//
//  NSObject+Flox.h
//  Flox
//
//  Created by Daniel Sperl on 05.12.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

/// A category that adds misc helpers to the NSObject class (utilized by Flox in different places).
@interface NSObject (Flox)

/// Indicates if the receiver points to a value or if it is `nil` / `[NSNull null]`.
- (BOOL)hasValue;

@end
