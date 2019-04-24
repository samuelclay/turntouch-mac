//
//  TTModeHuePicker.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 12/23/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#import "TTModeHue.h"
#import "TTModeHuePicker.h"

@interface TTModeHuePicker ()

@end

@implementation TTModeHuePicker

- (void)viewDidLoad {
    [super viewDidLoad];

    [self drawRooms];
}

- (void)drawRooms {
    [self.roomSpinner setHidden:YES];
    [self.roomRefreshButton setHidden:NO];

    NSString *roomSelectedIdentifier = [self.action optionValue:kHueRoom inDirection:self.appDelegate.modeMap.inspectingModeDirection];
    NSString *roomSelected;
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSMutableArray *rooms = [[NSMutableArray alloc] init];
    [self.roomDropdown removeAllItems];
    
    [rooms addObject:@{@"name": @"All Rooms", @"identifier": @"all"}];
    for (PHGroup *group in cache.groups.allValues) {
        //        NSLog(@"Room: %@ %@", group.identifier, group.name);
        [rooms addObject:@{@"name": group.name, @"identifier": group.identifier}];
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [rooms sortUsingDescriptors:@[sd]];
    
    for (NSDictionary *room in rooms) {
        [self.roomDropdown addItemWithTitle:room[@"name"]];
        if ([room[@"identifier"] isEqualToString:roomSelectedIdentifier]) {
            roomSelected = room[@"name"];
        }
    }
    
    [self.roomDropdown selectItemWithTitle:roomSelected];
}

#pragma mark - Actions

- (IBAction)didChangeRoom:(id)sender {
    NSMenuItem *menuItem = [self.roomDropdown selectedItem];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    NSString *roomIdentifier;
    
    for (PHGroup *group in cache.groups.allValues) {
        if ([group.name isEqualToString:menuItem.title]) {
            roomIdentifier = group.identifier;
            break;
        }
    }
    
    [self.action changeActionOption:kHueRoom to:roomIdentifier];
}

@end
