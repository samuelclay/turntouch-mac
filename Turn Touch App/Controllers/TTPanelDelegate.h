//
//  TTPanelDelegate.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/1/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTStatusItemView.h"

@class TTPanelController;

@protocol TTPanelControllerDelegate <NSObject>

@optional

- (TTStatusItemView *)statusItemViewForPanelController:(TTPanelController *)controller;

@end
