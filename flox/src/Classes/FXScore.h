//
//  FXScore.h
//  Flox
//
//  Created by Daniel Sperl on 18.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

/// Provides information about the value and origin of one score entry.
@interface FXScore : NSObject

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a score with the given properties.
- (instancetype)initWithPlayerID:(NSString *)playerID name:(NSString *)playerName
                           value:(NSInteger)value date:(NSDate *)date country:(NSString *)country;

/// ----------------
/// @name Properties
/// ----------------

/// The ID of the player who posted the score.
/// Note that this could be a guest player unknown to the server.
@property (nonatomic, readonly) NSString *playerID;

/// The name of the player who posted the score.
@property (nonatomic, readonly) NSString *playerName;

/// The actual value (score).
@property (nonatomic, readonly) NSInteger value;

/// The date at which the score was posted.
@property (nonatomic, readonly) NSDate *date;

/// The country from which the score originated, in a two-letter country code.
@property (nonatomic, readonly) NSString *country;

@end
