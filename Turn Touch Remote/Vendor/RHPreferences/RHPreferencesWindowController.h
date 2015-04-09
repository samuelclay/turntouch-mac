//
//  RHPreferencesWindowController.h
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


#import <Cocoa/Cocoa.h>

@protocol RHPreferencesViewControllerProtocol;


@interface RHPreferencesWindowController : NSWindowController <NSToolbarDelegate>

- (id)initWithViewControllers:(NSArray *)controllers;
- (id)initWithViewControllers:(NSArray *)controllers andTitle:(NSString *)title;


- (NSString *)windowTitle;
- (void)setWindowTitle:(NSString *)aTitle;
@property (readwrite, copy) NSString * defaultWindowTitle;
/** The defaultWindowTitle is used in any case where a title couldn't be retrieved from a toolbar item, or if 
 ** windowUsesViewControllerTitle is set to NO. **/

@property (readwrite, assign) BOOL windowUsesViewControllerTitle;
/** @note: Defaults to YES. **/

@property (readwrite, unsafe_unretained) IBOutlet NSToolbar * toolbar;
@property (readonly, strong) NSArray * viewControllers;
/** @note: Controllers should implement RHPreferencesViewControllerProtocol. **/

@property (readwrite, assign) NSUInteger selectedIndex;

- (NSViewController<RHPreferencesViewControllerProtocol> *)selectedViewController;
- (void)setSelectedViewController:(NSViewController<RHPreferencesViewControllerProtocol> *)aViewController;

- (NSViewController<RHPreferencesViewControllerProtocol> *)viewControllerWithIdentifier:(NSString *)identifier;

// You can include these placeholder controllers amongst your array of view controllers to show their respective items in the toolbar:
+ (id)separatorPlaceholderController;        // NSToolbarSeparatorItemIdentifier
+ (id)flexibleSpacePlaceholderController;    // NSToolbarFlexibleSpaceItemIdentifier
+ (id)spacePlaceholderController;            // NSToolbarSpaceItemIdentifier

+ (id)showColorsPlaceholderController;       // NSToolbarShowColorsItemIdentifier
+ (id)showFontsPlaceholderController;        // NSToolbarShowFontsItemIdentifier
+ (id)customizeToolbarPlaceholderController; // NSToolbarCustomizeToolbarItemIdentifier
+ (id)printPlaceholderController;            // NSToolbarPrintItemIdentifier

@end


@protocol RHPreferencesViewControllerProtocol <NSObject>
/** Implement this protocol on your view controller so that RHPreferencesWindow knows what to show in the tabbar. Label, image, etc. **/

@required

@property (readonly, copy) NSString * identifier;
@property (readonly, strong) NSImage * toolbarItemImage;
@property (readonly, copy) NSString * toolbarItemLabel;

@optional

@property (readonly, strong) NSToolbarItem * toolbarItem; // Optional, overrides the above 3 properties. Allows for custom tab bar items.

// Methods called when switching between tabs:
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;

- (NSView *)initialKeyView; // View that will be focused upon switching to this tab.

@end
