//
//  BITypes.h
//  BEACONinsideSDK
//
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;
@import CoreLocation;

@class BIBeacon;
@class BIBluetoothPeripheral;

extern NSString * const BIBeaconDefaultProximityUUID;

extern NSString * const BIBeaconGenericAccessServiceUUID;
extern NSString * const BIBeaconGenericAccessDeviceNameCharacteristicUUID;

extern NSString * const BIBeaconDeviceInformationServiceUUID;
extern NSString * const BIBeaconDeviceInformationModelNumberCharacteristicUUID;
extern NSString * const BIBeaconDeviceInformationSerialNumberCharacteristicUUID;
extern NSString * const BIBeaconDeviceInformationFirmwareRevisionCharacteristicUUID;
extern NSString * const BIBeaconDeviceInformationHardwareRevisionCharacteristicUUID;
extern NSString * const BIBeaconDeviceInformationSoftwareRevisionCharacteristicUUID;
extern NSString * const BIBeaconDeviceInformationManufacturerNameCharacteristicUUID;

extern NSString * const BIBeaconBatteryServiceUUID;
extern NSString * const BIBeaconBatteryLevelCharacteristicUUID;

extern NSString * const BIBeaconProximityServiceUUID;
extern NSString * const BIBeaconProximityUUIDCharacteristicUUID;
extern NSString * const BIBeaconProximityMajorCharacteristicUUID;
extern NSString * const BIBeaconProximityMinorCharacteristicUUID;

extern NSString * const BIBeaconTxPowerServiceUUID;
extern NSString * const BIBeaconTxPowerLevelCharacteristicUUID;

extern NSString * const BIBeaconTimerServiceUUID;
extern NSString * const BIBeaconTimerAdvertisingIntervalCharacteristicUUID;

extern NSString * const BIBeaconAccessControlServiceUUID;
extern NSString * const BIBeaconPasskeyCharacteristicUUID;

extern NSString * const BIBeaconResetServiceUUID;
extern NSString * const BIBeaconRebootDeviceCharacteristicUUID;
extern NSString * const BIBeaconResetToFactoryDefaultsCharacteristicUUID;

extern NSString * const BIBeaconTemperatureServiceCharacteristicUUID;
extern NSString * const BIBeaconTemperatureLevelCharacteristicUUID;

typedef void(^BIDidEnterRegionHandler)(CLBeaconRegion *region);
typedef void(^BIDidExitRegionHandler)(CLBeaconRegion *region);
typedef void(^BIDidDetermineRegionStateHandler)(CLBeaconRegion *region, CLRegionState state);
typedef void(^BIContinuousRangingUpdateHandler)(CLBeaconRegion *region, NSArray *smoothedBeacons, NSError *error);
typedef void(^BINearestBeaconUpdateHandler)(CLBeaconRegion *region, BIBeacon *nearestBeacon, NSError *error);
typedef void(^BIErrorHandler)(CLBeaconRegion *region, NSError *error);

typedef void(^BIBluetoothStateUpdateHandler)(CBCentralManagerState bluetoothState);
typedef void(^BIDidDiscoverDeviceHandler)(BIBluetoothPeripheral *device);
typedef void(^BIDidConnectDeviceHandler)(BIBluetoothPeripheral *device, NSError *error);
typedef void(^BIDidDisconnectDeviceHandler)(BIBluetoothPeripheral *device, NSError *error);
typedef void(^BIDidDiscoverServicesHandler)(BIBluetoothPeripheral *device, NSError *error);
typedef void(^BIDidDiscoverCharacteristicsHandler)(BIBluetoothPeripheral *device, CBService *service, NSError *error);
typedef void(^BIDidUpdateValueForCharacteristicHandler)(BIBluetoothPeripheral *device, CBCharacteristic *characteristic, id value, NSError *error);

// Define NS_DESIGNATED_INITIALIZER in a way that remains compatible with Apple when they eventually
// define it in a later SDK update.
// See https://gist.github.com/steipete/9482253
#ifndef NS_DESIGNATED_INITIALIZER
    #if __has_attribute(objc_designated_initializer)
        #define NS_DESIGNATED_INITIALIZER __attribute((objc_designated_initializer))
    #else
        #define NS_DESIGNATED_INITIALIZER
    #endif
#endif
