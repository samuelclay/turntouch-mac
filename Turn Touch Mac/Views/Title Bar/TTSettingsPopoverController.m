#import "TTSettingsPopoverController.h"
#import "TTAppDelegate.h"
#import "TTDevice.h"
#import "TTOptionsDetailViewController.h"
#import "TTHomeAssistantWindowController.h"

@interface TTSettingsDocumentView : NSView
@end
@implementation TTSettingsDocumentView
- (BOOL)isFlipped { return YES; }
@end

@interface TTSettingsRow : NSButton
@property (nonatomic, copy) void (^handler)(void);
@end
@implementation TTSettingsRow
- (void)invoke:(id)sender { if (self.handler) self.handler(); }
@end

@interface TTSettingsPopoverController ()
@property (nonatomic) NSStackView *sections;
@property (nonatomic) NSScrollView *scroll;
@property (nonatomic) NSTextField *modeHint;
@property (nonatomic) BOOL showAllApps;
@property (nonatomic) NSWindowController *connectionWindow;
@property (nonatomic) TTOptionsDetailViewController *connectionOptions;
@property (nonatomic) TTHomeAssistantWindowController *homeAssistantWindow;
@end

@implementation TTSettingsPopoverController

- (NSTextField *)label:(NSString *)text size:(CGFloat)size color:(NSColor *)color {
    NSTextField *label = [NSTextField wrappingLabelWithString:text];
    label.font = [NSFont systemFontOfSize:size];
    label.textColor = color;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
}

- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 340, 600)];
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor colorWithWhite:0.96 alpha:1].CGColor;
    NSTextField *title = [self label:TTText(@"Settings") size:17 color:NSColor.labelColor];
    title.font = [NSFont boldSystemFontOfSize:17];
    [self.view addSubview:title];
    NSButton *done = [NSButton buttonWithTitle:TTText(@"Done") target:self action:@selector(done:)];
    done.bezelStyle = NSBezelStyleInline;
    done.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:done];
    self.scroll = [[NSScrollView alloc] init];
    self.scroll.translatesAutoresizingMaskIntoConstraints = NO;
    self.scroll.hasVerticalScroller = YES;
    self.scroll.drawsBackground = NO;
    [self.view addSubview:self.scroll];
    TTSettingsDocumentView *document = [[TTSettingsDocumentView alloc] init];
    document.translatesAutoresizingMaskIntoConstraints = NO;
    self.scroll.documentView = document;
    self.sections = [NSStackView stackViewWithViews:@[]];
    self.sections.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.sections.alignment = NSLayoutAttributeLeading;
    self.sections.spacing = 12;
    self.sections.translatesAutoresizingMaskIntoConstraints = NO;
    [document addSubview:self.sections];
    [NSLayoutConstraint activateConstraints:@[
        [title.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18],
        [title.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
        [done.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [done.centerYAnchor constraintEqualToAnchor:title.centerYAnchor],
        [self.scroll.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:48],
        [self.scroll.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scroll.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scroll.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [document.widthAnchor constraintEqualToAnchor:self.scroll.contentView.widthAnchor],
        [self.sections.leadingAnchor constraintEqualToAnchor:document.leadingAnchor constant:14],
        [self.sections.trailingAnchor constraintEqualToAnchor:document.trailingAnchor constant:-14],
        [self.sections.topAnchor constraintEqualToAnchor:document.topAnchor constant:8],
        [self.sections.bottomAnchor constraintEqualToAnchor:document.bottomAnchor constant:-18]
    ]];
    [self rebuildSections];
}

- (TTSettingsRow *)row:(NSString *)title subtitle:(NSString *)subtitle image:(NSString *)image handler:(void (^)(void))handler {
    TTSettingsRow *row = [[TTSettingsRow alloc] init];
    row.translatesAutoresizingMaskIntoConstraints = NO;
    row.bordered = NO;
    row.alignment = NSTextAlignmentLeft;
    row.imagePosition = image ? NSImageLeft : NSNoImage;
    if (image) {
        NSImage *icon = [[NSImage imageNamed:image] copy];
        icon.size = NSMakeSize(24, 24);
        row.image = icon;
    }
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[@"  " stringByAppendingString:title] attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:13 weight:NSFontWeightMedium], NSForegroundColorAttributeName:NSColor.labelColor}];
    if (subtitle.length) [text appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n  %@", subtitle] attributes:@{NSFontAttributeName:[NSFont systemFontOfSize:11], NSForegroundColorAttributeName:NSColor.secondaryLabelColor}]];
    row.attributedTitle = text;
    row.accessibilityLabel = title;
    row.accessibilityHelp = subtitle;
    row.handler = handler;
    row.target = row;
    row.action = @selector(invoke:);
    [row.heightAnchor constraintEqualToConstant:subtitle.length ? 52 : 38].active = YES;
    return row;
}

