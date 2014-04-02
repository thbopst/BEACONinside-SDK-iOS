//
//  BIBluetoothServiceListViewController.h
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 26/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import UIKit;

#import <BEACONinsideSDK/BEACONinsideSDK.h>

@interface BIBluetoothServiceListViewController : UITableViewController

@property (nonatomic, strong) BIBeaconManager *beaconManager;
@property (nonatomic, strong) BIBluetoothPeripheral *device;

@end
