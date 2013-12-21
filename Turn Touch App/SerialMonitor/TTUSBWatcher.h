//
//  TTUSBWatcher.h
//  Turn Touch App
//
//  Created by Samuel Clay on 12/20/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//

#ifndef Turn_Touch_App_TTUSBWatcher_h
#define Turn_Touch_App_TTUSBWatcher_h

void DeviceNotification(void *refCon, io_service_t service, natural_t messageType, void *messageArgument);
void DeviceAdded(void *refCon, io_iterator_t iterator);
void SignalHandler(int sigraised);
void WatchUSB(dispatch_block_t addBlock, dispatch_block_t removeBlock);

#endif
