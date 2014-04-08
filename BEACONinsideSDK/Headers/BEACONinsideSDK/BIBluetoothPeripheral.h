//
//  BIBluetoothPeripheral.h
//  BEACONinsideSDK
//
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;

#import "BITypes.h"

/**
 *  A BIBluetoothPeripheral represents a generic Bluetooth Low Energy device (not necessarily an iBeacon). It is
 *  mostly a wrapper around the CBPeripheral class of Apple's Core Bluetooth framework. BIBeaconManager uses
 *  BIBluetoothPeripheral instances to interact with beacons on the Core Bluetooth level.
 */
@interface BIBluetoothPeripheral : NSObject

- (instancetype)initWithCBPeripheral:(CBPeripheral *)coreBluetoothPeripheral NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSUUID *identifier;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSNumber *RSSI;
@property (nonatomic, strong, readonly) NSDictionary *advertisementData;
@property (nonatomic, strong, readonly) NSArray *services;
@property (nonatomic, strong, readonly) CBPeripheral *peripheral;

@end
