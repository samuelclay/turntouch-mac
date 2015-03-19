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

@class TTAppDelegate;

typedef enum {
    ACTION_LAYOUT_TITLE = 0,
    ACTION_LAYOUT_IMAGE_TITLE = 1
} ActionLayout;

@interface TTMode : NSObject <TTModeProtocol> {
    TTAppDelegate *appDelegate;
    TTModeDirection modeDirection;
}

@property (nonatomic) TTModeDirection modeDirection;

- (void)activate:(TTModeDirection)_modeDirection;
- (void)runDirection:(TTModeDirection)direction;
- (NSString *)titleInDirection:(TTModeDirection)direction;
- (NSString *)titleForAction:(NSString *)actionName;
- (NSString *)actionTitleInDirection:(TTModeDirection)direction;
- (NSString *)imageNameInDirection:(TTModeDirection)direction;
- (NSString *)imageNameForAction:(NSString *)actionName;
- (ActionLayout)layoutInDirection:(TTModeDirection)direction;
- (NSView *)viewForLayout:(TTModeDirection)direction withRect:(NSRect)rect;
- (NSString *)actionNameInDirection:(TTModeDirection)direction;
- (NSInteger)progressInDirection:(TTModeDirection)direction;
- (void)changeDirection:(TTModeDirection)direction toAction:(NSString *)actionClassName;

@end
