//
//  TTOptionsDetailView.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 5/12/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTAppDelegate.h"
#import "TTTabView.h"

@class TTAppDelegate;

@interface TTOptionsDetailView : NSView
<NSTabViewDelegate>

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) IBOutlet TTTabView *tabView;
@property (nonatomic) TTMenuType menuType;

@end
