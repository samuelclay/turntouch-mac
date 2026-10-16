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

    TTHueResourceCache *cache = [TTModeHue resourceCache];
    NSMutableArray *scenes = [[NSMutableArray alloc] init];
    [self.scenePopup removeAllItems];
    [self.doubleTapScenePopup removeAllItems];

    if (!cache) {
        NSLog(@"No Hue cache available");
        return;
    }

    for (NSString *sceneId in cache.scenes) {
        TTHueScene *scene = cache.scenes[sceneId];
        NSLog(@"Scene: %@ %@", scene.sceneId, scene.metadata.name);
        [scenes addObject:@{@"name": scene.metadata.name, @"identifier": scene.sceneId}];
    }

    if (!sceneSelectedIdentifier) {
        // Find scene by name for default selection
        NSString *defaultSceneName = nil;
        if ([self.action.actionName isEqualToString:@"TTModeHueSceneEarlyEvening"]) {
            defaultSceneName = @"Early evening";
        } else if ([self.action.actionName isEqualToString:@"TTModeHueSceneLateEvening"]) {
            defaultSceneName = @"Late evening";
        } else {
            defaultSceneName = @"Early evening";
        }

        for (NSString *sceneId in cache.scenes) {
            TTHueScene *scene = cache.scenes[sceneId];
            if ([scene.metadata.name isEqualToString:defaultSceneName]) {
                sceneSelectedIdentifier = scene.sceneId;
                break;
            }
        }

        if (sceneSelectedIdentifier) {
            [self.action changeActionOption:kHueScene to:sceneSelectedIdentifier];
        }
    }

    if (!doubleTapSceneSelectedIdentifier) {
        // Find scene by name for default double-tap selection
        NSString *defaultSceneName = nil;
        if ([self.action.actionName isEqualToString:@"TTModeHueSceneEarlyEvening"]) {
            defaultSceneName = @"Early evening 2";
        } else if ([self.action.actionName isEqualToString:@"TTModeHueSceneLateEvening"]) {
            defaultSceneName = @"Late evening 2";
        } else {
            defaultSceneName = @"Early evening 2";
        }

        for (NSString *sceneId in cache.scenes) {
            TTHueScene *scene = cache.scenes[sceneId];
            if ([scene.metadata.name isEqualToString:defaultSceneName]) {
                doubleTapSceneSelectedIdentifier = scene.sceneId;
                break;
            }
        }

        if (doubleTapSceneSelectedIdentifier) {
            [self.action changeActionOption:kDoubleTapHueScene to:doubleTapSceneSelectedIdentifier];
        }
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
    TTHueResourceCache *cache = [TTModeHue resourceCache];
    NSString *sceneIdentifier;

    if (!cache) return;

    for (NSString *sceneId in cache.scenes) {
        TTHueScene *scene = cache.scenes[sceneId];
        if ([scene.metadata.name isEqualToString:menuItem.title]) {
            sceneIdentifier = scene.sceneId;
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

    TTHueAPIClient *client = [TTModeHue hueClient];
    if (!client) {
        [self drawScenes];
        return;
    }

    [client fetchScenesWithCompletion:^(NSArray<TTHueScene *> *scenes, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawScenes];
        });
    }];
}

@end
