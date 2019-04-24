//
//  TTOptionsActionTitle.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/27/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTOptionsActionTitle.h"

#define DIAMOND_SIZE 18.0f

@interface TTOptionsActionTitle ()

@property (nonatomic, strong) TTDiamondView *diamondView;
@property (nonatomic, strong) NSButton *renameButton;
@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSLayoutConstraint *titleWidthConstraint;
@property (nonatomic) BOOL editingTitle;

@end

@implementation TTOptionsActionTitle

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.editingTitle = NO;
        
        [self registerAsObserver];
        
        self.diamondView = [[TTDiamondView alloc] initWithFrame:CGRectZero];
        self.diamondView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.diamondView setIgnoreSelectedMode:YES];
        [self.diamondView setIgnoreActiveMode:YES];
        [self.diamondView setOverrideActiveDirection:self.appDelegate.modeMap.inspectingModeDirection];
        [self addSubview:self.diamondView];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.diamondView attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeLeading multiplier:1 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.diamondView attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.diamondView attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1.3*DIAMOND_SIZE]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.diamondView attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:DIAMOND_SIZE]];

        self.changeButton = [[TTChangeButtonView alloc] init];
        self.changeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self setChangeButtonTitle:@"Change"];
        [self.changeButton setBezelStyle:NSRoundRectBezelStyle];
        [self.changeButton setAction:@selector(showChangeActionMenu:)];
        [self.changeButton setTarget:self];
        [self addSubview:self.changeButton];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.changeButton attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeTrailing multiplier:1 constant:-12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.changeButton attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.changeButton attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:82]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.changeButton attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24]];
        
        self.titleLabel = [[NSTextField alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.delegate = self;
        self.titleLabel.editable = NO;
        self.titleLabel.bordered = NO;
        self.titleLabel.backgroundColor = [NSColor clearColor];
        self.titleLabel.font = [NSFont fontWithName:@"Effra" size:13.f];
        self.titleLabel.textColor = NSColorFromRGB(0x404A60);
        NSShadow *stringShadow = [[NSShadow alloc] init];
        stringShadow.shadowColor = [NSColor whiteColor];
        stringShadow.shadowOffset = NSMakeSize(0, -1);
        stringShadow.shadowBlurRadius = 0;
        self.titleLabel.shadow = stringShadow;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel setTarget:self];
        [self.titleLabel setAction:@selector(renameTitle:)];
        [self addSubview:self.titleLabel];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual toItem:self.diamondView
                                                         attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:12.0f]];
        self.titleWidthConstraint = [NSLayoutConstraint constraintWithItem:self.titleLabel attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual toItem:nil
                                                            attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
        [self addConstraint:self.titleWidthConstraint];

        self.renameButton = [[NSButton alloc] init];
        self.renameButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.renameButton setHidden:YES];
        [self.renameButton setImage:[NSImage imageNamed:@"pencil"]];
        [self.renameButton setImageScaling:NSImageScaleProportionallyDown];
        [self.renameButton setBordered:NO];
        [self.renameButton setButtonType:NSButtonTypeMomentaryChange];
        [self.renameButton setAction:@selector(editCustomTitle:)];
        [self.renameButton setTarget:self];
        [self addSubview:self.renameButton];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.renameButton attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual toItem:self.titleLabel
                                                         attribute:NSLayoutAttributeTrailing multiplier:1 constant:12]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.renameButton attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual toItem:self
                                                         attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.renameButton attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:18]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.renameButton attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:18]];
        
    }
    return self;
}

#pragma mark - KVO

- (void)dealloc {
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        [self.diamondView setOverrideActiveDirection:self.appDelegate.modeMap.inspectingModeDirection];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    if (self.appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) return;
    
    [super drawRect:dirtyRect];
    
    TTModeDirection labelDirection = self.appDelegate.modeMap.inspectingModeDirection;
    
    NSString *actionTitle = [self.appDelegate.modeMap.selectedMode titleInDirection:labelDirection buttonMoment:BUTTON_MOMENT_PRESSUP];
    self.titleLabel.stringValue = actionTitle;
    self.titleWidthConstraint.constant = [self.titleLabel intrinsicContentSize].width;

    if (self.appDelegate.modeMap.openedActionChangeMenu) {
        [self setChangeButtonTitle:@"Done"];
        [self.renameButton setHidden:NO];
    } else {
        [self setChangeButtonTitle:@"Change"];
        [self.renameButton setHidden:YES];
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
//    [self.changeButton setAttributedTitle:attributedString];
    [self.changeButton setTitle:title];
}

#pragma mark - Events

- (void)showChangeActionMenu:(id)sender {
    [self.appDelegate.modeMap setOpenedActionChangeMenu:!self.appDelegate.modeMap.openedActionChangeMenu];
    [self setNeedsDisplay:YES];
}

#pragma mark - NSTextField Delegate

- (void)editCustomTitle:(id)sender {
    if (self.editingTitle) {
        [self.appDelegate.modeMap.selectedMode setCustomTitle:nil
                                               direction:self.appDelegate.modeMap.inspectingModeDirection];

        [self disableCustomTitleEditor];
    } else {
        [self.renameButton setImage:[NSImage imageNamed:@"button_chevron_x"]];

        [self.titleLabel setEditable:YES];
        
        TTModeDirection labelDirection = self.appDelegate.modeMap.inspectingModeDirection;
        NSString *actionTitle = [self.appDelegate.modeMap.selectedMode titleInDirection:labelDirection buttonMoment:BUTTON_MOMENT_PRESSUP];
        self.titleLabel.stringValue = actionTitle;
        [self.titleLabel selectText:actionTitle];
        self.titleWidthConstraint.constant = 100;

        self.editingTitle = YES;
    }
}

- (void)disableCustomTitleEditor {
    [self.renameButton setImage:[NSImage imageNamed:@"pencil"]];
    [self.renameButton setHidden:YES];

    [[self.titleLabel currentEditor] setSelectedRange:NSMakeRange(0, 0)];
    [[self.titleLabel currentEditor] setSelectable:NO];
    [self.titleLabel setEditable:NO];
    
    self.titleWidthConstraint.constant = [self.titleLabel intrinsicContentSize].width;
    
    self.editingTitle = NO;
    
    [self.appDelegate.panelController.backgroundView.diamondLabels setNeedsDisplay:YES];
    
    [self setNeedsDisplay:YES];
}

- (void)renameTitle:(id)sender {
    [self.appDelegate.modeMap.selectedMode setCustomTitle:self.titleLabel.stringValue
                                           direction:self.appDelegate.modeMap.inspectingModeDirection];
    
    [self disableCustomTitleEditor];
}

- (void)cancelOperation:(id)sender {
    [self disableCustomTitleEditor];
}

@end
