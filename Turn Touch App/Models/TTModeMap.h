//
//  TTDiamond.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTMode.h"
#import <Cocoa/Cocoa.h>

typedef enum {
    NO_DIRECTION = 0,
    NORTH = 1,
    EAST = 2,
    WEST = 3,
    SOUTH = 4
} TTModeDirection;

@interface TTModeMap : NSObject

@property (nonatomic, assign) TTModeDirection activeModeDirection;
@property (nonatomic, assign) TTModeDirection selectedModeDirection;
@property (nonatomic, assign) TTModeDirection inspectingModeDirection;
@property (nonatomic) TTMode *selectedMode;
@property (nonatomic) TTMode *northMode;
@property (nonatomic) TTMode *eastMode;
@property (nonatomic) TTMode *westMode;
@property (nonatomic) TTMode *southMode;
@property (nonatomic) NSArray *availableModes;

- (void)reset;
- (void)runActiveButton;
- (NSArray *)availableModeTitles;
- (NSArray *)availableModeClassNames;
- (void)changeDirection:(TTModeDirection)direction toMode:(NSString *)modeClassName;
- (void)toggleInspectingModeDirection:(TTModeDirection)direction;

@end
