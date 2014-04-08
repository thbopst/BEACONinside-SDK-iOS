//
//  BIBeaconManager.h
//  BEACONinsideSDK
//
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import Foundation;
@import CoreLocation;

#import "BITypes.h"

/**
 *  The BIBeaconManager class defines the public interface for working with Bluetooth beacons using the BEACONinside SDK.
 *
 *  You create a BIBeaconManager instance in your code and use it to initiate the monitoring for beacon-related events.
 *  BIBeaconManager wraps the Bluetooth beacon-related functionality of Apple's CLLocationManager class and builds
 *  a higher level of abstraction on top of it. It makes it easier to work with Bluetooth beacons in your app than to
 *  work directly with CLLocationManager.
 *
 *  Specifically, the region monitoring and beacon ranging data reported by CLLocationManager can often seem quite erratic,
 *  frequently reporting short signal losses or sudden strong changes in a beacon's signal strength. BIBeaconManager
 *  attempt to smoothen the raw data reported by CLLocationManager in order to report a more stable situation. We have
 *  found this to work better in most common iBeacon usage scenarios.
 *
 *  In addition to the iBeacon region monitoring and ranging built on top of CLLocationManager, BIBeaconManager also wraps
 *  a large chunk of the lower-level Core Bluetooth APIs. This allows you to query beacons directly for other services and
 *  characteristics they offer. It also lets you connect to a beacon in order to read or write data such as the temperature
 *  directly. See the Core Bluetooth documentation for details on the design of the Bluetooth Low Energy standard.
 *
 *  Generally, BIBeaconManager's public interface is main thread based. It expects you to call its methods on the main 
 *  thread/queue and will deliver asynchronous callbacks also on the main thread. The internal work BIBeaconManager performs 
 *  may occur on a private background queue.
 *
 *  @warning Almost all events reported by BIBeaconManager are asynchronous. BIBeaconManager uses blocks to implement
 *  these asynchronous callbacks. This makes working with the class easier than a delegate-based interface, but beware of
 *  introducing unwanted reference cycles caused by the blocks' retaining objects referenced in them. You should either use
 *  weak references to objects referenced inside the block or take care to stop any asynchronous monitoring/ranging of
 *  the beacon manager to manually resolve reference cycles.
 */
@interface BIBeaconManager : NSObject

/**---------------------------------------------------------------------------------------
 * @name Monitoring iBeacon regions and ranging
 * ---------------------------------------------------------------------------------------
 */

/**
 *  Returns the application’s authorization status for using location services.
 *
 *  The authorization status of a given application is managed by the system and determined by several factors.
 *  Applications must be explicitly authorized to use location services by the user and location services must themselves
 *  currently be enabled for the system. A request for user authorization is displayed automatically when your application
 *  first attempts to use location services.
 *
 *  @return A value indicating whether the application is authorized to use location services, or whether the 
 *  authorization has not been determined yet, or whether authorization has been denied or restricted.
 */
+ (CLAuthorizationStatus)locationServicesAuthorizationStatus;

/**
 *  Returns a Boolean indicating whether the device supports region monitoring for Bluetooth beacons.
 *
 *  The availability of region monitoring support is dependent on the hardware present on the device. This method does 
 *  not take into account the availability of location services or the fact that the user might have disabled them for 
 *  the app or system; you must determine your app’s authorization status separately using the +authorizationStatus
 *  method.
 *
 *  @return YES if the device is capable of monitoring regions using Bluetooth beacons or NO if it is not.
 */
+ (BOOL)isBeaconRegionMonitoringAvailable;

/**
 *  Returns a Boolean indicating whether the device supports ranging of Bluetooth beacons.
 *
 *  This capability is required for continuous ranging of Bluetooth beacons and updating the strongest beacon in a region.
 *
 *  @return YES if the device supports ranging or NO if it does not.
 */
+ (BOOL)isBeaconRangingAvailable;

