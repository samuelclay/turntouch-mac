//
//  TTModeIftttConnected.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 6/22/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeIfttt.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeIftttConnected : TTOptionsDetailViewController {
    NSPopover *authPopover;
}

@property (nonatomic, strong) TTModeIfttt *modeIfttt;

- (IBAction)clickEditButton:(id)sender;

@end
