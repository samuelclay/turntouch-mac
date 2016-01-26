//
//  TTMode.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAppDelegate.h"
#import "TTModeProtocol.h"
#import "TTAction.h"

@class TTAppDelegate;
@class TTAction;

typedef enum {
    ACTION_LAYOUT_TITLE = 0,
    ACTION_LAYOUT_IMAGE_TITLE = 1
} ActionLayout;

@interface TTMode : NSObject <TTModeProtocol> {
    TTAppDelegate *appDelegate;
    TTModeDirection modeDirection;
}

@property (nonatomic) TTModeDirection modeDirection;
@property (nonatomic) TTAction *action;

- (void)activate:(TTModeDirection)_modeDirection;
- (void)runDirection:(TTModeDirection)direction;
- (void)runDoubleDirection:(TTModeDirection)direction;
- (NSString *)titleInDirection:(TTModeDirection)direction buttonMoment:(TTButtonMoment)buttonMoment;
- (NSString *)titleForAction:(NSString *)actionName buttonMoment:(TTButtonMoment)buttonMoment;
- (NSString *)actionTitleInDirection:(TTModeDirection)direction buttonMoment:(TTButtonMoment)buttonMoment;
- (NSString *)imageNameInDirection:(TTModeDirection)direction;
- (NSString *)imageNameForAction:(NSString *)actionName;
- (NSString *)imageNameForActionHudInDirection:(TTModeDirection)direction;
- (ActionLayout)layoutInDirection:(TTModeDirection)direction;
- (NSView *)viewForLayout:(TTModeDirection)direction withRect:(NSRect)rect;
- (NSString *)actionNameInDirection:(TTModeDirection)direction;
- (NSInteger)progressInDirection:(TTModeDirection)direction;
- (void)changeDirection:(TTModeDirection)direction toAction:(NSString *)actionClassName;
- (void)switchSelectedModeTo:(TTMode *)mode;

@end
