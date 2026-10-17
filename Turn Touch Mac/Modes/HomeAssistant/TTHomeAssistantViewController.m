#import "TTHomeAssistantViewController.h"
#import "TTHomeAssistantClient.h"
#import <WebKit/WebKit.h>
#import <arpa/inet.h>

// Native NSButton behavior and accessibility, with Turn Touch's blue primary treatment.
@interface TTHAAssignButton : NSButton
@end
@implementation TTHAAssignButton
- (void)drawRect:(NSRect)dirtyRect {
    NSRect rect = NSInsetRect(self.bounds, 2, 2);
    NSBezierPath *shape = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:8 yRadius:8];
    NSColor *blue = [NSColor colorWithCalibratedRed:0.22 green:0.49 blue:0.70 alpha:1];
    [(self.enabled ? (self.highlighted ? [blue shadowWithLevel:0.18] : blue) : [blue colorWithAlphaComponent:0.22]) setFill];
    [shape fill];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentCenter;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    NSDictionary *attributes = @{NSFontAttributeName: self.font, NSForegroundColorAttributeName: self.enabled ? NSColor.whiteColor : NSColor.secondaryLabelColor, NSParagraphStyleAttributeName: style};
    CGFloat height = ceil([self.title sizeWithAttributes:attributes].height);
    [self.title drawInRect:NSMakeRect(12, (NSHeight(self.bounds) - height) / 2, NSWidth(self.bounds) - 24, height) withAttributes:attributes];
    if (self.window.firstResponder == self) {
        [NSGraphicsContext saveGraphicsState]; NSSetFocusRingStyle(NSFocusRingOnly); [shape fill]; [NSGraphicsContext restoreGraphicsState];
    }
}
@end

@interface TTHomeAssistantViewController () <NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate, NSTextViewDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate, WKNavigationDelegate, NSWindowDelegate>
@property TTHomeAssistantClient *client;
@property NSTextField *address;
@property NSSecureTextField *token;
@property NSTextField *status;
@property NSTextField *detail;
@property NSTextField *fieldsHelp;
@property NSSearchField *search;
@property NSPopUpButton *category;
@property NSPopUpButton *actionPicker;
@property NSPopUpButton *discovered;
@property NSTableView *table;
@property NSTextView *dataEditor;
@property NSButton *saveButton;
@property NSButton *testButton;
@property NSButton *connectButton;
@property NSButton *tokenButton;


@property NSArray *filtered;
@property NSArray *actions;
@property NSDictionary *initialBinding;
@property NSString *selectedEntityID;
@property NSNetServiceBrowser *browser;
@property NSMutableArray *discoveredServices;
@property NSWindow *authWindow;
@property WKWebView *webView;
@property NSString *authState;
@property NSString *authServer;
@property (nonatomic) BOOL busy;
@property NSStackView *stack;
@property NSStackView *connectionStack;
@property NSStackView *tokenStack;
@property NSStackView *advancedStack;
@property NSStackView *actionOptionsStack;
@property NSStackView *assignmentStack;
@property NSTextField *destinationLabel;
@property BOOL showingAssignmentConfirmation;
@property NSTextField *emptyState;
@property NSButton *actionDisclosure;
@property NSButton *advancedDisclosure;
@property NSPopUpButton *connectionMenu;
@property NSMenuItem *refreshItem;
@property NSMenuItem *disconnectItem;
@property NSMenuItem *signInItem;
@end

