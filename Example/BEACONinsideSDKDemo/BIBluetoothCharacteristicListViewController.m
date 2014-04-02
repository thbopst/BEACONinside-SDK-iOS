//
//  BIBluetoothCharacteristicListViewController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 26/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BIBluetoothCharacteristicListViewController.h"
#import "BIActivityStatusCell.h"

@interface BIBluetoothCharacteristicListViewController ()

@property (nonatomic) BOOL working;
@property (nonatomic, copy) NSString *activityStatus;
@property (nonatomic, strong) NSArray *discoveredCharacteristics;
@property (nonatomic, strong) NSMutableDictionary *characteristicValues;

@end


@implementation BIBluetoothCharacteristicListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.characteristicValues = [NSMutableDictionary dictionary];
    
    self.title = [self.beaconManager localizedNameForServiceOrCharacteristicUUID:self.service.UUID] ?: [self.service.UUID bi_UUIDString];
    
    self.working = YES;
    self.activityStatus = @"Discovering Characteristics…";
    [self.beaconManager discoverCharacteristics:nil forService:self.service bluetoothDevice:self.device completionHandler:^(BIBluetoothPeripheral *device, CBService *service, NSError *error)
    {
        self.working = NO;
        if (error) {
            NSLog(@"Error discovering characteristics: %@", error);
            self.activityStatus = @"Error discovering characteristics";
        }
        self.discoveredCharacteristics = service.characteristics;
        self.activityStatus = @"Done";
        [self.tableView reloadData];
    }];
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

- (void)configureBluetoothCharacteristicListCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    CBCharacteristic *characteristic = self.discoveredCharacteristics[(NSUInteger)indexPath.row];
    NSString *characteristicName = [self.beaconManager localizedNameForServiceOrCharacteristicUUID:characteristic.UUID];
    if (characteristicName) {
        cell.textLabel.text = characteristicName;
    } else {
        cell.textLabel.text = [characteristic.UUID bi_UUIDString];
    }
    
    id characteristicValue = self.characteristicValues[characteristic.UUID];
    cell.detailTextLabel.text = characteristicValue ? [characteristicValue description] : nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.discoveredCharacteristics count] == 0) {
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
        return (NSInteger)[self.discoveredCharacteristics count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        BIActivityStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityStatusCell" forIndexPath:indexPath];
        [self configureActivityStatusCell:cell indexPath:indexPath];
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BluetoothCharacteristicCell" forIndexPath:indexPath];
        [self configureBluetoothCharacteristicListCell:cell indexPath:indexPath];
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
        return @"Discovered Characteristics";
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        return;
    }
    
    NSParameterAssert(indexPath.section == 1);
    
    CBCharacteristic *characteristic = self.discoveredCharacteristics[(NSUInteger)indexPath.row];
    NSIndexPath *indexPathOfActivityStatusCell = [NSIndexPath indexPathForRow:0 inSection:0];

    self.working = YES;
    self.activityStatus = @"Reading value…";
    [self.tableView reloadRowsAtIndexPaths:@[ indexPathOfActivityStatusCell ] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.beaconManager readValueForCharacteristic:characteristic device:self.device completionHandler:^(BIBluetoothPeripheral *device, CBCharacteristic *queriedCharacteristic, id value, NSError *error)
    {
        self.working = NO;
        if (error) {
            NSLog(@"Error reading value for characteristic %@: %@", queriedCharacteristic, error);
            self.characteristicValues[queriedCharacteristic.UUID] = @"(Error)";
            self.activityStatus = @"Error reading value";
        }
        self.characteristicValues[queriedCharacteristic.UUID] = value;
        self.activityStatus = @"Done";
        [self.tableView reloadRowsAtIndexPaths:@[ indexPathOfActivityStatusCell, indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    }];
}

@end
