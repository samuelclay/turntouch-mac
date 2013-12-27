//
//  TTModeMac.m
//  Turn Touch App
//
//  Created by Samuel Clay on 12/23/13.
//  Copyright (c) 2013 Turn Touch. All rights reserved.
//
#import <AudioToolbox/AudioServices.h>
#import "TTModeMac.h"
#include <sys/sysctl.h>

@implementation TTModeMac

@dynamic volume;

+ (NSString *)title {
    return @"Mac OS";
}

+ (NSString *)description {
    return @"System-level controls";
}

- (NSString *)imageName {
    NSString *machineModel = [[self class] machineModel];
    
    if ([machineModel rangeOfString:@"MacBook"].location != NSNotFound) {
        return @"macbookpro.png";
    }

    return @"imac.png";
}

- (NSString *)titleNorth {
    return @"Volume Up";
}

- (NSString *)titleEast {
    return @"Turn off screen";
}

- (NSString *)titleWest {
    return @"Mute";
}

- (NSString *)titleSouth {
    return @"Volume Down";
}

- (void)runNorth {
    [self setVolume:[self volume] + 0.1];
}
- (void)runSouth {
    [self setVolume:[self volume] - 0.1];
}
- (void)runWest {
    BOOL v = [self isMuted];
    if (v) {
        [self setVolume:self.volume];
    } else {
        [self setVolume:0];
    }
}

+(NSString *) machineModel
{
    size_t len = 0;
    sysctlbyname("hw.model", NULL, &len, NULL, 0);
    
    if (len)
    {
        char *model = malloc(len*sizeof(char));
        sysctlbyname("hw.model", model, &len, NULL, 0);
        NSString *model_ns = [NSString stringWithUTF8String:model];
        free(model);
        return model_ns;
    }
    
    return @"Just an Apple Computer"; //incase model name can't be read
}

- (float)volume {
    Float32 outputVolume;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    
    // Get the default device
    AudioDeviceID outputDeviceID = [self defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown) {
        NSLog(@"Unknown default device");
        return 0.0f;
    }
    
    // See if the device has a virtual master
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0f;
    }
    
    // Read the volume
    propertySize = (UInt32) sizeof(Float32);
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &outputVolume);
    
    // Check success
    if (status) {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0f;
    }
    
    // Clamp it to [0,1]
    if (outputVolume < 0.0f) return 0.0f;
    if (outputVolume > 1.0f) return 1.0f;
    
    return outputVolume;
}

- (void)setVolume:(float)newVolume {
    // Clamp it to [0,1]
    if (newVolume < 0.0f) newVolume = 0.0f;
    if (newVolume > 1.0f) newVolume = 1.0f;
    
    // Set up the change request
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    
    // If the new volume is very low, just mute
    if (newVolume < 0.001) {
        NSLog(@"Muting audio");
        propertyAOPA.mSelector = kAudioDevicePropertyMute;
    }	else {
        NSLog(@"Setting audio volume to %d%%", (int) (newVolume * 100.0));
        propertyAOPA.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMasterVolume;
    }
    
    // Get the default audio device
    AudioDeviceID outputDeviceID = [self defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown) {
        NSLog(@"Unknown default audio device");
        return;
    }
    
    // Check that the device has a virtual master volume
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) {
        NSLog(@"Device 0x%0x does not support volume control", outputDeviceID);
        return;
    }
    
    // Check that we can set the volume
    // TODO: If we're trying to mute and it's not supported, try just setting the volume
    Boolean canSetVolume = NO;
    status = AudioHardwareServiceIsPropertySettable(outputDeviceID, &propertyAOPA, &canSetVolume);
    
    if (status || canSetVolume == NO)	{
        NSLog(@"Device 0x%0x does not support volume control", outputDeviceID);
        return;
    }
    
    if (propertyAOPA.mSelector == kAudioDevicePropertyMute) {
        // Request setting the muted state
        propertySize = (UInt32) sizeof(UInt32);
        UInt32 mute = 1;
        status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
    } else {
        // Request setting the volume
        propertySize = (UInt32) sizeof(Float32);
        status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &newVolume);
        
        if (status) {
            NSLog(@"Unable to set volume for device 0x%0x", outputDeviceID);
        }
        
        // make sure we're not muted
        propertyAOPA.mSelector = kAudioDevicePropertyMute;
        propertySize = (UInt32) sizeof(UInt32);
        UInt32 mute = 0;
        if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) {
            NSLog(@"Device 0x%0x does not support muting", outputDeviceID);
            return;
        }
        
        // Check that we can set volume to non-muted
        Boolean canSetMute = NO;
        status = AudioHardwareServiceIsPropertySettable(outputDeviceID, &propertyAOPA, &canSetMute);
        if (status || !canSetMute) {
            NSLog(@"Device 0x%0x does not support muting", outputDeviceID);
            return;
        }
        
        // Set device unmuted
        status = AudioHardwareServiceSetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, propertySize, &mute);
	}
    
    if (status) {
        NSLog(@"Unable to set volume for device 0x%0x", outputDeviceID);
    }
}

- (BOOL)isMuted {
    bool muted;
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioDevicePropertyMute;
    propertyAOPA.mScope = kAudioDevicePropertyScopeOutput;
    
    // Get the default device
    AudioDeviceID outputDeviceID = [self defaultOutputDeviceID];
    if (outputDeviceID == kAudioObjectUnknown) {
        NSLog(@"Unknown default device");
        return 0.0f;
    }
    
    // See if the device has a virtual master
    if (!AudioHardwareServiceHasProperty(outputDeviceID, &propertyAOPA)) {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0f;
    }
    
    // Read the volume
    propertySize = (UInt32) sizeof(bool);
    status = AudioHardwareServiceGetPropertyData(outputDeviceID, &propertyAOPA, 0, NULL, &propertySize, &muted);
    
    // Check success
    if (status) {
        NSLog(@"No volume returned for device 0x%0x", outputDeviceID);
        return 0.0f;
    }
    
    return muted;
}

- (AudioDeviceID)defaultOutputDeviceID {
    AudioDeviceID	outputDeviceID = kAudioObjectUnknown;
    
    // Prepare the request
    UInt32 propertySize = 0;
    OSStatus status = noErr;
    AudioObjectPropertyAddress propertyAOPA;
    propertyAOPA.mScope = kAudioObjectPropertyScopeGlobal;
    propertyAOPA.mElement = kAudioObjectPropertyElementMaster;
    propertyAOPA.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    
    // Check that we can read the default output device
    if (!AudioHardwareServiceHasProperty(kAudioObjectSystemObject, &propertyAOPA)) {
        NSLog(@"Cannot find default output device!");
        return outputDeviceID;
    }
    
    // Send the request to get the default device
    propertySize = (UInt32) sizeof(AudioDeviceID);
    status = AudioHardwareServiceGetPropertyData(kAudioObjectSystemObject,
                                                 &propertyAOPA, 0, NULL, &propertySize, &outputDeviceID);
    if (status) {
        NSLog(@"Cannot find default output device!");
    }
    return outputDeviceID;
}


@end
