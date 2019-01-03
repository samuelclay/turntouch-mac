/*
 * Airfoil.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class AirfoilApplication, AirfoilDocument, AirfoilWindow, AirfoilApplication, AirfoilSpeaker, AirfoilAudioSource, AirfoilApplicationSource, AirfoilDeviceSource, AirfoilSystemSource;

enum AirfoilSaveOptions {
	AirfoilSaveOptionsYes = 'yes ' /* Save the file. */,
	AirfoilSaveOptionsNo = 'no  ' /* Do not save the file. */,
	AirfoilSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum AirfoilSaveOptions AirfoilSaveOptions;

enum AirfoilPrintingErrorHandling {
	AirfoilPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	AirfoilPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum AirfoilPrintingErrorHandling AirfoilPrintingErrorHandling;

@protocol AirfoilGenericMethods

- (void) closeSaving:(AirfoilSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(id)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface AirfoilApplication : SBApplication

- (SBElementArray<AirfoilDocument *> *) documents;
- (SBElementArray<AirfoilWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(AirfoilSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) connectTo:(NSArray<AirfoilSpeaker *> *)x password:(NSString *)password;  // Connect to the speakers
- (void) disconnectFrom:(NSArray<AirfoilSpeaker *> *)x;  // Disconnect from the speakers

@end

// A document.
@interface AirfoilDocument : SBObject <AirfoilGenericMethods>

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.


@end

// A window.
@interface AirfoilWindow : SBObject <AirfoilGenericMethods>

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?
@property (copy, readonly) AirfoilDocument *document;  // The document whose contents are displayed in the window.


@end



/*
 * Airfoil
 */

// The application's top-level scripting object.
@interface AirfoilApplication (Airfoil)

- (SBElementArray<AirfoilSpeaker *> *) speakers;
- (SBElementArray<AirfoilApplicationSource *> *) applicationSources;
- (SBElementArray<AirfoilDeviceSource *> *) deviceSources;
- (SBElementArray<AirfoilSystemSource *> *) systemSources;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (copy, readonly) NSString *version;  // The version of the application.
@property (readonly) BOOL frontmost;  // Is this the frontmost (active) application?
@property (copy) AirfoilAudioSource *currentAudioSource;  // The source of the audio sent to the speakers. 
@property BOOL linkedVolume;  // Is the volume of the speakers linked the the system volume?

@end

// A speaker on the network
@interface AirfoilSpeaker : SBObject <AirfoilGenericMethods>

@property (copy, readonly) NSString *name;  // The speaker name.
@property double volume;  // The volume of the speaker (between 0 and 1). If the volume is linked to the system volume, this property cannot be set.
@property (readonly) BOOL connected;  // Is the application connected to the speaker?
@property (copy, readonly) NSString *bonjourName;  // The Bonjour name of the speaker. This property was temporarily added in Airfoil 4.8.12 and may be removed in a future version.
- (NSString *) id;  // The unique identifier of the speaker


@end

// A source of audio to send to the speakers
@interface AirfoilAudioSource : SBObject <AirfoilGenericMethods>

@property (copy, readonly) NSString *name;  // The name of the audio source
- (NSNumber *) id;  // The unique identifier of the audio source object


@end

// An application whose sound will be sent to the speakers. This is the only audio source that can be directly created by a script.
@interface AirfoilApplicationSource : AirfoilAudioSource

@property (copy) NSString *applicationFile;  // The application file.


@end

// An audio device attached to the machine.
@interface AirfoilDeviceSource : AirfoilAudioSource


@end

// The internal system audio source.
@interface AirfoilSystemSource : AirfoilAudioSource


@end

