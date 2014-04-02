//
//  BIChartViewController.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 24/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BIChartViewController.h"
#import <BEACONinsideSDK/BEACONinsideSDK.h>
#import <NCICharts/NCISimpleChartView.h>

// We chart the signals for up to five beacons (the first five we see)
// Any more beacons are ignored
static const NSInteger MaxSeriesCount = 5;

@interface BIChartViewController ()

@property (strong, nonatomic) NSMutableDictionary *beaconToSeriesIndexMapping;

@property (weak, nonatomic) UIView *chart1Container;
@property (weak, nonatomic) UIView *chart2Container;
@property (weak, nonatomic) UILabel *chart1Label;
@property (weak, nonatomic) UILabel *chart2Label;
@property (weak, nonatomic) NCISimpleChartView *smoothedSignalsChartView;
@property (weak, nonatomic) NCISimpleChartView *rawSignalsChartView;

@end

@implementation BIChartViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BIDidReceiveContinuousRangingUpdateNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _beaconToSeriesIndexMapping = [NSMutableDictionary dictionary];
    
    [self _setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didUpdateKnownBeacons:) name:@"BIDidReceiveContinuousRangingUpdateNotification" object:nil];
}

- (void)_setupViews
{
    NCISimpleChartView *smoothedSignalsChartView = nil;
    UIView *chart1Container = [self _chartWithTitle:@"Smoothed Signals" chartView:&smoothedSignalsChartView];
    [self.view addSubview:chart1Container];
    self.chart1Container = chart1Container;
    self.smoothedSignalsChartView = smoothedSignalsChartView;
    
    NCISimpleChartView *rawSignalsChartView = nil;
    UIView *chart2Container = [self _chartWithTitle:@"Raw Signals" chartView:&rawSignalsChartView];
    [self.view addSubview:chart2Container];
    self.chart2Container = chart2Container;
    self.rawSignalsChartView = rawSignalsChartView;
    
    NSDictionary *viewsDict = @{ @"topLayoutGuide": self.topLayoutGuide, @"bottomLayoutGuide": self.bottomLayoutGuide, @"container1": self.chart1Container, @"container2": self.chart2Container };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLayoutGuide]-20-[container1][container2(==container1)]-10-[bottomLayoutGuide]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container1]|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container2]|" options:0 metrics:nil views:viewsDict]];
}

- (UIView *)_chartWithTitle:(NSString *)title chartView:(NCISimpleChartView * __autoreleasing *)outChartView
{
    UIView *chartContainer = [[UIView alloc] initWithFrame:CGRectZero];
    chartContainer.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont boldSystemFontOfSize:15.0];
    label.text = title;
    [chartContainer addSubview:label];
    
    // We chart the signals for up to five beacons (the first five we see)
    // Any more beacons are ignored
    NSArray *lineColors = @[ [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], [UIColor magentaColor] ];
    NSArray *lineWidths = @[ @1.0, @1.0, @1.0, @1.0, @1.0 ];
    NSArray *fillSeries = @[ @NO, @NO, @NO, @NO, @NO ];
    NSDictionary *chartOptions = @{ nciIsFill: fillSeries, nciLineColors: lineColors, nciLineWidths: lineWidths };
    
    NCISimpleChartView *lineChartView = [[NCISimpleChartView alloc] initWithFrame:CGRectZero andOptions:chartOptions];
    lineChartView.translatesAutoresizingMaskIntoConstraints = NO;
    lineChartView.nciXLabelRenderer = ^(double value) {
        return @"";
    };
    *outChartView = lineChartView;
    [chartContainer addSubview:lineChartView];
    
    NSDictionary *viewsDict = @{ @"label": label, @"chart": lineChartView };
    [chartContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label][chart]|" options:0 metrics:nil views:viewsDict]];
    [chartContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[label]-20-|" options:0 metrics:nil views:viewsDict]];
    [chartContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[chart]-5-|" options:0 metrics:nil views:viewsDict]];
    
    return chartContainer;
}

- (void)_didUpdateKnownBeacons:(NSNotification *)notification
{
    NSArray *beacons = [notification object];
    [self _assignSeriesIndexToBeacons:beacons upToMaxSeriesCount:MaxSeriesCount];

    [self _updateLineChart:self.smoothedSignalsChartView withBeacons:beacons keyPath:@"smoothedSignals"];
    [self _updateLineChart:self.rawSignalsChartView withBeacons:beacons keyPath:@"rawSignals"];
}

- (void)_assignSeriesIndexToBeacons:(NSArray *)beacons upToMaxSeriesCount:(NSUInteger)maxSeriesCount
{
    NSUInteger currentSeriesCount = [self.beaconToSeriesIndexMapping count];
    if (currentSeriesCount < maxSeriesCount) {
        NSUInteger __block nextSeriesIndex = currentSeriesCount;
        [beacons enumerateObjectsUsingBlock:^(BIBeacon *beacon, NSUInteger idx, BOOL *stop) {
            if (self.beaconToSeriesIndexMapping[beacon] == nil) {
                self.beaconToSeriesIndexMapping[beacon] = @(nextSeriesIndex);
                nextSeriesIndex++;
                if (nextSeriesIndex >= maxSeriesCount) {
                    *stop = YES;
                }
            }
        }];
    }
}

- (void)_updateLineChart:(NCISimpleChartView *)lineChart withBeacons:(NSArray *)beacons keyPath:(NSString *)keyPath
{
    if ([beacons count] == 0) {
        return;
    }
    
    [lineChart.chartData removeAllObjects];
    
    int numOfPoints = 100;
    for (int index = 0; index < numOfPoints; index ++) {
        NSMutableArray *signalValues = [NSMutableArray array];
        [self.beaconToSeriesIndexMapping enumerateKeysAndObjectsUsingBlock:^(BIBeacon *beacon, NSNumber *lineIndex, BOOL *stop) {
            [signalValues addObject:[NSNull null]];
        }];
        
        NSMutableSet *beaconsToUpdate = [NSMutableSet setWithArray:[self.beaconToSeriesIndexMapping allKeys]];

        for (BIBeacon *beacon in beacons) {
            NSInteger lineIndex = -1;
            [beaconsToUpdate removeObject:beacon];
            if (self.beaconToSeriesIndexMapping[beacon]) {
                lineIndex = [self.beaconToSeriesIndexMapping[beacon] integerValue];
            }
            
            if (lineIndex >= 0) {
                NSArray *signals = [beacon valueForKeyPath:keyPath];
                NSInteger signalIndex = (NSInteger)index - numOfPoints + (NSInteger)[signals count];
                if (signalIndex >= 0) {
                    BIBeaconSignal *signal = signals[(NSUInteger)signalIndex];
                    if (signal.proximity == CLProximityUnknown) {
                        signalValues[lineIndex] = @(-100);
                    } else {
                        signalValues[lineIndex] = @(signal.RSSI);
                    }
                } else {
                    signalValues[lineIndex] = @(-100);
                }
            }
        }
        
        [beaconsToUpdate enumerateObjectsUsingBlock:^(BIBeacon *beacon, BOOL *stop) {
            NSInteger lineIndex = -1;
            if (self.beaconToSeriesIndexMapping[beacon]) {
                lineIndex = [self.beaconToSeriesIndexMapping[beacon] integerValue];
            }

            if (lineIndex >= 0) {
                signalValues[lineIndex] = @(-100);
            }
        }];
        
        [lineChart addPoint:index val:signalValues];
    }
    [lineChart drawChart];
}

@end
