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

    TTHueResourceCache *cache = [TTModeHue resourceCache];
    NSMutableArray *rooms = [[NSMutableArray alloc] init];
    [self.roomDropdown removeAllItems];

    [rooms addObject:@{@"name": @"All Rooms", @"identifier": @"all"}];

    if (cache) {
        for (NSString *roomId in cache.rooms) {
            TTHueRoom *room = cache.rooms[roomId];
            [rooms addObject:@{@"name": room.metadata.name, @"identifier": room.roomId}];
        }
    }

    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [rooms sortUsingDescriptors:@[sd]];

    for (NSDictionary *room in rooms) {
        [self.roomDropdown addItemWithTitle:room[@"name"]];
        if ([room[@"identifier"] isEqualToString:roomSelectedIdentifier]) {
            roomSelected = room[@"name"];
        }
    }

    if (roomSelected) {
        [self.roomDropdown selectItemWithTitle:roomSelected];
    }
}

#pragma mark - Actions

- (IBAction)didChangeRoom:(id)sender {
    NSMenuItem *menuItem = [self.roomDropdown selectedItem];
    TTHueResourceCache *cache = [TTModeHue resourceCache];
    NSString *roomIdentifier = @"all";

    if (cache) {
        for (NSString *roomId in cache.rooms) {
            TTHueRoom *room = cache.rooms[roomId];
            if ([room.metadata.name isEqualToString:menuItem.title]) {
                roomIdentifier = room.roomId;
                break;
            }
        }
    }

    [self.action changeActionOption:kHueRoom to:roomIdentifier];
}

@end
