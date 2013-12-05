//
//  FXEntity.h
//  Flox
//
//  Created by Daniel Sperl on 06.11.13.
//  Copyright (c) 2013 Gamua. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it
//  in accordance with the terms of the accompanying license agreement.
//

#import <Foundation/Foundation.h>
#import "FXCommon.h"

typedef void (^FXEntityRequestCompleteBlock)(id entity, NSInteger httpStatus, NSError *error);

@class FXQuery;

/** ------------------------------------------------------------------------------------------------
 
 The abstract base class of all objects that can be stored persistently on the Flox server.
 
 To create custom entities, extend this class. Subclasses have to follow a few rules:

 * The server type of the class is defined by its name. 
   If you want to use a different name, implement the class method `type` (see sample below).
 * All private members starting with a single underscore (like `_value`) will be serialized.
   (Since this naming scheme is the compiler default, you don't need to do anything special.)
 * Serialized members may have any of the following types:
   * Any numeric type (like int, uint, float, double, BOOL)
   * NSString
   * NSDictionary
   * NSArray
   * NSDate

 Here is an example class:

    @interface GameState : FXEntity
 
    @property (nonatomic, assign) NSInteger score;
    @property (nonatomic, copy)   NSString *status;
 
    @end
 
 This class is already a complete entity; its server type will be "GameState". To change that,
 implement the `type` class method, like this:
 
    @implementation GameState
 
    + (NSString *)type
    {
        return @"state";
    }
 
    @end
 
 To avoid serialization of a certain member, prefix its name with two underscores.
 
    @implementation GameState
 
    @synthesize score = __score;
 
    @end
 
------------------------------------------------------------------------------------------------- */

@interface FXEntity : NSObject <NSCoding>

/// --------------------
/// @name Initialization
/// --------------------

/// Initializes an entity with a random UID. (Abstract class! To be called from a subclass only.)
- (instancetype)init;

/// Initializes an entity with a certain UID. (Abstract class! To be called from a subclass only.)
- (instancetype)initWithID:(NSString *)entityID;

/// -------------
/// @name Methods
/// -------------

/// Saves the entity on the server; if the entity already exists, the server version will
/// be updated with the local changes. In case of an error, use the utility function
/// `FXHTTPStatusIsTransientError(httpStatus)` to find out if the error is just temporary
/// (e.g. the server was not reachable).
- (void)save:(FXEntityRequestCompleteBlock)onComplete;

/// Saves the entity the next time the player goes online. When the Flox server cannot be
/// reached at the moment, the request will be added to a queue and will be repeated later.
- (void)saveQueued;

/// Refreshes the entity with the version that is currently stored on the server.
/// In case of an error, use the utility function `FXHTTPStatusIsTransientError(httpStatus)`
/// to find out if the error is just temporary (e.g. the server was not reachable).
- (void)refresh:(FXEntityRequestCompleteBlock)onComplete;

/// Deletes the entity from the server.
/// In case of an error, use the utility function `FXHTTPStatusIsTransientError(httpStatus)`
/// to find out if the error is just temporary (e.g. the server was not reachable).
- (void)destroy:(FXEntityRequestCompleteBlock)onComplete;

/// Deletes the entity the next time the player goes online. When the Flox server cannot be
/// reached at the moment, the request will be added to a queue and will be repeated later.
- (void)destroyQueued;

/// Loads an entity with the given ID from the server. Call this method on the subclass
/// the entity is an instance of (*not* on FXEntity).
///
/// If there is no Entity with this type and ID stored on the server, the 'httpStatus' will be
/// `FXHTTPStatusNotFound`.
+ (void)loadByID:(NSString *)entityID onComplete:(FXEntityRequestCompleteBlock)onComplete;

/// Deletes an entity with the given ID from the server. Call this method on the subclass
/// the entity is an instance of (*not* on FXEntity).
///
/// In case of an error, use the utility function `FXHTTPStatusIsTransientError(httpStatus)`
/// to find out if the error is just temporary (e.g. the server was not reachable).
+ (void)destroyByID:(NSString *)entityID onComplete:(FXEntityRequestCompleteBlock)onComplete;

/// Deletes an entity the next time the player goes online. When the Flox server cannot be
/// reached at the moment, the request will be added to a queue and will be repeated later.
/// Call this method on the subclass the entity is an instance of (*not* on FXEntity).
+ (void)destroyQueuedByID:(NSString *)entityID;

/// The server type that instances of this class will have. Per default, that's the name of the
/// class. Implement this method in subclasses for a custom mapping.
+ (NSString *)type;

/// Creates a new query for this entity type.
+ (FXQuery *)query;

/// Creates a new query for this entity type, initialized with the given constraints string.
/// Read the documentation of the `FXQuery` class to find out how that string must look like.
+ (FXQuery *)queryWhere:(NSString *)constraints, ...;

/// ----------------
/// @name Properties
/// ----------------

/// This is the primary identifier of the entity. It must be unique within the objects of
/// the same entity type. Allowed are alphanumeric characters, '-' and '_'.
@property (nonatomic, copy) NSString *id;

/// The player ID of the owner of the entity. (Referencing an FXPlayer entitity.)
@property (nonatomic, copy) NSString *ownerID;

/// The access rights of all players except the owner. (The owner always has unlimited access.)
@property (nonatomic, copy) NSString *publicAccess;

/// The date when this entity was created.
@property (nonatomic, readonly) NSDate *createdAt;

/// The date when this entity was last updated on the server.
@property (nonatomic, readonly) NSDate *updatedAt;

/// The type of the entity, which is per default the name of class. Do not override this method;
/// to change the type, override the class method of the same name.
@property (nonatomic, readonly) NSString *type;

@end
