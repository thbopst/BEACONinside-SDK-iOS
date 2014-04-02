//
//  BIBeaconSignal.h
//  BEACONinsideSDK
//
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import Foundation;
@import CoreLocation;

#import "BITypes.h"

/**
 *  Encapsulates the properties of a signal received by an iBeacon.
 */
@interface BIBeaconSignal : NSObject

- (instancetype)initWithTimestamp:(NSDate *)timestamp RSSI:(NSInteger)rssi proximity:(CLProximity)proximity accuracy:(CLLocationAccuracy)accuracy NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTimestamp:(NSDate *)timestamp coreLocationBeacon:(CLBeacon *)beacon;
- (instancetype)initWithTimestamp:(NSDate *)timestamp otherBeaconSignal:(BIBeaconSignal *)otherBeaconSignal;
+ (instancetype)notInRangeSignalWithTimestamp:(NSDate *)timestamp;

@property (nonatomic, strong, readonly) NSDate *timestamp;
@property (nonatomic, readonly) BOOL inRange;
@property (nonatomic, readonly) NSInteger RSSI;
@property (nonatomic, readonly) CLProximity proximity;
@property (nonatomic, readonly) CLLocationAccuracy accuracy;

@end
