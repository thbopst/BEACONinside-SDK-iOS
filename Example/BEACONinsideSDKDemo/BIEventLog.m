//
//  BIEventLog.m
//  BEACONinsideSDKDemo
//
//  Created by Ole Begemann on 01/04/14.
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import "BIEventLog.h"

@interface BIEventLog ()

@property (nonatomic, strong) NSMutableArray *mutableMessages;

@end


@implementation BIEventLog

- (id)init
{
    self = [super init];
    if (self) {
        _mutableMessages = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)messages
{
    return [NSArray arrayWithArray:self.mutableMessages];
}

- (void)logEvent:(NSString *)message
{
    NSString *timestamp = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle];
    NSString *messageWithTimestamp = [NSString stringWithFormat:@"%@: %@", timestamp, message];
    [self.mutableMessages insertObject:messageWithTimestamp atIndex:0];
}

@end
