//
//  TTModeNanoleafSceneCustomOptions.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 2/20/26.
//  Copyright (c) 2026 Turn Touch. All rights reserved.
//

#import "TTModeNanoleaf.h"
#import "TTModeNanoleafSceneCustomOptions.h"

@implementation TTModeNanoleafSceneCustomOptions

- (void)viewDidLoad {
    [super viewDidLoad];

    [self drawEffects];
}

- (void)drawEffects {
    [self.spinner setHidden:YES];
    [self.doubleTapSpinner setHidden:YES];
    [self.refreshButton setHidden:NO];
    [self.doubleTapRefreshButton setHidden:NO];

    NSString *sceneSelectedIdentifier = [self.action optionValue:kNanoleafScene
                                                     inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *doubleTapSceneSelectedIdentifier = [self.action optionValue:kDoubleTapNanoleafScene
                                                              inDirection:self.appDelegate.modeMap.inspectingModeDirection];

    NSArray<NSString *> *cachedEffects = [TTModeNanoleaf cachedEffects];
    [self.scenePopup removeAllItems];
    [self.doubleTapScenePopup removeAllItems];

    if (cachedEffects.count == 0) {
        return;
    }

    // Auto-assign defaults if nil
    if (!sceneSelectedIdentifier && cachedEffects.count > 0) {
        sceneSelectedIdentifier = cachedEffects.firstObject;
        [self.action changeActionOption:kNanoleafScene to:sceneSelectedIdentifier];
    }
    if (!doubleTapSceneSelectedIdentifier && cachedEffects.count > 0) {
        doubleTapSceneSelectedIdentifier = cachedEffects.firstObject;
        [self.action changeActionOption:kDoubleTapNanoleafScene to:doubleTapSceneSelectedIdentifier];
    }

    NSArray *sortedEffects = [cachedEffects sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    for (NSString *effect in sortedEffects) {
        [self.scenePopup addItemWithTitle:effect];
        [self.doubleTapScenePopup addItemWithTitle:effect];
    }

    if (sceneSelectedIdentifier) {
        [self.scenePopup selectItemWithTitle:sceneSelectedIdentifier];
    }
    if (doubleTapSceneSelectedIdentifier) {
        [self.doubleTapScenePopup selectItemWithTitle:doubleTapSceneSelectedIdentifier];
    }
}

#pragma mark - Actions

- (IBAction)didChangeScene:(id)sender {
    NSString *selected;

    if (sender == self.scenePopup) {
        selected = [self.scenePopup selectedItem].title;
        [self.action changeActionOption:kNanoleafScene to:selected];
    } else if (sender == self.doubleTapScenePopup) {
        selected = [self.doubleTapScenePopup selectedItem].title;
        [self.action changeActionOption:kDoubleTapNanoleafScene to:selected];
    }
}

- (IBAction)didClickRefresh:(id)sender {
    [self.spinner setHidden:NO];
    [self.doubleTapSpinner setHidden:NO];
    [self.refreshButton setHidden:YES];
    [self.doubleTapRefreshButton setHidden:YES];

    TTModeNanoleaf *modeNanoleaf = (TTModeNanoleaf *)self.mode;
    [modeNanoleaf fetchEffectsWithCompletion:^(NSArray<NSString *> *effects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (effects) {
                [TTModeNanoleaf updateCachedEffects:effects];
            }
            [self drawEffects];
        });
    }];
}

@end
