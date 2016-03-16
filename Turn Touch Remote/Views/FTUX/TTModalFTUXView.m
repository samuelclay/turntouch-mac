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

@end

@implementation TTModalFTUXView

@synthesize labelTitle;
@synthesize labelSubtitle;
@synthesize imageView;
@synthesize pageControl;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    indicatorViews = [NSMutableArray array];
    NSMutableArray *indicatorConstraints = [NSMutableArray array];
    for (int i=1; i <= 5; i++) {
        TTPageIndicatorView *indicatorView = [[TTPageIndicatorView alloc] init];
        indicatorView.modalFTUX = i;
        [indicatorViews addObject:indicatorView];
        [indicatorConstraints addObject:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.f constant:15.f]];
        [indicatorConstraints addObject:[NSLayoutConstraint constraintWithItem:indicatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.f constant:15.f]];
    }
    [pageControl setViews:indicatorViews inGravity:NSStackViewGravityCenter];
    [pageControl addConstraints:indicatorConstraints];
}

- (void)setPage:(TTModalFTUX)_modalFTUX {
    modalFTUX = _modalFTUX;
    
    for (TTPageIndicatorView *indicatorView in indicatorViews) {
        [indicatorView setNeedsDisplay:YES];
    }
    
    if (modalFTUX == MODAL_FTUX_INTRO) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_action"]];
        [labelTitle setStringValue:@"Here's how it works"];
        [labelSubtitle setStringValue:@"There are four buttons."];
    } else if (modalFTUX == MODAL_FTUX_ACTIONS) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_change_action"]];
        [labelTitle setStringValue:@"Each button performs an action"];
        [labelSubtitle setStringValue:@"Each button"];
    } else if (modalFTUX == MODAL_FTUX_MODES) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_mode"]];
        [labelTitle setStringValue:@"Press and hold to change apps"];
        [labelSubtitle setStringValue:@""];
    } else if (modalFTUX == MODAL_FTUX_BATCHACTIONS) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_doubletap"]];
        [labelTitle setStringValue:@"Each button can do multiple actions"];
        [labelSubtitle setStringValue:@""];
    } else if (modalFTUX == MODAL_FTUX_HUD) {
        [imageView setImage:[NSImage imageNamed:@"modal_ftux_change_mode"]];
        [labelTitle setStringValue:@"Customize each button"];
        [labelSubtitle setStringValue:@""];
    }

    NSLog(@"page control frame: %ld", (long)modalFTUX);

//    [pageControl setCurrentPage: modalFTUX+1];
    [pageControl setNeedsDisplay:YES];
}

- (void)closeModal:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

#pragma mark - Page Control

- (void)pageControl:(BFPageControl *)pageControl didSelectPageAtIndex:(NSInteger)index {
    [appDelegate.panelController.backgroundView switchPanelModalFTUX:index+1];
}

@end
