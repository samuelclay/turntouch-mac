//
//  RHPreferencesWindowController.m
//  RHPreferences
//
//  Created by Richard Heard on 10/04/12.
//  Copyright (c) 2012 Richard Heard. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions
//  are met:
//  1. Redistributions of source code must retain the above copyright
//  notice, this list of conditions and the following disclaimer.
//  2. Redistributions in binary form must reproduce the above copyright
//  notice, this list of conditions and the following disclaimer in the
//  documentation and/or other materials provided with the distribution.
//  3. The name of the author may not be used to endorse or promote products
//  derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
//  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
//  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
//  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


#import "RHPreferencesWindowController.h"
#import "RHPreferencesCustomPlaceholderController.h"


static NSString * const RHPreferencesWindowControllerSelectedItemIdentifier = @"RHPreferencesWindowControllerSelectedItemIdentifier";
//static const CGFloat RHPreferencesWindowControllerResizeAnimationDurationPer100Pixels = 0.05f;
static const CGFloat RHPreferencesWindowControllerResizeAnimationDuration = 0.2f;


@interface RHPreferencesWindowController ()

// Toolbar items:
- (NSToolbarItem *)toolbarItemWithItemIdentifier:(NSString *)anIdentifier;
- (NSToolbarItem *)newToolbarItemForViewController:(NSViewController<RHPreferencesViewControllerProtocol> *)aController;
- (void)reloadToolbarItems;
- (IBAction)selectToolbarItem:(NSToolbarItem *)anItem;
- (NSArray *)toolbarItemIdentifiers;

// NSWindowController methods:
- (void)resizeWindowForContentSize:(NSSize)size duration:(CGFloat)duration completionBlock:(void(^)(void))aBlock;

@end


@implementation RHPreferencesWindowController
{
    NSArray * toolbarItems;
    NSViewController<RHPreferencesViewControllerProtocol> * selectedViewController;
}
@synthesize toolbar, selectedIndex, viewControllers, defaultWindowTitle, windowUsesViewControllerTitle;

#pragma mark - Setup

- (instancetype)initWithViewControllers:(NSArray *)someControllers andTitle:(NSString *)aTitle
{
    if (!(self = [super initWithWindowNibName:@"RHPreferencesWindow"])) return nil;
    
    windowUsesViewControllerTitle = YES;
    [self setViewControllers:someControllers];
    defaultWindowTitle = [aTitle copy];
    
    return self;
}

- (instancetype)initWithViewControllers:(NSArray *)someControllers
{
    return [self initWithViewControllers:someControllers andTitle:@"Preferences"];
}

#pragma mark - Properties

- (NSString *)windowTitle
{
    return [self isWindowLoaded] ? [[self window] title] : defaultWindowTitle;
}

- (void)setWindowTitle:(NSString *)aWindowTitle
{
    if ([self isWindowLoaded]) {
        [[self window] setTitle:aWindowTitle];
    }
}

- (void)setViewControllers:(NSArray *)someViewControllers
{
    if ([viewControllers isEqualToArray:someViewControllers]) return;
    
    NSUInteger oldSelectedIndex = [self selectedIndex];
    viewControllers = someViewControllers;
    
    // Update the selected controller if we had one previously:
    if ([self selectedViewController]) {
        if (![viewControllers containsObject:[self selectedViewController]]) {
            [self setSelectedIndex:oldSelectedIndex]; // Reset the currently selected view controller.
        }
    }
    else {
        // Initial launch state (need to select previously selected tab):
        NSViewController * selectedController = [self viewControllerWithIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:RHPreferencesWindowControllerSelectedItemIdentifier]];
        if (selectedController) {
            [self setSelectedViewController:(NSViewController<RHPreferencesViewControllerProtocol> *)selectedController];
        }
        else {
            [self setSelectedIndex:0]; // Unknown, default to tab zero.
        }

    }

    [self reloadToolbarItems];
}

- (NSViewController<RHPreferencesViewControllerProtocol> *)selectedViewController
{
    return selectedViewController;
}

