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
    NORTH = 1,
    EAST = 2,
    WEST = 3,
    SOUTH = 4
} TTModeDirection;

@interface TTModeMap : NSObject

@property (nonatomic, assign) TTModeDirection activeModeDirection;
@property (nonatomic, assign) TTModeDirection selectedModeDirection;
@property (nonatomic) TTMode *selectedMode;
@property (nonatomic) TTMode *northMode;
@property (nonatomic) TTMode *eastMode;
@property (nonatomic) TTMode *westMode;
@property (nonatomic) TTMode *southMode;

- (void)runActiveButton;

@end