/**
 *  Starts monitoring the specified beacon region.
 *
 *  Region monitoring continues when the app enters the background or gets killed. The OS will continue to monitor the
 *  region and wake up the app when the device enters or exits the region. You must call this method once for each region
 *  you want to monitor. If an existing region with the same identifier is already being monitored by the application, 
 *  the old region is replaced by the new one. An app can register up to 20 regions at a time.
 *
 *  @param region The CLBeaconRegion object that defines the set of beacons you want to monitor. Must not be nil.
 *
 *  @param didEnterRegionHandler The block that should get called when the device enters the specified region. This event 
 *  is usually triggered instantly when a beacon that is part of the specified region comes into range.
 *
 *  @param didExitRegionHandler  The block that should get called when the device exits the specified region. This event
 *  is usually triggered with some delay after the specified region gets out of range. The delay can be a few seconds up 
 *  to a number of minutes and is determined by the OS.
 *
 *  @param errorHandler The block that should get called when an error during region monitoring occurs.
 *
 *  @warning The beacon manager will retain the blocks passed to this method until you call the stopMonitoringForRegion: 
 *  method. Watch out for possible reference cycles.
 */
- (void)startMonitoringForRegion:(CLBeaconRegion *)region didEnterRegionHandler:(BIDidEnterRegionHandler)didEnterRegionHandler didExitRegionHandler:(BIDidExitRegionHandler)didExitRegionHandler errorHandler:(BIErrorHandler)errorHandler;

/**
 *  Stops monitoring the specified region.
 *
 *  If the specified region object is not currently being monitored, this method has no effect.
 *
 *  @param region The CLBeaconRegion object currently being monitored. Must not be nil.
 */
- (void)stopMonitoringForRegion:(CLBeaconRegion *)region;

/**
 *  Retrieves the current state of a beacon region asynchronously.
 *
 *  @param region The CLBeaconRegion object whose state you want to know. Must not be nil.
 *
 *  @param completionHandler The block that should get called with the result when the beacon manager has determined
 *  the region's state. The method will release the completionBlock as soon as it has delivered the result.
 */
- (void)requestStateForRegion:(CLBeaconRegion *)region completionHandler:(BIDidDetermineRegionStateHandler)completionHandler;

/**
 *  Starts monitoring the specified beacon region for changes of the beacon nearest to the device.
 *
 *  This method will observe changes in signal strength of the beacons in the specified region and will notify you via
 *  the updateHandler block whenever the beacon nearest to the device changes.
 *
 *  @param region The beacon region you want to monitor. Must not be nil.
 *
 *  @param updateHandler The block that should get called when the beacon manager detects a change of beacon nearest to
 *  the device.
 */
- (void)startMonitoringNearestBeaconInRegion:(CLBeaconRegion *)region updateHandler:(BINearestBeaconUpdateHandler)updateHandler;

/**
 *  Stops monitoring the specified beacon region for changes of the beacon nearest to the device.
 *
 *  When you invoke this method, the receiver will release the block you have passed to
 *  startMonitoringNearestBeaconInRegion:updateHandler:.
 *
 *  @param region The CLBeaconRegion object currently being monitored for nearest beacon changes. Must not be nil.
 */
- (void)stopMonitoringNearestBeaconInRegion:(CLBeaconRegion *)region;

/**
 *  Starts delivering continuous ranging updates for the specified beacon region.
 *
 *  The updateHandler block will be called approximately once per second with a list of beacons the beacon manager has
 *  seen in the specified region. You should call this method if you want to receive a continuous stream of signals for
 *  all beacons that are currently in range of the device.
 *
 *  @param region The CLBeaconRegion object that defines the set of beacons you want to monitor. Must not be nil.
 *
 *  @param updateHandler The block that should get called when a ranging update is available.
 */
- (void)startContinuousRangingInRegion:(CLBeaconRegion *)region updateHandler:(BIContinuousRangingUpdateHandler)updateHandler;

