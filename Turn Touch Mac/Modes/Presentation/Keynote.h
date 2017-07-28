/*
 * Keynote.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class KeynoteApplication, KeynoteDocument, KeynoteWindow, KeynoteTheme, KeynoteRichText, KeynoteCharacter, KeynoteParagraph, KeynoteWord, KeynoteIWorkContainer, KeynoteSlide, KeynoteMasterSlide, KeynoteIWorkItem, KeynoteAudioClip, KeynoteShape, KeynoteChart, KeynoteImage, KeynoteGroup, KeynoteLine, KeynoteMovie, KeynoteTable, KeynoteTextItem, KeynoteRange, KeynoteCell, KeynoteRow, KeynoteColumn;

enum KeynoteSaveOptions {
	KeynoteSaveOptionsYes = 'yes ' /* Save the file. */,
	KeynoteSaveOptionsNo = 'no  ' /* Do not save the file. */,
	KeynoteSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum KeynoteSaveOptions KeynoteSaveOptions;

enum KeynotePrintingErrorHandling {
	KeynotePrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	KeynotePrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum KeynotePrintingErrorHandling KeynotePrintingErrorHandling;

enum KeynoteSaveableFileFormat {
	KeynoteSaveableFileFormatKeynote = 'Knff' /* The Keynote native file format */
};
typedef enum KeynoteSaveableFileFormat KeynoteSaveableFileFormat;

enum KeynoteExportFormat {
	KeynoteExportFormatHTML = 'Khtm' /* HTML */,
	KeynoteExportFormatQuickTimeMovie = 'Kmov' /* QuickTime movie */,
	KeynoteExportFormatPDF = 'Kpdf' /* PDF */,
	KeynoteExportFormatSlideImages = 'Kimg' /* image */,
	KeynoteExportFormatMicrosoftPowerPoint = 'Kppt' /* Microsoft PowerPoint */,
	KeynoteExportFormatKeynote09 = 'Kkey' /* Keynote 09 */
};
typedef enum KeynoteExportFormat KeynoteExportFormat;

enum KeynoteImageExportFormats {
	KeynoteImageExportFormatsJPEG = 'Kifj' /* JPEG */,
	KeynoteImageExportFormatsPNG = 'Kifp' /* PNG */,
	KeynoteImageExportFormatsTIFF = 'Kift' /* TIFF */
};
typedef enum KeynoteImageExportFormats KeynoteImageExportFormats;

enum KeynoteMovieExportFormats {
	KeynoteMovieExportFormats360p = 'Kmf3' /* 360p */,
	KeynoteMovieExportFormats540p = 'Kmf5' /* 540p */,
	KeynoteMovieExportFormats720p = 'Kmf7' /* 720p */,
	KeynoteMovieExportFormats1080p = 'Kmf8' /* 1080p */,
	KeynoteMovieExportFormats2160p = 'Kmf4' /* DCI 4K (4096x2160) */,
	KeynoteMovieExportFormatsNativeSize = 'KmfN' /* Exported movie will have the same dimensions as the document, up to 4096x2160 */
};
typedef enum KeynoteMovieExportFormats KeynoteMovieExportFormats;

enum KeynotePrintWhat {
	KeynotePrintWhatIndividualSlides = 'Kpwi' /* individual slides */,
	KeynotePrintWhatSlideWithNotes = 'Kpwn' /* slides with notes */,
	KeynotePrintWhatHandouts = 'Kpwh' /* handouts */
};
typedef enum KeynotePrintWhat KeynotePrintWhat;

enum KeynotePDFImageQuality {
	KeynotePDFImageQualityGood = 'KnP0' /* good quality */,
	KeynotePDFImageQualityBetter = 'KnP1' /* better quality */,
	KeynotePDFImageQualityBest = 'KnP2' /* best quality */
};
typedef enum KeynotePDFImageQuality KeynotePDFImageQuality;

enum KeynoteTransitionEffects {
	KeynoteTransitionEffectsNoTransitionEffect = 'tnil' /*  */,
	KeynoteTransitionEffectsMagicMove = 'tmjv' /*  */,
	KeynoteTransitionEffectsShimmer = 'tshm' /*  */,
	KeynoteTransitionEffectsSparkle = 'tspk' /*  */,
	KeynoteTransitionEffectsSwing = 'tswg' /*  */,
	KeynoteTransitionEffectsObjectCube = 'tocb' /*  */,
	KeynoteTransitionEffectsObjectFlip = 'tofp' /*  */,
	KeynoteTransitionEffectsObjectPop = 'topp' /*  */,
	KeynoteTransitionEffectsObjectPush = 'toph' /*  */,
	KeynoteTransitionEffectsObjectRevolve = 'torv' /*  */,
	KeynoteTransitionEffectsObjectZoom = 'tozm' /*  */,
	KeynoteTransitionEffectsPerspective = 'tprs' /*  */,
	KeynoteTransitionEffectsClothesline = 'tclo' /*  */,
	KeynoteTransitionEffectsConfetti = 'tcft' /*  */,
	KeynoteTransitionEffectsDissolve = 'tdis' /*  */,
	KeynoteTransitionEffectsDrop = 'tdrp' /*  */,
	KeynoteTransitionEffectsDroplet = 'tdpl' /*  */,
	KeynoteTransitionEffectsFadeThroughColor = 'tftc' /*  */,
	KeynoteTransitionEffectsGrid = 'tgrd' /*  */,
	KeynoteTransitionEffectsIris = 'tirs' /*  */,
	KeynoteTransitionEffectsMoveIn = 'tmvi' /*  */,
	KeynoteTransitionEffectsPush = 'tpsh' /*  */,
	KeynoteTransitionEffectsReveal = 'trvl' /*  */,
	KeynoteTransitionEffectsSwitch = 'tswi' /*  */,
	KeynoteTransitionEffectsWipe = 'twpe' /*  */,
	KeynoteTransitionEffectsBlinds = 'tbld' /*  */,
	KeynoteTransitionEffectsColorPlanes = 'tcpl' /*  */,
	KeynoteTransitionEffectsCube = 'tcub' /*  */,
	KeynoteTransitionEffectsDoorway = 'tdwy' /*  */,
	KeynoteTransitionEffectsFall = 'tfal' /*  */,
	KeynoteTransitionEffectsFlip = 'tfip' /*  */,
	KeynoteTransitionEffectsFlop = 'tfop' /*  */,
	KeynoteTransitionEffectsMosaic = 'tmsc' /*  */,
	KeynoteTransitionEffectsPageFlip = 'tpfl' /*  */,
	KeynoteTransitionEffectsPivot = 'tpvt' /*  */,
	KeynoteTransitionEffectsReflection = 'trfl' /*  */,
	KeynoteTransitionEffectsRevolvingDoor = 'trev' /*  */,
	KeynoteTransitionEffectsScale = 'tscl' /*  */,
	KeynoteTransitionEffectsSwap = 'tswp' /*  */,
	KeynoteTransitionEffectsSwoosh = 'tsws' /*  */,
	KeynoteTransitionEffectsTwirl = 'ttwl' /*  */,
	KeynoteTransitionEffectsTwist = 'ttwi' /*  */
};
typedef enum KeynoteTransitionEffects KeynoteTransitionEffects;

enum KeynoteTAVT {
	KeynoteTAVTBottom = 'avbt' /* Right-align content. */,
	KeynoteTAVTCenter = 'actr' /* Center-align content. */,
	KeynoteTAVTTop = 'avtp' /* Top-align content. */
};
typedef enum KeynoteTAVT KeynoteTAVT;

enum KeynoteTAHT {
	KeynoteTAHTAutoAlign = 'aaut' /* Auto-align based on content type. */,
	KeynoteTAHTCenter = 'actr' /* Center-align content. */,
	KeynoteTAHTJustify = 'ajst' /* Fully justify (left and right) content. */,
	KeynoteTAHTLeft = 'alft' /* Left-align content. */,
	KeynoteTAHTRight = 'arit' /* Right-align content. */
};
typedef enum KeynoteTAHT KeynoteTAHT;

enum KeynoteNMSD {
	KeynoteNMSDAscending = 'ascn' /* Sort in increasing value order */,
	KeynoteNMSDDescending = 'dscn' /* Sort in decreasing value order */
};
typedef enum KeynoteNMSD KeynoteNMSD;

enum KeynoteNMCT {
	KeynoteNMCTAutomatic = 'faut' /* Automatic format */,
	KeynoteNMCTCheckbox = 'fcch' /* Checkbox control format (Numbers only) */,
	KeynoteNMCTCurrency = 'fcur' /* Currency number format */,
	KeynoteNMCTDateAndTime = 'fdtm' /* Date and time format */,
	KeynoteNMCTFraction = 'ffra' /* Fraction number format */,
	KeynoteNMCTNumber = 'nmbr' /* Decimal number format */,
	KeynoteNMCTPercent = 'fper' /* Percentage number format */,
	KeynoteNMCTPopUpMenu = 'fcpp' /* Pop-up menu control format (Numbers only) */,
	KeynoteNMCTScientific = 'fsci' /* Scientific notation format */,
	KeynoteNMCTSlider = 'fcsl' /* Slider control format (Numbers only) */,
	KeynoteNMCTStepper = 'fcst' /* Stepper control format (Numbers only) */,
	KeynoteNMCTText = 'ctxt' /* Text format */,
	KeynoteNMCTDuration = 'fdur' /* Duration format */,
	KeynoteNMCTRating = 'frat' /* Rating format. (Numbers only) */,
	KeynoteNMCTNumeralSystem = 'fcns' /* Numeral System */
};
typedef enum KeynoteNMCT KeynoteNMCT;

enum KeynoteItemFillOptions {
	KeynoteItemFillOptionsNoFill = 'fino' /*  */,
	KeynoteItemFillOptionsColorFill = 'fico' /*  */,
	KeynoteItemFillOptionsGradientFill = 'figr' /*  */,
	KeynoteItemFillOptionsAdvancedGradientFill = 'fiag' /*  */,
	KeynoteItemFillOptionsImageFill = 'fiim' /*  */,
	KeynoteItemFillOptionsAdvancedImageFill = 'fiai' /*  */
};
typedef enum KeynoteItemFillOptions KeynoteItemFillOptions;

enum KeynotePlaybackRepetitionMethod {
	KeynotePlaybackRepetitionMethodNone = 'mvrn' /*  */,
	KeynotePlaybackRepetitionMethodLoop = 'mvlp' /*  */,
	KeynotePlaybackRepetitionMethodLoopBackAndForth = 'mvbf' /*  */
};
typedef enum KeynotePlaybackRepetitionMethod KeynotePlaybackRepetitionMethod;

// Visual style of chart
enum KeynoteLegacyChartType {
	KeynoteLegacyChartTypePie_2d = 'pie2' /* two-dimensional pie chart */,
	KeynoteLegacyChartTypeVertical_bar_2d = 'vbr2' /* two-dimensional vertical bar chart */,
	KeynoteLegacyChartTypeStacked_vertical_bar_2d = 'svb2' /* two-dimensional stacked vertical bar chart */,
	KeynoteLegacyChartTypeHorizontal_bar_2d = 'hbr2' /* two-dimensional horizontal bar chart */,
	KeynoteLegacyChartTypeStacked_horizontal_bar_2d = 'shb2' /* two-dimensional stacked horizontal bar chart */,
	KeynoteLegacyChartTypePie_3d = 'pie3' /* three-dimensional pie chart. */,
	KeynoteLegacyChartTypeVertical_bar_3d = 'vbr3' /* three-dimensional vertical bar chart */,
	KeynoteLegacyChartTypeStacked_vertical_bar_3d = 'svb3' /* three-dimensional stacked bar chart */,
	KeynoteLegacyChartTypeHorizontal_bar_3d = 'hbr3' /* three-dimensional horizontal bar chart */,
	KeynoteLegacyChartTypeStacked_horizontal_bar_3d = 'shb3' /* three-dimensional stacked horizontal bar chart */,
	KeynoteLegacyChartTypeArea_2d = 'are2' /* two-dimensional area chart. */,
	KeynoteLegacyChartTypeStacked_area_2d = 'sar2' /* two-dimensional stacked area chart */,
	KeynoteLegacyChartTypeLine_2d = 'lin2' /*  two-dimensional line chart. */,
	KeynoteLegacyChartTypeLine_3d = 'lin3' /* three-dimensional line chart */,
	KeynoteLegacyChartTypeArea_3d = 'are3' /* three-dimensional area chart */,
	KeynoteLegacyChartTypeStacked_area_3d = 'sar3' /* three-dimensional stacked area chart */,
	KeynoteLegacyChartTypeScatterplot_2d = 'scp2' /* two-dimensional scatterplot chart */
};
typedef enum KeynoteLegacyChartType KeynoteLegacyChartType;

// Grouping for chart data
enum KeynoteLegacyChartGrouping {
	KeynoteLegacyChartGroupingChartRow = 'KCgr' /* group by row */,
	KeynoteLegacyChartGroupingChartColumn = 'KCgc' /* group by column */
};
typedef enum KeynoteLegacyChartGrouping KeynoteLegacyChartGrouping;

@protocol KeynoteGenericMethods

- (void) closeSaving:(KeynoteSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(KeynoteSaveableFileFormat)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface KeynoteApplication : SBApplication

- (SBElementArray<KeynoteDocument *> *) documents;
- (SBElementArray<KeynoteWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(KeynoteSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) showNext;  // Advance one build or slide.
- (void) showPrevious;  // Go to the previous slide.

@end

// A document.
@interface KeynoteDocument : SBObject <KeynoteGenericMethods>

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.

- (void) exportTo:(NSURL *)to as:(KeynoteExportFormat)as withProperties:(NSDictionary *)withProperties;  // Export a slideshow to another file
- (void) startFrom:(KeynoteSlide *)from;  // Start playing the presentation.
- (void) makeImageSlidesFiles:(NSArray<NSURL *> *)files setTitles:(BOOL)setTitles master:(KeynoteMasterSlide *)master;  // Make a series of slides from a list of files.
- (void) stop;  // Stop the presentation.
- (void) showSlideSwitcher;  // Show the slide switcher in play mode
- (void) hideSlideSwitcher;  // Hide the slide switcher in play mode
- (void) moveSlideSwitcherForward;  // Move the slide switcher forward one slide
- (void) moveSlideSwitcherBackward;  // Move the slide switcher backward one slide
- (void) cancelSlideSwitcher;  // Hide the slide switcher without changing slides
- (void) acceptSlideSwitcher;  // Hide the slide switcher, going to the slide it has selected

@end

// A window.
@interface KeynoteWindow : SBObject <KeynoteGenericMethods>

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
@property (copy, readonly) KeynoteDocument *document;  // The document whose contents are displayed in the window.


@end



/*
 * Keynote Suite
 */

// The Keynote application.
@interface KeynoteApplication (KeynoteSuite)

- (SBElementArray<KeynoteTheme *> *) themes;

@end

// The Keynote document.
@interface KeynoteDocument (KeynoteSuite)

- (SBElementArray<KeynoteSlide *> *) slides;
- (SBElementArray<KeynoteMasterSlide *> *) masterSlides;

- (NSString *) id;  // Document ID.
@property BOOL slideNumbersShowing;  // Are the slide numbers displayed?
@property (copy) KeynoteTheme *documentTheme;  // The theme assigned to the document.
@property BOOL autoLoop;  // Make the slideshow play repeatedly.
@property BOOL autoPlay;  // Automatically play the presentation when opening the file.
@property BOOL autoRestart;  // Restart the slideshow if it's inactive for the specified time
@property NSInteger maximumIdleDuration;  // Restart the slideshow if it's inactive for the specified time
@property (copy) KeynoteSlide *currentSlide;  // The currently selected slide, or the slide that would display if the presentation was started.
@property NSInteger height;  // The height of the document (in points). Standard slide height = 768. Wide slide height = 1080.
@property NSInteger width;  // The width of the document (in points). Standard slide width = 1024. Wide slide width = 1920.

@end

// A collection of master slides, with shared design intents and elements.
@interface KeynoteTheme : SBObject <KeynoteGenericMethods>

- (NSString *) id;  // The identifier used by the application.
@property (copy, readonly) NSString *name;


@end



/*
 * iWork Text Suite
 */

// This provides the base rich text class for all iWork applications.
@interface KeynoteRichText : SBObject <KeynoteGenericMethods>

- (SBElementArray<KeynoteCharacter *> *) characters;
- (SBElementArray<KeynoteParagraph *> *) paragraphs;
- (SBElementArray<KeynoteWord *> *) words;

@property (copy) NSColor *color;  // The color of the font. Expressed as an RGB value consisting of a list of three color values from 0 to 65535. ex: Blue = {0, 0, 65535}.
@property (copy) NSString *font;  // The name of the font.  Can be the PostScript name, such as: “TimesNewRomanPS-ItalicMT”, or display name: “Times New Roman Italic”. TIP: Use the Font Book application get the information about a typeface.
@property NSInteger size;  // The size of the font.


@end

// One of some text's characters.
@interface KeynoteCharacter : KeynoteRichText


@end

// One of some text's paragraphs.
@interface KeynoteParagraph : KeynoteRichText

- (SBElementArray<KeynoteCharacter *> *) characters;
- (SBElementArray<KeynoteWord *> *) words;


@end

// One of some text's words.
@interface KeynoteWord : KeynoteRichText

- (SBElementArray<KeynoteCharacter *> *) characters;


@end



/*
 * iWork Suite
 */

// A container for iWork items
@interface KeynoteIWorkContainer : SBObject <KeynoteGenericMethods>

- (SBElementArray<KeynoteAudioClip *> *) audioClips;
- (SBElementArray<KeynoteChart *> *) charts;
- (SBElementArray<KeynoteImage *> *) images;
- (SBElementArray<KeynoteIWorkItem *> *) iWorkItems;
- (SBElementArray<KeynoteGroup *> *) groups;
- (SBElementArray<KeynoteLine *> *) lines;
- (SBElementArray<KeynoteMovie *> *) movies;
- (SBElementArray<KeynoteShape *> *) shapes;
- (SBElementArray<KeynoteTable *> *) tables;
- (SBElementArray<KeynoteTextItem *> *) textItems;


@end



/*
 * Keynote Suite
 */

// A slide in a slideshow document
@interface KeynoteSlide : KeynoteIWorkContainer

@property (copy) KeynoteMasterSlide *baseSlide;  // The master slide this slide is based upon
@property BOOL bodyShowing;  // Is the default body text displayed?
@property BOOL skipped;  // Is the slide skipped?
@property (readonly) NSInteger slideNumber;  // index of the slide in the document
@property BOOL titleShowing;  // Is the default slide title displayed?
@property (copy, readonly) KeynoteShape *defaultBodyItem;  // The default body container of the slide
@property (copy, readonly) KeynoteShape *defaultTitleItem;  // The default title container of the slide
@property (copy) KeynoteRichText *presenterNotes;  // The presenter notes for the slide
@property (copy) NSDictionary *transitionProperties;  // The transition settings to apply to the slide.

- (void) addChartRowNames:(NSArray<NSString *> *)rowNames columnNames:(NSArray<NSString *> *)columnNames data:(NSArray<id> *)data type:(KeynoteLegacyChartType)type groupBy:(KeynoteLegacyChartGrouping)groupBy;  // Add a chart to a slide

@end

// A master slide in a theme or slideshow document
@interface KeynoteMasterSlide : KeynoteSlide

@property (copy, readonly) NSString *name;  // The name of the master slide


@end



/*
 * iWork Suite
 */

// An item which supports formatting
@interface KeynoteIWorkItem : SBObject <KeynoteGenericMethods>

@property NSInteger height;  // The height of the iWork item.
@property BOOL locked;  // Whether the object is locked.
@property (copy, readonly) KeynoteIWorkContainer *parent;  // The iWork container containing this iWork item.
@property NSPoint position;  // The horizontal and vertical coordinates of the top left point of the iWork item.
@property NSInteger width;  // The width of the iWork item.


@end

// An audio clip
@interface KeynoteAudioClip : KeynoteIWorkItem

@property (copy) id fileName;  // The name of the audio file.
@property NSInteger clipVolume;  // The volume setting for the audio clip, from 0 (none) to 100 (full volume).
@property KeynotePlaybackRepetitionMethod repetitionMethod;  // If or how the audio clip repeats.


@end

// A shape container
@interface KeynoteShape : KeynoteIWorkItem

@property (readonly) KeynoteItemFillOptions backgroundFillType;  // The background, if any, for the shape.
@property (copy) KeynoteRichText *objectText;  // The text contained within the shape.
@property BOOL reflectionShowing;  // Is the iWork item displaying a reflection?
@property NSInteger reflectionValue;  // The percentage of reflection of the iWork item, from 0 (none) to 100 (full).
@property NSInteger rotation;  // The rotation of the iWork item, in degrees from 0 to 359.
@property NSInteger opacity;  // The opacity of the object, in percent.


@end

// A chart
@interface KeynoteChart : KeynoteIWorkItem


@end

// An image container
@interface KeynoteImage : KeynoteIWorkItem

@property (copy) NSString *objectDescription;  // Text associated with the image, read aloud by VoiceOver.
@property (copy, readonly) NSURL *file;  // The image file.
@property (copy) id fileName;  // The name of the image file.
@property NSInteger opacity;  // The opacity of the object, in percent.
@property BOOL reflectionShowing;  // Is the iWork item displaying a reflection?
@property NSInteger reflectionValue;  // The percentage of reflection of the iWork item, from 0 (none) to 100 (full).
@property NSInteger rotation;  // The rotation of the iWork item, in degrees from 0 to 359.


@end

// A group container
@interface KeynoteGroup : KeynoteIWorkContainer

@property NSInteger height;  // The height of the iWork item.
@property (copy, readonly) KeynoteIWorkContainer *parent;  // The iWork container containing this iWork item.
@property NSPoint position;  // The horizontal and vertical coordinates of the top left point of the iWork item.
@property NSInteger width;  // The width of the iWork item.
@property NSInteger rotation;  // The rotation of the iWork item, in degrees from 0 to 359.


@end

// A line
@interface KeynoteLine : KeynoteIWorkItem

@property NSPoint endPoint;  // A list of two numbers indicating the horizontal and vertical position of the line ending point.
@property BOOL reflectionShowing;  // Is the iWork item displaying a reflection?
@property NSInteger reflectionValue;  // The percentage of reflection of the iWork item, from 0 (none) to 100 (full).
@property NSInteger rotation;  // The rotation of the iWork item, in degrees from 0 to 359.
@property NSPoint startPoint;  // A list of two numbers indicating the horizontal and vertical position of the line starting point.


@end

// A movie container
@interface KeynoteMovie : KeynoteIWorkItem

@property (copy) id fileName;  // The name of the movie file.
@property NSInteger movieVolume;  // The volume setting for the movie, from 0 (none) to 100 (full volume).
@property NSInteger opacity;  // The opacity of the object, in percent.
@property BOOL reflectionShowing;  // Is the iWork item displaying a reflection?
@property NSInteger reflectionValue;  // The percentage of reflection of the iWork item, from 0 (none) to 100 (full).
@property KeynotePlaybackRepetitionMethod repetitionMethod;  // If or how the movie repeats.
@property NSInteger rotation;  // The rotation of the iWork item, in degrees from 0 to 359.


@end

// A table
@interface KeynoteTable : KeynoteIWorkItem

- (SBElementArray<KeynoteCell *> *) cells;
- (SBElementArray<KeynoteRow *> *) rows;
- (SBElementArray<KeynoteColumn *> *) columns;
- (SBElementArray<KeynoteRange *> *) ranges;

@property (copy) NSString *name;  // The item's name.
@property (copy, readonly) KeynoteRange *cellRange;  // The range describing every cell in the table.
@property (copy) KeynoteRange *selectionRange;  // The cells currently selected in the table.
@property NSInteger rowCount;  // The number of rows in the table.
@property NSInteger columnCount;  // The number of columns in the table.
@property NSInteger headerRowCount;  // The number of header rows in the table.
@property NSInteger headerColumnCount;  // The number of header columns in the table.
@property NSInteger footerRowCount;  // The number of footer rows in the table.

- (void) sortBy:(KeynoteColumn *)by direction:(KeynoteNMSD)direction inRows:(KeynoteRange *)inRows;  // Sort the rows of the table.

@end

// A text container
@interface KeynoteTextItem : KeynoteIWorkItem

@property (readonly) KeynoteItemFillOptions backgroundFillType;  // The background, if any, for the text item.
@property (copy) KeynoteRichText *objectText;  // The text contained within the text item.
@property NSInteger opacity;  // The opacity of the object, in percent.
@property BOOL reflectionShowing;  // Is the iWork item displaying a reflection?
@property NSInteger reflectionValue;  // The percentage of reflection of the iWork item, from 0 (none) to 100 (full).
@property NSInteger rotation;  // The rotation of the iWork item, in degrees from 0 to 359.


@end

// A range of cells in a table
@interface KeynoteRange : SBObject <KeynoteGenericMethods>

- (SBElementArray<KeynoteCell *> *) cells;
- (SBElementArray<KeynoteColumn *> *) columns;
- (SBElementArray<KeynoteRow *> *) rows;

@property (copy) NSString *fontName;  // The font of the range's cells.
@property double fontSize;  // The font size of the range's cells.
@property KeynoteNMCT format;  // The format of the range's cells.
@property KeynoteTAHT alignment;  // The horizontal alignment of content in the range's cells.
@property (copy, readonly) NSString *name;  // The range's coordinates.
@property (copy) NSColor *textColor;  // The text color of the range's cells.
@property BOOL textWrap;  // Whether text should wrap in the range's cells.
@property (copy) NSColor *backgroundColor;  // The background color of the range's cells.
@property KeynoteTAVT verticalAlignment;  // The vertical alignment of content in the range's cells.

- (void) clear;  // Clear the contents of a specified range of cells, including formatting and style.
- (void) merge;  // Merge a specified range of cells.
- (void) unmerge;  // Unmerge all merged cells in a specified range.

@end

// A cell in a table
@interface KeynoteCell : KeynoteRange

@property (copy, readonly) KeynoteColumn *column;  // The cell's column.
@property (copy, readonly) KeynoteRow *row;  // The cell's row.
@property (copy) id value;  // The actual value in the cell, or missing value if the cell is empty.
@property (copy, readonly) NSString *formattedValue;  // The formatted value in the cell, or missing value if the cell is empty.
@property (copy, readonly) NSString *formula;  // The formula in the cell, as text, e.g. =SUM(40+2). If the cell does not contain a formula, returns missing value. To set the value of a cell to a formula as text, use the value property.


@end

// A row of cells in a table
@interface KeynoteRow : KeynoteRange

@property (readonly) NSInteger address;  // The row's index in the table (e.g., the second row has address 2).
@property double height;  // The height of the row.


@end

// A column of cells in a table
@interface KeynoteColumn : KeynoteRange

@property (readonly) NSInteger address;  // The column's index in the table (e.g., the second column has address 2).
@property double width;  // The width of the column.


@end



/*
 * Compatibility Suite
 */

// Deprecated Keynote application properties and verbs.
@interface KeynoteApplication (CompatibilitySuite)


@end

@interface KeynoteDocument (CompatibilitySuite)

@end

@interface KeynoteSlide (CompatibilitySuite)

@end

