//
//  BIBeacon.h
//  BEACONinsideSDK
//
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import Foundation;
@import CoreLocation;

#import "BITypes.h"

@class BIBeaconSignal;

/**
 *  The BIBeacon class represents an iBeacon whose range is actively being or has been monitored by a BIBeaconManager.
 *  It is the equivalent to the CLBeacon class used by Apple in the Core Location framework.
 *
 *  Unlike their CLBeacon counterparts, BIBeacon instances are unique. Beacons are identified by their proximityUUID,
 *  major and minor values. There exists only one BIBeacon instance for each combination of proximityUUID, major, and minor.
 *  Internally, BIBeacon keeps a list of known beacons (since app launch). When you call +beaconWithProximityUUID:major:minor:,
 *  the class returns the existing instance if it already knows the beacon or creates a new object if it doesn't.
 *
 *  You generally do not create instances of this class because new beacons are reported to you by the beacon manager.
 *  Retrieving a known beacon can be useful, however, e.g. for matching it with a list of beacons you have stored in a
 *  collection.
 *
 *  BIBeacon instances can be used as keys in an NSDictionary or as elements in an NSSet. Equality is tested based on
 *  proximityUUID, major and minor only, as is the return value of the -hash method.
 */
@interface BIBeacon : NSObject <NSCopying>

/**---------------------------------------------------------------------------------------
 * @name Retrieving a beacon
 * ---------------------------------------------------------------------------------------
 */

/**
 *  Retrieves the beacon identified by proximityUUID, major, and minor from the list of known beacons and returns it.
 *  Or creates a new instance if the beacon has not been seen before.
 *
 *  @param proximityUUID The proximityUUID of the beacon instance you want to retrieve
 *  @param major The major value of the beacon instance you want to retrieve
 *  @param minor The minor value of the beacon instance you want to retrieve
 *
 *  @return The unique BIBeacon instance representing this beacon.
 */
+ (instancetype)beaconWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor;

/**---------------------------------------------------------------------------------------
 * @name Identifying the beacon
 * ---------------------------------------------------------------------------------------
 */

/**
 *  The proximity ID of the beacon. Uniquely identifies the beacon in combination with its major and minor value.
 */
@property (nonatomic, strong, readonly) NSUUID *proximityUUID;

/**
 *  The most significant value in the beacon. Uniquely identifies the beacon in combination with its proximityUUID and 
 *  minor value.
 */
@property (nonatomic, strong, readonly) NSNumber *major;

/**
 *  The least significant value in the beacon. Uniquely identifies the beacon in combination with its proximityUUID and 
 *  major value.
 */
@property (nonatomic, strong, readonly) NSNumber *minor;

/**
 *  A string that combines proximityUUID, major and minor in one value.
 *  Can be used to uniquely identify this beacon, for example as a key in a dictionary.
 *  Two BIBeacon instances with the same beaconIdentifier are considered equal.
 */
@property (nonatomic, strong, readonly) NSString *beaconIdentifier;

@property (nonatomic, strong, readonly) NSDictionary *beaconIdentifierDictionaryRepresentation;

@property (nonatomic, strong, readonly) BIBeaconSignal *smoothedSignal;
@property (nonatomic, strong, readonly) BIBeaconSignal *rawSignal;
@property (nonatomic, strong, readonly) NSArray *smoothedSignals;
@property (nonatomic, strong, readonly) NSArray *rawSignals;

@property (nonatomic, readonly, getter=isInRange) BOOL inRange;
@property (nonatomic, readonly) NSInteger smoothedRSSI;
@property (nonatomic, readonly) CLProximity smoothedProximity;
@property (nonatomic, readonly) CLLocationAccuracy smoothedAccuracy;

@end