- (void)setSelectedViewController:(NSViewController<RHPreferencesViewControllerProtocol> *)aViewController
{
    NSViewController * previousViewController = [self selectedViewController];
    selectedViewController = aViewController; // Weak reference, because we retain it in our array.

    //stash to defaults also
    [[NSUserDefaults standardUserDefaults] setObject:[self toolbarItemIdentifierForViewController:aViewController] forKey:RHPreferencesWindowControllerSelectedItemIdentifier];
    
    // Bail if not yet loaded, or if the same view controller was selected:
    if (![self isWindowLoaded] || (previousViewController == aViewController)) return;
                
    // Notify the old view controller that it's going away:
    if ([previousViewController respondsToSelector:@selector(viewWillDisappear)]) {
        [(id)previousViewController viewWillDisappear];
    }
    
    [[previousViewController view] removeFromSuperview];
    
    if ([previousViewController respondsToSelector:@selector(viewDidDisappear)]) {
        [(id)previousViewController viewDidDisappear];
    }
    
    // Notify the new view controller of its appearance:
    if ([aViewController respondsToSelector:@selector(viewWillAppear)]) {
        [(id)aViewController viewWillAppear];
    }   
    /*
    // Resize to preferred window size for given view (duration is determined by difference between current and new sizes):
    float hDifference = fabs([[aViewController view] bounds].size.height - [[previousViewController view] bounds].size.height);
    float wDifference = fabs([[aViewController view] bounds].size.width - [[previousViewController view] bounds].size.width);
    float difference = MAX(hDifference, wDifference);
    float duration = MAX(RHPreferencesWindowControllerResizeAnimationDurationPer100Pixels * (difference / 100), 0.10); // We always want a slight animation.
    */
    float duration = RHPreferencesWindowControllerResizeAnimationDuration; // Use a constant duration, it's prettier.
    [self resizeWindowForContentSize:[[aViewController view] bounds].size duration:duration completionBlock:^(void) {
        // Make sure our "new" view controller is still selected before we add it as a subview, otherwise it's possible we could add more than one to the window (if another tab is selected during resizing):
        if (selectedViewController == aViewController) {
            [[[self window] contentView] addSubview:[aViewController view]];
            
            if ([aViewController respondsToSelector:@selector(viewDidAppear)]){
                [(id)aViewController viewDidAppear];
            }
            
            //if there is a initialKeyView set it as key
            if ([aViewController respondsToSelector:@selector(initialKeyView)]){
                [[aViewController initialKeyView] becomeFirstResponder];
            }
        }
    }];

    [[aViewController view] setFrameOrigin:NSMakePoint(0, 0)]; // Force our view to a 0,0 origin, fixed in the lower right corner.
    [[aViewController view] setAutoresizingMask:NSViewMaxXMargin|NSViewMaxYMargin];
    
    // Set the currently selected toolbar item:
    [toolbar setSelectedItemIdentifier:[self toolbarItemIdentifierForViewController:aViewController]];
            
    // If we should auto-update the window title, do it now:
    if ([self windowUsesViewControllerTitle]) {
        NSString * identifier = [self toolbarItemIdentifierForViewController:aViewController];
        NSString * title = [[self toolbarItemWithItemIdentifier:identifier] label];
        
        if (title) {
            [self setWindowTitle:title];
        }
        else {
            [self setWindowTitle:defaultWindowTitle];
        }
    }
    else {
        // Undo any changes that may have been made to the title of the window:
        [self setWindowTitle:defaultWindowTitle];
    }
}

- (NSUInteger)selectedIndex
{
    return [viewControllers indexOfObject:[self selectedViewController]];
}

- (void)setSelectedIndex:(NSUInteger)anIndex
{
    NSViewController<RHPreferencesViewControllerProtocol> * newSelection = (anIndex < [viewControllers count]) ? [viewControllers objectAtIndex:anIndex] : [viewControllers lastObject];
    [self setSelectedViewController:newSelection];
}

