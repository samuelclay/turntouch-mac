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

@interface TTModeMenuItemView : NSView {
    TTAppDelegate *appDelegate;
    TTMenuType menuType;

    TTMode *activeMode;
    Class modeClass;
    NSString *modeTitle;
    NSImage *modeImage;
    NSDictionary *modeAttributes;
    CGSize textSize;


    BOOL hoverActive;
    BOOL mouseDownActive;
}

@property (nonatomic) NSString *modeName;

- (void)setModeName:(NSString *)_modeName;
- (void)setActionName:(NSString *)_actionName;

- (void)setAddModeName:(NSString *)_modeName;
- (void)setAddActionName:(NSString *)_actionName;

@end
