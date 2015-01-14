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
    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    [scenePopup removeAllItems];
    for (PHScene *scene in cache.scenes.allValues) {
        NSLog(@"Scene: %@ %@", scene, scene.name);
        [scenes addObject:@{@"name": scene.name, @"identifier": scene.identifier}];
    }

    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [scenes sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *scene in scenes) {
        NSLog(@"Adding %@", scene[@"name"]);
        [scenePopup addItemWithTitle:scene[@"name"]];
    }
}

#pragma mark - Actions

- (IBAction)didChangeScene:(id)sender {
    
}

- (IBAction)didChangeDuration:(id)sender {
    NSInteger duration = durationSlider.integerValue;

    NSString *durationString;
    if (duration == 0)      durationString = @"Immediate";
    else if (duration == 1) durationString = @"1 minute";
    else                    durationString = [NSString stringWithFormat:@"%@ minutes", @(duration)];
    
    [durationLabel setStringValue:durationString];
}

@end
