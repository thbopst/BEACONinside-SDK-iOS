# BEACONinsideSDK

[![Version](http://cocoapod-badges.herokuapp.com/v/BEACONinsideSDK/badge.png)](http://cocoadocs.org/docsets/BEACONinsideSDK)
[![Platform](http://cocoapod-badges.herokuapp.com/p/BEACONinsideSDK/badge.png)](http://cocoadocs.org/docsets/BEACONinsideSDK)

## Demo App

To run the demo app, clone the repo, and run `pod install` from the Example directory first:

    > git clone git@github.com:beaconinside/BEACONinside-SDK-iOS.git
    > cd BEACONinside-SDK-iOS/Example
    > pod install

The demo app uses the [NCIChartView](https://github.com/FlowForwarding/dynamiccharts) Cocoapod to display a chart of the signal strength of iBeacons in range.

## Requirements

The SDK requires iOS 7.x for its functionality.

We support a deployment target of iOS 6.0, but the SDK provides no functionality when run on iOS 6.

## Installation

BEACONinsideSDK is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "BEACONinsideSDK"

## Usage

Import the SDK header file:

    #import <BEACONinsideSDK/BEACONinsideSDK.h>

Create a `BIBeaconManager` instance. The `BIBeaconManager` class is the primary class that you interact with when you work with the BEACONinside SDK. You should hold a strong reference to the beacon manager (e.g. with a property).

    @property (nonatomic, strong) BIBeaconManager *beaconManager;
    
    ...
    
    self.beaconManager = [[BIBeaconManager alloc] init];

Next, we tell the beacon manager to monitor a specific beacon region. Whenever the device comes into or gets out of range of the specified iBeacon(s), we get a callback in the form of a block.

    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:BIBeaconDefaultProximityUUID];
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:@"My Beacon Region"];
    
    [self.beaconManager startMonitoringForRegion:self.monitoredRegion 
    didEnterRegionHandler:^(CLBeaconRegion *region) {
        NSLog(@"Entered region: %@", region.identifier);
    } didExitRegionHandler:^(CLBeaconRegion *region) {
        NSLog(@"Exited region: %@", region.identifier);
    } errorHandler:^(CLBeaconRegion *region, NSError *error) {
        NSLog(@"Error monitoring region: %@", error);
    }];

Region monitoring continues when your app goes into the background and even when your app gets killed. If you post a local notification from the handler blocks, your app can notify the user that they entered or exited a beacon region even when it is not active.

You can also monitor how the device moves from one iBeacon to another within a larger region of beacons. This piece of code will notify you (again, by calling a handler block you specify) whenever the beacon that is currently nearest to the device changes:

    CLBeaconRegion *beaconRegion = ...
    [self.beaconManager startMonitoringNearestBeaconInRegion:beaconRegion
    updateHandler:^(CLBeaconRegion *region, BIBeacon *nearestBeacon, NSError *error) {
        if (error) {
            NSLog(@"Error monitoring nearest beacon change: %@", error)
            return;
        }
        NSLog(@"The nearest beacon is now: %@", nearestBeacon);
     }];

Finally, you can tell the beacon manager to deliver continuous updates of the signal strength  for all beacons within the specified region that are currently in range. In this case, the handler block will be called approximately once evert second and will pass you a list of all beacons it has seen in the specified region, sorted by signal strength. The list includes all beacons the beacon manager has seen in the specified region, even when they are currently not in range.

    CLBeaconRegion *beaconRegion = ...
    [self.beaconManager startContinuousRangingInRegion:beaconRegion
    updateHandler:^(CLBeaconRegion *region, NSArray *smoothedBeacons, NSError *error)
    {
        if (error) {
            NSLog(@"Continuous ranging error: %@", error)
            return;
        }
        NSLog(@"List of beacons: %@", smoothedBeacons);
    }];

## Author

[BEACONinside GmbH](http://www.beaconinside.com/)

## License

BEACONinsideSDK is available under the MIT license. See the LICENSE file for more info.

