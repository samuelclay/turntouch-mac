//
//  CBPeripheral+Extras.m
//  Turn Touch Mac
//
//  Created by David Sinclair on 2019-04-23.
//  Copyright © 2019 Turn Touch. All rights reserved.
//

#import "CBPeripheral+Extras.h"

@implementation CBPeripheral (Extras)

/// Temporary workaround for `identifier` not being available in the SDK prior to 10.13 (though it is actually implemented).
- (NSUUID *)tt_identifier {
    if (@available(macOS 10.13, *)) {
        return self.identifier;
    } else {
        return [self valueForKey:@"identifier"];
    }
}

/// Get the peripheral identifier as a string.
- (NSString *)tt_identifierString {
    return self.tt_identifier.UUIDString;
}

@end
