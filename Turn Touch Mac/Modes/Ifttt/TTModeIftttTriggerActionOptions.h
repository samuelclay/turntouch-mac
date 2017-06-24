//
//  TTModeIftttTriggerActionOptions.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "TTAppDelegate.h"
#import "TTModeIfttt.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeIftttTriggerActionOptions : TTOptionsDetailViewController <WebResourceLoadDelegate> {
    
}

@property (nonatomic) TTModeIfttt *modeIfttt;
@property (nonatomic) NSPopover *authPopover;

- (IBAction)clickRecipeButton:(id)sender;

@end
