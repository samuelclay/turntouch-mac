//
//  TTModalFTUXViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/13/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalFTUXView.h"
#import "TTPageIndicatorView.h"

@interface TTModalFTUXView ()

@property (nonatomic) TTModalFTUX modalFTUX;
@property (nonatomic, strong) NSMutableArray *indicatorViews;

@end

@implementation TTModalFTUXView

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.indicatorViews = [NSMutableArray array];
    NSMutableArray *indicatorConstraints = [NSMutableArray array];
    for (int i=1; i <= 5; i++) {
        TTPageIndicatorView *indicatorView = [[TTPageIndicatorView alloc] init];
        indicatorView.modalFTUX = i;
        [self.indicatorViews addObject:indicatorView];
        [indicatorConstraints addObject:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.f constant:15.f]];
        [indicatorConstraints addObject:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.f constant:15.f]];
    }
    [self.pageControl setViews:self.indicatorViews inGravity:NSStackViewGravityCenter];
    [self.pageControl addConstraints:indicatorConstraints];
}

- (void)setPage:(TTModalFTUX)_modalFTUX {
    self.modalFTUX = _modalFTUX;
    
    for (TTPageIndicatorView *indicatorView in self.indicatorViews) {
        [indicatorView setNeedsDisplay:YES];
    }
    
    if (self.modalFTUX == MODAL_FTUX_INTRO) {
        [self.imageView setImage:[NSImage imageNamed:@"modal_ftux_action"]];
        [self.labelTitle setStringValue:@"Here's how it works"];
        [self.labelSubtitle setStringValue:@"Your remote has four buttons"];
    } else if (self.modalFTUX == MODAL_FTUX_ACTIONS) {
        [self.imageView setImage:[NSImage imageNamed:@"modal_ftux_doubletap"]];
        [self.labelTitle setStringValue:@"Each button performs an action"];
        [self.labelSubtitle setStringValue:@"Like changing the lights, playing music, or turning up the volume"];
    } else if (self.modalFTUX == MODAL_FTUX_MODES) {
        [self.imageView setImage:[NSImage imageNamed:@"modal_ftux_mode"]];
        [self.labelTitle setStringValue:@"Press and hold to change apps"];
        [self.labelSubtitle setStringValue:@"Four apps × four buttons per app\n= sixteen different actions"];
    } else if (self.modalFTUX == MODAL_FTUX_BATCHACTIONS) {
        [self.imageView setImage:[NSImage imageNamed:@"modal_ftux_change_action"]];
        [self.labelTitle setStringValue:@"Each button can do multiple actions"];
        [self.labelSubtitle setStringValue:@"There are batch actions and double-tap actions, all configurable in this app"];
    } else if (self.modalFTUX == MODAL_FTUX_HUD) {
        [self.imageView setImage:[NSImage imageNamed:@"modal_ftux_change_mode"]];
        [self.labelTitle setStringValue:@"Press all four buttons for the HUD"];
        [self.labelSubtitle setStringValue:@"The Heads-Up Display (HUD) shows what each button does and gives you access to even more actions and apps"];
    }

    [self.pageControl setNeedsDisplay:YES];
}

- (void)closeModal:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

@end
