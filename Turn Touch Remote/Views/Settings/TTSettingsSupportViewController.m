//
//  TTSettingsSupportViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTSettingsSupportViewController.h"

@interface TTSettingsSupportViewController ()

@end

@implementation TTSettingsSupportViewController

@synthesize emailButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"TTSettingsSupportViewController" bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSColor *color = NSColorFromRGB(0x086DD6);
    NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc]
                                             initWithAttributedString:[emailButton attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    [colorTitle addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:titleRange];
    [emailButton setAttributedTitle:colorTitle];
    
    [emailButton addCursorRect:[emailButton bounds] cursor:[NSCursor pointingHandCursor]];

}

#pragma mark - RHPreferencesViewControllerProtocol

- (NSString*)identifier {
    return NSStringFromClass(self.class);
}
- (NSImage*)toolbarItemImage {
    return [NSImage imageNamed:@"heart"];
}
- (NSString*)toolbarItemLabel {
    return @" Support ";
}

- (NSView*)initialKeyView {
    return nil;
}

#pragma mark - Actions

- (IBAction)openSupportEmail:(id)sender {
    NSString *mailtoAddress = [[NSString stringWithFormat:@"mailto:%@?Subject=%@&body=%@", @"samuel@turntouch.com", @"", @""] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:mailtoAddress]];
}

@end

@interface TTLinkButton : NSButton

@end

@implementation TTLinkButton

- (void)resetCursorRects {
    [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

@end