@implementation TTHomeAssistantViewController
- (NSStackView *)column:(NSArray<NSView *> *)views spacing:(CGFloat)spacing {
    NSStackView *stack = [NSStackView stackViewWithViews:views];
    stack.orientation = NSUserInterfaceLayoutOrientationVertical;
    stack.alignment = NSLayoutAttributeLeading;
    stack.spacing = spacing;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    for (NSView *view in views) [view.widthAnchor constraintEqualToAnchor:stack.widthAnchor].active = YES;
    return stack;
}
- (NSTextField *)label:(NSString *)text frame:(NSRect)frame size:(CGFloat)size {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = text; label.editable = NO; label.selectable = YES;
    label.bordered = NO; label.drawsBackground = NO;
    label.font = [NSFont fontWithName:@"Effra" size:size] ?: [NSFont systemFontOfSize:size];
    return label;
}
- (NSButton *)button:(NSString *)title action:(SEL)action {
    NSButton *button = [NSButton buttonWithTitle:title target:self action:action];
    button.bezelStyle = NSBezelStyleRounded;
    button.font = [NSFont fontWithName:@"Effra" size:13] ?: [NSFont systemFontOfSize:13];
    return button;
}
- (NSButton *)disclosure:(NSString *)title action:(SEL)action {
    NSButton *button = [self button:title action:action];
    button.bordered = NO;
    button.alignment = NSTextAlignmentLeft;
    button.font = [NSFont fontWithName:@"Effra" size:13] ?: [NSFont systemFontOfSize:13];
    [button.heightAnchor constraintEqualToConstant:26].active = YES;
    return button;
}
- (instancetype)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.client = TTHomeAssistantClient.sharedClient;
        self.filtered = @[]; self.actions = @[];
        self.discoveredServices = [NSMutableArray array];
    }
    return self;
}
- (void)loadView {
    self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 380, 470)];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    self.view.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColor.whiteColor.CGColor;

    self.search = [[NSSearchField alloc] init];
    self.search.placeholderString = TTText(@"Search Home Assistant");
    self.search.font = [NSFont fontWithName:@"Effra" size:13] ?: [NSFont systemFontOfSize:13];
    self.search.delegate = self;
    self.search.accessibilityLabel = TTText(@"Search Home Assistant");
    [self.search.heightAnchor constraintEqualToConstant:28].active = YES;
    self.category = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    [self.category addItemsWithTitles:@[TTText(@"Controllable entities"), TTText(@"All entities"), TTText(@"Lights"), TTText(@"Switches"), TTText(@"Scenes"), TTText(@"Scripts"), TTText(@"Automations"), TTText(@"Covers"), TTText(@"Media players"), TTText(@"Climate"), TTText(@"Other")]];
    self.category.font = self.search.font;
    self.category.target = self; self.category.action = @selector(filter:);
    self.category.accessibilityLabel = TTText(@"Filter");
    self.connectionMenu = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
    self.connectionMenu.bordered = NO;
    self.connectionMenu.accessibilityLabel = TTText(@"Home Assistant menu");
    self.connectionMenu.toolTip = TTText(@"Home Assistant menu");
    [self.connectionMenu addItemWithTitle:@"•••"];
    ((NSPopUpButtonCell *)self.connectionMenu.cell).arrowPosition = NSPopUpNoArrow;
    if (@available(macOS 11.0, *)) {
        self.connectionMenu.itemArray.firstObject.image = [NSImage imageWithSystemSymbolName:@"ellipsis.circle" accessibilityDescription:TTText(@"Home Assistant menu")];
        self.connectionMenu.itemArray.firstObject.title = @"";
    }
    [self menuItem:TTText(@"Connection…") action:@selector(showConnection:)];
    self.signInItem = [self menuItem:TTText(@"Sign in…") action:@selector(signInFromMenu:)];
    [self menuItem:TTText(@"Use access token…") action:@selector(showToken:)];
    [self menuItem:TTText(@"Open token settings") action:@selector(openProfile:)];
    [self.connectionMenu.menu addItem:NSMenuItem.separatorItem];
    self.refreshItem = [self menuItem:TTText(@"Refresh") action:@selector(refresh:)];
    self.disconnectItem = [self menuItem:TTText(@"Disconnect") action:@selector(disconnect:)];
    self.connectionMenu.menu.autoenablesItems = NO;
    [self.connectionMenu.widthAnchor constraintEqualToConstant:36].active = YES;
    NSStackView *filters = [NSStackView stackViewWithViews:@[self.category, self.connectionMenu]];
    filters.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    filters.spacing = 8;
    [self.category.widthAnchor constraintEqualToAnchor:filters.widthAnchor constant:-44].active = YES;
    [filters.heightAnchor constraintEqualToConstant:28].active = YES;

    self.address = [[NSTextField alloc] init];
    self.address.placeholderString = @"http://homeassistant.local:8123";
    self.address.stringValue = self.client.serverURL ?: @"";
    self.address.accessibilityLabel = TTText(@"Home Assistant address");
    self.discovered = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    [self.discovered addItemWithTitle:TTText(@"Looking for your home…")];
    self.discovered.target = self; self.discovered.action = @selector(chooseDiscovered:);
    self.connectButton = [self button:TTText(@"Sign in…") action:@selector(signIn:)];
    self.token = [[NSSecureTextField alloc] init];
    self.token.placeholderString = TTText(@"Or paste a long-lived access token");
    self.tokenButton = [self button:TTText(@"Use token") action:@selector(connectToken:)];
    self.tokenStack = [self column:@[self.token, self.tokenButton] spacing:6];
    self.tokenStack.hidden = YES;
    self.connectionStack = [self column:@[self.address, self.discovered, self.connectButton, self.tokenStack] spacing:6];
    self.connectionStack.hidden = YES;

    NSScrollView *scroll = [[NSScrollView alloc] init];
    scroll.borderType = NSNoBorder; scroll.hasVerticalScroller = YES;
    scroll.wantsLayer = YES; scroll.layer.cornerRadius = 8;
    scroll.layer.borderWidth = 1; scroll.layer.borderColor = [NSColor colorWithCalibratedWhite:0.9 alpha:1].CGColor;
    scroll.scrollerStyle = NSScrollerStyleOverlay;
    [scroll.heightAnchor constraintEqualToConstant:210].active = YES;
    self.table = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 350, 190)];
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"entity"];
    column.width = 340; column.resizingMask = NSTableColumnAutoresizingMask;
    [self.table addTableColumn:column]; self.table.headerView = nil; self.table.rowHeight = 49;
    self.table.columnAutoresizingStyle = NSTableViewLastColumnOnlyAutoresizingStyle;
    self.table.delegate = self; self.table.dataSource = self;
    self.table.accessibilityLabel = TTText(@"Home Assistant entities");
    self.table.allowsEmptySelection = YES;
    self.table.usesAlternatingRowBackgroundColors = NO;
    self.table.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    self.table.gridColor = [NSColor colorWithCalibratedWhite:0.94 alpha:1];
    scroll.documentView = self.table;
    NSView *results = [[NSView alloc] init];
    scroll.translatesAutoresizingMaskIntoConstraints = NO;
    [results addSubview:scroll];
    self.emptyState = [self label:@"" frame:NSZeroRect size:13];
    self.emptyState.alignment = NSTextAlignmentCenter;
    self.emptyState.textColor = NSColor.secondaryLabelColor;
    self.emptyState.maximumNumberOfLines = 3;
    self.emptyState.translatesAutoresizingMaskIntoConstraints = NO;
    [results addSubview:self.emptyState];
    [NSLayoutConstraint activateConstraints:@[
        [scroll.leadingAnchor constraintEqualToAnchor:results.leadingAnchor],
        [scroll.trailingAnchor constraintEqualToAnchor:results.trailingAnchor],
        [scroll.topAnchor constraintEqualToAnchor:results.topAnchor],
        [scroll.bottomAnchor constraintEqualToAnchor:results.bottomAnchor],
        [self.emptyState.centerYAnchor constraintEqualToAnchor:results.centerYAnchor],
        [self.emptyState.leadingAnchor constraintEqualToAnchor:results.leadingAnchor constant:24],
        [self.emptyState.trailingAnchor constraintEqualToAnchor:results.trailingAnchor constant:-24]
    ]];
    self.detail = [self label:TTText(@"Choose an entity") frame:NSZeroRect size:13];
    self.detail.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    self.detail.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.detail.heightAnchor constraintEqualToConstant:22].active = YES;
    self.actionDisclosure = [self disclosure:TTText(@"Action") action:@selector(toggleAction:)];
    self.actionPicker = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    self.actionPicker.target = self; self.actionPicker.action = @selector(actionChanged:);
    self.actionPicker.accessibilityLabel = TTText(@"Action");
    self.actionPicker.font = self.search.font;
    self.actionPicker.hidden = YES;
    self.advancedDisclosure = [self disclosure:TTText(@"Action data (optional JSON)") action:@selector(toggleAdvanced:)];
    self.fieldsHelp = [self label:@"" frame:NSZeroRect size:11];
    self.fieldsHelp.textColor = NSColor.secondaryLabelColor;
    self.fieldsHelp.maximumNumberOfLines = 4;
    [self.fieldsHelp.heightAnchor constraintEqualToConstant:56].active = YES;
    NSScrollView *editor = [[NSScrollView alloc] init];
    editor.borderType = NSBezelBorder; editor.hasVerticalScroller = YES;
    [editor.heightAnchor constraintEqualToConstant:90].active = YES;
    self.dataEditor = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 350, 90)];
    self.dataEditor.delegate = self;
    self.dataEditor.richText = NO; self.dataEditor.font = [NSFont userFixedPitchFontOfSize:12];
    self.dataEditor.automaticQuoteSubstitutionEnabled = NO; self.dataEditor.automaticDashSubstitutionEnabled = NO;
    self.dataEditor.accessibilityLabel = TTText(@"Action data (optional JSON)");
    self.dataEditor.string = @"{}"; editor.documentView = self.dataEditor;
    self.advancedStack = [self column:@[self.fieldsHelp, editor] spacing:6];
    self.advancedStack.hidden = YES;
    NSTextField *actionHelp = [self label:TTText(@"Choose what the remote button does in Home Assistant.") frame:NSZeroRect size:12];
    actionHelp.textColor = NSColor.secondaryLabelColor;
    actionHelp.maximumNumberOfLines = 2;
    [actionHelp.heightAnchor constraintEqualToConstant:32].active = YES;
    self.actionOptionsStack = [self column:@[actionHelp, self.actionPicker, self.advancedDisclosure, self.advancedStack] spacing:8];
    self.actionOptionsStack.hidden = YES;
    self.testButton = [self button:TTText(@"Test action") action:@selector(test:)];
    self.saveButton = [[TTHAAssignButton alloc] init];
    self.saveButton.title = TTText(@"Set remote button");
    self.saveButton.target = self; self.saveButton.action = @selector(save:);
    self.saveButton.bordered = NO;
    self.saveButton.font = [NSFont fontWithName:@"Effra" size:15] ?: [NSFont systemFontOfSize:15 weight:NSFontWeightMedium];
    [self.saveButton.heightAnchor constraintEqualToConstant:42].active = YES;
    self.destinationLabel = [self label:self.buttonDestination ?: @"" frame:NSZeroRect size:12];
    self.destinationLabel.alignment = NSTextAlignmentCenter;
    self.destinationLabel.textColor = NSColor.secondaryLabelColor;
    [self.destinationLabel.heightAnchor constraintEqualToConstant:18].active = YES;
    self.assignmentStack = [self column:@[self.destinationLabel, self.saveButton] spacing:3];
    [self.assignmentStack setHuggingPriority:NSLayoutPriorityRequired forOrientation:NSLayoutConstraintOrientationVertical];
    [self.testButton.heightAnchor constraintEqualToConstant:30].active = YES;
    self.status = [self label:@"" frame:NSZeroRect size:13];
    self.status.textColor = NSColor.secondaryLabelColor;
    self.status.maximumNumberOfLines = 3;
    [self.status.heightAnchor constraintEqualToConstant:32].active = YES;
    NSBox *separator = [[NSBox alloc] init];
    separator.boxType = NSBoxSeparator;
    [separator.heightAnchor constraintEqualToConstant:1].active = YES;
    self.stack = [self column:@[self.search, filters, self.connectionStack, results, self.actionDisclosure, self.actionOptionsStack, self.testButton, separator, self.assignmentStack, self.status] spacing:10];
    [self.view addSubview:self.stack];
    [NSLayoutConstraint activateConstraints:@[
        [self.stack.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:12],
        [self.stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:12],
        [self.stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-12],
        [self.stack.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-12]
    ]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catalogChanged:) name:TTHAConnectionChanged object:self.client];
    self.browser = [[NSNetServiceBrowser alloc] init]; self.browser.delegate = self;
    [self.browser searchForServicesOfType:@"_home-assistant._tcp." inDomain:@"local."];
    [self updateDisclosureTitles];
    [self setMessage:@"" error:NO];
    [self filter:nil];
}
- (NSMenuItem *)menuItem:(NSString *)title action:(SEL)action {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
    item.target = self; [self.connectionMenu.menu addItem:item]; return item;
}
- (void)showConnection:(id)sender {
    self.connectionStack.hidden = !self.connectionStack.hidden;
}
- (void)showToken:(id)sender {
    self.connectionStack.hidden = NO; self.tokenStack.hidden = NO;
    [self.view.window makeFirstResponder:self.token];
}
- (void)signInFromMenu:(id)sender {
    self.connectionStack.hidden = NO;
    if ([TTHomeAssistantClient normalizedURL:self.address.stringValue]) [self signIn:sender];
    else [self.view.window makeFirstResponder:self.address];
}
- (void)toggleAction:(id)sender {
    self.actionOptionsStack.hidden = !self.actionOptionsStack.hidden;
    self.actionPicker.hidden = self.actionOptionsStack.hidden;
    [self updateDisclosureTitles];
}
- (void)toggleAdvanced:(id)sender {
    self.advancedStack.hidden = !self.advancedStack.hidden;
    if (!self.advancedStack.hidden) { self.actionOptionsStack.hidden = NO; self.actionPicker.hidden = NO; }
    [self updateDisclosureTitles];
}
- (void)updateDisclosureTitles {
    NSString *action = TTText(@"Action settings");
    self.actionDisclosure.title = action;
    self.actionDisclosure.toolTip = self.actionPicker.titleOfSelectedItem;
    if (@available(macOS 11.0, *)) {
        self.actionDisclosure.image = [NSImage imageWithSystemSymbolName:self.actionOptionsStack.hidden ? @"chevron.down" : @"chevron.up" accessibilityDescription:nil];
        self.actionDisclosure.imagePosition = NSImageRight;
    } else {
        self.actionDisclosure.title = [self.actionDisclosure.title stringByAppendingString:self.actionOptionsStack.hidden ? @"  ▾" : @"  ▴"];
    }
    self.actionDisclosure.accessibilityLabel = action;
    self.actionDisclosure.accessibilityValue = @(!self.actionPicker.hidden);
    self.advancedDisclosure.title = [NSString stringWithFormat:@"%@ %@", self.advancedStack.hidden ? @"▸" : @"▾", TTText(@"Action data (optional JSON)")];
    self.advancedDisclosure.accessibilityLabel = TTText(@"Action data (optional JSON)");
    self.advancedDisclosure.accessibilityValue = @(!self.advancedStack.hidden);
}
- (void)loadBinding:(NSDictionary *)binding {
    (void)self.view;
    self.initialBinding = binding ?: @{};
    [self.actionPicker removeAllItems];
    self.selectedEntityID = binding[@"entity_id"];
    self.dataEditor.string = binding[@"data"] ?: @"{}";
    self.search.stringValue = @""; [self.category selectItemAtIndex:0];
    [self filter:nil];
    if (self.client.connected && !self.client.entities.count) [self refresh:nil];
}
- (void)setButtonDestination:(NSString *)buttonDestination {
    _buttonDestination = [buttonDestination copy];
    if (self.isViewLoaded) [self updateButtons];
}
- (void)setSaveHandler:(void (^)(NSDictionary *))saveHandler {
    _saveHandler = [saveHandler copy];
    if (self.isViewLoaded) [self updateButtons];
}
- (void)viewWillDisappear {
    [super viewWillDisappear];
    [self closeAuthentication];
}

- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; [self.browser stop]; }
- (void)setMessage:(NSString *)message error:(BOOL)error {
    self.status.stringValue = message;
    self.status.hidden = !message.length;
    self.status.textColor = error ? NSColor.systemRedColor : NSColor.secondaryLabelColor;
}
- (void)setBusy:(BOOL)busy { _busy = busy; [self updateButtons]; }
- (void)updateButtons {
    BOOL chosen = self.table.selectedRow >= 0 && self.actionPicker.selectedItem != nil;
    NSDictionary *entity = self.table.selectedRow >= 0 && self.table.selectedRow < self.filtered.count ? self.filtered[self.table.selectedRow] : nil;
    BOOL available = ![entity[@"state"] isEqual:@"unavailable"];
    self.testButton.enabled = chosen && available && self.client.connected && !self.busy;
    self.saveButton.enabled = chosen && self.saveHandler != nil && !self.busy;
    self.assignmentStack.hidden = self.saveHandler == nil;
    self.destinationLabel.hidden = !self.buttonDestination.length;
    self.destinationLabel.stringValue = self.buttonDestination ?: @"";
    self.saveButton.toolTip = TTText(@"Assign this action to the selected remote button");
    self.signInItem.enabled = !self.busy;
    self.actionDisclosure.enabled = chosen;
    self.actionDisclosure.hidden = !chosen;
    if (!chosen) { self.actionOptionsStack.hidden = YES; self.actionPicker.hidden = YES; }
    self.emptyState.hidden = self.filtered.count > 0;
    self.emptyState.stringValue = self.client.restoringConnection ? TTText(@"Connecting to your home…") :
        self.client.connected ? TTText(@"No matching entities") : TTText(@"Connect using the Home Assistant menu.");
    self.advancedDisclosure.enabled = chosen;
    self.connectButton.enabled = !self.busy;
    self.tokenButton.enabled = !self.busy;
    self.refreshItem.enabled = self.client.connected && !self.busy;
    self.disconnectItem.enabled = self.client.connected && !self.busy;
    self.address.enabled = !self.busy; self.token.enabled = !self.busy;
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    [self.discoveredServices addObject:service]; service.delegate = self; [service resolveWithTimeout:5];
}
- (void)netServiceDidResolveAddress:(NSNetService *)service {
    // Resolve the service address itself rather than trusting an arbitrary TXT URL.
    NSString *host;
    for (NSData *address in service.addresses) {
        const struct sockaddr *sa = address.bytes;
        if (sa->sa_family == AF_INET) {
            char buffer[INET_ADDRSTRLEN]; inet_ntop(AF_INET, &((const struct sockaddr_in *)sa)->sin_addr, buffer, sizeof(buffer));
            host = [NSString stringWithUTF8String:buffer]; break;
        }
    }
    if (!host) host = service.hostName;
    if (!host.length) return;
    NSString *url = [NSString stringWithFormat:@"http://%@:%ld", host, (long)service.port];
    for (NSMenuItem *item in self.discovered.itemArray) if ([item.representedObject isEqual:url]) return;
    if (!self.discovered.itemArray.firstObject.representedObject) [self.discovered removeAllItems];
    [self.discovered addItemWithTitle:service.name]; self.discovered.lastItem.representedObject = url;
    if (!self.address.stringValue.length) {
        self.address.stringValue = url;
        [self setMessage:[NSString stringWithFormat:TTText(@"Found %@ on your network. Sign in to browse your home."), service.name] error:NO];
    }
    if (!self.busy && !self.client.connected && !self.client.restoringConnection && [self.address.stringValue isEqual:url]) {
        [self.client restoreConnectionToURL:url completion:^(id result, NSError *error) {}];
    }
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    for (NSNetService *found in [self.discoveredServices copy]) if ([found.name isEqual:service.name]) [self.discoveredServices removeObject:found];
    for (NSMenuItem *item in [self.discovered.itemArray copy]) if ([item.title isEqual:service.name]) [self.discovered.menu removeItem:item];
}
- (void)chooseDiscovered:(id)sender {
    if ([self.discovered.selectedItem.representedObject isKindOfClass:NSString.class]) self.address.stringValue = self.discovered.selectedItem.representedObject;
}
- (void)connectToken:(id)sender {
    self.busy = YES; [self setMessage:TTText(@"Connecting to your home…") error:NO];
    [self.client connectToURL:self.address.stringValue token:self.token.stringValue completion:^(id result, NSError *error) {
        self.busy = NO;
        if (!error) self.token.stringValue = @"";
        [self finishRefresh:error];
    }];
}
- (void)refresh:(id)sender {
    self.busy = YES; [self setMessage:TTText(@"Reading entities and actions…") error:NO];
    [self.client refreshCatalog:^(id result, NSError *error) { self.busy = NO; [self finishRefresh:error]; }];
}
- (void)finishRefresh:(NSError *)error {
    if (error) [self setMessage:error.localizedDescription error:YES];
    else [self setMessage:@"" error:NO];
    if (!error) { self.connectionStack.hidden = YES; self.tokenStack.hidden = YES; }
    [self filter:nil];
}
- (void)disconnect:(id)sender {
    [self.client disconnect]; self.token.stringValue = @"";
    [self setMessage:TTText(@"Disconnected. Credentials removed from this Mac’s Keychain.") error:NO]; [self filter:nil];
}
- (void)openProfile:(id)sender {
    NSString *url = [TTHomeAssistantClient normalizedURL:self.address.stringValue];
    if (url) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[url stringByAppendingString:@"/profile/security"]]];
}
- (void)signIn:(id)sender {
    NSString *url = [TTHomeAssistantClient normalizedURL:self.address.stringValue];
    if (!url) { [self setMessage:TTText(@"Enter a valid Home Assistant URL first.") error:YES]; return; }
    self.authServer = url; self.authState = NSUUID.UUID.UUIDString;
    NSURLComponents *authorize = [NSURLComponents componentsWithString:[url stringByAppendingString:@"/auth/authorize"]];
    authorize.queryItems = @[[NSURLQueryItem queryItemWithName:@"client_id" value:TTHAClientID], [NSURLQueryItem queryItemWithName:@"redirect_uri" value:TTHARedirectURI], [NSURLQueryItem queryItemWithName:@"state" value:self.authState]];
    self.authWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 560, 660) styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable backing:NSBackingStoreBuffered defer:NO];
    self.authWindow.title = [TTText(@"Sign in to ") stringByAppendingString:url]; self.authWindow.releasedWhenClosed = NO; self.authWindow.delegate = self;
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    if (@available(macOS 10.11, *)) config.websiteDataStore = WKWebsiteDataStore.nonPersistentDataStore;
    NSRect webFrame = self.authWindow.contentView.bounds; webFrame.origin.y = 48; webFrame.size.height -= 48;
    self.webView = [[WKWebView alloc] initWithFrame:webFrame configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.authWindow.contentView addSubview:self.webView];
    NSButton *cancel = [[NSButton alloc] initWithFrame:NSMakeRect(430, 10, 110, 30)];
    cancel.title = TTText(@"Cancel"); cancel.bezelStyle = NSBezelStyleRounded; cancel.target = self; cancel.action = @selector(cancelSignIn:);
    [self.authWindow.contentView addSubview:cancel];
    if (self.interactionHandler) self.interactionHandler(YES);
    [self.view.window beginSheet:self.authWindow completionHandler:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authorize.URL]];
}
- (void)cancelSignIn:(id)sender { [self closeAuthentication]; }
- (void)closeAuthentication {
    if (self.authWindow && self.interactionHandler) self.interactionHandler(NO);
    if (self.authWindow.sheetParent) [self.authWindow.sheetParent endSheet:self.authWindow];
    [self.authWindow orderOut:nil]; self.webView.navigationDelegate = nil; self.webView = nil; self.authWindow = nil; self.authState = nil;
}
- (void)windowWillClose:(NSNotification *)notification {
    if (notification.object == self.authWindow || notification.object == self.view.window) [self closeAuthentication];
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)action decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = action.request.URL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSURLComponents *callback = [NSURLComponents componentsWithString:TTHARedirectURI];
    if ([components.scheme isEqual:callback.scheme] && [components.host isEqual:callback.host] && [components.path isEqual:callback.path] && !components.port && !components.user && !components.password) {
        decisionHandler(WKNavigationActionPolicyCancel);
        NSMutableDictionary *query = [NSMutableDictionary dictionary]; for (NSURLQueryItem *item in components.queryItems) if (item.value) query[item.name] = item.value;
        if (![query[@"state"] isEqual:self.authState] || ![query[@"code"] length]) { [self setMessage:TTText(@"Sign-in could not be verified. Please try again.") error:YES]; [self closeAuthentication]; return; }
        NSString *server = self.authServer; [self closeAuthentication]; self.busy = YES;
        [self setMessage:TTText(@"Finishing sign-in…") error:NO];
        [self.client exchangeCode:query[@"code"] serverURL:server completion:^(id result, NSError *error) { self.busy = NO; [self finishRefresh:error]; }];
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code != NSURLErrorCancelled) { [self setMessage:error.localizedDescription error:YES]; [self closeAuthentication]; }
}
- (void)catalogChanged:(NSNotification *)notification {
    if (self.client.connected && !self.client.entities.count && !self.busy && !self.client.lastError.length) [self refresh:nil];
    [self filter:nil];
    if (self.client.lastError.length) [self setMessage:self.client.lastError error:YES];
}
- (void)controlTextDidChange:(NSNotification *)notification { [self filter:nil]; }
- (void)filter:(id)sender {
    NSArray *domains = @[@"controllable", @"", @"light", @"switch", @"scene", @"script", @"automation", @"cover", @"media_player", @"climate", @"other"];
    NSString *category = domains[MAX(0, self.category.indexOfSelectedItem)];
    NSString *query = self.search.stringValue;
    self.filtered = [self.client.entities filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary *entity, NSDictionary *bindings) {
        NSString *domain = [entity[@"entity_id"] componentsSeparatedByString:@"."].firstObject;
        if ([category isEqual:@"controllable"] && [TTHomeAssistantClient actionsForEntity:entity services:self.client.services].count == 0) return NO;
        if (category.length && ![category isEqual:@"controllable"] && ![category isEqual:domain] && !([category isEqual:@"other"] && ![domains containsObject:domain])) return NO;
        NSString *text = [NSString stringWithFormat:@"%@ %@ %@ %@", entity[@"attributes"][@"friendly_name"] ?: @"", entity[@"entity_id"], entity[@"tt_device"] ?: @"", entity[@"tt_area"] ?: @""];
        return !query.length || [text rangeOfString:query options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch].location != NSNotFound;
    }]];
    NSString *previous = self.selectedEntityID;
    NSString *previousService = self.actionPicker.selectedItem.representedObject;
    NSString *previousData = self.dataEditor.string;
    [self.table reloadData]; [self.table deselectAll:nil];
    NSUInteger index = [self.filtered indexOfObjectPassingTest:^BOOL(NSDictionary *entity, NSUInteger idx, BOOL *stop) { return [entity[@"entity_id"] isEqual:previous]; }];
    if (index != NSNotFound) [self.table selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
    self.selectedEntityID = previous;
    for (NSMenuItem *item in self.actionPicker.itemArray) if ([item.representedObject isEqual:previousService]) [self.actionPicker selectItem:item];
    self.dataEditor.string = previousData;
    if (self.actionPicker.selectedItem) [self actionChanged:nil];
    [self updateButtons];
    [self updateDisclosureTitles];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { return self.filtered.count; }
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    NSDictionary *entity = self.filtered[row];
    CGFloat width = MAX(280, tableView.bounds.size.width);
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, width, 49)];
    NSString *domain = [entity[@"entity_id"] componentsSeparatedByString:@"."].firstObject;
    NSDictionary *symbols = @{@"light": @"lightbulb", @"switch": @"powerplug", @"scene": @"sparkles", @"script": @"play.rectangle", @"automation": @"gearshape.2", @"cover": @"window.vertical.closed", @"media_player": @"speaker.wave.2", @"climate": @"thermometer"};
    if (@available(macOS 11.0, *)) {
        NSImageView *icon = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 15, 20, 20)];
        icon.image = [NSImage imageWithSystemSymbolName:symbols[domain] ?: @"house" accessibilityDescription:nil];
        icon.contentTintColor = [NSColor colorWithCalibratedRed:0.32 green:0.52 blue:0.67 alpha:1];
        [view addSubview:icon];
    }
    NSTextField *name = [self label:entity[@"attributes"][@"friendly_name"] ?: entity[@"entity_id"] frame:NSMakeRect(40, 25, width - 52, 20) size:14];
    name.textColor = [NSColor colorWithCalibratedRed:0.25 green:0.29 blue:0.38 alpha:1];
    name.autoresizingMask = NSViewWidthSizable; name.selectable = NO; name.lineBreakMode = NSLineBreakByTruncatingTail; [view addSubview:name];
    NSDictionary *categories = @{@"light": TTText(@"Lights"), @"switch": TTText(@"Switches"), @"scene": TTText(@"Scenes"), @"script": TTText(@"Scripts"), @"automation": TTText(@"Automations"), @"cover": TTText(@"Covers"), @"media_player": TTText(@"Media players"), @"climate": TTText(@"Climate")};
    NSString *kind = categories[domain] ?: TTText(@"Other");
    NSString *subtitle = [entity[@"tt_area"] length] ? [NSString stringWithFormat:@"%@ · %@", entity[@"tt_area"], kind] : kind;
    NSTextField *sub = [self label:subtitle frame:NSMakeRect(40, 5, width - 52, 17) size:12];
    sub.textColor = NSColor.secondaryLabelColor; sub.autoresizingMask = NSViewWidthSizable; sub.selectable = NO; sub.lineBreakMode = NSLineBreakByTruncatingTail; [view addSubview:sub];
    view.toolTip = [NSString stringWithFormat:@"%@ · %@", entity[@"entity_id"], entity[@"state"]];
    return view;
}
- (void)clearAssignmentConfirmation {
    if (self.showingAssignmentConfirmation) { [self setMessage:@"" error:NO]; self.showingAssignmentConfirmation = NO; }
}
- (void)textDidChange:(NSNotification *)notification { [self clearAssignmentConfirmation]; }
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self clearAssignmentConfirmation];
    NSString *previousAction = self.actionPicker.selectedItem.representedObject;
    [self.actionPicker removeAllItems];
    if (self.table.selectedRow < 0 || self.table.selectedRow >= self.filtered.count) {
        self.detail.stringValue = self.filtered.count ? TTText(@"Choose an entity") : (self.client.connected ? TTText(@"No matching entities") : TTText(@"Connect to browse your home"));
        self.fieldsHelp.stringValue = TTText(@"Scenes activate a saved look. Scripts run a sequence. Automations created from blueprints appear here too.");
        [self updateButtons]; [self updateDisclosureTitles]; return;
    }
    NSDictionary *entity = self.filtered[self.table.selectedRow];
    BOOL same = [self.selectedEntityID isEqual:entity[@"entity_id"]];
    self.selectedEntityID = entity[@"entity_id"];
    self.detail.stringValue = entity[@"attributes"][@"friendly_name"] ?: self.selectedEntityID;
    self.actions = [TTHomeAssistantClient actionsForEntity:entity services:self.client.services];
    for (NSDictionary *action in self.actions) { [self.actionPicker addItemWithTitle:action[@"name"]]; self.actionPicker.lastItem.representedObject = action[@"id"]; }
    NSString *wanted = same ? previousAction : nil;
    if ([self.initialBinding[@"entity_id"] isEqual:self.selectedEntityID]) { wanted = self.initialBinding[@"service"]; self.initialBinding = @{}; }
    for (NSMenuItem *item in self.actionPicker.itemArray) if ([item.representedObject isEqual:wanted]) [self.actionPicker selectItem:item];
    if (!same) self.dataEditor.string = @"{}";
    [self actionChanged:nil];
}
- (void)actionChanged:(id)sender {
    [self clearAssignmentConfirmation];
    NSInteger index = self.actionPicker.indexOfSelectedItem;
    if (index < 0) { self.fieldsHelp.stringValue = TTText(@"This entity has no callable actions. Sensors are usually read-only."); [self updateButtons]; return; }
    NSDictionary *action = self.actions[index], *metadata = action[@"metadata"];
    NSMutableArray *required = [NSMutableArray array];
    for (NSString *key in metadata[@"fields"]) if ([metadata[@"fields"][key][@"required"] boolValue] && ![key isEqual:@"entity_id"]) [required addObject:key];
    NSString *description = metadata[@"description"] ?: @"";
    NSString *requiredText = required.count ? [TTText(@"Required data: ") stringByAppendingString:[required componentsJoinedByString:@", "]] : TTText(@"No required action data.");
    self.fieldsHelp.stringValue = [NSString stringWithFormat:@"%@\n%@\n%@", action[@"id"], description, requiredText];
    self.fieldsHelp.toolTip = self.fieldsHelp.stringValue;
    [self updateButtons];
    [self updateDisclosureTitles];
}
- (NSDictionary *)binding {
    if (self.table.selectedRow < 0 || !self.actionPicker.selectedItem) return nil;
    NSError *error;
    NSDictionary *body = [TTHomeAssistantClient serviceBodyForEntity:self.selectedEntityID data:self.dataEditor.string error:&error];
    if (!body) { self.actionOptionsStack.hidden = NO; self.actionPicker.hidden = NO; self.advancedStack.hidden = NO; [self updateDisclosureTitles]; [self setMessage:error.localizedDescription error:YES]; return nil; }
    NSDictionary *metadata = self.actions[self.actionPicker.indexOfSelectedItem][@"metadata"];
    for (NSString *key in metadata[@"fields"]) {
        if ([metadata[@"fields"][key][@"required"] boolValue] && !body[key] && !metadata[@"fields"][key][@"default"]) {
            self.actionOptionsStack.hidden = NO; self.actionPicker.hidden = NO; self.advancedStack.hidden = NO; [self updateDisclosureTitles];
            [self setMessage:[TTText(@"Add the required action data field: ") stringByAppendingString:key] error:YES]; return nil;
        }
    }
    return @{@"entity_id": self.selectedEntityID, @"service": self.actionPicker.selectedItem.representedObject,
             @"data": self.dataEditor.string, @"name": self.detail.stringValue, @"server_url": self.client.serverURL};
}
- (void)test:(id)sender {
    NSDictionary *binding = [self binding]; if (!binding) return;
    self.busy = YES; [self setMessage:TTText(@"Running action…") error:NO];
    [self.client callAction:binding[@"service"] entity:binding[@"entity_id"] data:binding[@"data"] completion:^(id result, NSError *error) {
        self.busy = NO;
        [self setMessage:error ? error.localizedDescription : TTText(@"Home Assistant accepted the action.") error:error != nil];
    }];
}
- (void)save:(id)sender {
    NSDictionary *binding = [self binding]; if (!binding || !self.saveHandler) return;
    self.saveHandler(binding);
    NSString *message = self.buttonDestination.length ?
        [NSString stringWithFormat:TTText(@"%@ now runs “%@”."), self.buttonDestination, binding[@"name"]] :
        [NSString stringWithFormat:TTText(@"Remote button set to “%@”."), binding[@"name"]];
    [self setMessage:[@"✓ " stringByAppendingString:message] error:NO];
    self.status.textColor = [NSColor colorWithCalibratedRed:0.22 green:0.49 blue:0.70 alpha:1];
    self.showingAssignmentConfirmation = YES;
}
@end
