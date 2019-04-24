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
#import "Powerpoint.h"

@implementation TTModePresentation

NSString *const kPresentationApp = @"TT:Presentation:app";
NSString *const kPresentationPlayStartFirstSlide = @"TT:Presentation:playStartFirstSlide";

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

- (BOOL)isKeynote {
    return [[self.appDelegate.modeMap mode:self optionValue:kPresentationApp] isEqualToString:@"keynote"];
}

- (BOOL)isPowerpoint {
    return [[self.appDelegate.modeMap mode:self optionValue:kPresentationApp] isEqualToString:@"powerpoint"];
}

- (void)runTTModePresentationToggleSlides {
    if ([self isKeynote]) {
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
    } else if ([self isPowerpoint]) {
        PowerpointApplication *powerpoint = [SBApplication applicationWithBundleIdentifier:@"com.microsoft.Powerpoint"];
        [powerpoint activate];
        
//        for (PowerpointSlideShowWindow *slideshow in [powerpoint slideShowWindows]) {
//            [slideshow slideshowView]
//        }
    }
}

- (void)runTTModePresentationNextSlide {
    if ([self isKeynote]) {
        KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
        if (slideChooserVisible) {
            for (KeynoteDocument *document in [keynote documents]) {
                [document acceptSlideSwitcher];
            }
            slideChooserVisible = NO;
        } else {
            [keynote showNext];
        }
    } else if ([self isPowerpoint]) {
        PowerpointApplication *powerpoint = [SBApplication applicationWithBundleIdentifier:@"com.microsoft.Powerpoint"];
        [powerpoint activate];
        
        for (PowerpointSlideShowWindow *slideshow in [powerpoint slideShowWindows]) {
            [[slideshow slideshowView] goToNextSlide];
        }
    }
}

- (void)runTTModePresentationPreviousSlide {
    if ([self isKeynote]) {
        KeynoteApplication *keynote = [SBApplication applicationWithBundleIdentifier:@"com.apple.iWork.Keynote"];
        if (slideChooserVisible) {
            for (KeynoteDocument *document in [keynote documents]) {
                [document cancelSlideSwitcher];
            }
            slideChooserVisible = NO;
        } else {
            [keynote showPrevious];
        }
    } else if ([self isPowerpoint]) {
        PowerpointApplication *powerpoint = [SBApplication applicationWithBundleIdentifier:@"com.microsoft.Powerpoint"];
        [powerpoint activate];
        
        for (PowerpointSlideShowWindow *slideshow in [powerpoint slideShowWindows]) {
            [[slideshow slideshowView] goToPreviousSlide];
        }
    }
}

- (void)runTTModePresentationPlay {
    BOOL startFirstSlide = [[self.appDelegate.modeMap mode:self optionValue:kPresentationPlayStartFirstSlide] boolValue];
    
    if ([self isKeynote]) {
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
    } else if ([self isPowerpoint]) {
        PowerpointApplication *powerpoint = [SBApplication applicationWithBundleIdentifier:@"com.microsoft.Powerpoint"];
        [powerpoint activate];
        
        [[[[powerpoint activeWindow] presentation] slideShowSettings] runSlideShow];
        
        if (startFirstSlide) {
            for (PowerpointSlideShowWindow *slideshow in [powerpoint slideShowWindows]) {
                [[slideshow slideshowView] goToFirstSlide];
            }
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
