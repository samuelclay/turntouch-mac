/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "TTModeHueOptions.h"
#import "TTModeHueConnected.h"
#import <HueSDK_OSX/HueSDK.h>
#import "TTAppDelegate.h"
#import "TTModeHue.h"

#define MAX_HUE 65535

@interface TTModeHueConnected ()
    @property (nonatomic,weak) IBOutlet NSTextField *bridgeMacLabel;
    @property (nonatomic,weak) IBOutlet NSTextField *bridgeIpLabel;
    @property (nonatomic,weak) IBOutlet NSTextField *bridgeLastHeartbeatLabel;
    @property (nonatomic,weak) IBOutlet NSButton *randomLightsButton;
@end

@implementation TTModeHueConnected

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)selectOtherBridge:(id)sender{
    [self.modeHue searchForBridgeLocal];
}

@end
