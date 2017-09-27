//
//  SonosManager.m
//  Sonos Controller
//
//  Created by Axel Möller on 14/01/14.
//  Copyright (c) 2014 Appreviation AB. All rights reserved.
//

#import "SonosManager.h"
#import "SonosController.h"
#import "SonosDiscover.h"

@implementation SonosManager

+ (SonosManager *)sharedInstance {
    static SonosManager *sharedInstanceInstance = nil;
    static dispatch_once_t p;
    dispatch_once(&p, ^{
        sharedInstanceInstance = [[self alloc] init];
    });
    return sharedInstanceInstance;
}

- (id)init {
    self = [super init];
    
    if(self){
        
        self.coordinators = [[NSMutableArray alloc] init];
        self.slaves = [[NSMutableArray alloc] init];
        
//        [self discoverControllers:nil];
    }
    
    return self;
}

- (NSMutableArray *)coordinators {
    return [_coordinators copy];
}

- (NSMutableArray *)slaves {
    return [_slaves copy];
}

- (NSArray *)allDevices {
    return [self.coordinators arrayByAddingObjectsFromArray:self.slaves];
}

- (void)discoverControllers:(void (^)(void))completion {
    [SonosDiscover discoverControllers:^(NSArray *devices){
        NSMutableArray *coordinators = [[NSMutableArray alloc] init];
        NSMutableArray *slaves = [[NSMutableArray alloc] init];
        
        // Save all devices
        for(SonosController *controller in devices) {
//            SonosController *controller = [[SonosController alloc] initWithIP:[device valueForKey:@"ip"] port:[[device valueForKey:@"port"] intValue]];
//            controller.group = device[@"group"];
//            controller.name = device[@"name"];
//            controller.uuid = device[@"uuid"];
//            controller.coordinator = [device[@"coordinator"] boolValue];
            if([controller isCoordinator]) {
                [coordinators addObject:controller];
            }
            else {
                [slaves addObject:controller];
            }
        }
        
        // Add slaves to masters
        for(SonosController *slave in slaves) {
            for(SonosController *coordinator in coordinators) {
                if([[coordinator group] isEqualToString:[slave group]]) {
                    [[coordinator slaves] addObject:slave];
                    break;
                }
            }
        }
        
        [self willChangeValueForKey:@"allDevices"];
        self.coordinators = coordinators;
        self.slaves = slaves;
        [self didChangeValueForKey:@"allDevices"];
        
        // Find current device (this implementation may change in the future)
        if([[self allDevices] count] > 0) {
            [self willChangeValueForKey:@"currentDevice"];
            self.currentDevice = [self.coordinators objectAtIndex:0];
            for(SonosController *controller in self.coordinators) {
                // If a coordinator is playing, make it the current device
                [controller playbackStatus:^(BOOL playing, NSDictionary *response, NSError *error){
                    if(playing) self.currentDevice = controller;
                }];
            }
            [self didChangeValueForKey:@"currentDevice"];
        }
        
        if (completion) {
            completion();
        }
    }];
}

@end
