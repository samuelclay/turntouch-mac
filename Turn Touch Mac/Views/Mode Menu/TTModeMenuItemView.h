//
//  TTModeMenuItemView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/28/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTMenuType.h"

@class TTAppDelegate;

@interface TTModeMenuItemView : NSView

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) NSString *modeName;

- (void)setModeName:(NSString *)_modeName;
- (void)setActionName:(NSString *)_actionName;

- (void)setAddModeName:(NSDictionary *)_modeName;
- (void)setAddActionName:(NSDictionary *)_actionName;
- (void)setChangeActionName:(NSDictionary *)_actionName;

@end
