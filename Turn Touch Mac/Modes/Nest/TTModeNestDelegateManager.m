//
//  TTModeNestDelegateManager.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/22/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeNestDelegateManager.h"

@implementation TTModeNestDelegateManager

@synthesize delegates;

- (instancetype)init {
    if (self = [super init]) {
        delegates = [NSMutableArray array];
    }
    
    return self;
}

- (void)thermostatValuesChanged:(Thermostat *)thermostat {
    for (id<NestThermostatManagerDelegate>delegate in delegates) {
        [delegate thermostatValuesChanged:thermostat];
    }
}

- (void)structureUpdated:(NSDictionary *)structure {
    for (id<NestStructureManagerDelegate>delegate in delegates) {
        [delegate structureUpdated:structure];
    }
}

@end
