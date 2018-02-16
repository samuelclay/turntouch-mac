//
//  TTModeMusicPlaylist.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/16/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTOptionsDetailViewController.h"
#import "TTModeMusicPlaylistOptions.h"
#import "iTunes.h"
#import "TTModeMusic.h"

@interface TTModeMusicPlaylistOptions : TTOptionsDetailViewController

@property (nonatomic) IBOutlet NSPopUpButton *singleDropdowniTunesSources;
@property (nonatomic) IBOutlet NSTextField *singleTextTracksCount;
@property (nonatomic) IBOutlet NSButton *singleCheckboxShuffle;
@property (nonatomic) IBOutlet NSPopUpButton *doubleDropdowniTunesSources;
@property (nonatomic) IBOutlet NSTextField *doubleTextTracksCount;
@property (nonatomic) IBOutlet NSButton *doubleCheckboxShuffle;

- (IBAction)changeiTunesSource:(id)sender;

@end
