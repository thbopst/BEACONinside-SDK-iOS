//
//  BISettingsViewController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 01/04/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BISettingsViewController.h"
#import "BIPreferencesController.h"

@interface BISettingsViewController ()

@property (nonatomic, strong) NSMutableSet *knownBeaconIdentifiers;
@property (nonatomic, strong, readonly) NSArray *sortedBeaconIdentifiers;

@end


@implementation BISettingsViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    _knownBeaconIdentifiers = [NSMutableSet setWithArray:[[BIPreferencesController sharedPreferencesController] knownBeaconIdentifiers]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userDefaultsDidChange:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSArray *)sortedBeaconIdentifiers
{
    NSSortDescriptor *majorSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"major" ascending:YES];
    NSSortDescriptor *minorSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"minor" ascending:YES];
    return [[self.knownBeaconIdentifiers allObjects] sortedArrayUsingDescriptors:@[ majorSortDescriptor, minorSortDescriptor ]];
}

- (void)_userDefaultsDidChange:(NSNotification *)notification
{
    _knownBeaconIdentifiers = [NSMutableSet setWithArray:[[BIPreferencesController sharedPreferencesController] knownBeaconIdentifiers]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[self.knownBeaconIdentifiers count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsKnownBeaconCell" forIndexPath:indexPath];
    
    NSDictionary *beaconIdentifierDict = self.sortedBeaconIdentifiers[(NSUInteger)indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", beaconIdentifierDict[@"major"], beaconIdentifierDict[@"minor"]];
    cell.detailTextLabel.text = beaconIdentifierDict[@"proximityUUID"];
    if ([beaconIdentifierDict isEqual:[[BIPreferencesController sharedPreferencesController] beaconIdentifierForRegionMonitoring]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Beacon for Region Monitoring";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"Select the beacon you want to use for region monitoring notifications. Start beacon ranging on the Radar tab to add beacons in range to this list.";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *beaconIdentifierDict = self.sortedBeaconIdentifiers[(NSUInteger)indexPath.row];
    [[BIPreferencesController sharedPreferencesController] setBeaconIdentifierForRegionMonitoring:beaconIdentifierDict];

    [self.tableView reloadData];
}

@end
