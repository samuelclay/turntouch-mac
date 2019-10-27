//
//  TTModalSupportView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/15/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModalSupportView.h"
#import "NSString+TTEncoding.h"

@interface TTModalSupportView ()

@property (nonatomic) TTModalSupport modalSupport;
@property (nonatomic, strong) NSMutableData *receivedData;

@end

@implementation TTModalSupportView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.appDelegate = (TTAppDelegate *)[NSApp delegate];
    [self chooseSupportSegmentedControl:nil];
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    NSString *lastSupportEmail = [preferences objectForKey:@"TT:support:last_email"];
    if (lastSupportEmail) {
        [self.supportEmail setStringValue:lastSupportEmail];
    }

    [self.supportComment setFont:[NSFont fontWithName:@"Effra" size:13]];
    [[self.supportComment textStorage] setFont:[NSFont fontWithName:@"Effra" size:13]];
}

- (void)closeModal:(id)sender {
    [self.appDelegate.panelController.backgroundView switchPanelModal:PANEL_MODAL_APP];
}

- (IBAction)chooseSupportSegmentedControl:(id)sender {
    if (self.supportSegmentedControl.selectedSegment == 0) {
        [self.supportLabel setStringValue:@"What can we help you with?"];
        self.modalSupport = MODAL_SUPPORT_QUESTION;
    } else if (self.supportSegmentedControl.selectedSegment == 1) {
        [self.supportLabel setStringValue:@"What feature would you like to see?"];
        self.modalSupport = MODAL_SUPPORT_IDEA;
    } else if (self.supportSegmentedControl.selectedSegment == 2) {
        [self.supportLabel setStringValue:@"What issue are you running into?"];
        self.modalSupport = MODAL_SUPPORT_PROBLEM;
    } else if (self.supportSegmentedControl.selectedSegment == 3) {
        [self.supportLabel setStringValue:@"Thank you! What would you like to say?"];
        self.modalSupport = MODAL_SUPPORT_PRAISE;
    }

    [self.appDelegate.panelController.backgroundView.modalBarButton setPageSupport:self.modalSupport];
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
        [self.supportEmail becomeFirstResponder];
    }
    
    return result;
}

- (void)textDidChange:(NSNotification *)notification {
    [self.supportComment setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
    [self.supportEmail setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
}
                        

- (void)controlTextDidChange:(NSNotification *)obj {
    [self.supportComment setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
    [self.supportEmail setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
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
    if (![self isValidEmailAddress:self.supportEmail.stringValue]) {
        [self.supportEmail setBackgroundColor:NSColorFromRGB(0xFFCA44)];
        return;
    }
    
    if ([self isEmptyMessage:self.supportComment.string]) {
        [self.supportComment setBackgroundColor:NSColorFromRGB(0xFFCA44)];
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://www.turntouch.com/support/in_app"];
    NSString *postString = [NSString stringWithFormat:@"thread_type=%@&email=%@&comments=%@",
                            self.supportSegmentedControl.selectedSegment == 0 ? @"question" :
                            self.supportSegmentedControl.selectedSegment == 1 ? @"idea" :
                            self.supportSegmentedControl.selectedSegment == 2 ? @"problem" :
                            self.supportSegmentedControl.selectedSegment == 3 ? @"praise" : @"error",
                            [self.supportEmail.stringValue urlEncodeUsingEncoding:NSUTF8StringEncoding],
                            [self.supportComment.string urlEncodeUsingEncoding:NSUTF8StringEncoding]];
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
    self.receivedData = [NSMutableData data];
    [connection start];
    
    [self.spinner setHidden:NO];
    [self.supportComment setBackgroundColor:NSColorFromRGB(0xE0E0E0)];
    [self.supportComment setEditable:NO];
    [self.supportEmail setBackgroundColor:NSColorFromRGB(0xE0E0E0)];
    [self.supportEmail setEditable:NO];
    [self.supportSegmentedControl setEnabled:NO];
    [self.appDelegate.panelController.backgroundView.modalBarButton setPageSupport:MODAL_SUPPORT_SUBMITTING];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *receivedString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"Connection finished: %@", receivedString);
    [self.spinner setHidden:YES];
    [self.successImage setHidden:NO];
    [self.appDelegate.panelController.backgroundView.modalBarButton setPageSupport:MODAL_SUPPORT_SUBMITTED];

    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    [preferences setObject:self.supportEmail.stringValue forKey:@"TT:support:last_email"];
    [preferences synchronize];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection error: %@ / %@", connection, error);
    [self.spinner setHidden:YES];
    [self.successImage setHidden:YES];
    [self.supportComment setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
    [self.supportComment setEditable:YES];
    [self.supportEmail setBackgroundColor:NSColorFromRGB(0xFFFFFF)];
    [self.supportEmail setEditable:YES];
    [self.supportSegmentedControl setEnabled:YES];
    [self.appDelegate.panelController.backgroundView.modalBarButton setPageSupport:self.modalSupport];
}

@end
