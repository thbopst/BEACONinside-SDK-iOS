//
//  BIPreferencesController.h
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 01/04/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A singleton object that manages the app's preferences and settings and load and saves them to NSUserDefaults
 */
@interface BIPreferencesController : NSObject

+ (instancetype)sharedPreferencesController;

@property (nonatomic, strong) NSDictionary *beaconIdentifierForRegionMonitoring;
@property (nonatomic, strong) NSArray *knownBeaconIdentifiers;

- (void)addBeaconsToKnownBeaconIdentifiers:(NSArray *)beacons;

@end
