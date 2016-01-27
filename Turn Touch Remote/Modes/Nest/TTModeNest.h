//
//  TTModeNest.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/14/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import "NestThermostatManager.h"
#import "NestStructureManager.h"


typedef enum TTNestState : NSUInteger {
    NEST_STATE_NOT_CONNECTED,
    NEST_STATE_CONNECTING,
    NEST_STATE_CONNECTED
} TTNestState;

@class TTModeNest;

@protocol TTModeNestDelegate <NSObject>
@required

- (void)changeState:(TTNestState)nestState withMode:(TTModeNest *)modeNest;
- (void)updateThermostat:(Thermostat *)thermostat;
@end


@interface TTModeNest : TTMode <NestThermostatManagerDelegate, NestStructureManagerDelegate>

extern NSString *const kNestThermostat;
extern NSString *const kNestSetTemperature;

//@property (nonatomic, strong) NestThermostatManager *nestThermostatManager;
//@property (nonatomic, strong) NestStructureManager *nestStructureManager;
//@property (nonatomic, strong) NSDictionary *currentStructure;
@property (nonatomic, weak) id <TTModeNestDelegate> delegate;
@property (nonatomic) TTNestState nestState;

- (NSDictionary *)currentStructure;
- (void)beginConnectingToNest;
- (void)cancelConnectingToNest;
- (void)subscribeToThermostat:(Thermostat *)thermostat;
- (Thermostat *)selectedThermostat;

@end
