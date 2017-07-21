//
//  TTModeSonosConnecting.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/18/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModeSonos.h"
#import "TTOptionsDetailViewController.h"

@interface TTModeSonosConnecting : TTOptionsDetailViewController

@property (nonatomic, strong) TTModeSonos *modeSonos;
@property (nonatomic) IBOutlet NSTextField *progressMessage;
@property (nonatomic) IBOutlet NSButton *cancelButton;
@property (nonatomic,weak) IBOutlet NSProgressIndicator *progressIndicator;

- (void)setConnectingWithMessage:(NSString*)message;
- (IBAction)clickCancelButton:(id)sender;

@end
