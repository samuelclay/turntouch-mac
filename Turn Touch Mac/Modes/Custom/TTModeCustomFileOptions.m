//
//  TTModeCustomFile.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 1/9/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTModeCustomFileOptions.h"
#import "TTModeCustom.h"

@interface TTModeCustomFileOptions ()

@end

@implementation TTModeCustomFileOptions

@synthesize chooseFile;
@synthesize pathControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *urlString = [self.action optionValue:kCustomFileUrl];
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        [pathControl setURL:url];
    }
}

- (IBAction)openFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    NSString *urlString = [self.action optionValue:kCustomFileUrl];
    if (urlString) {
        NSURL *url = [NSURL URLWithString:urlString];
        [panel setDirectoryURL:url];
    }
    
    appDelegate.panelController.preventClosing = YES;
    
    NSInteger clicked = [panel runModal];
    
    appDelegate.panelController.preventClosing = NO;

    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            [pathControl setURL:url];
            [self.action changeActionOption:kCustomFileUrl to:[url absoluteString]];
        }
    } else {
        
    }
}
@end
