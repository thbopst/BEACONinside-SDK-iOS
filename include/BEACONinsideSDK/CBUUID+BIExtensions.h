//
//  CBUUID+BIExtensions.h
//  BEACONinsideSDK
//
//  Copyright (c) 2014 BEACONinside. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBUUID (BIExtensions)

/**
 *  Returns a string representation of the UUID.
 *
 *  Added to make the functionality of -[CBUUID UUIDString] that Apple added in iOS 7.1 available in iOS 7.0.
 *  On iOS 7.1 and later, this method just returns the value of -[CBUUID UUIDString]. On iOS 7.0, we use a custom
 *  implementation that returns the same format.
 *
 *  @return The UUID as a string.
 */
- (NSString *)bi_UUIDString;

@end
