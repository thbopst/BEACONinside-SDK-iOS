//
//  BIBluetoothServiceListViewController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 26/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BIBluetoothServiceListViewController.h"
#import "BIBluetoothCharacteristicListViewController.h"
#import "BIActivityStatusCell.h"

@interface BIBluetoothServiceListViewController ()

@property (nonatomic) BOOL working;
@property (nonatomic, copy) NSString *activityStatus;
@property (nonatomic, strong) NSArray *discoveredServices;

@end


@implementation BIBluetoothServiceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.title = self.device.name ?: @"Unknown Device";
    
    self.working = YES;
    self.activityStatus = @"Connecting…";
    [self.beaconManager connectBluetoothDevice:self.device didConnectHandler:^(BIBluetoothPeripheral *connectedDevice, NSError *connectError) {
        if (connectError) {
            NSLog(@"Error connecting to device %@: %@", connectedDevice, connectError);
            self.working = NO;
            self.activityStatus = @"Error connecting to device.";
            [self.tableView reloadData];
            return;
        }
        
        self.working = YES;
        self.activityStatus = @"Discovering Services…";
        [self.tableView reloadData];
        
        [self.beaconManager discoverServices:nil forBluetoothDevice:connectedDevice completionHandler:^(BIBluetoothPeripheral *queriedDevice, NSError *discoverError)
        {
            self.working = NO;
            if (discoverError) {
                NSLog(@"Error discovering services for device %@: %@", queriedDevice, discoverError);
                self.activityStatus = @"Error discovering services.";
            } else {
                self.activityStatus = @"Done";
            }
            self.discoveredServices = queriedDevice.services;
            [self.tableView reloadData];
        }];
    } didDisconnectHandler:^(BIBluetoothPeripheral *disconnectedDevice, NSError *error) {
        if (error) {
            NSLog(@"Error disconnecting from device %@: %@", disconnectedDevice, error);
            return;
        }
        NSLog(@"Disconnected from device %@", disconnectedDevice);
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    // Disconnect from the device when we go back to the device list view
    if (![self.navigationController.viewControllers containsObject:self]) {
        [self.beaconManager disconnectBluetoothDevice:self.device];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PushBluetoothCharacteristicsView"])
    {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        CBService *service = self.discoveredServices[(NSUInteger)selectedIndexPath.row];
        
        BIBluetoothCharacteristicListViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.beaconManager = self.beaconManager;
        destinationViewController.device = self.device;
        destinationViewController.service = service;
    }
}

- (void)configureActivityStatusCell:(BIActivityStatusCell *)cell indexPath:(NSIndexPath *)indexPath
{
    cell.statusLabel.text = self.activityStatus;
    if (self.working) {
        [cell.activityIndicator startAnimating];
    } else {
        [cell.activityIndicator stopAnimating];
    }
}

- (void)configureBluetoothServiceListCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    CBService *service = self.discoveredServices[(NSUInteger)indexPath.row];
    NSString *serviceName = [self.beaconManager localizedNameForServiceOrCharacteristicUUID:service.UUID];
    if (serviceName) {
        cell.textLabel.text = serviceName;
        cell.detailTextLabel.text = [service.UUID bi_UUIDString];
    } else {
        cell.textLabel.text = [service.UUID bi_UUIDString];
        cell.detailTextLabel.text = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.discoveredServices count] == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return (NSInteger)[self.discoveredServices count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        BIActivityStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityStatusCell" forIndexPath:indexPath];
        [self configureActivityStatusCell:cell indexPath:indexPath];
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BluetoothServiceCell" forIndexPath:indexPath];
        [self configureBluetoothServiceListCell:cell indexPath:indexPath];
        return cell;
    } else {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else if (section == 1) {
        return @"Discovered Services";
    } else {
        return nil;
    }
}

@end
