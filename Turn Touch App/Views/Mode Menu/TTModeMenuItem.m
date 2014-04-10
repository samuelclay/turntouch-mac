//
//  TTModeMenuItem.m
//  Turn Touch App
//
//  Created by Samuel Clay on 11/5/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#import "TTModeMenuItem.h"

#define DIAMOND_SIZE 22.0f

@implementation TTModeMenuItem

@synthesize changeButton;

- (id)initWithFrame:(NSRect)frame direction:(TTModeDirection)direction {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = [NSApp delegate];
        modeDirection = direction;
        hoverActive = NO;
        
        NSRect diamondRect = NSMakeRect((NSWidth(frame) / 2) - (DIAMOND_SIZE / 2),
                                        NSHeight(frame) - 18 - DIAMOND_SIZE,
                                        DIAMOND_SIZE * 1.3, DIAMOND_SIZE);
        diamondView = [[TTDiamondView alloc] initWithFrame:diamondRect];
        [diamondView setOverrideSelectedDirection:modeDirection];
        [diamondView setIgnoreSelectedMode:YES];
        [self addSubview:diamondView];

        changeButton = [[NSButton alloc] init];
        [self setChangeButtonTitle:@"change"];
        [changeButton setBezelStyle:NSInlineBezelStyle];
        [changeButton setAlphaValue:0];
        [changeButton setHidden:YES];
        [changeButton setAction:@selector(showChangeModeMenu:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
        
        modeDropdown = [[NSPopUpButton alloc] init];
        [modeDropdown setHidden:YES];
        [modeDropdown setAction:@selector(changeModeDropdown:)];
        [modeDropdown setTarget:self];
        [self addSubview:modeDropdown];
        
        [self setupMode];
        [self registerAsObserver];
        [self createTrackingArea];
    }
    
    return self;
}

- (void)setupMode {
    switch (modeDirection) {
        case NORTH:
            itemMode = appDelegate.modeMap.northMode;
            break;
        case EAST:
            itemMode = appDelegate.modeMap.eastMode;
            break;
        case WEST:
            itemMode = appDelegate.modeMap.westMode;
            break;
        case SOUTH:
            itemMode = appDelegate.modeMap.southMode;
            break;
        case NO_DIRECTION:
            break;
    }
    
    [self drawBackground];

    modeImage = [NSImage imageNamed:[itemMode imageName]];
    
    modeTitle = [[[itemMode class] title] uppercaseString];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = (hoverActive && appDelegate.modeMap.selectedModeDirection != modeDirection) ? NSColorFromRGB(0x404A60) :
    appDelegate.modeMap.selectedModeDirection == modeDirection ?
    NSColorFromRGB(0x404A60) : NSColorFromRGB(0x808388);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Futura" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

#pragma mark - KVO

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"activeModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedModeDirection"
                             options:0 context:nil];
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(activeModeDirection))] ||
        [keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        if (appDelegate.modeMap.selectedModeDirection == modeDirection) {
            [diamondView setIgnoreSelectedMode:NO];
            [diamondView setIgnoreActiveMode:NO];
            [self setupMode];
            [self setNeedsDisplay:YES];
        } else {
            [diamondView setIgnoreSelectedMode:YES];
            [diamondView setIgnoreActiveMode:YES];
        }
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(selectedModeDirection))]) {
        [self setupMode];
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
//    [modeImage drawInRect:NSMakeRect(12, 6, 24, 24)
//                 fromRect:NSZeroRect
//                operation:NSCompositeSourceOver
//                 fraction:1.0];
    
    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    NSPoint titlePoint = NSMakePoint((NSWidth(self.frame)/2) - (titleSize.width/2),
                                     18);

    if (isModeChangeActive) {
        [modeDropdown setHidden:NO];
        [modeDropdown setFrame:NSMakeRect(44, titlePoint.y - 3, 160, 24)];
        NSRect buttonFrame = NSMakeRect(titlePoint.x + 160 + 12, titlePoint.y + 3, 50, 12);
        [self setChangeButtonTitle:@"cancel"];
        changeButton.frame = buttonFrame;
    } else {
        [modeDropdown setHidden:YES];
        [modeTitle drawAtPoint:titlePoint withAttributes:modeAttributes];
        NSRect buttonFrame = NSMakeRect(titlePoint.x + titleSize.width + 12, titlePoint.y + 3, 50, 12);
        [self setChangeButtonTitle:@"change"];
        changeButton.frame = buttonFrame;
    }
}

