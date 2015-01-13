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

- (IBAction)randomizeColoursOfConnectLights:(id)sender{
    [self.randomLightsButton setEnabled:NO];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:[NSNumber numberWithInt:arc4random() % MAX_HUE]];
        [lightState setBrightness:[NSNumber numberWithInt:254]];
        [lightState setSaturation:[NSNumber numberWithInt:254]];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
            [self.randomLightsButton setEnabled:YES];
        }];
    }
}

@end
