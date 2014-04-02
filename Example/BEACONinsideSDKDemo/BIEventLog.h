//
//  BIEventLog.h
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 01/04/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BIEventLog : NSObject

@property (nonatomic, strong, readonly) NSArray *messages;

- (void)logEvent:(NSString *)message;

@end
