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
    return @"presentation_toggle_slides.png";
}

- (NSString *)imageTTModePresentationNextSlide {
    return @"presentation_next_slide.png";
}

- (NSString *)imageTTModePresentationPreviousSlide {
    return @"presentation_previous_slide.png";
}

- (NSString *)imageTTModePresentationPlay {
    return @"presentation_play.png";
}

- (NSString *)imageTTModePresentationVolumeUp {
    return @"volume_up.png";
}

- (NSString *)imageTTModePresentationVolumeDown {
    return @"volume_down.png";
}

#pragma mark - Layout

- (BOOL)shouldHideHudTTModePresentationNextSlide {
    return YES;
}

- (BOOL)shouldHideHudTTModePresentationPreviousSlide {
    return YES;
}

#pragma mark - Action methods

- (void)runTTModePresentationToggleSlides {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    for (KeynoteDocument *document in [keynote documents]) {
        [document showSlideSwitcher];
    }
}

- (void)runTTModePresentationNextSlide {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    [keynote showNext];
}

- (void)runTTModePresentationPreviousSlide {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    [keynote showPrevious];
}

- (void)runTTModePresentationPlay {
    KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
    for (KeynoteDocument *document in [keynote documents]) {
        [document startFrom:document.slides[0]];
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
