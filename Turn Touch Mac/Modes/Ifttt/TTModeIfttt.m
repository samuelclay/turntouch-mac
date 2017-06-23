//
//  TTModeIfttt.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/12/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIfttt.h"
#import "AFNetworking.h"

@implementation TTModeIfttt

NSString *const kIftttUserIdKey = @"TT:IFTTT:shared_user_id";
NSString *const kIftttDeviceIdKey = @"TT:IFTTT:device_id";
NSString *const kIftttIsActionSetup = @"isActionSetup";
NSString *const kIftttTapType = @"tapType";

static TTIftttState iftttState;

@synthesize delegate;

- (instancetype)init {
    if (self = [super init]) {
        [self.delegate changeState:TTModeIfttt.iftttState withMode:self];
    }
    
    return self;
}


#pragma mark - Mode

+ (NSString *)title {
    return @"IFTTT";
}

+ (NSString *)description {
    return @"Buttons for If This Then That";
}

+ (NSString *)imageName {
    return @"mode_ifttt.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModeIftttTriggerAction",
             ];
}

#pragma mark - Action Titles

- (NSString *)titleTTModeIftttTriggerAction {
    return @"Trigger action";
}

#pragma mark - Action Images

- (NSString *)imageTTModeIftttTriggerAction {
    return @"trigger";
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModeIftttTriggerAction";
}
- (NSString *)defaultEast {
    return @"TTModeIftttTriggerAction";
}
- (NSString *)defaultWest {
    return @"TTModeIftttTriggerAction";
}
- (NSString *)defaultSouth {
    return @"TTModeIftttTriggerAction";
}

#pragma mark - Action methods

- (void)runTTModeIftttTriggerAction:(TTModeDirection)direction {
    NSLog(@"Running runTTModeIftttTriggerAction");
    [self trigger:NO];
}

- (void)doubleRunTTModeIftttTriggerAction:(TTModeDirection)direction {
    NSLog(@"Running doublerunTTModeIftttTriggerAction");
    [self trigger:YES];
}

- (void)trigger:(BOOL)doubleTap {
    
}

#pragma mark - Wemo devices
@end
