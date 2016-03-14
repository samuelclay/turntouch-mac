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

@interface TTModalBarButton : TTFooterView {
    TTAppDelegate *appDelegate;
    TTModalPairing modalPairing;
    TTModalFTUX modalFTUX;
    NSTrackingArea *trackingArea;
}

@property (nonatomic) IBOutlet NSTextField *buttonLabel;
@property (nonatomic) IBOutlet NSImageView *chevronImage;

- (instancetype)initWithPairing:(TTModalPairing)_modalPairing;
- (instancetype)initWithFTUX:(TTModalFTUX)_modalFTUX;

@end
