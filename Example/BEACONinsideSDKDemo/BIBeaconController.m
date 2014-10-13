//
//  BIBeaconController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 01/04/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import UIKit;
@import AudioToolbox;
@import CoreLocation;

#import "BIBeaconController.h"
#import "BIPreferencesController.h"

@interface BIBeaconController ()

@property (nonatomic, strong, readwrite) CLBeaconRegion *monitoredRegion;
@property (nonatomic, strong, readwrite) CLBeaconRegion *rangedRegion;
@property (nonatomic, strong, readwrite) CLLocationManager *locationManager;

@end


@implementation BIBeaconController

+ (instancetype)sharedBeaconController
{
    static BIBeaconController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _regionMonitoringLog = [[BIEventLog alloc] init];
        _rangingLog = [[BIEventLog alloc] init];
        _beaconManager = [[BIBeaconManager alloc] init];
        
        // Check and request location service access authorization (iOS 8)
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if ( [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestWhenInUseAuthorization]; // calls delegate
        }
        
        [self _setupMonitoredRegion];
        [self _setupRangedRegion];
        [self _reregisterEventHandlers];
        [self _registerBluetoothStateUpdateHandler];
        
        // Listen to user defaults changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark - Region Monitoring

- (BOOL)canStartRegionMonitoring
{
    return (self.monitoredRegion != nil);
}

- (BOOL)isMonitoringRegion
{
    if (self.monitoredRegion == nil) {
        return NO;
    }
    return [self.beaconManager isMonitoringRegion:self.monitoredRegion];
}

- (void)startRegionMonitoring
{
    if (self.monitoredRegion == nil) {
        [self.regionMonitoringLog logEvent:@"Cannot start region monitoring. Please select a beacon to use for region monitoring on the Setup tab."];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
        return;
    }

    [self.beaconManager startMonitoringForRegion:self.monitoredRegion didEnterRegionHandler:^(CLBeaconRegion *region) {
        [self _notifyUserWithMessage:[NSString stringWithFormat:@"Welcome in zone %@:%@.", region.major, region.minor]];
        [self.regionMonitoringLog logEvent:[NSString stringWithFormat:@"Entered zone %@:%@", region.major, region.minor]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
    } didExitRegionHandler:^(CLBeaconRegion *region) {
        [self _notifyUserWithMessage:[NSString stringWithFormat:@"You left zone %@:%@.", region.major, region.minor]];
        [self.regionMonitoringLog logEvent:[NSString stringWithFormat:@"Exited zone %@:%@", region.major, region.minor]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
    } errorHandler:^(CLBeaconRegion *region, NSError *error) {
        [self.regionMonitoringLog logEvent:[NSString stringWithFormat:@"Region monitoring error: %@", error]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
    }];

    [self.regionMonitoringLog logEvent:[NSString stringWithFormat:@"Started monitoring zone %@:%@", self.monitoredRegion.major, self.monitoredRegion.minor]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
}

- (void)stopRegionMonitoring
{
    [self stopRegionMonitoringForRegion:self.monitoredRegion];
}

- (void)stopRegionMonitoringForRegion:(CLBeaconRegion *)region
{
    [self.beaconManager stopMonitoringForRegion:region];
    [self.regionMonitoringLog logEvent:[NSString stringWithFormat:@"Stopped monitoring region %@", region.identifier]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
}

#pragma mark - Ranging

- (BOOL)isRanging
{
    return [self.beaconManager isRangingRegion:self.rangedRegion];
}

- (void)startRanging
{
    // Start monitoring changes to nearest beacon
    [self.beaconManager startMonitoringNearestBeaconInRegion:self.rangedRegion updateHandler:^(CLBeaconRegion *region, BIBeacon *nearestBeacon, NSError *error) {
        if (error) {
            [self.rangingLog logEvent:[NSString stringWithFormat:@"Ranging error: %@", error]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
            return;
        }
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BINearestBeaconDidChangeNotification" object:nearestBeacon];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
     }];
    
    // Start continuous ranging of beacons
    [self.beaconManager startContinuousRangingInRegion:self.rangedRegion updateHandler:^(CLBeaconRegion *region, NSArray *smoothedBeacons, NSError *error)
     {
         if (error) {
             [self.rangingLog logEvent:[NSString stringWithFormat:@"Ranging error: %@", error]];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
             return;
         }
         
         NSMutableString *logMessage = [NSMutableString stringWithString:@"Ranging update:\n"];
         [logMessage appendString:[self _logMessageForBeacons:smoothedBeacons]];
         [self.rangingLog logEvent:logMessage];

         [[BIPreferencesController sharedPreferencesController] addBeaconsToKnownBeaconIdentifiers:smoothedBeacons];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"BIDidReceiveContinuousRangingUpdateNotification" object:smoothedBeacons];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
     }];
    
    [self.rangingLog logEvent:@"Started ranging"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
}

- (NSString *)_logMessageForBeacons:(NSArray *)beacons
{
    NSMutableString *logMessage = [NSMutableString string];
    [logMessage appendString:@"Smoothed data:\n"];
    [beacons enumerateObjectsUsingBlock:^(BIBeacon *beacon, NSUInteger idx, BOOL *stop) {
        [logMessage appendFormat:@"%lu) %@:%@ • %ld dB • prox %ld ±%.2fm\n", (unsigned long)(idx + 1), beacon.major, beacon.minor, beacon.smoothedRSSI, beacon.smoothedProximity, beacon.smoothedAccuracy];
    }];
    [logMessage appendString:@"\n"];
    [logMessage appendString:@"Raw data:\n"];
    [beacons enumerateObjectsUsingBlock:^(BIBeacon *beacon, NSUInteger idx, BOOL *stop) {
        [logMessage appendFormat:@"%lu) %@:%@ • %ld dB • prox %ld ±%.2fm\n", (unsigned long)(idx + 1), beacon.major, beacon.minor, beacon.rawSignal.RSSI, beacon.rawSignal.proximity, beacon.rawSignal.accuracy];
    }];
    return logMessage;
}

- (void)stopRanging
{
    [self.beaconManager stopMonitoringNearestBeaconInRegion:self.rangedRegion];
    [self.beaconManager stopContinuousRangingInRegion:self.rangedRegion];
    [self.rangingLog logEvent:@"Stopped ranging"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBeaconControllerStateDidChange" object:self];
}

#pragma mark - Notifications

- (void)_userDefaultsDidChange:(NSNotification *)notification
{
    BOOL isMonitoringRegion = [self isMonitoringRegion];
    CLBeaconRegion *previousMonitoredRegion = self.monitoredRegion;
    
    [self _setupMonitoredRegion];
    
    if (!isMonitoringRegion) {
        return;
    }
    
    if (self.monitoredRegion == previousMonitoredRegion) {
        return;
    }

    if (previousMonitoredRegion) {
        [self stopRegionMonitoringForRegion:previousMonitoredRegion];
    }
    if (self.monitoredRegion) {
        [self startRegionMonitoring];
    }
}

#pragma mark - Helpers

- (void)_setupMonitoredRegion
{
    NSDictionary *beaconIdentifierForRegionMonitoring = [[BIPreferencesController sharedPreferencesController] beaconIdentifierForRegionMonitoring];
    if (beaconIdentifierForRegionMonitoring == nil) {
        self.monitoredRegion = nil;
        return;
    }
    
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:beaconIdentifierForRegionMonitoring[@"proximityUUID"]];
    NSNumber *major = beaconIdentifierForRegionMonitoring[@"major"];
    NSNumber *minor = beaconIdentifierForRegionMonitoring[@"minor"];
    
    if ([beaconUUID isEqual:self.monitoredRegion.proximityUUID] && [major isEqual:self.monitoredRegion.major] && [minor isEqual:self.monitoredRegion.minor]) {
        // Monitored region did not change
        return;
    }
    
    NSString *regionIdentifier = [NSString stringWithFormat:@"%@:%@", major, minor];
    self.monitoredRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID major:[major unsignedShortValue] minor:[minor unsignedShortValue] identifier:regionIdentifier];
}

- (void)_setupRangedRegion
{
    // We do beacon ranging without restricting the major or minor values, scanning for all beacons with the specified proximityUUID
    NSUUID *beaconUUID = [[NSUUID alloc] initWithUUIDString:BIBeaconDefaultProximityUUID];
    self.rangedRegion = [[CLBeaconRegion alloc] initWithProximityUUID:beaconUUID identifier:@"All BEACONinside Beacons"];
}

- (void)_reregisterEventHandlers
{
    // Re-register event handlers at startup.
    // This is necessary because region monitoring can continue when the app gets killed.
    // Upon relaunch, we should re-register our event handler blocks in order to get region monitoring updates.
    if ([self canStartRegionMonitoring]) {
        if ([self.beaconManager isMonitoringRegion:self.monitoredRegion]) {
            [self startRegionMonitoring];
        }
    }

    if ([self.beaconManager isRangingRegion:self.rangedRegion]) {
        [self startRanging];
    }
}

- (void)_registerBluetoothStateUpdateHandler
{
    id __weak weakSelf = self;
    self.beaconManager.bluetoothStateUpdateHandler = ^(CBCentralManagerState bluetoothState) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BIBluetoothStateDidUpdate" object:weakSelf];
    };
}

- (void)_notifyUserWithMessage:(NSString *)message
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        NSLog(@"Posting local notification: %@", message);
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = message;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    } else {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

# pragma mark - CLLocationManagerDelegate protocol

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // delegate method is required! Otherwise iOS 8 does not present the location service authorization prompt to the user.
}

@end
