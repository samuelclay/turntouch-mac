//
//  TTModalSupportView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalSupportView.h"

@interface TTModalSupportView ()

@end

@implementation TTModalSupportView

@synthesize supportComment;
@synthesize supportEmail;
@synthesize supportLabel;
@synthesize supportSegmentedControl;

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    [self chooseSupportSegmentedControl:nil];
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *lastSupportEmail = [preferences objectForKey:@"TT:support:last_email"];
    if (lastSupportEmail) {
        [supportEmail setStringValue:lastSupportEmail];
    }
}

- (void)closeModal:(id)sender {
    [appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

- (IBAction)chooseSupportSegmentedControl:(id)sender {
    if (supportSegmentedControl.selectedSegment == 0) {
        [supportLabel setStringValue:@"What can we help you with?"];
        [appDelegate.panelController.backgroundView.modalBarButton setPageSupport:MODAL_SUPPORT_QUESTION];
    } else if (supportSegmentedControl.selectedSegment == 1) {
        [supportLabel setStringValue:@"What feature would you like to see?"];
        [appDelegate.panelController.backgroundView.modalBarButton setPageSupport:MODAL_SUPPORT_IDEA];
    } else if (supportSegmentedControl.selectedSegment == 2) {
        [supportLabel setStringValue:@"What issue are you running into?"];
        [appDelegate.panelController.backgroundView.modalBarButton setPageSupport:MODAL_SUPPORT_PROBLEM];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
    
    BOOL result = NO;
    
    if (commandSelector == @selector(insertNewline:))
    {
        // new line action:
        // always insert a line-break character and don’t cause the receiver to end editing
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    else if (commandSelector == @selector(insertTab:))
    {
        // tab action:
        // always insert a tab character and don’t cause the receiver to end editing
//        [textView insertTabIgnoringFieldEditor:self];
//        result = YES;
        [supportEmail becomeFirstResponder];
    }
    
    return result;
}

@end
