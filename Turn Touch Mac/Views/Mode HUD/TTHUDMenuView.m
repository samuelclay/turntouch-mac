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

- (void)awakeFromNib {
    self.appDelegate = (TTAppDelegate *)[NSApp delegate];
    
    [self setWantsLayer:YES];
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    if (version.minorVersion <= 10) {
        [self setMaterial:NSVisualEffectMaterialAppearanceBased];
    } else {
        [self setMaterial:NSVisualEffectMaterialSidebar];
    }
    [self setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
    [self setState:NSVisualEffectStateActive];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.highlightedRow = 1;
    [self.tableView deselectAll:nil];
    [self setHidden:NO];
    
    [self.offsetConstraint setConstant:self.menuInitialPosition];
    [self.widthConstraint setConstant:self.menuWidth];

}

- (BOOL)allowsVibrancy {
    return YES;
}

- (NSInteger)menuWidth {
    if ([self.delegate respondsToSelector:@selector(menuWidth)]) {
        return [self.delegate menuWidth];
    }
    
    NSScreen *mainScreen = [[NSScreen screens] objectAtIndex:0];
    
    return MIN(400, NSWidth(mainScreen.frame) * 0.25);
}

- (NSInteger)menuInitialPosition {
    if ([self.delegate respondsToSelector:@selector(menuInitialPosition)]) {
        return [self.delegate menuInitialPosition];
    }
    
    return -1 * self.menuWidth;
}

- (NSArray *)menuOptions {
    if ([self.delegate respondsToSelector:@selector(menuOptions)]) {
        return [self.delegate menuOptions];
    }
    
    return self.appDelegate.modeMap.selectedMode.menuOptions;
}

#pragma mark - Interaction

- (void)slideIn {
    [self setHidden:NO];
    [self.tableView reloadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self changeHighlightedRow:0];
    });
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.24f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [[self.offsetConstraint animator] setConstant:0];
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
    [[self.offsetConstraint animator] setConstant:-1 * self.menuWidth];
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
    
    NSInteger newRow;
    if (direction == 0) {
        newRow = 1;
    } else {
        newRow = [self nextRowInDirection:direction];
    }
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRow] byExtendingSelection:NO];
}

- (NSInteger)nextRowInDirection:(NSInteger)direction {
    NSInteger newRow = self.highlightedRow + direction;
    
    if (newRow >= self.tableView.numberOfRows) {
//        NSLog(@"Skipping change highlighted row: %ld+%ld >= %ld", (long)highlightedRow, (long)direction, (long)tableView.numberOfRows);
        newRow = 0 + direction ;
    } else if (newRow < 0) {
//        NSLog(@"Skipping change highlighted row: %ld+%ld < 0/%ld", (long)highlightedRow, (long)direction, (long)tableView.numberOfRows);
        newRow = self.tableView.numberOfRows + (self.highlightedRow + direction);
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
    NSDictionary *menuOption = [self.menuOptions objectAtIndex:self.highlightedRow];
    if ([[menuOption objectForKey:@"group"] isEqualToString:@"action"]) {
        [self.appDelegate.modeMap.selectedMode runAction:[menuOption objectForKey:@"identifier"] inDirection:NO_DIRECTION];
        [self.appDelegate.hudController toastActiveAction:[menuOption objectForKey:@"identifier"] inDirection:NO_DIRECTION];
    } else if ([[menuOption objectForKey:@"identifier"] isEqualToString:@"close"]) {
        [self.appDelegate.hudController.modeHUDController fadeOut:nil];
    } else {
        NSLog(@"Switch into: %@", menuOption);
        [self.appDelegate.modeMap switchMode:NO_DIRECTION modeName:[menuOption objectForKey:@"identifier"]];
        [self.appDelegate.hudController activateHudMenu];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self changeHighlightedRow:0];
        });
    }
}

- (NSString *)highlightedRowTitle {
    NSDictionary *menuOption = [self.menuOptions objectAtIndex:self.highlightedRow];
    
    return menuOption[@"title"];
}

#pragma mark - NSTableView Delegate

- (BOOL)isRowASpace:(NSInteger)row {
    if (!self.menuOptions.count) return NO;
    
    return [[[self.menuOptions objectAtIndex:row] objectForKey:@"identifier"] isEqualToString:@"space"];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.menuOptions count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if ([self isRowASpace:row]) {
        return 54;
    }
    
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger height = round(CGRectGetWidth(screen.frame) / 32);
    if (NSWidth(screen.frame) > 1500) {
        height = round(CGRectGetWidth(screen.frame) / 48);
    }
    return height;
}

