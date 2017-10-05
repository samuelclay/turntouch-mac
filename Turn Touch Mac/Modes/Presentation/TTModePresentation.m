//
//  TTModePresentation.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 7/26/17.
//  Copyright © 2017 Turn Touch. All rights reserved.
//

#import "TTModePresentation.h"
#import "TTModeMac.h"
#import "Keynote.h"

@implementation TTModePresentation
- (instancetype)init {
    if (self = [super init]) {
        slideChooserVisible = NO;
        slideshowPlaying = NO;
    }
    return self;
}
#pragma mark - Mode

+ (NSString *)title {
    return @"Presentation";
}

+ (NSString *)description {
    return @"Keynote and PowerPoint";
}

+ (NSString *)imageName {
    return @"mode_presentation.png";
}

#pragma mark - Actions

- (NSArray *)actions {
    return @[@"TTModePresentationNextSlide",
             @"TTModePresentationPreviousSlide",
             @"TTModePresentationToggleSlides",
             @"TTModePresentationPlay",
             @"TTModePresentationVolumeUp",
             @"TTModePresentationVolumeDown",
             ];
}

#pragma mark - Defaults

- (NSString *)defaultNorth {
    return @"TTModePresentationToggleSlides";
}
- (NSString *)defaultEast {
    return @"TTModePresentationNextSlide";
}
- (NSString *)defaultWest {
    return @"TTModePresentationPreviousSlide";
}
- (NSString *)defaultSouth {
    return @"TTModePresentationPlay";
}

#pragma mark - Action Titles

- (NSString *)titleTTModePresentationToggleSlides {
    return @"Toggle slides";
}

- (NSString *)titleTTModePresentationNextSlide {
    return @"Next slide";
}

- (NSString *)titleTTModePresentationPreviousSlide {
    return @"Previous slide";
}

- (NSString *)titleTTModePresentationPlay {
    return @"Play presentation";
}

- (NSString *)titleTTModePresentationVolumeUp {
    return @"Volume up";
}

- (NSString *)titleTTModePresentationVolumeDown {
    return @"Volume down";
}

#pragma mark - Action Images

- (NSString *)imageTTModePresentationToggleSlides {
    return @"presentation_slides";
}

- (NSString *)imageTTModePresentationNextSlide {
    return @"music_ff.png";
}

- (NSString *)imageTTModePresentationPreviousSlide {
    return @"music_rewind.png";
}

- (NSString *)imageTTModePresentationPlay {
    return @"music_play.png";
}

- (NSString *)imageTTModePresentationVolumeUp {
    return @"music_volume_up.png";
}

- (NSString *)imageTTModePresentationVolumeDown {
    return @"music_volume_down.png";
}

#pragma mark - Layout

- (BOOL)shouldHideHudTTModePresentationNextSlide {
    return YES;
}

- (BOOL)shouldHideHudTTModePresentationPreviousSlide {
    return YES;
}

- (BOOL)shouldHideHudTTModePresentationToggleSlides {
    if (!slideChooserVisible) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)shouldHideHudTTModePresentationPlay {
    if (!slideChooserVisible) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Action methods

- (void)runTTModePresentationToggleSlides {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    if (!slideChooserVisible) {
        for (KeynoteDocument *document in [keynote documents]) {
            [document showSlideSwitcher];
        }
        slideChooserVisible = YES;
    } else {
        for (KeynoteDocument *document in [keynote documents]) {
            [document moveSlideSwitcherBackward];
        }
    }
}

- (void)runTTModePresentationNextSlide {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    if (slideChooserVisible) {
        for (KeynoteDocument *document in [keynote documents]) {
            [document acceptSlideSwitcher];
        }
        slideChooserVisible = NO;
    } else {
        [keynote showNext];
    }
}

- (void)runTTModePresentationPreviousSlide {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    if (slideChooserVisible) {
        for (KeynoteDocument *document in [keynote documents]) {
            [document cancelSlideSwitcher];
        }
        slideChooserVisible = NO;
    } else {
        [keynote showPrevious];
    }
}

- (void)runTTModePresentationPlay {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    for (KeynoteDocument *document in [keynote documents]) {
        if (!slideChooserVisible) {
            if (slideshowPlaying) {
                [document stop];
                slideshowPlaying = NO;
            } else {
                [document startFrom:document.currentSlide];
                slideshowPlaying = YES;
            }
        } else {
            [document moveSlideSwitcherForward];
        }
    }
}

- (void)runTTModePresentationVolumeUp {
    TTModeMac *modeMac = [[TTModeMac alloc] init];
    
    [modeMac runTTModeMacVolumeUp];
}

- (void)runTTModePresentationVolumeDown {
    TTModeMac *modeMac = [[TTModeMac alloc] init];
    
    [modeMac runTTModeMacVolumeDown];
}

@end
