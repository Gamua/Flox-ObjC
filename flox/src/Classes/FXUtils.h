//
//  FXUtils.h
//  Flox
//
//  Created by Daniel Sperl on 28.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

typedef void (^FXNotificationBlock)(NSNotification *notification);

/// The FXUtils class contains utility methods for different purposes.
@interface FXUtils : NSObject

/// Generates a random UID (unique identifier) that can be used for Entity IDs.
+ (NSString *)randomUIDWithLength:(NSInteger)length;

/// Generates a random UID (unique identifier) that can be used for Entity IDs.
+ (NSString *)randomUID;

/// Constructs a path to a certain file in the given standard directory.
+ (NSString *)pathForResource:(NSString *)fileName inDirectory:(NSSearchPathDirectory)directory;

/// Parses dates that conform to the `xs:DateTime` format.
+ (NSDate *)dateFromString:(NSString *)string;

/// Returns a date string formatted according to the `xs:DateTime` format.
+ (NSString *)stringFromDate:(NSDate *)date;

/// Adds an observer to the default notification center. When the notification is dispatched,
/// the block is executed and the observer is removed.
+ (void)observeNextNotification:(NSString *)name fromObject:(id)object
                     usingBlock:(FXNotificationBlock)block;

/// Returns a dictionary that contains the names of all members of the class as keys. The
/// respective values indicate the type of the member, given as type encodings
/// (`NSString`s containing the same encodings that are used by the `@encode` compiler directive).
+ (NSDictionary *)describeClass:(Class)class;

@end
