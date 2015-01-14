//
//  TTDiamond.h
//  Turn Touch App
//
//  Created by Samuel Clay on 8/21/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTModeDirection.h"
#import "TTMode.h"

@class TTMode;

@interface TTModeMap : NSObject {

}

@property (nonatomic, assign) TTModeDirection activeModeDirection;
@property (nonatomic, assign) TTModeDirection selectedModeDirection;
@property (nonatomic, assign) TTModeDirection inspectingModeDirection;
@property (nonatomic, assign) TTModeDirection hoverModeDirection;
@property (nonatomic, assign) BOOL openedModeChangeMenu;
@property (nonatomic, assign) BOOL openedActionChangeMenu;
@property (nonatomic) TTMode *selectedMode;
@property (nonatomic) TTMode *northMode;
@property (nonatomic) TTMode *eastMode;
@property (nonatomic) TTMode *westMode;
@property (nonatomic) TTMode *southMode;
@property (nonatomic) NSArray *availableModes;
@property (nonatomic) NSArray *availableActions;

- (void)reset;
- (void)runActiveButton;
- (NSString *)directionName:(TTModeDirection)direction;
- (void)changeDirection:(TTModeDirection)direction toMode:(NSString *)modeClassName;
- (void)changeDirection:(TTModeDirection)direction toAction:(NSString *)actionClassName;
- (void)changeModeOption:(NSString *)optionName to:(id)optionValue;
- (void)changeActionOption:(NSString *)optionName to:(id)optionValue;
- (NSString *)modeOptionValue:(NSString *)optionName;
- (NSString *)actionOptionValue:(NSString *)optionName;
- (NSString *)actionOptionValue:(NSString *)optionName inDirection:(TTModeDirection)direction;
- (void)toggleInspectingModeDirection:(TTModeDirection)direction;
- (void)toggleHoverModeDirection:(TTModeDirection)direction hovering:(BOOL)hovering;

@end