- (NSView *)tableView:(NSTableView *)_tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableRowView *rowView = [self.tableView rowViewAtRow:row makeIfNecessary:NO];
    [rowView setBackgroundColor:[NSColor clearColor]];
    NSScreen *screen = [[NSScreen screens] objectAtIndex:0];
    NSInteger fontSize = round(CGRectGetWidth(screen.frame) / 64);
    NSInteger iconSize = round(CGRectGetWidth(screen.frame) / 44);
    if (NSWidth(screen.frame) > 1500) {
        fontSize = round(CGRectGetWidth(screen.frame) / 84);
        iconSize = round(CGRectGetWidth(screen.frame) / 72);
    }

    if ([@[@"leadingPaddingColumn", @"trailingPaddingColumn"] containsObject:tableColumn.identifier]) {
        [tableColumn setWidth:24];
        return nil;
    } else if ([tableColumn.identifier isEqualToString:@"imageColumn"]) {
        [tableColumn setWidth:iconSize*2];
    } else {
        [tableColumn setWidth:(self.menuWidth - 24*2 - iconSize*2)];
    }
    
    BOOL isSpace = [self isRowASpace:row];
    NSString *identifier = isSpace ? @"space" : tableColumn.identifier;
    NSTableCellView *result = [self.tableView makeViewWithIdentifier:identifier owner:self.tableView];
    [self.tableView setRowSizeStyle:NSTableViewRowSizeStyleCustom];
    if (result == nil) {
        result = [[NSTableCellView alloc] init];
        [result setIdentifier:identifier];
    }
    
    if (!isSpace) {
        NSDictionary *menuOption = [self.menuOptions objectAtIndex:row];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"run%@", [menuOption objectForKey:@"identifier"]]);
        if ([tableColumn.identifier isEqualToString:@"imageColumn"]) {
            NSImage *icon = [NSImage imageNamed:[menuOption objectForKey:@"icon"]];
            [icon setSize:NSMakeSize(iconSize, iconSize)];
//            NSLog(@"icon size: %@", NSStringFromSize(icon.size));
            result.imageView.image = icon;
        } else {
            result.textField.font = [NSFont fontWithName:@"Effra" size:fontSize];
            result.textField.stringValue = [menuOption objectForKey:@"title"];
            if ([NSStringFromClass([self.appDelegate.modeMap.selectedMode class]) isEqualToString:[menuOption objectForKey:@"identifier"]]) {
                result.textField.textColor = NSColorFromRGB(0x4685BE);
            } else {
                result.textField.textColor = NSColorFromRGB(0xFFFFFF);
            }
        }
        if ([self.appDelegate.modeMap.selectedMode respondsToSelector:selector]) {
            [result.textField setTarget:self.appDelegate.modeMap.selectedMode];
            [result.imageView setTarget:self.appDelegate.modeMap.selectedMode];
        } else {
//            NSLog(@" ***> %@ doesn't respond to menu%@", appDelegate.modeMap.selectedMode, [menuOption objectForKey:@"identifier"]);
        }
    } else {
        result.textField.stringValue = @"";
    }
    
//    if (row == highlightedRow) {
//        [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
//    }

    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = [self.tableView selectedRow];
    if (self.highlightedRow < 0 || self.highlightedRow >= self.tableView.numberOfRows) self.highlightedRow = 1;
    NSTableRowView *oldRowView = [self.tableView rowViewAtRow:self.highlightedRow makeIfNecessary:NO];
    if (selectedRow < 0 || selectedRow >= self.tableView.numberOfRows) selectedRow = 1;
    NSTableRowView *newRowView = [self.tableView rowViewAtRow:selectedRow makeIfNecessary:NO];
    CGFloat alpha = 0.2f;
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:.12f];
    [[NSAnimationContext currentContext] setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[oldRowView animator] setBackgroundColor:[NSColor clearColor]];
    [[newRowView animator] setBackgroundColor:NSColorFromRGBAlpha(0x000000, alpha)];
    [NSAnimationContext endGrouping];
    
//    NSLog(@"Highlighting row: %ld (was: %ld)", selectedRow, highlightedRow);
    self.highlightedRow = selectedRow;
    [self.tableView setNeedsDisplay:YES];
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    BOOL isSpace = [self isRowASpace:row];
    return !isSpace;
}

@end