- (void)createTrackingArea {
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    NSTrackingArea *trackingArea = [ [NSTrackingArea alloc] initWithRect:[self bounds]
                                                                 options:opts
                                                                   owner:self
                                                                userInfo:nil];
    [self addTrackingArea:trackingArea];
}

- (void)setChangeButtonTitle:(NSString *)title {
    NSMutableParagraphStyle *centredStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [centredStyle setLineHeightMultiple:0.6f];
    [centredStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:centredStyle,
                           NSParagraphStyleAttributeName,
                           [NSFont fontWithName:@"Helvetica-Bold" size:8.f],
                           NSFontAttributeName,
                           [NSColor whiteColor],
                           NSForegroundColorAttributeName,
                           nil];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:[title uppercaseString] attributes:attrs];
    [changeButton setAttributedTitle:attributedString];
}

- (void)drawBackground {
    if (appDelegate.modeMap.selectedModeDirection == modeDirection) {
        [self setWantsLayer:YES]; // view's backing store is using a Core Animation Layer
        [self.layer setBackgroundColor:CGColorCreateGenericRGB(1, 1, 1, 1)];
    } else {
        [self.layer setBackgroundColor:nil];
    }
}

- (void)drawBorders {
    BOOL leftActive = (appDelegate.modeMap.selectedModeDirection == modeDirection &&
                       modeDirection != NORTH);
    BOOL rightActive = (appDelegate.modeMap.selectedModeDirection == modeDirection &&
                        modeDirection != SOUTH);
}

#pragma mark - Actions

- (void)mouseEntered:(NSEvent *)theEvent {
    [[NSCursor pointingHandCursor] set];
    
//    NSLog(@"Mouse entered");
    hoverActive = YES;
    [self setupMode];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[NSCursor arrowCursor] set];

//    NSLog(@"Mouse exited");
    hoverActive = NO;
    [self setupMode];
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (appDelegate.modeMap.selectedModeDirection != modeDirection) {
        [appDelegate.modeMap setSelectedModeDirection:modeDirection];
    }
}

- (void)showChangeModeMenu:(id)sender {
    if (isModeChangeActive) {
        isModeChangeActive = NO;
        [self setNeedsDisplay:YES];
    } else {
        isModeChangeActive = YES;
        [modeDropdown removeAllItems];
        [modeDropdown addItemsWithTitles:appDelegate.modeMap.availableModeTitles];
        [self setNeedsDisplay:YES];
        NSInteger selectedIndex = 0;
        for (NSString *modeClass in appDelegate.modeMap.availableModeClassNames) {
            if ([modeClass isEqualToString:NSStringFromClass([itemMode class])]) {
                break;
            }
            selectedIndex++;
        }
        [modeDropdown selectItemAtIndex:selectedIndex];
    }
}

- (void)changeModeDropdown:(id)sender {
    NSString *newModeClassName = [appDelegate.modeMap.availableModeClassNames
                                  objectAtIndex:[sender indexOfSelectedItem]];
    [appDelegate.modeMap changeDirection:modeDirection toMode:newModeClassName];
    isModeChangeActive = NO;
    [self setupMode];
    [self setNeedsDisplay:YES];
}

- (void)hidePopupMenu {
    if (isModeChangeActive) {
        isModeChangeActive = NO;
        [self setNeedsDisplay:YES];
    }
}

@end
