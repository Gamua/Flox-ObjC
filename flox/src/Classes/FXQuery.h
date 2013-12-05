//
//  FXQuery.h
//  Flox
//
//  Created by Daniel Sperl on 01.12.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>

typedef void (^FXQueryCompleteBlock)(NSArray *entities, NSInteger httpStatus, NSError *error);

/** ------------------------------------------------------------------------------------------------
 
 The FXQuery class allows you to retrieve entities from the server by narrowing down
 the results with certain constraints. The system works similar to SQL "select" statements.
 
 Before you can make a query, you have to create indices that match the query. You can
 do that in the Flox web interface. An index has to contain all the properties that are
 referenced in the constraints.
 
 Here is an example of how you can execute a query with Flox. This query searches for entities
 of the type "MyPlayer", for which an index with both "level" and "score" properties was prepared.
 
    FXQuery *query = [MyPlayer queryWhere:@"level == ? AND score > ?", @"tutorial", 500];
    [query find:^(NSArray *players, NSInteger httpStatus, NSError *error)
     {
        // the 'players' array contains all players in the 'tutorial' level
        // with a score higher than 500.
     }];
 
 ------------------------------------------------------------------------------------------------ */

@interface FXQuery : NSObject

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes a query over a specific entity type. _Designated Initializer_.
- (instancetype)initWithClass:(Class)entityClass;

/// -------------
/// @name Methods
/// -------------

/** 
 
 You can narrow down the results of the query with an SQL like where-clause. The
 constraints string supports the following comparison operators:
 
    ==, >, <, >=;, >=, !=
 
 You can combine constraints using "AND" and "OR"; construct logical groups with
 round brackets.
 
 To simplify creation of the constraints string, you can use questions marks ("?")
 as placeholders. They will be replaced one by one with the additional parameters you
 pass to the method, while making sure their format is correct (e.g. it surrounds
 Strings with quotations marks). Here is an example:

    [query where:@"name == ? AND score > ?", @"thomas", 500];
    // -> name == "thomas" AND score > 500
 
 Use the 'IN'-operator to check for inclusion within a list of possible values:

    [query where:@"name IN ?", @[@"alfa", @"bravo", @"charlie"]];
    // -> name IN ["alfa", "bravo", "charlie"]
 
 Note that subsequent calls to this method will replace preceding constraints.
 
*/
- (void)where:(NSString *)format, ...;

/// Executes a query with a custom argument list.
- (void)where:(NSString *)format arguments:(va_list)argList;

/// Executes the query asynchronously and passes the list of results to the "onComplete" block.
/// Don't forget to create appropriate indices for your queries!
- (void)find:(FXQueryCompleteBlock)onComplete;

/// ----------------
/// @name Properties
/// ----------------

/// The type of entity the query will operate on.
@property (nonatomic, readonly) Class entityClass;

/// The current contraints that will be used as WHERE-clause by the 'find' method.
@property (nonatomic, readonly) NSString *constraints;

/// Indicates the offset of the results returned by the query, i.e. how many results
/// should be skipped from the beginning of the result list. (Default: 0)
@property (nonatomic, assign) NSInteger offset;

/// Indicates the maximum number of returned entities. (Default: 50)
@property (nonatomic, assign) NSInteger limit;

/// Order the results by a certain property of your Entities. Set it to 'nil' if you
/// don't care (which is also the default). Sample values: 'price ASC', 'name DESC'.
@property (nonatomic, copy) NSString *orderBy;

@end
