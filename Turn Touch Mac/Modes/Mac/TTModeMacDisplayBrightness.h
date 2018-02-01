//
//  TTModeMacDisplayBrightness.h
//  Turn Touch Mac
//
//  Created by Samuel Clay on 1/31/18.
//  Copyright © 2018 Turn Touch. All rights reserved.
//

#ifndef TTModeMacDisplayBrightness_h
#define TTModeMacDisplayBrightness_h

#include <stdio.h>

/*
 Set Mac Display Backlight Brightness
 Usage:
 gcc -std=c99 -o dbrightness display-brightness.c -framework IOKit -framework ApplicationServices
 ./dbrightness 0.8
 */

#include <IOKit/graphics/IOGraphicsLib.h>
#include <ApplicationServices/ApplicationServices.h>

// According to: https://stackoverflow.com/questions/20025868/cgdisplayioserviceport-is-deprecated-in-os-x-10-9-how-to-replace
// ...CGDisplayIOServicePort is deprecated. However, the discussion from: https://github.com/glfw/glfw/blob/e0a6772e5e4c672179fc69a90bcda3369792ed1f/src/cocoa_monitor.m
// ...suggests that GLFW's cocoa_monitor offers the implementation we need. Eun's solution appears to work well. It is pasted below.

// Returns the io_service_t corresponding to a CG display ID, or 0 on failure.
// The io_service_t should be released with IOObjectRelease when not needed.
//
static io_service_t IOServicePortFromCGDisplayID(CGDirectDisplayID displayID);
float getDisplayBrightness(void);
void setDisplayBrightness(float brightness);

#endif /* TTModeMacDisplayBrightness_h */