- (NSStackView *)section:(NSString *)title views:(NSArray<NSView *> *)views {
    NSTextField *heading = [self label:title size:10 color:NSColor.secondaryLabelColor];
    heading.font = [NSFont systemFontOfSize:10 weight:NSFontWeightSemibold];
    [self.sections addArrangedSubview:heading];
    NSStackView *card = [NSStackView stackViewWithViews:views];
    card.orientation = NSUserInterfaceLayoutOrientationVertical;
    card.alignment = NSLayoutAttributeLeading;
    card.spacing = 0;
    card.edgeInsets = NSEdgeInsetsMake(4, 8, 4, 8);
    card.wantsLayer = YES;
    card.layer.backgroundColor = NSColor.whiteColor.CGColor;
    card.layer.cornerRadius = 12;
    [self.sections addArrangedSubview:card];
    [card.widthAnchor constraintEqualToAnchor:self.sections.widthAnchor].active = YES;
    for (NSView *view in views) [view.widthAnchor constraintEqualToAnchor:card.widthAnchor constant:-16].active = YES;
    return card;
}

- (void)rebuildSections {
    for (NSView *view in self.sections.arrangedSubviews.copy) { [self.sections removeArrangedSubview:view]; [view removeFromSuperview]; }
    __weak typeof(self) weakSelf = self;
    [self section:TTText(@"Language") views:@[[self row:TTText(@"Language") subtitle:TTLocalization.displayName image:nil handler:^{
        [weakSelf done:nil]; [TTLocalization showLanguagePicker];
    }]]];
    NSMutableArray *remotes = [NSMutableArray array];
    for (TTDevice *device in NSAppDelegate.bluetoothMonitor.foundDevices) {
        if (!device.isPaired && device.state != TTDeviceStateConnected) continue;
        NSString *status = device.state == TTDeviceStateConnected ? [NSString stringWithFormat:TTText(@"Connected · %d%% battery"), device.batteryPct.intValue] : TTText(@"Disconnected");
        [remotes addObject:[self row:device.nickname ?: TTText(@"Turn Touch remote") subtitle:status image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_DEVICES]; }]];
    }
    if (!remotes.count) [remotes addObject:[self row:TTText(@"Remotes") subtitle:TTText(@"View saved remotes and connection status") image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_DEVICES]; }]];
    [remotes addObject:[self row:TTText(@"Add a new remote…") subtitle:nil image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_PAIRING]; }]];
    [self section:TTText(@"REMOTES") views:remotes];

    NSStackView *mode = [NSStackView stackViewWithViews:@[]];
    mode.orientation = NSUserInterfaceLayoutOrientationVertical;
    mode.alignment = NSLayoutAttributeLeading;
    mode.spacing = 8;
    mode.edgeInsets = NSEdgeInsetsMake(8, 4, 10, 4);
    [mode addArrangedSubview:[self label:TTText(@"Button mode") size:13 color:NSColor.labelColor]];
    self.modeHint = [self label:[self buttonModeHint] size:11 color:NSColor.secondaryLabelColor];
    [mode addArrangedSubview:self.modeHint];
    NSSegmentedControl *control = [NSSegmentedControl segmentedControlWithLabels:@[TTText(@"12 actions"), TTText(@"16 actions")] trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(changeMode:)];
    control.accessibilityLabel = TTText(@"Button mode");
    control.selectedSegment = NSAppDelegate.modeMap.isTwelveButtonMode ? 0 : 1;
    [control setWidth:132 forSegment:0]; [control setWidth:132 forSegment:1];
    [mode addArrangedSubview:control];
    NSButton *perform = [NSButton checkboxWithTitle:TTText(@"Run actions from the screen") target:self action:@selector(changePerform:)];
    perform.state = NSAppDelegate.modeMap.buttonActionMode == TTButtonActionModePerform ? NSControlStateValueOn : NSControlStateValueOff;
    perform.font = [NSFont systemFontOfSize:12];
    [perform.heightAnchor constraintEqualToConstant:36].active = YES;
    [self section:TTText(@"BUTTONS") views:@[mode, perform]];

    NSArray *favorites = @[@"TTModeHomeAssistant", @"TTModeHue", @"TTModeNanoleaf", @"TTModeGovee", @"TTModeSonos", @"TTModeKasa"];
    NSMutableArray *apps = [NSMutableArray array];
    for (NSString *name in self.showAllApps ? NSAppDelegate.modeMap.availableModes : favorites) {
        if ([name isEqualToString:@"TTModeNest"]) continue;
        Class modeClass = NSClassFromString(name);
        BOOL hasOptions = NSClassFromString([name stringByAppendingString:@"Options"]) != Nil;
        [apps addObject:[self row:[modeClass title] subtitle:hasOptions ? TTText(@"Connection and app options") : TTText(@"About this app’s actions") image:[modeClass imageName] handler:^{ [weakSelf openApp:name]; }]];
    }
    [apps addObject:[self row:self.showAllApps ? TTText(@"Show fewer apps") : TTText(@"Show all apps") subtitle:nil image:nil handler:^{ weakSelf.showAllApps = !weakSelf.showAllApps; [weakSelf rebuildSections]; }]];
    [self section:TTText(@"APPS & CONNECTIONS") views:apps];
    [self section:TTText(@"PREFERENCES") views:@[[self row:TTText(@"HUD, keyboard shortcuts & privacy") subtitle:TTText(@"Customize Turn Touch on this Mac") image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_SETTINGS]; }]]];
    [self section:TTText(@"HELP") views:@[
        [self row:TTText(@"How it works") subtitle:nil image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_FTUX]; }],
        [self row:TTText(@"Devices & connection diagnostics") subtitle:nil image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_DEVICES]; }],
        [self row:TTText(@"Contact support") subtitle:nil image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_SUPPORT]; }],
        [self row:TTText(@"About Turn Touch & updates") subtitle:nil image:nil handler:^{ [weakSelf openPanel:PANEL_MODAL_ABOUT]; }],
        [self row:TTText(@"Quit Turn Touch") subtitle:nil image:nil handler:^{ [NSApp terminate:nil]; }]
    ]];
    NSString *version = [NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ?: @"";
    [self.sections addArrangedSubview:[self label:[TTText(@"Turn Touch for Mac · ") stringByAppendingString:version] size:10 color:NSColor.secondaryLabelColor]];
}

