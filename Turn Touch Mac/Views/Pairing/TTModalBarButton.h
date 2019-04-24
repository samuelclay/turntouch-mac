//
//  TTModalBarButton.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TTPanelStates.h"
#import "TTFooterView.h"
#import "TTAppDelegate.h"

@interface TTModalBarButton : TTFooterView

@property (nonatomic, weak) TTAppDelegate *appDelegate;
@property (nonatomic) IBOutlet NSTextField *buttonLabel;
@property (nonatomic) IBOutlet NSImageView *chevronImage;

- (void)setPagePairing:(TTModalPairing)_modalPairing;
- (void)setPageFTUX:(TTModalFTUX)_modalFTUX;
- (void)setPageSupport:(TTModalSupport)_modalSupport;

@end
