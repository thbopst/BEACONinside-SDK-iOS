//
//  BIBluetoothCharacteristicListViewController.h
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 26/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import UIKit;
@import CoreBluetooth;

#import <BEACONinsideSDK/BEACONinsideSDK.h>

@interface BIBluetoothCharacteristicListViewController : UITableViewController

@property (nonatomic, strong) BIBeaconManager *beaconManager;
@property (nonatomic, strong) BIBluetoothPeripheral *device;
@property (nonatomic, strong) CBService *service;

@end