- (NSString *)buttonModeHint {
    return NSAppDelegate.modeMap.isTwelveButtonMode ? TTText(@"Single tap, double tap, and hold") : TTText(@"Hold a button to switch between four apps");
}
- (void)changeMode:(NSSegmentedControl *)sender {
    [NSAppDelegate.modeMap switchButtonAppMode:sender.selectedSegment == 0];
    self.modeHint.stringValue = [self buttonModeHint];
}
- (void)changePerform:(NSButton *)sender {
    [NSAppDelegate.modeMap switchPerformActionMode:sender.state == NSControlStateValueOn ? TTButtonActionModePerform : TTButtonActionModeEdit];
}
- (void)done:(id)sender { if (self.dismissHandler) self.dismissHandler(); }
- (void)openPanel:(TTPanelModal)modal {
    [self done:nil];
    [NSAppDelegate.panelController.backgroundView switchPanelModal:modal];
}
- (void)openApp:(NSString *)name {
    [self done:nil];
    if ([name isEqualToString:@"TTModeHomeAssistant"]) {
        if (!self.homeAssistantWindow) self.homeAssistantWindow = [[TTHomeAssistantWindowController alloc] init];
        self.homeAssistantWindow.saveHandler = nil;
        [self.homeAssistantWindow showWithBinding:nil];
        return;
    }
    [self.connectionWindow close];
    self.connectionOptions = nil;
    TTMode *mode = [[NSClassFromString(name) alloc] init];
    [mode activate:NO_DIRECTION];
    NSString *controllerName = [name stringByAppendingString:@"Options"];
    TTOptionsDetailViewController *options = [[NSClassFromString(controllerName) alloc] initWithNibName:controllerName bundle:nil];
    NSView *content;
    if (options) {
        options.mode = mode;
        options.menuType = MODE_MENU_TYPE;
        content = options.view;
        self.connectionOptions = options;
    } else {
        content = [self label:TTText(@"Choose an action for this app using Add Action below a remote button.") size:14 color:NSColor.labelColor];
    }
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 380, 300) styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:NO];
    window.title = [mode.class title];
    window.releasedWhenClosed = NO;
    window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    NSView *container = window.contentView;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [container addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:12],
        [content.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-12],
        [content.topAnchor constraintEqualToAnchor:container.topAnchor constant:16],
        [container.bottomAnchor constraintGreaterThanOrEqualToAnchor:content.bottomAnchor constant:16]
    ]];
    [window setContentSize:NSMakeSize(380, MAX(180, content.fittingSize.height + 32))];
    // Keep connection editing separate from remote assignments and the selected bank.
    self.connectionWindow = [[NSWindowController alloc] initWithWindow:window];
    [window center];
    [self.connectionWindow showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}
@end