- (NSViewController<RHPreferencesViewControllerProtocol> *)viewControllerWithIdentifier:(NSString *)anIdentifier
{
    for (NSViewController<RHPreferencesViewControllerProtocol> * aViewController in viewControllers) {
        if ([aViewController respondsToSelector:@selector(toolbarItem)] && [[[aViewController toolbarItem] itemIdentifier] isEqualToString:anIdentifier]) {
            return aViewController;
        } 
        
        if ([[aViewController identifier] isEqualToString:anIdentifier]) {
            return aViewController;
        }
    }
    
    return nil;
}


#pragma mark - View Controller Methods

- (void)resizeWindowForContentSize:(NSSize)aSize duration:(CGFloat)aDuration completionBlock:(void(^)(void))aBlock
{
    NSWindow * window = [self window];
    
    NSRect frame = [window contentRectForFrameRect:[window frame]];
    
    CGFloat newX = NSMinX(frame) + (0.5 * (NSWidth(frame) - aSize.width));
    NSRect newFrame = [window frameRectForContentRect:NSMakeRect(newX, NSMaxY(frame) - aSize.height, aSize.width, aSize.height)];
    
    if (aDuration > 0.0f) {
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:aDuration];
        [[NSAnimationContext currentContext] setCompletionHandler:aBlock];
        
        [[window animator] setFrame:newFrame display:YES];
        
        [NSAnimationContext endGrouping];
    }
    else {
        [window setFrame:newFrame display:YES];
    }

}

#pragma mark - Toolbar Items

- (NSToolbarItem *)toolbarItemWithItemIdentifier:(NSString *)anIdentifier
{
    for (NSToolbarItem * item in toolbarItems) {
        if ([[item itemIdentifier] isEqualToString:anIdentifier]) {
            return item;
        }
    }
    
    return nil;
}

- (NSString *)toolbarItemIdentifierForViewController:(NSViewController *)aController
{
    if ([aController respondsToSelector:@selector(toolbarItem)]) {
        NSToolbarItem * item = [(id)aController toolbarItem];
        if (item) {
            return [item itemIdentifier];
        }
    }
    
    if ([aController respondsToSelector:@selector(identifier)]) {
        return [(id)aController identifier];
    }
    
    return nil;
}


- (NSToolbarItem *)newToolbarItemForViewController:(NSViewController<RHPreferencesViewControllerProtocol> *)aController
{
    NSToolbarItem * item;
    
    if ([aController respondsToSelector:@selector(toolbarItem)]) {
        // If the controller wants to provide a toolbar item, grab it:
        item = [aController toolbarItem];
        if (item) {
            item = [item copy]; // We copy the item because it needs to be unique for each toolbar.
        }
    }
    else {
        // Otherwise, create a new item:
        item = [[NSToolbarItem alloc] initWithItemIdentifier:[aController identifier]];
        [item setImage:[aController toolbarItemImage]];
        [item setLabel:[aController toolbarItemLabel]];
    }
    
    [item setTarget:self];
    [item setAction:@selector(selectToolbarItem:)];
    
    return item;
}

- (void)reloadToolbarItems
{
    NSMutableArray * newItems = [NSMutableArray arrayWithCapacity:[viewControllers count]];
    
    for (NSViewController<RHPreferencesViewControllerProtocol> * viewController in viewControllers) {
        NSToolbarItem * item = [self toolbarItemWithItemIdentifier:[viewController identifier]];
        if (!item) {
            item = [self newToolbarItemForViewController:viewController];
        }
        
        [newItems addObject:item];
    }
    
    toolbarItems = [NSArray arrayWithArray:newItems];
}


- (IBAction)selectToolbarItem:(NSToolbarItem *)anItem
{
    if ([selectedViewController commitEditing] && [[NSUserDefaultsController sharedUserDefaultsController] commitEditing]) {
        NSUInteger index = [toolbarItems indexOfObject:anItem];
        if (index != NSNotFound) {
            [self setSelectedViewController:[viewControllers objectAtIndex:index]];
        }
    }
    else {
        // Set the toolbar back to the current controller's selection:
        if ([selectedViewController respondsToSelector:@selector(toolbarItem)] && [[selectedViewController toolbarItem] itemIdentifier]) {
            [toolbar setSelectedItemIdentifier:[[selectedViewController toolbarItem] itemIdentifier]];
        }
        else if ([selectedViewController respondsToSelector:@selector(identifier)]) {
            [toolbar setSelectedItemIdentifier:[selectedViewController identifier]];
        }
    }
}

