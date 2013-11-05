//
//  FXScore.m
//  Flox
//
//  Created by Daniel Sperl on 18.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXScore.h"
#import "FXUtils.h"

@implementation FXScore
{
    NSString *_playerID;
    NSString *_playerName;
    NSString *_country;
    NSInteger _value;
    NSDate *_date;
}

- (instancetype)initWithPlayerID:(NSString *)playerID name:(NSString *)playerName
                           value:(NSInteger)value date:(NSDate *)date country:(NSString *)country;
{
    if ((self = [super init]))
    {
        _playerID = playerID;
        _playerName = playerName;
        _country = country;
        _value = value;
        _date = date;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[FXScore playerName='%@' value='%d' country='%@' date='%@']",
            _playerName, (int)_value, _country, [FXUtils stringFromDate:_date]];
}

@end
