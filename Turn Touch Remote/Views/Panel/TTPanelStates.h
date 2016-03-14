//
//  TTPanelStates.h
//  Turn Touch Remote
//
//  Created by Samuel Clay on 3/10/16.
//  Copyright © 2016 Turn Touch. All rights reserved.
//

#ifndef TTPanelStates_h
#define TTPanelStates_h

typedef enum TTPanelModal : NSUInteger {
    PANEL_MODAL_APP,
    PANEL_MODAL_FTUX,
    PANEL_MODAL_PAIRING,
    PANEL_MODAL_DEVICES,
    PANEL_MODAL_ABOUT,
} TTPanelModal;

typedef enum TTModalPairing : NSUInteger {
    MODAL_PAIRING_INTRO = 1,
    MODAL_PAIRING_SEARCH = 2,
    MODAL_PAIRING_SUCCESS = 3,
    MODAL_PAIRING_FAILURE = 4,
    MODAL_PAIRING_FAILURE_EXPLAINER = 5,
} TTModalPairing;

typedef enum TTModalFTUX : NSUInteger {
    MODAL_FTUX_INTRO = 1,
    MODAL_FTUX_ACTIONS = 2,
    MODAL_FTUX_MODES = 3,
    MODAL_FTUX_BATCHACTIONS = 4,
    MODAL_FTUX_HUD = 5,
} TTModalFTUX;

#endif /* TTPanelStates_h */
