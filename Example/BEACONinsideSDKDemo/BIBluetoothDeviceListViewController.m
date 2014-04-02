//
//  BIBluetoothDeviceListViewController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 25/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BIBluetoothDeviceListViewController.h"
#import "BIBeaconController.h"
#import "BIActivityStatusCell.h"
#import "BIToggleButtonCell.h"
#import "BIBluetoothServiceListViewController.h"

@interface BIBluetoothDeviceListViewController ()

@property (nonatomic, strong) NSMutableArray *discoveredDevices;

@end

@implementation BIBluetoothDeviceListViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BIBluetoothStateDidUpdate" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.discoveredDevices = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bluetoothStateDidUpdate:) name:@"BIBluetoothStateDidUpdate" object:nil];
}

- (void)_configureBluetoothStateCell:(BIActivityStatusCell *)cell indexPath:(NSIndexPath *)indexPath
{
    BIBeaconController *beaconController = [BIBeaconController sharedBeaconController];
    NSString *bluetoothStateString = [beaconController.beaconManager localizedNameForBluetoothState:beaconController.beaconManager.bluetoothState];
    cell.statusLabel.text = [NSString stringWithFormat:@"Bluetooth state: %@", bluetoothStateString ?: @"(unknown)"];
}

- (void)_configureToggleScanningButtonCell:(BIToggleButtonCell *)cell indexPath:(NSIndexPath *)indexPath
{
    BIBeaconController *beaconController = [BIBeaconController sharedBeaconController];
    if (beaconController.beaconManager.scanningForBluetoothDevices) {
        cell.titleLabel.text = @"Stop Scanning";
        [cell.activityIndicator startAnimating];
    } else {
        cell.titleLabel.text = @"Start Scanning";
        [cell.activityIndicator stopAnimating];
    }
}

- (void)_configureBluetoothDeviceListCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    BIBluetoothPeripheral *device = self.discoveredDevices[(NSUInteger)indexPath.row];
    cell.textLabel.text = device.name ?: @"(unknown)";
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ dB", [device.RSSI stringValue]];
}

- (void)_toogleBluetoothScanning
{
    BIBeaconController *beaconController = [BIBeaconController sharedBeaconController];
    if (beaconController.beaconManager.scanningForBluetoothDevices) {
        [beaconController.beaconManager stopScanningForBluetoothDevices];
        [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:1 inSection:0] ] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [beaconController.beaconManager startScanningForBluetoothDevicesWithContinuousUpdates:YES discoverHandler:^(BIBluetoothPeripheral *device)
        {
            [self.tableView beginUpdates];

            NSIndexPath *deviceIndexPath = nil;
            NSUInteger deviceIndex = [self.discoveredDevices indexOfObject:device];
            if (deviceIndex == NSNotFound) {
                if ([self.discoveredDevices count] == 0) {
                    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                [self.discoveredDevices addObject:device];
                deviceIndexPath = [NSIndexPath indexPathForRow:(NSInteger)([self.discoveredDevices count] - 1) inSection:1];
                [self.tableView insertRowsAtIndexPaths:@[ deviceIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            } else {
                deviceIndexPath = [NSIndexPath indexPathForRow:(NSInteger)deviceIndex inSection:1];
                [self.tableView reloadRowsAtIndexPaths:@[ deviceIndexPath ] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            [self.tableView endUpdates];
        }];
        [self.discoveredDevices removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)_bluetoothStateDidUpdate:(NSNotification *)notification
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BIBeaconController *beaconController = [BIBeaconController sharedBeaconController];
    if ([segue.identifier isEqualToString:@"PushBluetoothServicesView"]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        BIBluetoothPeripheral *selectedDevice = self.discoveredDevices[(NSUInteger)selectedIndexPath.row];
        
        BIBluetoothServiceListViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.beaconManager = beaconController.beaconManager;
        destinationViewController.device = selectedDevice;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.discoveredDevices count] == 0) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return (NSInteger)[self.discoveredDevices count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            BIActivityStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BluetoothStateCell" forIndexPath:indexPath];
            [self _configureBluetoothStateCell:cell indexPath:indexPath];
            return cell;
        } else {
            BIToggleButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ToggleScanningButtonCell" forIndexPath:indexPath];
            [self _configureToggleScanningButtonCell:cell indexPath:indexPath];
            return cell;
        }
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BluetoothDeviceListCell" forIndexPath:indexPath];
        [self _configureBluetoothDeviceListCell:cell indexPath:indexPath];
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
        return @"Discovered Bluetooth Devices";
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // We only handle the "Start/stop scanning" button in section 0 here.
    // Selections of the cells in section 1 (representing BLE devices) is done via storyboard segues.
    // See the -prepareForSegue: method for details.
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self _toogleBluetoothScanning];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
