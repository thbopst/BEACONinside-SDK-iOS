//
//  BIPreferencesController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 01/04/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BIPreferencesController.h"
#import <BEACONinsideSDK/BEACONinsideSDK.h>

@implementation BIPreferencesController

+ (instancetype)sharedPreferencesController
{
    static BIPreferencesController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSDictionary *)beaconIdentifierForRegionMonitoring
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"BeaconIdentifierForRegionMonitoring"];
}

- (void)setBeaconIdentifierForRegionMonitoring:(NSDictionary *)beaconIdentifierForRegionMonitoring
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (beaconIdentifierForRegionMonitoring) {
        [defaults setObject:beaconIdentifierForRegionMonitoring forKey:@"BeaconIdentifierForRegionMonitoring"];
    } else {
        [defaults removeObjectForKey:@"BeaconIdentifierForRegionMonitoring"];
    }
    [defaults synchronize];
}

- (NSArray *)knownBeaconIdentifiers
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"KnownBeaconIdentifiers"];
}

- (void)setKnownBeaconIdentifiers:(NSArray *)knownBeaconIdentifiers
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (knownBeaconIdentifiers) {
        [defaults setObject:knownBeaconIdentifiers forKey:@"KnownBeaconIdentifiers"];
    } else {
        [defaults removeObjectForKey:@"KnownBeaconIdentifiers"];
    }
    [defaults synchronize];
}

- (void)addBeaconsToKnownBeaconIdentifiers:(NSArray *)beacons
{
    NSParameterAssert(beacons);
    
    NSMutableSet *knownBeaconIdentifiersSet = [NSMutableSet setWithArray:self.knownBeaconIdentifiers];
    
    BOOL __block didAddNewBeacons;
    [beacons enumerateObjectsUsingBlock:^(BIBeacon *beacon, NSUInteger idx, BOOL *stop) {
        NSDictionary *beaconIdentifer = beacon.beaconIdentifierDictionaryRepresentation;
        if (![knownBeaconIdentifiersSet containsObject:beaconIdentifer]) {
            [knownBeaconIdentifiersSet addObject:beacon.beaconIdentifierDictionaryRepresentation];
            didAddNewBeacons = YES;
        }
    }];
    
    if (didAddNewBeacons) {
        [self setKnownBeaconIdentifiers:[knownBeaconIdentifiersSet allObjects]];
    }
}

@end
