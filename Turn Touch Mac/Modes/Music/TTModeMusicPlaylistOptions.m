//
//  TTModeMusicPlaylist.m
//  Turn Touch Mac
//
//  Created by Samuel Clay on 2/16/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#import "TTModeMusicPlaylistOptions.h"

@interface TTModeMusicPlaylistOptions ()

@end

@implementation TTModeMusicPlaylistOptions

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    
//    BOOL playlistShuffle = [[self.action optionValue:kMusicPlaylistShuffle] boolValue];
//    [checkboxShuffle setState:playlistShuffle];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, (unsigned long)NULL), ^(void){
                       [self populateiTunesSources];
                   });
}


- (IBAction)changeiTunesSource:(id)sender {
    SBElementArray *playlists = [TTModeMusic userPlaylists];
    iTunesUserPlaylist *singleSelectedPlaylist;
    iTunesUserPlaylist *doubleSelectedPlaylist;

    for (iTunesUserPlaylist *playlist in playlists) {
        if ([playlist.name isEqualToString:self.singleDropdowniTunesSources.selectedItem.title]) {
            singleSelectedPlaylist = playlist;
        }
        if ([playlist.name isEqualToString:self.doubleDropdowniTunesSources.selectedItem.title]) {
            doubleSelectedPlaylist = playlist;
        }
    }
    
    [self.action changeActionOption:kMusicPlaylistSingle to:singleSelectedPlaylist.persistentID];
    [self.action changeActionOption:kMusicPlaylistDouble to:doubleSelectedPlaylist.persistentID];

    [self updateTracksCount:singleSelectedPlaylist label:self.singleTextTracksCount];
    [self updateTracksCount:doubleSelectedPlaylist label:self.doubleTextTracksCount];
}

- (void)updateTracksCount:(iTunesPlaylist *)selectedPlaylist label:(NSTextField *)label {
    NSInteger tracks = selectedPlaylist.tracks.count;
    [label setStringValue:[NSString stringWithFormat:@"%ld %@",
                                     (long)tracks, tracks == 1 ? @"track" : @"tracks"]];
}

- (iTunesLibraryPlaylist *)iTunesPlaylist:(NSString *)persistentId {
    SBElementArray *playlists = [TTModeMusic userPlaylists];
    for (iTunesLibraryPlaylist *playlist in playlists) {
        if ([playlist.persistentID isEqualToString:persistentId]) {
            return playlist;
        }
    }
    
    return nil;
}

