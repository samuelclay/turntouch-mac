#import <Cocoa/Cocoa.h>
#import "TTModeMap.h"
#import "TTModeTwelve.h"
#import "Shortcut.h"

NSString *const kIftttUserIdKey = @"test-user";
NSString *const kIftttDeviceIdKey = @"test-device";

// No global hotkeys, network requests, or real device actions in this fixture.
@implementation MASShortcutBinder
+ (instancetype)sharedBinder { return nil; }
@end
@interface LayoutTestDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic) TTModeMap *modeMap;
@end
@implementation LayoutTestDelegate
@end
@interface LayoutTestMap : TTModeMap
@end
@implementation LayoutTestMap
- (void)bindShortcuts {}
- (void)recordUsage:(NSDictionary *)params {}
@end
static NSMutableArray *executed;
@interface LayoutProbeMode : TTMode
@end
@implementation LayoutProbeMode
- (NSArray *)actions { return @[@"Probe"]; }
- (NSString *)defaultNorth { return @"Probe"; }
- (NSString *)defaultEast { return @"Probe"; }
- (NSString *)defaultWest { return @"Probe"; }
- (NSString *)defaultSouth { return @"Probe"; }
- (void)runProbe { [executed addObject:[self.action optionValue:@"marker"] ?: @"primary"]; }
- (void)doubleRunProbe { [executed addObject:@"legacy-double"]; }
@end
// Stand-ins keep default loading offline; action identifiers come from the shipped plist.
@interface TTModeMusic : LayoutProbeMode @end
@implementation TTModeMusic @end
@interface TTModeHue : LayoutProbeMode @end
@implementation TTModeHue @end
@interface TTModeWemo : LayoutProbeMode @end
@implementation TTModeWemo @end
static int checks;
static void check(BOOL condition, NSString *message) {
    checks++;
    if (!condition) { NSLog(@"FAIL: %@", message); exit(1); }
}
int main(int argc, const char *argv[]) { @autoreleasepool {
    [NSApplication sharedApplication];
    NSUserDefaults *prefs = NSUserDefaults.standardUserDefaults;
    NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
    [prefs registerDefaults:defaults];
    // The runner uses a unique executable name; these defaults never touch the Turn Touch app domain.
    for (NSString *bank in @[@"north", @"east", @"west", @"south"]) [prefs setObject:@"LayoutProbeMode" forKey:[@"TT:mode:" stringByAppendingString:bank]];
    [prefs setObject:@"16_buttons" forKey:@"TT:buttonAppMode"];
    [prefs setInteger:EAST forKey:@"TT:selectedModeDirection"];
    [prefs setObject:@[@"LayoutProbeMode:Probe:legacy"] forKey:@"TT:mode:east:action:north:batchactions"];
    [prefs setObject:@"legacy" forKey:@"TT:mode:east:action:north:batchactions:LayoutProbeMode:Probe:legacy:actionoption:marker"];
    LayoutTestDelegate *delegate = [[LayoutTestDelegate alloc] init];
    NSApp.delegate = delegate;
    delegate.modeMap = [[LayoutTestMap alloc] init];
    TTModeMap *map = delegate.modeMap;
    [map switchMode];
    executed = [NSMutableArray array];
    [map runDirection:NORTH];
    check([executed isEqual:@[@"primary", @"legacy"]], @"existing primary and batch actions still run in 16 mode");
    [map switchButtonAppMode:YES];
    check(map.selectedModeDirection == SINGLE_TAP && map.isTwelveButtonMode, @"12 mode starts on single tap");
    check([[[map selectedModeBatchActions:NORTH].firstObject actionName] isEqualToString:@"TTModeMusicVolumeUp"], @"12 mode starts with iOS music actions, separate from 16 assignments");
    NSArray *expected = @[
        @[@"TTModeMusicVolumeUp", @"TTModeMusicNextTrack", @"TTModeMusicPlayPause", @"TTModeMusicVolumeDown"],
        @[@"TTModeHueSceneEarlyEvening", @"TTModeHueSceneLateEvening", @"TTModeHueRandom", @"TTModeHueSleep"],
        @[@"TTModeWemoDeviceOn", @"TTModeWemoDeviceToggle", @"TTModeWemoDeviceToggle", @"TTModeWemoDeviceOff"]
    ];
    for (TTModeDirection gesture = SINGLE_TAP; gesture <= HOLD; gesture++) {
        [map switchMode:gesture modeName:nil];
        for (TTModeDirection direction = NORTH; direction <= SOUTH; direction++) {
            TTAction *action = [map selectedModeBatchActions:direction].firstObject;
            check([action.actionName isEqualToString:expected[gesture - SINGLE_TAP][direction - NORTH]], @"all twelve defaults match iOS with the Mac Wemo On equivalent");
            map.inspectingModeDirection = direction;
            [map removeBatchAction:action.batchActionKey];
        }
    }
    [map switchMode:SINGLE_TAP modeName:nil];
    check([map selectedModeBatchActions:NORTH].count == 0, @"deliberately removed defaults stay removed");
    for (TTModeDirection gesture = SINGLE_TAP; gesture <= HOLD; gesture++) {
        [map switchMode:gesture modeName:nil];
        for (TTModeDirection direction = NORTH; direction <= SOUTH; direction++) {
            map.inspectingModeDirection = direction;
            map.tempModeName = @"LayoutProbeMode";
            [map addBatchAction:@"Probe"];
            TTAction *action = [map selectedModeBatchActions:direction].firstObject;
            [action changeActionOption:@"marker" to:[NSString stringWithFormat:@"%d:%d", gesture, direction]];
        }
    }
    for (TTModeDirection gesture = SINGLE_TAP; gesture <= HOLD; gesture++) {
        for (TTModeDirection direction = NORTH; direction <= SOUTH; direction++) {
            [executed removeAllObjects];
            [map runGesture:gesture direction:direction];
            check([executed isEqual:@[[NSString stringWithFormat:@"%d:%d", gesture, direction]]], @"all twelve slots dispatch their own normal action and options");
        }
    }
    [map switchButtonAppMode:NO];
    check(!map.isTwelveButtonMode && map.selectedModeDirection == EAST, @"returning to 16 restores the selected app bank");
    [executed removeAllObjects]; [map runDirection:NORTH];
    check([executed isEqual:@[@"primary", @"legacy"]], @"16 assignments and options survive layout changes");
    [map switchButtonAppMode:YES];
    check(map.selectedModeDirection == HOLD, @"returning to 12 restores the selected gesture bank");
    // Recreate the model to prove preferences survive restart rather than an in-memory cache.
    delegate.modeMap = [[LayoutTestMap alloc] init]; map = delegate.modeMap;
    [map switchMode];
    check(map.isTwelveButtonMode && map.selectedModeDirection == HOLD, @"layout and selected bank survive restart");
    [executed removeAllObjects]; [map runGesture:DOUBLE_TAP direction:WEST];
    check([executed isEqual:@[@"7:3"]], @"double tap remains its own normal action after restart");
    // Changing the app edits one action, never the whole gesture bank or its siblings.
    map.inspectingModeDirection = WEST;
    map.tempModeName = @"LayoutProbeMode";
    [map addBatchAction:@"Probe"];
    TTAction *extra = [map selectedModeBatchActions:WEST].lastObject;
    [extra changeActionOption:@"marker" to:@"extra"];
    [map changeDirection:WEST toMode:@"TTModeMusic"];
    check([[map selectedModeBatchActions:WEST].firstObject mode].class == TTModeMusic.class, @"selected button can change apps");
    check([map selectedModeBatchActions:WEST].count == 2, @"changing the primary app preserves additional actions");
    check([[[map selectedModeBatchActions:WEST].lastObject optionValue:@"marker"] isEqual:@"extra"], @"additional action options remain intact");
    check([[[map selectedModeBatchActions:NORTH].firstObject optionValue:@"marker"] isEqual:@"7:1"], @"other physical buttons remain intact");
    [map changeBatchAction:[map selectedModeBatchActions:WEST].lastObject toMode:@"TTModeHue"];
    check([[map selectedModeBatchActions:WEST].lastObject mode].class == TTModeHue.class, @"additional actions can independently change apps");
    [map switchMode:SINGLE_TAP modeName:nil];
    check([[[map selectedModeBatchActions:WEST].firstObject optionValue:@"marker"] isEqual:@"6:3"], @"other gesture banks remain intact");
    delegate.modeMap = [[LayoutTestMap alloc] init]; map = delegate.modeMap;
    [map switchMode:DOUBLE_TAP modeName:nil];
    check([[map selectedModeBatchActions:WEST].firstObject mode].class == TTModeMusic.class && [[map selectedModeBatchActions:WEST].lastObject mode].class == TTModeHue.class, @"changed apps survive restart");
    [prefs removePersistentDomainForName:NSProcessInfo.processInfo.processName];
    printf("PASS: %d button layout and dispatch checks\n", checks);
} return 0; }
