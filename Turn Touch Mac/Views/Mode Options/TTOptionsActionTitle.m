//
//  TTOptionsActionTitle.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTOptionsActionTitle.h"

#define DIAMOND_SIZE 18.0f

@implementation TTOptionsActionTitle

@synthesize changeButton;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        editingTitle = NO;
        
        [self registerAsObserver];
        
        diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero];
        diamondView.translatesAutoresizingMaskIntoConstraints = NO;
        [diamondView setIgnoreSelectedMode:YES];
        [diamondView setIgnoreActiveMode:YES];
        [diamondView setOverrideActiveDirection:appDelegate.modeMap.inspectingModeDirection];
        [self addSubview:diamondView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:diamondView attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeLeading multiplier:1 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:diamondView attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:diamondView attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1.3*DIAMOND_SIZE]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:diamondView attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:DIAMOND_SIZE]];

        changeButton = [[TTChangeButtonView alloc] init];
        changeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self setChangeButtonTitle:@"Change"];
        [changeButton setBezelStyle:NSRoundRectBezelStyle];
        [changeButton setAction:@selector(showChangeActionMenu:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:changeButton attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeTrailing multiplier:1 constant:-12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:changeButton attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:changeButton attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:82]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:changeButton attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24]];
        
        titleLabel = [[NSTextField alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.delegate = self;
        titleLabel.editable = NO;
        titleLabel.bordered = NO;
        titleLabel.backgroundColor = [NSColor clearColor];
        titleLabel.font = [NSFont fontWithName:@"Effra" size:13.f];
        titleLabel.textColor = NSColorFromRGB(0x404A60);
        NSShadow *stringShadow = [[NSShadow alloc] init];
        stringShadow.shadowColor = [NSColor whiteColor];
        stringShadow.shadowOffset = NSMakeSize(0, -1);
        stringShadow.shadowBlurRadius = 0;
        titleLabel.shadow = stringShadow;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [titleLabel setTarget:self];
        [titleLabel setAction:@selector(renameTitle:)];
        [self addSubview:titleLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual toItem:diamondView
                                                         attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:12.0f]];
        titleWidthConstraint = [NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        [self addConstraint:titleWidthConstraint];

        renameButton = [[NSButton alloc] init];
        renameButton.translatesAutoresizingMaskIntoConstraints = NO;
        [renameButton setHidden:YES];
        [renameButton setImage:[NSImage imageNamed:@"pencil"]];
        [renameButton setImageScaling:NSImageScaleProportionallyDown];
        [renameButton setBordered:NO];
        [renameButton setButtonType:NSButtonTypeMomentaryChange];
        [renameButton setAction:@selector(editCustomTitle:)];
        [renameButton setTarget:self];
        [self addSubview:renameButton];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:renameButton attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual toItem:titleLabel
                                                         attribute:NSLayoutAttributeTrailing multiplier:1 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:renameButton attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:renameButton attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:18]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:renameButton attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:18]];
        
    }
    return self;
}

#pragma mark - KVO

- (void)dealloc {
    [appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [diamondView setOverrideActiveDirection:appDelegate.modeMap.inspectingModeDirection];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    if (appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) return;
    
    [super drawRect:dirtyRect];
    
    TTModeDirection labelDirection = appDelegate.modeMap.inspectingModeDirection;
    
    NSString *actionTitle = [appDelegate.modeMap.selectedMode titleInDirection:labelDirection buttonMoment:BUTTON_MOMENT_PRESSUP];
    titleLabel.stringValue = actionTitle;
    titleWidthConstraint.constant = [titleLabel intrinsicContentSize].width;

    if (appDelegate.modeMap.openedActionChangeMenu) {
        [self setChangeButtonTitle:@"Done"];
        [renameButton setHidden:NO];
    } else {
        [self setChangeButtonTitle:@"Change"];
        [renameButton setHidden:YES];
    }
}

#pragma mark - Attributes

- (void)setChangeButtonTitle:(NSString *)title {
//    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    [centredStyle setLineHeightMultiple:0.6f];
//    [centredStyle setAlignment:NSCenterTextAlignment];
//    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
//                           NSParagraphStyleAttributeName,
//                           [NSFont fontWithName:@"Effra" size:10.f],
//                           NSFontAttributeName,
//                           NSColorFromRGB(0xA0A3A8),
//                           NSForegroundColorAttributeName,
//                           nil];
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
//                                                   initWithString:[title uppercaseString] attributes:attrs];
//    [changeButton setAttributedTitle:attributedString];
    [changeButton setTitle:title];
}

#pragma mark - Events

- (void)showChangeActionMenu:(id)sender {
    [appDelegate.modeMap setOpenedActionChangeMenu:!appDelegate.modeMap.openedActionChangeMenu];
    [self setNeedsDisplay:YES];
}

#pragma mark - NSTextField Delegate

- (void)editCustomTitle:(id)sender {
    if (editingTitle) {
        [appDelegate.modeMap.selectedMode setCustomTitle:nil
                                               direction:appDelegate.modeMap.inspectingModeDirection];

        [self disableCustomTitleEditor];
    } else {
        [renameButton setImage:[NSImage imageNamed:@"button_chevron_x"]];

        [titleLabel setEditable:YES];
        
        TTModeDirection labelDirection = appDelegate.modeMap.inspectingModeDirection;
        NSString *actionTitle = [appDelegate.modeMap.selectedMode titleInDirection:labelDirection buttonMoment:BUTTON_MOMENT_PRESSUP];
        titleLabel.stringValue = actionTitle;
        [titleLabel selectText:actionTitle];
        titleWidthConstraint.constant = 100;

        editingTitle = YES;
    }
}

- (void)disableCustomTitleEditor {
    [renameButton setImage:[NSImage imageNamed:@"pencil"]];
    [renameButton setHidden:YES];

    [[titleLabel currentEditor] setSelectedRange:NSMakeRange(0, 0)];
    [[titleLabel currentEditor] setSelectable:NO];
    [titleLabel setEditable:NO];
    
    titleWidthConstraint.constant = [titleLabel intrinsicContentSize].width;
    
    editingTitle = NO;
    
    [appDelegate.panelController.backgroundView.diamondLabels setNeedsDisplay:YES];
    
    [self setNeedsDisplay:YES];
}

- (void)renameTitle:(id)sender {
    [appDelegate.modeMap.selectedMode setCustomTitle:titleLabel.stringValue
                                           direction:appDelegate.modeMap.inspectingModeDirection];
    
    [self disableCustomTitleEditor];
}

- (void)cancelOperation:(id)sender {
    [self disableCustomTitleEditor];
}

@end
