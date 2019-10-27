//
//  CBPeripheral+Extras.h
//  Turn Touch Mac
//
//  Created by David Sinclair on 2019-04-23.
//  Copyright © 2019 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>

NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (Extras)

/// Temporary workaround for `identifier` not being available in the SDK prior to 10.13 (though it is actually implemented).
@property (nonatomic, readonly)NSUUID *tt_identifier;

/// Get the peripheral identifier as a string.
@property (nonatomic, readonly) NSString *tt_identifierString;

@end

NS_ASSUME_NONNULL_END
