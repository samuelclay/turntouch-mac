//
//  TTDiamond.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeDirection.h"
#import "TTMode.h"
#import "TTBatchActions.h"

@class TTMode;
@class TTBatchActions;

@interface TTModeMap : NSObject {
    BOOL waitingForDoubleClick;
}

@property (nonatomic, assign) TTModeDirection activeModeDirection;
@property (nonatomic, assign) TTModeDirection selectedModeDirection;
@property (nonatomic, assign) TTModeDirection inspectingModeDirection;
@property (nonatomic, assign) TTModeDirection hoverModeDirection;
@property (nonatomic, assign) NSString *tempModeName;
@property (nonatomic, assign) BOOL openedModeChangeMenu;
@property (nonatomic, assign) BOOL openedActionChangeMenu;
@property (nonatomic, assign) BOOL openedAddActionChangeMenu;
@property (nonatomic) TTMode *selectedMode;
@property (nonatomic) TTMode *northMode;
@property (nonatomic) TTMode *eastMode;
@property (nonatomic) TTMode *westMode;
@property (nonatomic) TTMode *southMode;
@property (nonatomic) TTMode *tempMode;
@property (nonatomic) TTBatchActions *batchActions;
@property (nonatomic) NSArray *availableModes;
@property (nonatomic) NSArray *availableActions;
@property (nonatomic) NSArray *availableAddModes;
@property (nonatomic) NSArray *availableAddActions;

- (void)activateTimers;
- (void)switchMode;
- (void)reset;
- (void)runActiveButton;
- (void)runDoubleButton:(TTModeDirection)direction;
- (NSString *)directionName:(TTModeDirection)direction;
- (TTMode *)modeInDirection:(TTModeDirection)direction;
- (void)changeDirection:(TTModeDirection)direction toMode:(NSString *)modeClassName;
- (void)changeDirection:(TTModeDirection)direction toAction:(NSString *)actionClassName;
- (void)addBatchAction:(NSString *)actionName;
- (NSArray *)selectedModeBatchActions:(TTModeDirection)direction;
- (void)changeModeOption:(NSString *)optionName to:(id)optionValue;
- (void)changeMode:(TTMode *)mode option:(NSString *)optionName to:(id)optionValue;
- (void)changeActionOption:(NSString *)optionName to:(id)optionValue;
- (void)changeMode:(TTMode *)mode actionOption:(NSString *)optionName to:(id)optionValue;
- (id)modeOptionValue:(NSString *)optionName;
- (id)mode:(TTMode *)mode optionValue:(NSString *)optionName;
- (id)actionOptionValue:(NSString *)optionName;
- (id)actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction;
- (id)mode:(TTMode *)mode actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction;
- (void)toggleInspectingModeDirection:(TTModeDirection)direction;
- (void)toggleHoverModeDirection:(TTModeDirection)direction hovering:(BOOL)hovering;

@end