/**
 *  Stops delivering continuous ranging updates for the specified beacon region.
 *
 *  When you invoke this method, the receiver will release the block you have passed to startContinuousRangingInRegion:updateHandler:.
 *
 *  @param region The CLBeaconRegion object currently being observed for continuous ranging. Must not be nil.
 */
- (void)stopContinuousRangingInRegion:(CLBeaconRegion *)region;

/**
 *  Returns a boolean indicating whether the beacon manager is currently monitoring the specified region.
 *
 *  @param region The CLBeaconRegion object you want to query. Must not be nil.
 *
 *  @return YES if the region is currently being monitored, otherwise NO.
 */
- (BOOL)isMonitoringRegion:(CLBeaconRegion *)region;

/**
 *  Returns a boolean indicating whether the beacon manager is currently ranging beacons in the specified region.
 *
 *  Ranging includes both continuous beacon updates and monitoring of nearest beacon updates in a region.
 *
 *  @param region The CLBeaconRegion object you want to query. Must not be nil.
 *
 *  @return YES if the region is currently being ranged, otherwise NO.
 */
- (BOOL)isRangingRegion:(CLBeaconRegion *)region;

/**---------------------------------------------------------------------------------------
 * @name Low-level Bluetooth Low Energy stack
 * ---------------------------------------------------------------------------------------
 */

/**
 *  The current state of the Bluetooth Low Energy stack. Possible values include:
 *
 *  - CBCentralManagerStateUnknown
 *  - CBCentralManagerStateResetting
 *  - CBCentralManagerStateUnsupported
 *  - CBCentralManagerStateUnauthorized
 *  - CBCentralManagerStatePoweredOff
 *  - CBCentralManagerStatePoweredOn
 *
 *  See the Core Bluetooth documentation for explanations of these values.
 *
 *  You should only scan for Bluetooth devices, connect to a device, discover a device's services or characteristics,
 *  or read or write the value of a characteristic if bluetoothState is CBCentralManagerStatePoweredOn.
 *
 *  @see bluetoothStateUpdateHandler
 *  @see localizedNameForBluetoothState:
 */
@property (nonatomic, readonly) CBCentralManagerState bluetoothState;

/**
 *  A block that gets called each time the state of the Bluetooth Low Energy stack changes. Assign a block to this
 *  property to get informed about state changes.
 *
 *  @see bluetoothState
 */
@property (nonatomic, copy) BIBluetoothStateUpdateHandler bluetoothStateUpdateHandler;

/**
 *  A boolean value that indicates whether the beacon manager is currently scanning for Bluetooth Low Energy devices.
 *
 *  @see startScanningForBluetoothDevicesWithContinuousUpdates:discoverHandler:
 *  @see stopScanningForBluetoothDevices
 */
@property (nonatomic, readonly, getter=isScanningForBluetoothDevices) BOOL scanningForBluetoothDevices;

/**
 *  Start a scan for any Bluetooth Low Energy devices that are advertising.
 *
 *  @param continuousUpdates A boolean value that indicates whether the beacon manager should continue to send discovery
 *  events when it receives advertising packets for devices that have already been discovered.
 *
 *  @param discoverDeviceHandler A block that gets called for each discovered device. The block gets called on the main
 *  thread.
 *  If continuousUpdates is set to YES, the block will get called for every advertising packet received (multiple times 
 *  per device). This is useful if you want to continually monitor the signal strength of discovered devices. 
 *  If continuousUpdates is set to NO, the block is only called once for each discovered device. Enabling continuous 
 *  updates can have an adverse effect on battery life and should be used only if necessary.
 *
 *  @see stopScanningForBluetoothDevices
 *  @see scanningForBluetoothDevices
 */
- (void)startScanningForBluetoothDevicesWithContinuousUpdates:(BOOL)continuousUpdates discoverHandler:(BIDidDiscoverDeviceHandler)discoverDeviceHandler;

/**
 *  Stop an active scan for Bluetooth Low Energy devices.
 *
 *  This method releases the block passed to the startScanningForBluetoothDevicesWithContinuousUpdates:discoverHandler:
 *  method.
 *
 *  This method does nothing if the beacon manager is currently not scanning for devices.
 *
 *  @see startScanningForBluetoothDevicesWithContinuousUpdates:discoverHandler:
 *  @see scanningForBluetoothDevices
 */