- (void)populateiTunesSources {
    NSString *singleSelectedPlaylistId = [self.action optionValue:kMusicPlaylistSingle];
    NSString *doubleSelectedPlaylistId = [self.action optionValue:kMusicPlaylistDouble];
    NSMenuItem *singleSelectedMenuItem;
    NSMenuItem *doubleSelectedMenuItem;
    SBElementArray *playlists = [TTModeMusic userPlaylists];
    NSInteger tag = 0;
    iTunesUserPlaylist *singleSelectedPlaylist;
    iTunesUserPlaylist *doubleSelectedPlaylist;
    iTunesUserPlaylist *libraryPlaylist;
    NSMenuItem *singleLibraryMenuItem;
    NSMenuItem *doubleLibraryMenuItem;
    NSImage *image;
    NSMutableArray *singleMenuItems = [NSMutableArray array];
    NSMutableArray *doubleMenuItems = [NSMutableArray array];

    for (iTunesUserPlaylist *playlist in playlists) {
        tag++;
        if (!playlist.size) continue;
        NSMenuItem *singleMenuItem = [[NSMenuItem alloc] init];
        NSMenuItem *doubleMenuItem = [[NSMenuItem alloc] init];
        switch (playlist.specialKind) {
            case iTunesESpKLibrary:
                image = [NSImage imageNamed:@"itunes_library_icon"];
                break;
                
            case iTunesESpKMusic:
                image = [NSImage imageNamed:@"itunes_music_icon"];
                libraryPlaylist = playlist;
                singleLibraryMenuItem = singleMenuItem;
                doubleLibraryMenuItem = doubleMenuItem;
                break;
                
            case iTunesESpKGenius:
                image = [NSImage imageNamed:@"itunes_genius_icon"];
                break;
                
            case iTunesESpKBooks:
                image = [NSImage imageNamed:@"itunes_audiobook_icon"];
                break;
                
            case iTunesESpKPodcasts:
                image = [NSImage imageNamed:@"itunes_podcast_icon"];
                break;
                
            case iTunesESpKITunesU:
                image = [NSImage imageNamed:@"itunes_itunesu_icon"];
                break;
                
            case iTunesESpKMovies:
                image = [NSImage imageNamed:@"itunes_movies_icon"];
                break;
                
            case iTunesESpKTVShows:
                image = [NSImage imageNamed:@"itunes_tv_icon"];
                break;
                
            default:
                //                NSLog(@"playlist.specialKind: %@", playlist.properties);
                if ([playlist smart]) {
                    image = [NSImage imageNamed:@"itunes_playlist_icon"];
                } else {
                    image = [NSImage imageNamed:@"itunes_library_icon"];
                }
                break;
        }
        [image setSize:NSMakeSize(16, 16)];
        singleMenuItem.image = image;
        doubleMenuItem.image = image;
        singleMenuItem.title = playlist.name;
        doubleMenuItem.title = playlist.name;
        singleMenuItem.tag = tag;
        doubleMenuItem.tag = tag;
        [singleMenuItems addObject:singleMenuItem];
        [doubleMenuItems addObject:doubleMenuItem];
        if ([playlist.persistentID isEqualToString:singleSelectedPlaylistId]) {
            singleSelectedMenuItem = singleMenuItem;
            singleSelectedPlaylist = playlist;
        }
        if ([playlist.persistentID isEqualToString:doubleSelectedPlaylistId]) {
            doubleSelectedMenuItem = doubleMenuItem;
            doubleSelectedPlaylist = playlist;
        }
    }
    
    if (!singleSelectedPlaylistId) {
        singleSelectedMenuItem = singleLibraryMenuItem;
    }
    if (!doubleSelectedPlaylistId) {
        doubleSelectedMenuItem = doubleLibraryMenuItem;
    }
    dispatch_async(dispatch_get_main_queue(), ^(void){
        for (NSMenuItem *menuItem in singleMenuItems) {
            [self.singleDropdowniTunesSources.menu addItem:menuItem];
        }
        for (NSMenuItem *menuItem in doubleMenuItems) {
            [self.doubleDropdowniTunesSources.menu addItem:menuItem];
        }

        if (!singleSelectedPlaylistId) {
            [self.action changeActionOption:kMusicPlaylistSingle to:libraryPlaylist.persistentID];
            [self updateTracksCount:libraryPlaylist label:self.singleTextTracksCount];
        } else {
            [self updateTracksCount:singleSelectedPlaylist label:self.singleTextTracksCount];
        }
        
        if (!doubleSelectedPlaylistId) {
            [self.action changeActionOption:kMusicPlaylistDouble to:libraryPlaylist.persistentID];
            [self updateTracksCount:libraryPlaylist label:self.doubleTextTracksCount];
        } else {
            [self updateTracksCount:doubleSelectedPlaylist label:self.doubleTextTracksCount];
        }

        [self.singleDropdowniTunesSources selectItem:singleSelectedMenuItem];
        [self.doubleDropdowniTunesSources selectItem:doubleSelectedMenuItem];
        [self.singleDropdowniTunesSources setNeedsDisplay:YES];
        [self.doubleDropdowniTunesSources setNeedsDisplay:YES];
    });
}

- (IBAction)changeShuffle:(id)sender {
//    [self.action changeActionOption:kMusicPlaylistShuffle
//                                 to:[NSNumber numberWithBool:checkboxShuffle.state]];
}

@end
