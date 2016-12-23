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

NSString *const kHueRoom = @"hueRoom";
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
    
    NSString *sceneSelectedIdentifier = [self.action optionValue:kHueScene inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *doubleTapSceneSelectedIdentifier = [self.action optionValue:kDoubleTapHueScene inDirection:appDelegate.modeMap.inspectingModeDirection];
    NSString *sceneSelected;
    NSString *doubleTapSceneSelected;
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    [scenePopup removeAllItems];
    [doubleTapScenePopup removeAllItems];
    
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
        [self.action changeActionOption:kHueScene to:sceneIdentifier];
    } else if (sender == doubleTapScenePopup) {
        [self.action changeActionOption:kDoubleTapHueScene to:sceneIdentifier];
    }
}

- (IBAction)didClickRefresh:(id)sender {
    [spinner setHidden:NO];
    [doubleTapSpinner setHidden:NO];
    [refreshButton setHidden:YES];
    [doubleTapRefreshButton setHidden:YES];
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    [bridgeSendAPI getAllScenesWithCompletionHandler:^(NSDictionary *dictionary, NSArray *errors) {
        [self drawScenes];
    }];
}

@end
