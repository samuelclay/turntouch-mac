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
    MODAL_PAIRING_INTRO,
    MODAL_PAIRING_SEARCH,
    MODAL_PAIRING_SUCCESS,
    MODAL_PAIRING_FAILURE,
    MODAL_PAIRING_FAILURE_EXPLAINER,
} TTModalPairing;

typedef enum TTModalFTUX : NSUInteger {
    MODAL_FTUX_INTRO,
    MODAL_FTUX_ACTIONS,
    MODAL_FTUX_MODES,
    MODAL_FTUX_BATCHACTIONS,
} TTModalFTUX;

#endif /* TTPanelStates_h */
