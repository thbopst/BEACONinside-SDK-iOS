//
//  BIZoneViewController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 24/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BIZoneViewController.h"

@interface BIZoneViewController ()

@property (strong, nonatomic) BIBeacon *nearestBeacon;
@property (weak, nonatomic) IBOutlet UILabel *nearestBeaconLabel;

@end

@implementation BIZoneViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_nearestBeaconDidChange:) name:@"BINearestBeaconDidChangeNotification" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BINearestBeaconDidChangeNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _updateUI];
}

- (void)setNearestBeacon:(BIBeacon *)nearestBeacon
{
    _nearestBeacon = nearestBeacon;
    [self _updateUI];
}

- (void)_updateUI
{
    if (self.nearestBeacon) {
        self.nearestBeaconLabel.text = [NSString stringWithFormat:@"%@:%@", self.nearestBeacon.major, self.nearestBeacon.minor];
    } else {
        self.nearestBeaconLabel.text = @"(unknown)";
    }
}

- (void)_nearestBeaconDidChange:(NSNotification *)notification
{
    self.nearestBeacon = [notification object];
    [self _updateUI];
}

@end
