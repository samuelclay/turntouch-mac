#import "TTLocalization.h"

static NSString *TTResolve(NSArray<NSString *> *preferred) {
    for (NSString *tag in preferred) {
        NSLocale *locale = [NSLocale localeWithLocaleIdentifier:tag];
        NSString *language = locale.languageCode;
        if ([language isEqual:@"zh"]) return [locale.scriptCode isEqual:@"Hant"] || [@[@"TW", @"HK", @"MO"] containsObject:locale.countryCode ?: @""] ? @"zh-Hant" : @"zh-Hans";
        if ([language isEqual:@"pt"]) return @"pt-BR";
        for (NSArray *entry in TTLocalization.languages) if ([entry[0] isEqual:tag] || [entry[0] isEqual:language]) return entry[0];
    }
    return @"en";
}
NSString *TTText(NSString *source) {
    static NSBundle *bundle;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *selection = TTLocalization.selection;
        NSString *code = TTResolve([selection isEqual:@"auto"] ? NSLocale.preferredLanguages : @[selection]);
        bundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:code ofType:@"lproj"]] ?: NSBundle.mainBundle;
    });
    return [bundle localizedStringForKey:source value:source table:@"Localizable"];
}
@implementation TTLocalization
+ (NSArray<NSArray<NSString *> *> *)languages {
    static NSArray *languages;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSURL *url = [NSBundle.mainBundle URLForResource:@"languages" withExtension:@"json" subdirectory:@"Localization"];
        NSDictionary *names = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:nil];
        NSMutableArray *entries = [NSMutableArray arrayWithObject:@[@"en", @"English"]];
        for (NSString *key in [[names allKeys] sortedArrayUsingSelector:@selector(compare:)]) if (![key isEqual:@"en"]) [entries addObject:@[key, names[key]]];
        languages = entries;
    });
    return languages;
}
+ (NSString *)selection { return [NSUserDefaults.standardUserDefaults stringForKey:@"TT:language"] ?: @"auto"; }
+ (NSString *)displayName {
    if ([self.selection isEqual:@"auto"]) return TTText(@"Automatic (device language)");
    for (NSArray *entry in self.languages) if ([entry[0] isEqual:self.selection]) return entry[1];
    return @"English";
}
+ (BOOL)needsWelcome { return ![NSUserDefaults.standardUserDefaults boolForKey:@"TT:language:welcomed"]; }
+ (void)showLanguagePicker {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = self.needsWelcome ? TTText(@"Welcome to Turn Touch") : TTText(@"Language");
    alert.informativeText = TTText(@"You can change this anytime in Settings. Language changes apply the next time you launch Turn Touch.");
    NSPopUpButton *picker = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 300, 28) pullsDown:NO];
    NSArray *choices = [@[@[@"auto", TTText(@"Automatic (device language)")]] arrayByAddingObjectsFromArray:self.languages];
    for (NSArray *entry in choices) { [picker addItemWithTitle:entry[1]]; picker.lastItem.representedObject = entry[0]; }
    for (NSMenuItem *item in picker.itemArray) if ([item.representedObject isEqual:self.selection]) [picker selectItem:item];
    alert.accessoryView = picker;
    [alert addButtonWithTitle:TTText(@"Continue")];
    if (!self.needsWelcome) [alert addButtonWithTitle:TTText(@"Cancel")];
    [NSApp activateIgnoringOtherApps:YES];
    if ([alert runModal] != NSAlertFirstButtonReturn) return;
    NSString *value = picker.selectedItem.representedObject;
    NSUserDefaults *prefs = NSUserDefaults.standardUserDefaults;
    [prefs setObject:value forKey:@"TT:language"];
    [prefs setBool:YES forKey:@"TT:language:welcomed"];
    if ([value isEqual:@"auto"]) [prefs removeObjectForKey:@"AppleLanguages"];
    else [prefs setObject:@[value] forKey:@"AppleLanguages"];
}
@end
