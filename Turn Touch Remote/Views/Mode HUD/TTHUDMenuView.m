//
//  TTHUDMenuView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 1/28/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TTHUDMenuView.h"
#import "TTAppDelegate.h"
#import "TTHUDMenuButton.h"

@implementation TTHUDMenuView

@synthesize offsetConstraint;
@synthesize widthConstraint;
@synthesize tableView;
@synthesize scrollView;
@synthesize clipView;
@synthesize delegate;

- (void)awakeFromNib {
    appDelegate = (TTAppDelegate *)[NSApp delegate];
    
    [self setWantsLayer:YES];
    [self setMaterial:NSVisualEffectMaterialSidebar];
    [self setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [self setState:NSVisualEffectStateActive];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    highlightedRow = 1;
    [self setHidden:NO];
    [self changeHighlightedRow:0];
    
    [offsetConstraint setConstant:self.menuInitialPosition];
    [widthConstraint setConstant:self.menuWidth];

}

- (NSInteger)menuWidth {
    if ([delegate respondsToSelector:@selector(menuWidth)]) {
        return [delegate menuWidth];
    }
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return MIN(400, NSWidth(mainScreen.frame) * 0.25);
}

- (NSInteger)menuInitialPosition {
    if ([delegate respondsToSelector:@selector(menuInitialPosition)]) {
        return [delegate menuInitialPosition];
    }
    
    return -1 * self.menuWidth;
}

- (NSArray *)menuOptions {
    if ([delegate respondsToSelector:@selector(menuOptions)]) {
        return [delegate menuOptions];
    }
    
    return appDelegate.modeMap.selectedMode.menuOptions;
}

#pragma mark - Interaction

- (void)slideIn {
    [self setHidden:NO];
    [self changeHighlightedRow:0];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.24f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[offsetConstraint animator] setConstant:0];
    [NSAnimationContext endGrouping];
}

- (void)slideOut {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.3f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self setHidden:YES];
    }];
    [[offsetConstraint animator] setConstant:-1 * self.menuWidth];
    [NSAnimationContext endGrouping];
}

- (void)menuUp {
    [self changeHighlightedRow:-1];
}

- (void)menuDown {
    [self changeHighlightedRow:1];
}

- (void)changeHighlightedRow:(NSInteger)direction {
    if (![self.menuOptions count]) return;
    
    NSInteger newRow = [self nextRowInDirection:direction];
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
}

- (NSInteger)nextRowInDirection:(NSInteger)direction {
    NSInteger newRow = highlightedRow + direction;
    
    if (newRow >= tableView.numberOfRows) {
//        NSLog(@"Skipping change highlighted row: %ld+%ld >= %ld", (long)highlightedRow, (long)direction, (long)tableView.numberOfRows);
        newRow = 0 + direction ;
    } else if (newRow < 0) {
//        NSLog(@"Skipping change highlighted row: %ld+%ld < 0/%ld", (long)highlightedRow, (long)direction, (long)tableView.numberOfRows);
        newRow = tableView.numberOfRows + (highlightedRow + direction);
    }
    
    if ([self isRowASpace:newRow]) {
        if (direction >= 0) direction += 1;
        else if (direction < 0) direction -= 1;
//        NSLog(@"Found space: %ld+%ld >|< %ld", (long)highlightedRow, (long)direction, (long)tableView.numberOfRows);
        return [self nextRowInDirection:direction];
    }
    
    return newRow;
}

- (void)selectMenuItem {
    NSDictionary *menuOption = [self.menuOptions objectAtIndex:highlightedRow];
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"menu%@", [menuOption objectForKey:@"identifier"]]);
    IMP imp = [appDelegate.modeMap.selectedMode methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    if ([appDelegate.modeMap.selectedMode respondsToSelector:selector]) {
        func(appDelegate.modeMap.selectedMode, selector);
    }
}

#pragma mark - NSTableView Delegate

- (BOOL)isRowASpace:(NSInteger)row {
    return [[[self.menuOptions objectAtIndex:row] objectForKey:@"identifier"] isEqualToString:@"space"];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.menuOptions count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self isRowASpace:row]) {
        return 54;
    }
    
    return 54;
}

- (NSView *)tableView:(NSTableView *)_tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableRowView *rowView = [tableView rowViewAtRow:row makeIfNecessary:NO];
    [rowView setBackgroundColor:[NSColor clearColor]];
    
    if ([@[@"leadingPaddingColumn", @"trailingPaddingColumn"] containsObject:tableColumn.identifier]) {
        [tableColumn setWidth:24];
        return nil;
    } else if ([tableColumn.identifier isEqualToString:@"imageColumn"]) {
        [tableColumn setWidth:72];
    } else {
        [tableColumn setWidth:(self.menuWidth - 24*2 - 72)];
    }
    
    BOOL isSpace = [self isRowASpace:row];
    NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if (result == nil) {
        result = [[NSTableCellView alloc] init];
        [result setIdentifier:tableColumn.identifier];
    }
    
    if (!isSpace) {
        NSDictionary *menuOption = [self.menuOptions objectAtIndex:row];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"menu%@", [menuOption objectForKey:@"identifier"]]);
        if ([tableColumn.identifier isEqualToString:@"imageColumn"]) {
            NSImage *icon = [NSImage imageNamed:[menuOption objectForKey:@"icon"]];
            [icon setSize:NSMakeSize(36, 36)];
            result.imageView.image = icon;
        } else {
            result.textField.stringValue = [menuOption objectForKey:@"title"];
        }
        if ([appDelegate.modeMap.selectedMode respondsToSelector:selector]) {
//            [result setTarget:appDelegate.modeMap.selectedMode];
        } else {
//            NSLog(@" ***> %@ doesn't respond to menu%@", appDelegate.modeMap.selectedMode, [menuOption objectForKey:@"identifier"]);
        }
    } else {
        result.textField.stringValue = @"";
    }
    
    return result;
}

-(void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    
    NSInteger selectedRow = [tableView selectedRow];
    NSTableRowView *myRowView = [tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
    [myRowView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [myRowView setEmphasized:NO];
    
    NSTableRowView *oldRowView = [tableView rowViewAtRow:highlightedRow makeIfNecessary:NO];
    NSTableRowView *newRowView = [tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
    CGFloat alpha = 0.2f;
    
    [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow] byExtendingSelection:NO];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.12f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[oldRowView animator] setBackgroundColor:[NSColor clearColor]];
    [[newRowView animator] setBackgroundColor:NSColorFromRGBAlpha(0x000000, alpha)];
    [NSAnimationContext endGrouping];
    
    highlightedRow = selectedRow;
    [tableView setNeedsDisplay:YES];

}
@end
