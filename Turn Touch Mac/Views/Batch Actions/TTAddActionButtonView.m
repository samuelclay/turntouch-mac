//
//  TTActionAddView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 12/17/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTAddActionButtonView.h"
#import "TTChangeButtonView.h"

#define ADD_BUTTON_WIDTH 120

@interface TTAddActionButtonView ()

@property (nonatomic, strong) TTChangeButtonView *addButton;

@end

@implementation TTAddActionButtonView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        // Clip to bounds so the centered button isn't drawn over its neighbors
        // while the row is collapsed to zero height (not inspecting an action).
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;

        self.addButton = [[TTChangeButtonView alloc] init];
        [self.addButton setBorderRadius:12.f];
        [self setChangeButtonTitle:@"Add Action"];
        [self.addButton setAction:@selector(showAddActionMenu:)];
        [self.addButton setTarget:self];
        NSImage *icon = [NSImage imageNamed:@"button_plus"];
        [icon setSize:NSMakeSize(15, 10)];
        [self.addButton setImage:icon];
        [self.addButton setImagePosition:NSImageRight];
        [self addSubview:self.addButton];
        
        [self registerAsObserver];
    }
    
    return self;
}


#pragma mark - KVO

- (void)registerAsObserver {
    [self.appDelegate.modeMap addObserver:self forKeyPath:@"inspectingModeDirection"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(inspectingModeDirection))]) {
        if (self.appDelegate.modeMap.inspectingModeDirection == NO_DIRECTION) {
            // Only hide when switching modes (or closing actions), not when switching actions
            [self hideAddActionMenu:nil];
        }
    }
}

- (void)dealloc {
    [self.appDelegate.modeMap removeObserver:self forKeyPath:@"inspectingModeDirection"];
}

#pragma mark - Drawing

//- (void)adjustHeight {
//    [appDelegate.panelController.backgroundView toggleAddButtonView];
//}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self drawBackground];
}

- (void)drawBackground {
    [NSColorFromRGB(0xFFFFFF) set];
    NSRectFill(self.bounds);
}

- (void)layout {
    [super layout];
    [self layoutAddButton];
}

- (void)layoutAddButton {
    static const CGFloat buttonHeight = 24.f;
    CGFloat x = MAX(0.f, floor((NSWidth(self.bounds) - ADD_BUTTON_WIDTH) / 2.f));
    CGFloat y = MAX(0.f, floor((NSHeight(self.bounds) - buttonHeight) / 2.f));
    NSRect buttonFrame = NSMakeRect(x,
                                    y,
                                    ADD_BUTTON_WIDTH, buttonHeight);
    self.addButton.frame = buttonFrame;
}

- (void)setChangeButtonTitle:(NSString *)title {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:title attributes:nil];
    [self.addButton setAttributedTitle:attributedString];
}

- (IBAction)showAddActionMenu:(id)sender {
    [self setChangeButtonTitle:@"Cancel"];
    [self.addButton setAction:@selector(hideAddActionMenu:)];
    NSImage *icon = [NSImage imageNamed:@"button_x"];
    [icon setSize:NSMakeSize(15, 10)];
    [self.addButton setImage:icon];
    [self.addButton setImagePosition:NSImageLeft];
    
    if (self.appDelegate.modeMap.tempModeName) {
        [self.appDelegate.modeMap setTempModeName:nil];
    }
    [self.appDelegate.modeMap setOpenedAddActionChangeMenu:YES];
}

- (IBAction)hideAddActionMenu:(id)sender {
    [self setChangeButtonTitle:@"Add Action"];
    [self.addButton setAction:@selector(showAddActionMenu:)];
    NSImage *icon = [NSImage imageNamed:@"button_plus"];
    [icon setSize:NSMakeSize(15, 10)];
    [self.addButton setImage:icon];
    [self.addButton setImagePosition:NSImageRight];

    if (self.appDelegate.modeMap.tempModeName) {
        [self.appDelegate.modeMap setTempModeName:nil];
    }
    if (self.appDelegate.modeMap.openedAddActionChangeMenu) {
        [self.appDelegate.modeMap setOpenedAddActionChangeMenu:NO];
    }
    
    [self.appDelegate.panelController.backgroundView adjustBatchActionsHeight:YES];
}

@end
