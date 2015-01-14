//
//  TTModeHueSceneEarlyEvening.m
//  Turn Touch App
//
//  Created by Samuel Clay on 1/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHueSceneEarlyEveningOptions.h"
#import <HueSDK_OSX/HueSDK.h>

@interface TTModeHueSceneEarlyEveningOptions ()

@end

@implementation TTModeHueSceneEarlyEveningOptions

@synthesize scenePopup;
@synthesize durationLabel;
@synthesize durationSlider;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    [scenePopup removeAllItems];
    
    for (PHScene *scene in cache.scenes.allValues) {
        NSLog(@"Scnee: %@ %@", scene, scene.name);
        [scenePopup addItemWithTitle:scene.name];
    }
}

#pragma mark - Actions

- (IBAction)didChangeScene:(id)sender {
    
}

- (IBAction)didChangeDuration:(id)sender {
    
}

@end
