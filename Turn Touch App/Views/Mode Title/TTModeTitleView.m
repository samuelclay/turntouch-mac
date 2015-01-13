//
//  TTModeTitleView.m
//  Turn Touch App
//
//  Created by Samuel Clay on 4/10/14.
//  Copyright (c) 2014 Turn Touch. All rights reserved.
//

#import "TTModeTitleView.h"

#define IMAGE_SIZE 32.0f
#define BUTTON_WIDTH 82.0f

@implementation TTModeTitleView

@synthesize changeButton;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        self.translatesAutoresizingMaskIntoConstraints = NO;

        changeButton = [[TTChangeButtonView alloc] init];
        [self setChangeButtonTitle:@"change"];
        [changeButton setAction:@selector(showChangeModeMenu:)];
        [changeButton setTarget:self];
        [self addSubview:changeButton];
        
        [self registerAsObserver];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self setupTitleAttributes];
    [self drawBackground];

    modeImage = [NSImage imageNamed:[[appDelegate.modeMap.selectedMode class] imageName]];
    [modeImage setSize:NSMakeSize(IMAGE_SIZE, IMAGE_SIZE)];
    CGFloat offset = (NSHeight(self.frame)/2) - (modeImage.size.height/2);
    NSPoint imagePoint = NSMakePoint(offset, offset);
    [modeImage drawInRect:NSMakeRect(imagePoint.x, imagePoint.y,
                                     modeImage.size.width, modeImage.size.height)];

    NSSize titleSize = [modeTitle sizeWithAttributes:modeAttributes];
    NSPoint titlePoint = NSMakePoint(imagePoint.x + modeImage.size.width + 12,
                                     (NSHeight(self.frame)/2) - (titleSize.height/2));
    [modeTitle drawAtPoint:titlePoint withAttributes:modeAttributes];

    NSRect buttonFrame = NSMakeRect(NSWidth(self.frame) - BUTTON_WIDTH - 12,
                                    (NSHeight(self.frame)/2) - (32.0f/2),
                                    BUTTON_WIDTH, NSHeight(self.frame) - 32.0f);
    changeButton.frame = buttonFrame;
    if (appDelegate.modeMap.openedModeChangeMenu) {
        [self setChangeButtonTitle:@"cancel"];
    } else {
        [self setChangeButtonTitle:@"change"];
    }
}

- (void)drawBackground {
    [[NSColor whiteColor] setFill];
    NSRectFill(self.bounds);
}

#pragma mark - Attributes

- (void)setChangeButtonTitle:(NSString *)title {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                   initWithString:title attributes:nil];
    [changeButton setAttributedTitle:attributedString];
}

- (void)setupTitleAttributes {
    modeTitle = [[appDelegate.modeMap.selectedMode class] description];
    NSShadow *stringShadow = [[NSShadow alloc] init];
    stringShadow.shadowColor = [NSColor whiteColor];
    stringShadow.shadowOffset = NSMakeSize(0, -1);
    stringShadow.shadowBlurRadius = 0;
    NSColor *textColor = NSColorFromRGB(0x404A60);
    modeAttributes = @{NSFontAttributeName:[NSFont fontWithName:@"Effra" size:13],
                       NSForegroundColorAttributeName: textColor,
                       NSShadowAttributeName: stringShadow
                       };
    textSize = [modeTitle sizeWithAttributes:modeAttributes];
}

#pragma mark - KVO

- (void)dealloc {
    [appDelegate.modeMap removeObserver:self forKeyPath:@"selectedMode"];
}

- (void)registerAsObserver {
    [appDelegate.modeMap addObserver:self forKeyPath:@"selectedMode"
                             options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(selectedMode))]) {
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Events

- (void)showChangeModeMenu:(id)sender {
    [appDelegate.modeMap setOpenedModeChangeMenu:!appDelegate.modeMap.openedModeChangeMenu];
    [appDelegate.modeMap setInspectingModeDirection:NO_DIRECTION];
    [self setNeedsDisplay:YES];
}

@end
