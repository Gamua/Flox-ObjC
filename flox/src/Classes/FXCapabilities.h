//
//  FXCapabilities.h
//  Flox
//
//  Created by Daniel Sperl on 31.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/// The FXCapabilities class provides information about the system that is executing the application.
@interface FXCapabilities : NSObject

/// The size of the screen in pixels.
+ (CGSize)screenResolution;

/// The two-letter language code of the user's preferred interface language.
+ (NSString *)language;

/// The operating system version, e.g. "iPhone OS 7.0.3".
+ (NSString *)osVersion;

/// The device version identifier, e.g. "iPhone4,1".
+ (NSString *)deviceVersion;

@end