- (NSArray *)toolbarItemIdentifiers
{
    NSMutableArray * identifiers = [NSMutableArray arrayWithCapacity:[viewControllers count]];
    
    for (NSViewController<RHPreferencesViewControllerProtocol> * viewController in viewControllers) {
        [identifiers addObject:[self toolbarItemIdentifierForViewController:viewController]];
    }
    
    return identifiers; // Who cares if this is mutable, we aren't keeping it.
}

#pragma mark - Custom Placeholder Controller Toolbar Items

+ (id)separatorPlaceholderController
{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarSeparatorItemIdentifier];
}

+ (id)flexibleSpacePlaceholderController
{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarFlexibleSpaceItemIdentifier];
}

+ (id)spacePlaceholderController
{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarSpaceItemIdentifier]; 
}

+ (id)showColorsPlaceholderController
{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarShowColorsItemIdentifier]; 
}

+ (id)showFontsPlaceholderController
{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarShowFontsItemIdentifier]; 
}

+ (id)customizeToolbarPlaceholderController
{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarCustomizeToolbarItemIdentifier]; 
}

+ (id)printPlaceholderController
{
    return [RHPreferencesCustomPlaceholderController controllerWithIdentifier:NSToolbarPrintItemIdentifier]; 
}

#pragma mark - NSWindowController

- (void)loadWindow
{
    [super loadWindow];
    
    if (defaultWindowTitle) {
        [[self window] setTitle:defaultWindowTitle];
    }
    
    if (selectedViewController) {
        // Add the view to the window's content view:
        if ([selectedViewController respondsToSelector:@selector(viewWillAppear)]) {
            [selectedViewController viewWillAppear];
        }
        
        [[[self window] contentView] addSubview:[selectedViewController view]];
        
        if ([selectedViewController respondsToSelector:@selector(viewDidAppear)]) {
            [selectedViewController viewDidAppear];
        }        
        
        // Resize to preferred window size for given view:
        [self resizeWindowForContentSize:[[selectedViewController view] bounds].size duration:0.0f completionBlock:nil];
        
        [[selectedViewController view] setFrameOrigin:NSMakePoint(0, 0)];
        [[selectedViewController view] setAutoresizingMask:NSViewMaxXMargin|NSViewMaxYMargin];
        
        
        // Set the current controllers tab to selected:
        [toolbar setSelectedItemIdentifier:[self toolbarItemIdentifierForViewController:selectedViewController]];
        
        // If there is a initialKeyView set it as key:
        if ([selectedViewController respondsToSelector:@selector(initialKeyView)]) {
            [[selectedViewController initialKeyView] becomeFirstResponder];
        }
        
        // If we should auto-update the window title, do it now:
        if ([self windowUsesViewControllerTitle]) {
            NSString * identifier = [self toolbarItemIdentifierForViewController:selectedViewController];
            NSString * title = [[self toolbarItemWithItemIdentifier:identifier] label];
            if (title) {
                [self setWindowTitle:title];
            }
        }
    }
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(id)sender
{
    if (selectedViewController) {
        return [selectedViewController commitEditing];
    }
    
    return YES;
}

- (void)windowWillClose:(NSNotification *)aNotification {
    // Steal firstResponder away from text fields, to commit editing to bindings:
    [[self window] makeFirstResponder:self];
}

#pragma mark - NSToolbarDelegate

- (NSToolbarItem *)toolbar:(NSToolbar *)aToolbar itemForItemIdentifier:(NSString *)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
   return [self toolbarItemWithItemIdentifier:anItemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [self toolbarItemIdentifiers];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [self toolbarItemIdentifiers];
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return [self toolbarItemIdentifiers];
}

@end
