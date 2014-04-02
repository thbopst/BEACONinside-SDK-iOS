//
//  BIRadarViewController.h
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 17/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import QuartzCore;

#import "BIRadarViewController.h"
#import "BIBeaconController.h"
#import <BEACONinsideSDK/BEACONinsideSDK.h>

@interface BIRadarViewController ()

@property (weak, nonatomic) IBOutlet UILabel *locationServicesStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *regionMonitoringStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *rangingStatusLabel;
@property (weak, nonatomic) IBOutlet UIButton *toggleRegionMonitoringButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleRangingButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *regionMonitoringActivityIndicator;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *rangingActivityIndicator;
@property (weak, nonatomic) IBOutlet UITextView *regionMonitoringLogTextView;
@property (weak, nonatomic) IBOutlet UITextView *rangingLogTextView;

@end


@implementation BIRadarViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BIBeaconControllerStateDidChange" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _updateUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_beaconControllerStateDidChange:) name:@"BIBeaconControllerStateDidChange" object:nil];
}

#pragma mark - Button actions

- (IBAction)handleToggleRegionMonitoringButton:(id)sender
{
    BIBeaconController *beaconController = [BIBeaconController sharedBeaconController];
    if ([beaconController isMonitoringRegion]) {
        [beaconController stopRegionMonitoring];
    } else {
        [beaconController startRegionMonitoring];
    }
}

- (IBAction)handleToggleRangingButton:(id)sender
{
    BIBeaconController *beaconController = [BIBeaconController sharedBeaconController];
    if ([beaconController isRanging]) {
        [beaconController stopRanging];
    } else {
        [beaconController startRanging];
    }
}

#pragma mark - Notifications

- (void)_eventLogDidChange:(NSNotification *)notification
{
    [self _updateUI];
}

- (void)_beaconControllerStateDidChange:(NSNotification *)notification
{
    [self _updateUI];
}

#pragma mark - Helpers

- (void)_updateUI
{
    self.locationServicesStatusLabel.text = [self _locationServicesStatusText];
    self.regionMonitoringStatusLabel.text = [self _regionMonitoringStatusText];
    self.rangingStatusLabel.text = [self _rangingStatusText];
    
    BIBeaconController *beaconController = [BIBeaconController sharedBeaconController];
    if ([beaconController isMonitoringRegion]) {
        [self.regionMonitoringActivityIndicator startAnimating];
        [self.toggleRegionMonitoringButton setTitle:@"Stop Region Monitoring" forState:UIControlStateNormal];
    } else {
        [self.regionMonitoringActivityIndicator stopAnimating];
        [self.toggleRegionMonitoringButton setTitle:@"Start Region Monitoring" forState:UIControlStateNormal];
    }
    
    if ([beaconController isRanging]) {
        [self.rangingActivityIndicator startAnimating];
        [self.toggleRangingButton setTitle:@"Stop Ranging" forState:UIControlStateNormal];
    } else {
        [self.rangingActivityIndicator stopAnimating];
        [self.toggleRangingButton setTitle:@"Start Ranging" forState:UIControlStateNormal];
    }
    
    self.regionMonitoringLogTextView.text = [[[[BIBeaconController sharedBeaconController] regionMonitoringLog] messages] firstObject];
    self.rangingLogTextView.text = [[[[BIBeaconController sharedBeaconController] rangingLog] messages] firstObject];
}

- (NSString *)_locationServicesStatusText
{
    CLAuthorizationStatus status = [BIBeaconManager locationServicesAuthorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorized: return @"authorized";
        case kCLAuthorizationStatusNotDetermined: return @"not determined";
        case kCLAuthorizationStatusDenied: return @"denied";
        case kCLAuthorizationStatusRestricted: return @"restricted";
        default: return @"unknown";
    }
}

- (NSString *)_regionMonitoringStatusText
{
    return [BIBeaconManager isBeaconRegionMonitoringAvailable] ? @"available" : @"not available";
}

- (NSString *)_rangingStatusText
{
    return [BIBeaconManager isBeaconRangingAvailable] ? @"available" : @"not available";
}

@end
