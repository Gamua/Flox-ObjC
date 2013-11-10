//
//  CustomEntity.h
//  Flox
//
//  Created by Daniel Sperl on 06.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//

#import "FXEntity.h"

@interface CustomEntity : FXEntity

- (instancetype)initWithName:(NSString *)name age:(NSInteger)age;

@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, copy)   NSDate *birthday;
@property (nonatomic, strong) NSArray *list;

@end
