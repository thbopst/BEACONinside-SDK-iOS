//
//  BIActivityStatusCell.h
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 26/03/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

@import UIKit;

@interface BIActivityStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
