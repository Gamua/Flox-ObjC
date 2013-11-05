//
//  FXCapabilities.m
//  Flox
//
//  Created by Daniel Sperl on 31.10.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//

#import "FXCapabilities.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation FXCapabilities

+ (CGSize)screenResolution
{
    UIScreen *screen = [UIScreen mainScreen];
    CGSize size = screen.bounds.size;
    CGFloat scale = screen.scale;
    return CGSizeMake(size.width * scale, size.height * scale);
}

+ (NSString *)language
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *)osVersion
{
    UIDevice *device = [UIDevice currentDevice];
    return [NSString stringWithFormat:@"%@ %@", device.systemName, device.systemVersion];
}

+ (NSString *)deviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

@end
