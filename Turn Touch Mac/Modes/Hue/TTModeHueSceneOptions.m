//
//  TTModeHueSceneEarlyEvening.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/13/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHueSceneOptions.h"
#import "TTModeHuePicker.h"
#import <HueSDK_OSX/HueSDK.h>

NSString *const kHueRoom = @"hueRoom";
NSString *const kHueScene = @"hueScene";
NSString *const kDoubleTapHueScene = @"doubleTapHueScene";

@interface TTModeHueSceneOptions ()

@end

@implementation TTModeHueSceneOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self drawScenes];
}

- (void)drawScenes {
    [self.spinner setHidden:YES];
    [self.roomSpinner setHidden:YES];
    [self.doubleTapSpinner setHidden:YES];
    [self.refreshButton setHidden:NO];
    [self.roomRefreshButton setHidden:NO];
    [self.doubleTapRefreshButton setHidden:NO];
    
    NSString *sceneSelectedIdentifier = [self.action optionValue:kHueScene inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *doubleTapSceneSelectedIdentifier = [self.action optionValue:kDoubleTapHueScene inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *sceneSelected;
    NSString *doubleTapSceneSelected;
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    [self.scenePopup removeAllItems];
    [self.doubleTapScenePopup removeAllItems];
    
    for (PHScene *scene in cache.scenes.allValues) {
        NSLog(@"Scene: %@ %@", scene.identifier, scene.name);
        [scenes addObject:@{@"name": scene.name, @"identifier": scene.identifier}];
    }
    
    if (!sceneSelectedIdentifier) {
        if ([self.action.actionName isEqualToString:@"TTModeHueSceneEarlyEvening"]) {
            sceneSelectedIdentifier = @"TT-ee-1";
        } else if ([self.action.actionName isEqualToString:@"TTModeHueSceneLateEvening"]) {
            sceneSelectedIdentifier = @"TT-le-1";
        } else {
            sceneSelectedIdentifier = @"TT-ee-1";
        }
        [self.action changeActionOption:kHueScene to:sceneSelectedIdentifier];
    }
    
    if (!doubleTapSceneSelectedIdentifier) {
        if ([self.action.actionName isEqualToString:@"TTModeHueSceneEarlyEvening"]) {
            doubleTapSceneSelectedIdentifier = @"TT-ee-2";
        } else if ([self.action.actionName isEqualToString:@"TTModeHueSceneLateEvening"]) {
            doubleTapSceneSelectedIdentifier = @"TT-le-2";
        } else {
            doubleTapSceneSelectedIdentifier = @"TT-ee-2";
        }
        [self.action changeActionOption:kDoubleTapHueScene to:doubleTapSceneSelectedIdentifier];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [scenes sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *scene in scenes) {
        [self.scenePopup addItemWithTitle:scene[@"name"]];
        [self.doubleTapScenePopup addItemWithTitle:scene[@"name"]];
        if ([scene[@"identifier"] isEqualToString:sceneSelectedIdentifier]) {
            sceneSelected = scene[@"name"];
        }
        if ([scene[@"identifier"] isEqualToString:doubleTapSceneSelectedIdentifier]) {
            doubleTapSceneSelected = scene[@"name"];
        }
        
    }
    if (sceneSelected) {
        [self.scenePopup selectItemWithTitle:sceneSelected];
    }
    if (doubleTapSceneSelected) {
        [self.doubleTapScenePopup selectItemWithTitle:doubleTapSceneSelected];
    }
}

#pragma mark - Actions

- (IBAction)didChangeScene:(id)sender {
    BOOL doubleTap = sender == self.doubleTapScenePopup;
    NSMenuItem *menuItem = [(doubleTap ? self.doubleTapScenePopup : self.scenePopup) selectedItem];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSString *sceneIdentifier;
    
    for (PHScene *scene in cache.scenes.allValues) {
        if ([scene.name isEqualToString:menuItem.title]) {
            sceneIdentifier = scene.identifier;
            break;
        }
    }
    
    if (sender == self.scenePopup) {
        [self.action changeActionOption:kHueScene to:sceneIdentifier];
    } else if (sender == self.doubleTapScenePopup) {
        [self.action changeActionOption:kDoubleTapHueScene to:sceneIdentifier];
    }
}

- (IBAction)didClickRefresh:(id)sender {
    [self.spinner setHidden:NO];
    [self.doubleTapSpinner setHidden:NO];
    [self.roomSpinner setHidden:NO];
    [self.refreshButton setHidden:YES];
    [self.roomRefreshButton setHidden:YES];
    [self.doubleTapRefreshButton setHidden:YES];
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI getAllScenesWithCompletionHandler:^(NSDictionary *dictionary, NSArray *errors) {
        [self drawScenes];
    }];
}

@end
