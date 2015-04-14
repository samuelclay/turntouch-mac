//
//  TTPairingViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/14/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTSettingsPairingViewController.h"
#import "TTDiamondView.h"

@interface TTSettingsPairingViewController ()

@end

@implementation TTSettingsPairingViewController

@synthesize titleBox;
@synthesize labelPressButtons;
@synthesize countdownIndicator;
@synthesize diamondViewPlaceholder;
@synthesize diamondView;
@synthesize spinnerScanning;
@synthesize labelScanning;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"TTSettingsPairingViewController" bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        
        [self registerAsObserver];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    [self countChanged];
    [appDelegate.bluetoothMonitor startScan];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"unpairedDevicesCount"
                                      options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(unpairedDevicesCount))]) {
        [self countChanged];
    }
}

- (void)dealloc {
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"unpairedDevicesCount"];
}

#pragma mark - RHPreferencesViewControllerProtocol

- (NSString*)identifier {
    return NSStringFromClass(self.class);
}
- (NSImage*)toolbarItemImage {
    return [NSImage imageNamed:@"television"];
}
- (NSString*)toolbarItemLabel {
    return @"Add Remote";
}

- (NSView*)initialKeyView {
    return nil;
}

#pragma mark - Drawing

- (void)countChanged {
    BOOL found = !!appDelegate.bluetoothMonitor.unpairedDevicesCount;
    
    [titleBox setHidden:!found];
    [labelPressButtons setHidden:!found];
    [countdownIndicator setHidden:!found];
    [diamondView setHidden:!found];
    if (found) {
        diamondView = [[TTDiamondView alloc] initWithFrame:diamondViewPlaceholder.bounds pairing:YES];
        [diamondView setIgnoreSelectedMode:YES];
        [diamondView setIgnoreActiveMode:YES];
        for (NSView *subview in diamondViewPlaceholder.subviews) {
            [subview removeFromSuperview];
        }
        [diamondViewPlaceholder addSubview:diamondView];
    }
    
    [spinnerScanning setHidden:found];
    [labelScanning setHidden:found];
    if (found) {
        [spinnerScanning stopAnimation:nil];
    } else {
        [spinnerScanning startAnimation:nil];
    }
}

@end
