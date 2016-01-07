//
//  TTModeWebMenuView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/30/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTModeWebMenuView.h"

@implementation TTModeWebMenuView

@synthesize widthConstraint;
@synthesize tableView;
@synthesize scrollView;
@synthesize clipView;

- (void)awakeFromNib {
    [self setMaterial:NSVisualEffectMaterialSidebar];
    [self setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
    [self setState:NSVisualEffectStateActive];
    [self setWantsLayer:YES];

    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [clipView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    menuOptions = @[@{@"identifier" : @"space"},
                    @{@"identifier" : @"TTModeWebMenuReturn",
                      @"title"      : @"Return",
                      @"icon"       : @"arrow",
                      },
                    @{@"identifier" : @"space"},
                    @{@"identifier" : @"TTModeWebMenuNextStory",
                      @"title"      : @"Next story",
                      @"icon"       : @"arrow",
                      },
                    @{@"identifier" : @"TTModeWebMenuPreviousStory",
                      @"title"      : @"Previous story",
                      @"icon"       : @"arrow",
                      },
                    @{@"identifier" : @"space"},
                    @{@"identifier" : @"TTModeWebMenuFontSizeUp",
                      @"title"      : @"Larger text",
                      @"icon"       : @"plus",
                      },
                    @{@"identifier" : @"TTModeWebMenuFontSizeDown",
                      @"title"      : @"Smaller text",
                      @"icon"       : @"minus",
                      },
                    @{@"identifier" : @"space"},
                    @{@"identifier" : @"TTModeWebMenuMarginWider",
                      @"title"      : @"Widen margin",
                      @"icon"       : @"arrow",
                      },
                    @{@"identifier" : @"TTModeWebMenuMarginNarrower",
                      @"title"      : @"Narrow margin",
                      @"icon"       : @"arrow",
                      },
                    @{@"identifier" : @"space"},
                    @{@"identifier" : @"TTModeWebMenuClose",
                      @"title"      : @"Close Reader",
                      @"icon"       : @"button_x",
                      },
                    ];

    [widthConstraint setConstant:400];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}



#pragma mark - Interaction

- (void)slideIn {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.24f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[widthConstraint animator] setConstant:400];
    [NSAnimationContext endGrouping];
}

- (void)slideOut {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.3f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[widthConstraint animator] setConstant:0];
    [NSAnimationContext endGrouping];
}

#pragma mark - NSTableView Delegate

- (BOOL)isRowASpace:(NSInteger)row {
    return [[[menuOptions objectAtIndex:row] objectForKey:@"identifier"] isEqualToString:@"space"];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [menuOptions count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self isRowASpace:row]) {
        return 54;
    }
    
    return 54;
}

- (NSView *)tableView:(NSTableView *)_tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([@[@"leadingPaddingColumn", @"trailingPaddingColumn"] containsObject:tableColumn.identifier]) {
        return nil;
    }
    
    BOOL isSpace = [self isRowASpace:row];
    NSString *cellIdentifier = isSpace ? @"space" : @"option";
    NSButton *result = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
    
    if (result == nil) {
        result = [[NSButton alloc] init];
        [result setTarget:self];
        [result setAction:nil];
        [result setBordered:NO];
        [result setFont:[NSFont fontWithName:@"Effra" size:28]];
        [result setImagePosition:NSImageRight];
        [result setAlignment:NSTextAlignmentLeft];
        [result setButtonType:NSMomentaryChangeButton];
        [result setIdentifier:cellIdentifier];
        
    }
    
    if (!isSpace) {
        NSDictionary *menuOption = [menuOptions objectAtIndex:row];
        NSString *imageFile = [NSString stringWithFormat:@"%@/icons/%@.png", [[NSBundle mainBundle] resourcePath], [menuOption objectForKey:@"icon"]];
        NSImage *icon = [[NSImage alloc] initWithContentsOfFile:imageFile];
        [icon setSize:NSMakeSize(75, 50)];
        [result setImage:icon];
        [result setTitle:[menuOption objectForKey:@"title"]];
    } else {
        [result setTitle:@""];
    }
    
    return result;
}

@end
