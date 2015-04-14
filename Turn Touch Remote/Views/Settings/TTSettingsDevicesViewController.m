//
//  TTSettingsDevicesViewController.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 4/8/15.
//  Copyright (c) 2015 Turn Touch. All rights reserved.
//

#import "TTSettingsDevicesViewController.h"
#import "TTDevice.h"
#import "NSDate+TimeAgo.h"

@interface TTSettingsDevicesViewController ()

@end

@implementation TTSettingsDevicesViewController

@synthesize devicesTable;
@synthesize latencySlider;
@synthesize modeChangeSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"TTSettingsDevicesViewController" bundle:nibBundleOrNil];
    if (self) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];

        [self registerAsObserver];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillAppear {
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    [super viewWillAppear];
    [devicesTable reloadData];
    [latencySlider setIntegerValue:[[preferences objectForKey:@"TT:firmware:interval_max"] integerValue]];
    [modeChangeSlider setIntegerValue:[[preferences objectForKey:@"TT:firmware:mode_duration"] integerValue]];
}

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"batteryPct"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"lastActionDate"
                                      options:0 context:nil];
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"connectedDevicesCount"
                                      options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(batteryPct))]) {
        [devicesTable reloadData];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(lastActionDate))]) {
        [devicesTable reloadData];
    } else if ([keyPath isEqual:NSStringFromSelector(@selector(connectedDevicesCount))]) {
        [devicesTable reloadData];
    }
}

- (void)dealloc {
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"batteryPct"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"lastActionDate"];
    [appDelegate.bluetoothMonitor removeObserver:self forKeyPath:@"connectedDevicesCount"];
}

#pragma mark - RHPreferencesViewControllerProtocol

- (NSString*)identifier {
    return NSStringFromClass(self.class);
}
- (NSImage*)toolbarItemImage {
    return [NSImage imageNamed:@"imac"];
}
- (NSString*)toolbarItemLabel {
    return @" Devices ";
}

- (NSView*)initialKeyView {
    return nil;
}

#pragma mark - Devices Table

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return appDelegate.bluetoothMonitor.connectedDevicesCount.integerValue;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    NSTextField *result = [tableView makeViewWithIdentifier:@"Devices" owner:self];
    if (result == nil) {
        result = [[NSTextField alloc] initWithFrame:NSZeroRect];
        [result setIdentifier:@"Devices"];
        [result setEditable:NO];
        [result setBordered:NO];
        [result setBackgroundColor:[NSColor clearColor]];
    }
    
    TTDevice *device = [appDelegate.bluetoothMonitor.connectedDevices objectAtIndex:row];
    if (device.batteryPct.intValue <= 0) {
        // Still connecting
        if ([tableColumn.identifier isEqualToString:@"deviceIdentifier"]) {
            result.stringValue = @"Connecting to remote...";
        } else if ([tableColumn.identifier isEqualToString:@"batteryLevel"]) {
            result.stringValue = @"";
        } else if ([tableColumn.identifier isEqualToString:@"lastAction"]) {
            result.stringValue = @"";
        }
    } else {
        if ([tableColumn.identifier isEqualToString:@"deviceIdentifier"]) {
            result.stringValue = device.uuid.UUIDString;
        } else if ([tableColumn.identifier isEqualToString:@"batteryLevel"]) {
            result.stringValue = [NSString stringWithFormat:@"%@%%", device.batteryPct];
        } else if ([tableColumn.identifier isEqualToString:@"lastAction"]) {
            result.stringValue = [device.lastActionDate timeAgo];
        }
    }
    
    return result;
}

#pragma mark - Latency Slider

- (IBAction)slideLatency:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    BOOL endingDrag = event.type == NSLeftMouseUp;
//    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
//    NSLog(@"slider value: %d - %d", [sender integerValue], [[preferences objectForKey:@"TT:firmware:interval_min"] intValue]);
    
    if (endingDrag) {
        [appDelegate.bluetoothMonitor setDeviceLatency:[sender integerValue]];
    }
}

#pragma mark - Mode Change Slider

- (void)slideModeChange:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    BOOL endingDrag = event.type == NSLeftMouseUp;
//    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
//    NSLog(@"slider value: %d - %d", [sender integerValue], [[preferences objectForKey:@"TT:firmware:mode_duration"] intValue]);
    
    if (endingDrag) {
        [appDelegate.bluetoothMonitor setModeDuration:[sender integerValue]];
    }
}

@end
