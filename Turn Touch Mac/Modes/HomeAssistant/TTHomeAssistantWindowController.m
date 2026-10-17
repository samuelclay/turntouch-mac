#import "TTHomeAssistantWindowController.h"
#import "TTHomeAssistantClient.h"
#import <WebKit/WebKit.h>
#import <arpa/inet.h>

@interface TTHomeAssistantWindowController () <NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate, WKNavigationDelegate, NSWindowDelegate>
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
@property NSButton *refreshButton;
@property NSButton *disconnectButton;
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
@end

@implementation TTHomeAssistantWindowController
- (NSTextField *)label:(NSString *)text frame:(NSRect)frame size:(CGFloat)size {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = text; label.editable = NO; label.selectable = YES;
    label.bordered = NO; label.drawsBackground = NO;
    label.font = [NSFont systemFontOfSize:size];
    return label;
}
- (NSButton *)button:(NSString *)title frame:(NSRect)frame action:(SEL)action {
    NSButton *button = [[NSButton alloc] initWithFrame:frame];
    button.title = title; button.bezelStyle = NSBezelStyleRounded;
    button.target = self; button.action = action;
    [self.window.contentView addSubview:button]; return button;
}
- (instancetype)init {
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 900, 650) styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable backing:NSBackingStoreBuffered defer:NO];
    if ((self = [super initWithWindow:window])) {
        window.title = TTText(@"Turn Touch · Home Assistant"); window.releasedWhenClosed = NO; window.delegate = self;
        self.client = TTHomeAssistantClient.sharedClient;
        self.filtered = @[]; self.actions = @[]; self.discoveredServices = [NSMutableArray array];
        NSView *view = window.contentView;
        NSTextField *heading = [self label:TTText(@"Your home. One button away.") frame:NSMakeRect(26, 600, 810, 30) size:24];
        heading.font = [NSFont boldSystemFontOfSize:24]; [view addSubview:heading];
        [view addSubview:[self label:TTText(@"Connect locally, find an entity, and choose what your Turn Touch remote should do.") frame:NSMakeRect(26, 571, 840, 24) size:13]];
        self.address = [[NSTextField alloc] initWithFrame:NSMakeRect(26, 533, 398, 26)];
        self.address.placeholderString = @"http://homeassistant.local:8123";
        self.address.stringValue = self.client.serverURL; [view addSubview:self.address];
        self.discovered = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(432, 532, 230, 28) pullsDown:NO];
        [self.discovered addItemWithTitle:TTText(@"Looking for your home…")];
        self.discovered.target = self; self.discovered.action = @selector(chooseDiscovered:); [view addSubview:self.discovered];
        self.connectButton = [self button:TTText(@"Sign in…") frame:NSMakeRect(675, 530, 92, 30) action:@selector(signIn:)];
        self.disconnectButton = [self button:TTText(@"Disconnect") frame:NSMakeRect(772, 530, 104, 30) action:@selector(disconnect:)];
        self.token = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(26, 495, 398, 25)];
        self.token.placeholderString = TTText(@"Or paste a long-lived access token"); [view addSubview:self.token];
        self.tokenButton = [self button:TTText(@"Use token") frame:NSMakeRect(432, 492, 105, 30) action:@selector(connectToken:)];
        [self button:TTText(@"Open token settings") frame:NSMakeRect(544, 492, 166, 30) action:@selector(openProfile:)];
        self.refreshButton = [self button:TTText(@"Refresh") frame:NSMakeRect(778, 492, 98, 30) action:@selector(refresh:)];
        self.status = [self label:TTText(@"Choose a discovered home or enter its address to get started.") frame:NSMakeRect(26, 453, 848, 34) size:12];
        self.status.textColor = NSColor.secondaryLabelColor; [view addSubview:self.status];
        self.search = [[NSSearchField alloc] initWithFrame:NSMakeRect(26, 412, 570, 28)];
        self.search.placeholderString = TTText(@"Search entities, devices, rooms, or entity IDs"); self.search.delegate = self; [view addSubview:self.search];
        self.category = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(607, 411, 267, 30) pullsDown:NO];
        [self.category addItemsWithTitles:@[TTText(@"Controllable entities"), TTText(@"All entities"), TTText(@"Lights"), TTText(@"Switches"), TTText(@"Scenes"), TTText(@"Scripts"), TTText(@"Automations"), TTText(@"Covers"), TTText(@"Media players"), TTText(@"Climate"), TTText(@"Other")]];
        self.category.target = self; self.category.action = @selector(filter:); [view addSubview:self.category];
        NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(26, 91, 455, 307)];
        scroll.borderType = NSBezelBorder; scroll.hasVerticalScroller = YES;
        self.table = [[NSTableView alloc] initWithFrame:scroll.bounds];
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"entity"]; column.width = 430;
        [self.table addTableColumn:column]; self.table.headerView = nil; self.table.rowHeight = 53;
        self.table.delegate = self; self.table.dataSource = self; self.table.allowsEmptySelection = YES;
        scroll.documentView = self.table; [view addSubview:scroll];
        self.detail = [self label:TTText(@"Choose an entity") frame:NSMakeRect(504, 354, 370, 44) size:16];
        self.detail.font = [NSFont boldSystemFontOfSize:16]; [view addSubview:self.detail];
        self.actionPicker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(500, 310, 378, 32) pullsDown:NO];
        self.actionPicker.target = self; self.actionPicker.action = @selector(actionChanged:); [view addSubview:self.actionPicker];
        self.fieldsHelp = [self label:TTText(@"Available actions come from your Home Assistant.") frame:NSMakeRect(504, 209, 370, 94) size:12];
        self.fieldsHelp.textColor = NSColor.secondaryLabelColor; [view addSubview:self.fieldsHelp];
        [view addSubview:[self label:TTText(@"Action data (optional JSON)") frame:NSMakeRect(504, 182, 370, 23) size:12]];
        NSScrollView *editorScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(504, 91, 370, 87)];
        editorScroll.borderType = NSBezelBorder; editorScroll.hasVerticalScroller = YES;
        self.dataEditor = [[NSTextView alloc] initWithFrame:editorScroll.bounds];
        self.dataEditor.richText = NO; self.dataEditor.font = [NSFont userFixedPitchFontOfSize:12];
        self.dataEditor.automaticQuoteSubstitutionEnabled = NO; self.dataEditor.automaticDashSubstitutionEnabled = NO;
        self.dataEditor.string = @"{}"; editorScroll.documentView = self.dataEditor; [view addSubview:editorScroll];
        [view addSubview:[self label:TTText(@"Test runs the action now. Save assigns it to the selected remote button.") frame:NSMakeRect(26, 28, 560, 43) size:12]];
        self.testButton = [self button:TTText(@"Test action") frame:NSMakeRect(612, 31, 116, 32) action:@selector(test:)];
        self.saveButton = [self button:TTText(@"Save to button") frame:NSMakeRect(736, 31, 140, 32) action:@selector(save:)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catalogChanged:) name:TTHAConnectionChanged object:self.client];
        self.browser = [[NSNetServiceBrowser alloc] init]; self.browser.delegate = self;
        [self.browser searchForServicesOfType:@"_home-assistant._tcp." inDomain:@"local."];
        [window center]; [self updateButtons];
    }
    return self;
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; [self.browser stop]; }
- (void)showWithBinding:(NSDictionary *)binding {
    self.initialBinding = binding ?: @{};
    self.selectedEntityID = binding[@"entity_id"];
    self.dataEditor.string = binding[@"data"] ?: @"{}";
    self.search.stringValue = @""; [self.category selectItemAtIndex:0];
    [self showWindow:nil]; [NSApp activateIgnoringOtherApps:YES]; [self.window makeKeyAndOrderFront:nil];
    [self filter:nil];
    if (self.client.connected) [self refresh:nil];
}
- (void)setMessage:(NSString *)message error:(BOOL)error {
    self.status.stringValue = message;
    self.status.textColor = error ? NSColor.systemRedColor : NSColor.secondaryLabelColor;
}
- (void)setBusy:(BOOL)busy { _busy = busy; [self updateButtons]; }
- (void)updateButtons {
    BOOL chosen = self.table.selectedRow >= 0 && self.actionPicker.selectedItem != nil;
    NSDictionary *entity = self.table.selectedRow >= 0 && self.table.selectedRow < self.filtered.count ? self.filtered[self.table.selectedRow] : nil;
    BOOL available = ![entity[@"state"] isEqual:@"unavailable"];
    self.testButton.enabled = chosen && available && self.client.connected && !self.busy;
    self.saveButton.enabled = chosen && self.saveHandler != nil && !self.busy;
    self.saveButton.toolTip = self.saveHandler ? TTText(@"Assign this action to the selected remote button") : TTText(@"Open this browser from a remote button in Turn Touch to save an assignment.");
    self.connectButton.enabled = !self.busy;
    self.tokenButton.enabled = !self.busy;
    self.refreshButton.enabled = self.client.connected && !self.busy;
    self.disconnectButton.enabled = self.client.connected && !self.busy;
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
    if (!self.busy && !self.client.connected && [self.address.stringValue isEqual:url] && [self.client restoreConnectionToURL:url]) [self refresh:nil];
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
    else [self setMessage:[NSString stringWithFormat:TTText(@"Connected · %lu entities · %@"), (unsigned long)self.client.entities.count, self.client.serverURL] error:NO];
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
    [self.window beginSheet:self.authWindow completionHandler:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:authorize.URL]];
}
- (void)cancelSignIn:(id)sender { [self closeAuthentication]; }
- (void)closeAuthentication {
    if (self.authWindow.sheetParent) [self.window endSheet:self.authWindow];
    [self.authWindow orderOut:nil]; self.webView.navigationDelegate = nil; self.webView = nil; self.authWindow = nil; self.authState = nil;
}
- (void)windowWillClose:(NSNotification *)notification {
    if (notification.object == self.authWindow || notification.object == self.window) [self closeAuthentication];
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
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView { return self.filtered.count; }
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)column row:(NSInteger)row {
    NSDictionary *entity = self.filtered[row];
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 430, 53)];
    NSTextField *name = [self label:entity[@"attributes"][@"friendly_name"] ?: entity[@"entity_id"] frame:NSMakeRect(9, 27, 416, 20) size:13];
    name.font = [NSFont boldSystemFontOfSize:13]; name.selectable = NO; name.lineBreakMode = NSLineBreakByTruncatingTail; [view addSubview:name];
    NSString *subtitle = [NSString stringWithFormat:@"%@  ·  %@%@", entity[@"entity_id"], entity[@"state"], [entity[@"tt_area"] length] ? [@"  ·  " stringByAppendingString:entity[@"tt_area"]] : @""];
    NSTextField *sub = [self label:subtitle frame:NSMakeRect(9, 6, 416, 18) size:11];
    sub.textColor = NSColor.secondaryLabelColor; sub.selectable = NO; sub.lineBreakMode = NSLineBreakByTruncatingTail; [view addSubview:sub]; return view;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSString *previousAction = self.actionPicker.selectedItem.representedObject;
    [self.actionPicker removeAllItems];
    if (self.table.selectedRow < 0 || self.table.selectedRow >= self.filtered.count) {
        self.detail.stringValue = self.filtered.count ? TTText(@"Choose an entity") : (self.client.connected ? TTText(@"No matching entities") : TTText(@"Connect to browse your home"));
        self.fieldsHelp.stringValue = TTText(@"Scenes activate a saved look. Scripts run a sequence. Automations created from blueprints appear here too.");
        [self updateButtons]; return;
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
}
- (NSDictionary *)binding {
    if (self.table.selectedRow < 0 || !self.actionPicker.selectedItem) return nil;
    NSError *error;
    NSDictionary *body = [TTHomeAssistantClient serviceBodyForEntity:self.selectedEntityID data:self.dataEditor.string error:&error];
    if (!body) { [self setMessage:error.localizedDescription error:YES]; return nil; }
    NSDictionary *metadata = self.actions[self.actionPicker.indexOfSelectedItem][@"metadata"];
    for (NSString *key in metadata[@"fields"]) {
        if ([metadata[@"fields"][key][@"required"] boolValue] && !body[key] && !metadata[@"fields"][key][@"default"]) {
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
        [self setMessage:error ? error.localizedDescription : TTText(@"Home Assistant accepted the action. Check the device, then save when ready.") error:error != nil];
    }];
}
- (void)save:(id)sender {
    NSDictionary *binding = [self binding]; if (!binding || !self.saveHandler) return;
    self.saveHandler(binding);
    [self setMessage:[NSString stringWithFormat:TTText(@"Saved %@ · %@ to your remote button."), binding[@"name"], binding[@"service"]] error:NO];
}
@end
