//
//  TTModePresentationPlayOptions.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 1/9/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTModePresentationPlayOptions.h"
#import "TTModePresentation.h"

@interface TTModePresentationPlayOptions ()

@end

@implementation TTModePresentationPlayOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    BOOL selected = [[self.appDelegate.modeMap mode:self.mode optionValue:kPresentationPlayStartFirstSlide] boolValue];
    self.selectFirstSlide.state = selected ? NSControlStateValueOn : NSControlStateValueOff;
}

- (void)selectStartPresentationFirstSlide:(id)sender {
    BOOL selected = self.selectFirstSlide.state == NSControlStateValueOn;
    
    [self.appDelegate.modeMap changeMode:self.mode option:kPresentationPlayStartFirstSlide to:@(selected)];
}

@end