- (void)stopScanningForBluetoothDevices;

/**
 *  Establishes a connection to a Bluetooth Low Energy device.
 *
 *  @param device The device you want to connect to. Must not be nil.
 *
 *  @param didConnectHandler A block that gets called when the connection has been established. The block gets called
 *  on the main thread. Once the connection is established, you can continue to discover the services this devices
 *  supports by sending it a discoverServices:forBluetoothDevice:completionHandler: message.
 *
 *  @param didDisconnectHandler A block that gets called when the device disconnected from the beacon manager. The block
 *  gets called on the main thread. Disconnections can either be initiated explicitly with the disconnectBluetoothDevice: 
 *  method or happen for other reasons. This parameter can be nil.
 */
- (void)connectBluetoothDevice:(BIBluetoothPeripheral *)device didConnectHandler:(BIDidConnectDeviceHandler)didConnectHandler didDisconnectHandler:(BIDidDisconnectDeviceHandler)didDisconnectHandler;

/**
 *  Disconnect from a Bluetooth Low Energy device.
 *
 *  This method releases the blocks passed to the connectBluetoothDevice:didConnectHandler:didDisconnectHandler: method.
 *
 *  This method does nothing if the device is not currently connected to the beacon manager.
 *
 *  @param device The device you want to disconnect. Must not be nil.
 */
- (void)disconnectBluetoothDevice:(BIBluetoothPeripheral *)device;

/**
 *  Discovers the specified services of the device.
 *
 *  @param serviceUUIDs An array of CBUUID objects that you are interested in. Here, each CBUUID object represents a 
 *  UUID that identifies the type of service you want to discover. If the servicesUUIDs parameter is nil, all the 
 *  available services of the peripheral are returned; setting the parameter to nil is considerably slower and is not 
 *  recommended.
 *
 *  @param device The Bluetooth Low Energy device whose services you want to discover. Must not be nil.
 *
 *  @param completionHandler A block that gets called when the beacon manager discovers one or more of the device's services.
 *  The block gets called on the main thread. The beacon manager will release this block once it has called it.
 */
- (void)discoverServices:(NSArray *)serviceUUIDs forBluetoothDevice:(BIBluetoothPeripheral *)device completionHandler:(BIDidDiscoverServicesHandler)completionHandler;

/**
 *  Discovers the specified characteristics of a service.
 *
 *  @param characteristicUUIDs An array of CBUUID objects that you are interested in. Here, each CBUUID object represents
 *  a UUID that identifies the type of a characteristic you want to discover. As a result, the beacon manager returns 
 *  only the characteristics your app is interested in (recommended). If the characteristicUUIDs parameter is nil, all
 *  the characteristics of the service are returned; setting the parameter to nil is considerably slower and is not 
 *  recommended.
 *
 *  @param service The service whose characteristics you want to discover. Must not be nil.
 *
 *  @param device The Bluetooth Low Energy device whose characteristics you want to discover. Must not be nil.
 *
 *  @param completionHandler A block that gets called when the beacon manager discovers one or more of characteristics.
 *  The block gets called on the main thread. The beacon manager will release this block once it has called it.
 */
- (void)discoverCharacteristics:(NSArray *)characteristicUUIDs forService:(CBService *)service bluetoothDevice:(BIBluetoothPeripheral *)device completionHandler:(BIDidDiscoverCharacteristicsHandler)completionHandler;

