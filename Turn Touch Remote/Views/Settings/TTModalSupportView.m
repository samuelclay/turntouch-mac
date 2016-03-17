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
@synthesize spinner;
@synthesize successImage;

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
        modalSupport = MODAL_SUPPORT_QUESTION;
    } else if (supportSegmentedControl.selectedSegment == 1) {
        [supportLabel setStringValue:@"What feature would you like to see?"];
        modalSupport = MODAL_SUPPORT_IDEA;
    } else if (supportSegmentedControl.selectedSegment == 2) {
        [supportLabel setStringValue:@"What issue are you running into?"];
        modalSupport = MODAL_SUPPORT_PROBLEM;
    } else if (supportSegmentedControl.selectedSegment == 3) {
        [supportLabel setStringValue:@"Thank you! What would you like to say?"];
        modalSupport = MODAL_SUPPORT_PRAISE;
    }

    [appDelegate.panelController.backgroundView.modalBarButton setPageSupport:modalSupport];
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

- (void)controlTextDidChange:(NSNotification *)obj {
    [supportComment setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
    [supportEmail setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
}

#pragma mark - Submitting support request

- (BOOL)isEmptyMessage:(NSString *)message {
    BOOL result = YES;
    if ([message length] > 0) {
        NSString *regEx = @".*[^ \t\r\n]+.*";
        NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
        if ([test evaluateWithObject:message]) {
            result = NO;
        }
    }
    
    return result;
}

- (BOOL)isValidEmailAddress:(NSString *)emailAddress {
    if (emailAddress != nil && ![emailAddress isEqualToString:@""]) {
        NSString* emailRegEx = @"[ ]*[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}[ ]*";
        NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        if([emailTest evaluateWithObject:emailAddress]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)submitSupport {
    if (![self isValidEmailAddress:supportEmail.stringValue]) {
        [supportEmail setBackgroundColor:NSColorFromRGB(0xFFCA44)];
        return;
    }
    
    if ([self isEmptyMessage:supportComment.stringValue]) {
        [supportComment setBackgroundColor:NSColorFromRGB(0xFFCA44)];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://www.turntouch.com/support/in_app"];
    NSString *postString = [NSString stringWithFormat:@"type=%@&email=%@&comments=%@",
                            supportSegmentedControl.selectedSegment == 0 ? @"question" :
                            supportSegmentedControl.selectedSegment == 1 ? @"idea" :
                            supportSegmentedControl.selectedSegment == 2 ? @"problem" : @"error",
                            [supportEmail.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                            [supportComment.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%ld", (long)postData.length];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self];
    
    [connection start];
    
    [spinner setHidden:NO];
    [supportComment setBackgroundColor:NSColorFromRGB(0xE0E0E0)];
    [supportComment setEditable:NO];
    [supportEmail setBackgroundColor:NSColorFromRGB(0xE0E0E0)];
    [supportEmail setEditable:NO];
    [supportSegmentedControl setEnabled:NO];
    [appDelegate.panelController.backgroundView.modalBarButton setPageSupport:MODAL_SUPPORT_SUBMITTING];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Connection finished: %@", connection);
    [spinner setHidden:YES];
    [successImage setHidden:NO];
    [appDelegate.panelController.backgroundView.modalBarButton setPageSupport:MODAL_SUPPORT_SUBMITTED];

    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:supportEmail.stringValue forKey:@"TT:support:last_email"];
    [preferences synchronize];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error: %@ / %@", connection, error);
    [spinner setHidden:YES];
    [successImage setHidden:YES];
    [supportComment setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
    [supportComment setEditable:YES];
    [supportEmail setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
    [supportEmail setEditable:YES];
    [supportSegmentedControl setEnabled:YES];
    [appDelegate.panelController.backgroundView.modalBarButton setPageSupport:modalSupport];
}

@end
