//
//  BIBeaconController.h
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 01/04/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import Foundation;
#import <BEACONinsideSDK/BEACONinsideSDK.h>
#import "BIEventLog.h"

/**
 *  A singleton object that manages the BIBeaconManager for the app and interacts with the app's view controllers.
 */
@interface BIBeaconController : NSObject

+ (instancetype)sharedBeaconController;

- (BOOL)canStartRegionMonitoring;
- (BOOL)isMonitoringRegion;
- (void)startRegionMonitoring;
- (void)stopRegionMonitoring;

- (BOOL)isRanging;
- (void)startRanging;
- (void)stopRanging;

@property (nonatomic, strong, readonly) BIBeaconManager *beaconManager;
@property (nonatomic, strong, readonly) CLBeaconRegion *monitoredRegion;
@property (nonatomic, strong, readonly) CLBeaconRegion *rangedRegion;
@property (nonatomic, strong, readonly) BIEventLog *regionMonitoringLog;
@property (nonatomic, strong, readonly) BIEventLog *rangingLog;

@end
