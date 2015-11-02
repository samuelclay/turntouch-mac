//
//  TTModeHueSceneEarlyEvening.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueSceneOptions.h"
#import <HueSDK_OSX/HueSDK.h>

NSString *const kHueScene = @"hueScene";
NSString *const kDoubleTapHueScene = @"doubleTapHueScene";

@interface TTModeHueSceneOptions ()

@end

@implementation TTModeHueSceneOptions

@synthesize scenePopup;
@synthesize spinner;
@synthesize refreshButton;
@synthesize doubleTapScenePopup;
@synthesize doubleTapSpinner;
@synthesize doubleTapRefreshButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self drawScenes];
}

- (void)drawScenes {
    [spinner setHidden:YES];
    [doubleTapSpinner setHidden:YES];
    [refreshButton setHidden:NO];
    [doubleTapRefreshButton setHidden:NO];
    
    NSString *sceneSelectedIdentifier = [appDelegate.modeMap actionOptionValue:kHueScene];
    NSString *doubleTapSceneSelectedIdentifier = [appDelegate.modeMap actionOptionValue:kDoubleTapHueScene];
    NSString *sceneSelected;
    NSString *doubleTapSceneSelected;
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    [scenePopup removeAllItems];
    for (PHScene *scene in cache.scenes.allValues) {
        NSLog(@"Scene: %@ %@", scene.identifier, scene.name);
        [scenes addObject:@{@"name": scene.name, @"identifier": scene.identifier}];
    }

    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [scenes sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *scene in scenes) {
        [scenePopup addItemWithTitle:scene[@"name"]];
        [doubleTapScenePopup addItemWithTitle:scene[@"name"]];
        if ([scene[@"identifier"] isEqualToString:sceneSelectedIdentifier]) {
            sceneSelected = scene[@"name"];
        }
        if ([scene[@"identifier"] isEqualToString:doubleTapSceneSelectedIdentifier]) {
            doubleTapSceneSelected = scene[@"name"];
        }
        
    }
    if (sceneSelected) {
        [scenePopup selectItemWithTitle:sceneSelected];
    }
    if (doubleTapSceneSelected) {
        [doubleTapScenePopup selectItemWithTitle:doubleTapSceneSelected];
    }
}

#pragma mark - Actions

- (IBAction)didChangeScene:(id)sender {
    BOOL doubleTap = sender == doubleTapScenePopup;
    NSMenuItem *menuItem = [(doubleTap ? doubleTapScenePopup : scenePopup) selectedItem];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSString *sceneIdentifier;
    
    for (PHScene *scene in cache.scenes.allValues) {
        if ([scene.name isEqualToString:menuItem.title]) {
            sceneIdentifier = scene.identifier;
            break;
        }
    }
    
    if (sender == scenePopup) {
        [appDelegate.modeMap changeActionOption:kHueScene to:sceneIdentifier];
    } else if (sender == doubleTapScenePopup) {
        [appDelegate.modeMap changeActionOption:kDoubleTapHueScene to:sceneIdentifier];
    }
}

- (IBAction)didClickRefresh:(id)sender {
    [spinner setHidden:NO];
    [refreshButton setHidden:YES];
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI getAllScenesWithCompletionHandler:^(NSDictionary *dictionary, NSArray *errors) {
        [self drawScenes];
    }];
}

@end