/**
 *  Reads the value of the specified characteristic.
 *
 *  If the beacon manager knows how to interpret the binary data it retrieves for the specified characteristic,
 *  it will convert the value to a user-friendly format before passing it to the completionHandler block. If the
 *  beacon manager does not know how to interpret the specified characteristic, it will pass the value an NSData
 *  object containing the raw binary data to the completionHandler block.
 *
 *  Currently, the beacon manager know how to interpret these characteristics:
 *
 *  - BIBeaconDeviceInformationManufacturerNameCharacteristicUUID: The returned value is an NSString.
 *  - BIBeaconDeviceInformationModelNumberCharacteristicUUID: The returned value is an NSString.
 *  - BIBeaconDeviceInformationSerialNumberCharacteristicUUID: The returned value is an NSString.
 *  - BIBeaconDeviceInformationFirmwareRevisionCharacteristicUUID: The returned value is an NSString.
 *  - BIBeaconDeviceInformationHardwareRevisionCharacteristicUUID: The returned value is an NSString.
 *  - BIBeaconDeviceInformationSoftwareRevisionCharacteristicUUID: The returned value is an NSString.
 *  - BIBeaconBatteryLevelCharacteristicUUID: The returned value is an NSNumber that contains an integer value representing
 *  the current battery level in percent.
 *  - BIBeaconProximityUUIDCharacteristicUUID: The returned value is an NSUUID object representing the beacon's proximityUUID.
 *  - BIBeaconProximityMajorCharacteristicUUID: The returned value is an NSNumber that contains a 16-bit unsigned integer
 *  representing the beacon's major value.
 *  - BIBeaconProximityMinorCharacteristicUUID: The returned value is an NSNumber that contains a 16-bit unsigned integer
 *  representing the beacon's minor value.
 *  - BIBeaconTxPowerLevelCharacteristicUUID: The returned value is an NSNumber that contains an integer value.
 *  0 == -23dBm (min), 1 == -6dBm, 2 == 0dBm (max/default).
 *  - BIBeaconTimerAdvertisingIntervalCharacteristicUUID: The returned value is an NSNumber that contains an integer value
 *  representing the advertising interval in 635us steps.
 *  10ms == 16 (min), 100ms == 160, 250ms == 400, 500ms == 800, 1s == 1600, 10s == 16000 (max).
 *  - BIBeaconTemperatureLevelCharacteristicUUID: The returned value is an NSNumber that contains an integer value representing
 *  the temperature in degrees Celsius.
 *
 *  @param characteristic The characteristic whose value you want to retrieve. Must not be nil.
 *
 *  @param device The Bluetooth Low Energy device whose characteristics you want to discover. Must not be nil.
 *
 *  @param completionHandler A block that gets called when the beacon manager has retrieved the value for the specified
 *  characteristic. The block gets called on the main thread. The beacon manager will release this block once it has 
 *  called it.
 */
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic device:(BIBluetoothPeripheral *)device completionHandler:(BIDidUpdateValueForCharacteristicHandler)completionHandler;

/**---------------------------------------------------------------------------------------
 * @name Helpers
 * ---------------------------------------------------------------------------------------
 */

/**
 *  Returns a localized string describing the specified Bluetooth state.
 *
 *  This method is useful for logging or for showing the Bluetooth state to the user in simple demo apps. Since you cannot
 *  specify the actual wording used by this method, you should not use it for user-facing strings in a production app.
 *
 *  @warning Localization is currently not implemented. The returned string is always in English.
 *
 *  @param bluetoothState The Bluetooth state you want to describe
 *
 *  @return An NSString containing the localized description of the specified Bluetooth state.
 *
 *  @see bluetoothState
 */
- (NSString *)localizedNameForBluetoothState:(CBCentralManagerState)bluetoothState;

/**
 *  Returns a localized string describing the specified service or characteristic.
 *
 *  This method is useful for logging or for showing the Bluetooth state to the user in an internal app. Since you cannot
 *  specify the actual wording used by this method, you should not use it for user-facing strings in a production app.
 *
 *  @warning Localization is currently not implemented. The returned string is always in English.
 *
 *  @param UUID The UUID of the service or characteristic you want to describe. Must not be nil.
 *
 *  @return An NSString containing the localized description of the specified service or characteristic.
 */
- (NSString *)localizedNameForServiceOrCharacteristicUUID:(CBUUID *)UUID;

@end
