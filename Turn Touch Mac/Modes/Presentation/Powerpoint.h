/*
 * Powerpoint.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class PowerpointApplication, PowerpointDocument, PowerpointWindow, PowerpointCommandBarControl, PowerpointCommandBarButton, PowerpointCommandBarCombobox, PowerpointCommandBarPopup, PowerpointCommandBar, PowerpointDocumentProperty, PowerpointCustomDocumentProperty, PowerpointWebPageFont, PowerpointActionSetting, PowerpointAddIn, PowerpointAnimationBehavior, PowerpointAnimationPoint, PowerpointAnimationSettings, PowerpointApplication, PowerpointAutocorrectEntry, PowerpointAutocorrect, PowerpointBroadcast, PowerpointBulletFormat, PowerpointColorScheme, PowerpointColorsEffect, PowerpointCommandEffect, PowerpointCustomLayout, PowerpointDefaultWebOptions, PowerpointDesign, PowerpointDocumentWindow, PowerpointEffectInformation, PowerpointEffectParameters, PowerpointEffect, PowerpointFilterEffect, PowerpointFirstLetterException, PowerpointFont, PowerpointHeaderOrFooter, PowerpointHeadersAndFooters, PowerpointHyperlink, PowerpointMaster, PowerpointMotionEffect, PowerpointNamedSlideShow, PowerpointPageSetup, PowerpointPane, PowerpointParagraphFormat, PowerpointPlaySettings, PowerpointPlayer, PowerpointPreferences, PowerpointPresentation, PowerpointPresenterTool, PowerpointPresenterViewWindow, PowerpointPrintOptions, PowerpointPrintRange, PowerpointPropertyEffect, PowerpointRotatingEffect, PowerpointRulerLevel, PowerpointRuler, PowerpointSaveAsMovieSettings, PowerpointScaleEffect, PowerpointSectionProperties, PowerpointSelection, PowerpointSequence, PowerpointSetEffect, PowerpointSlideRange, PowerpointSlideShowSettings, PowerpointSlideShowTransition, PowerpointSlideShowView, PowerpointSlideShowWindow, PowerpointSlide, PowerpointSoundEffect, PowerpointTabStop, PowerpointTextStyleLevel, PowerpointTextStyle, PowerpointTimeline, PowerpointTiming, PowerpointTwoInitialCapsException, PowerpointView, PowerpointWebOptions, PowerpointAdjustment, PowerpointCalloutFormat, PowerpointConnectorFormat, PowerpointFillFormat, PowerpointGlowFormat, PowerpointGradientStop, PowerpointLineFormat, PowerpointLinkFormat, PowerpointOfficeTheme, PowerpointPictureFormat, PowerpointPlaceholderFormat, PowerpointReflectionFormat, PowerpointShadowFormat, PowerpointShapeRange, PowerpointShape, PowerpointCallout, PowerpointComment, PowerpointConnector, PowerpointLineShape, PowerpointMediaObject, PowerpointMedia2Object, PowerpointPicture, PowerpointPlaceHolder, PowerpointShapeTable, PowerpointSoftEdgeFormat, PowerpointTextBox, PowerpointTextColumn, PowerpointTextFrame, PowerpointThemeColorScheme, PowerpointThemeColor, PowerpointThemeEffectScheme, PowerpointThemeFontScheme, PowerpointThemeFont, PowerpointMajorThemeFont, PowerpointMinorThemeFont, PowerpointThreeDFormat, PowerpointWordArtFormat, PowerpointTextRange, PowerpointCharacter, PowerpointLine, PowerpointParagraph, PowerpointSentence, PowerpointTextFlow, PowerpointWord, PowerpointCell, PowerpointColumn, PowerpointRow, PowerpointTable;

enum PowerpointSaveOptions {
	PowerpointSaveOptionsYes = 'yes ' /* Save the file. */,
	PowerpointSaveOptionsNo = 'no  ' /* Do not save the file. */,
	PowerpointSaveOptionsAsk = 'ask ' /* Ask the user whether or not to save the file. */
};
typedef enum PowerpointSaveOptions PowerpointSaveOptions;

enum PowerpointPrintingErrorHandling {
	PowerpointPrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	PowerpointPrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum PowerpointPrintingErrorHandling PowerpointPrintingErrorHandling;

enum PowerpointMsoLineDashStyle {
	PowerpointMsoLineDashStyleLineDashStyleUnset = '\000\222\377\376',
	PowerpointMsoLineDashStyleLineDashStyleSolid = '\000\223\000\001',
	PowerpointMsoLineDashStyleLineDashStyleSquareDot = '\000\223\000\002',
	PowerpointMsoLineDashStyleLineDashStyleRoundDot = '\000\223\000\003',
	PowerpointMsoLineDashStyleLineDashStyleDash = '\000\223\000\004',
	PowerpointMsoLineDashStyleLineDashStyleDashDot = '\000\223\000\005',
	PowerpointMsoLineDashStyleLineDashStyleDashDotDot = '\000\223\000\006',
	PowerpointMsoLineDashStyleLineDashStyleLongDash = '\000\223\000\007',
	PowerpointMsoLineDashStyleLineDashStyleLongDashDot = '\000\223\000\010',
	PowerpointMsoLineDashStyleLineDashStyleLongDashDotDot = '\000\223\000\011',
	PowerpointMsoLineDashStyleLineDashStyleSystemDash = '\000\223\000\012',
	PowerpointMsoLineDashStyleLineDashStyleSystemDot = '\000\223\000\013',
	PowerpointMsoLineDashStyleLineDashStyleSystemDashDot = '\000\223\000\014'
};
typedef enum PowerpointMsoLineDashStyle PowerpointMsoLineDashStyle;

enum PowerpointMsoLineStyle {
	PowerpointMsoLineStyleLineStyleUnset = '\000\224\377\376',
	PowerpointMsoLineStyleSingleLine = '\000\225\000\001',
	PowerpointMsoLineStyleThinThinLine = '\000\225\000\002',
	PowerpointMsoLineStyleThinThickLine = '\000\225\000\003',
	PowerpointMsoLineStyleThickThinLine = '\000\225\000\004',
	PowerpointMsoLineStyleThickBetweenThinLine = '\000\225\000\005'
};
typedef enum PowerpointMsoLineStyle PowerpointMsoLineStyle;

enum PowerpointMsoArrowheadStyle {
	PowerpointMsoArrowheadStyleArrowheadStyleUnset = '\000\221\377\376',
	PowerpointMsoArrowheadStyleNoArrowhead = '\000\222\000\001',
	PowerpointMsoArrowheadStyleTriangleArrowhead = '\000\222\000\002',
	PowerpointMsoArrowheadStyleOpen_arrowhead = '\000\222\000\003',
	PowerpointMsoArrowheadStyleStealthArrowhead = '\000\222\000\004',
	PowerpointMsoArrowheadStyleDiamondArrowhead = '\000\222\000\005',
	PowerpointMsoArrowheadStyleOvalArrowhead = '\000\222\000\006'
};
typedef enum PowerpointMsoArrowheadStyle PowerpointMsoArrowheadStyle;

enum PowerpointMsoArrowheadWidth {
	PowerpointMsoArrowheadWidthArrowheadWidthUnset = '\000\220\377\376',
	PowerpointMsoArrowheadWidthNarrowWidthArrowhead = '\000\221\000\001',
	PowerpointMsoArrowheadWidthMediumWidthArrowhead = '\000\221\000\002',
	PowerpointMsoArrowheadWidthWideArrowhead = '\000\221\000\003'
};
typedef enum PowerpointMsoArrowheadWidth PowerpointMsoArrowheadWidth;

enum PowerpointMsoArrowheadLength {
	PowerpointMsoArrowheadLengthArrowheadLengthUnset = '\000\223\377\376',
	PowerpointMsoArrowheadLengthShortArrowhead = '\000\224\000\001',
	PowerpointMsoArrowheadLengthMediumArrowhead = '\000\224\000\002',
	PowerpointMsoArrowheadLengthLongArrowhead = '\000\224\000\003'
};
typedef enum PowerpointMsoArrowheadLength PowerpointMsoArrowheadLength;

enum PowerpointMsoFillType {
	PowerpointMsoFillTypeFillUnset = '\000c\377\376',
	PowerpointMsoFillTypeFillSolid = '\000d\000\001',
	PowerpointMsoFillTypeFillPatterned = '\000d\000\002',
	PowerpointMsoFillTypeFillGradient = '\000d\000\003',
	PowerpointMsoFillTypeFillTextured = '\000d\000\004',
	PowerpointMsoFillTypeFillBackground = '\000d\000\005',
	PowerpointMsoFillTypeFillPicture = '\000d\000\006'
};
typedef enum PowerpointMsoFillType PowerpointMsoFillType;

enum PowerpointMsoGradientStyle {
	PowerpointMsoGradientStyleGradientUnset = '\000d\377\376',
	PowerpointMsoGradientStyleHorizontalGradient = '\000e\000\001',
	PowerpointMsoGradientStyleVerticalGradient = '\000e\000\002',
	PowerpointMsoGradientStyleDiagonalUpGradient = '\000e\000\003',
	PowerpointMsoGradientStyleDiagonalDownGradient = '\000e\000\004',
	PowerpointMsoGradientStyleFromCornerGradient = '\000e\000\005',
	PowerpointMsoGradientStyleFromTitleGradient = '\000e\000\006',
	PowerpointMsoGradientStyleFromCenterGradient = '\000e\000\007'
};
typedef enum PowerpointMsoGradientStyle PowerpointMsoGradientStyle;

enum PowerpointMsoGradientColorType {
	PowerpointMsoGradientColorTypeGradientTypeUnset = '\003\357\377\376',
	PowerpointMsoGradientColorTypeSingleShadeGradientType = '\003\360\000\001',
	PowerpointMsoGradientColorTypeTwoColorsGradientType = '\003\360\000\002',
	PowerpointMsoGradientColorTypePresetColorsGradientType = '\003\360\000\003',
	PowerpointMsoGradientColorTypeMultiColorsGradientType = '\003\360\000\004'
};
typedef enum PowerpointMsoGradientColorType PowerpointMsoGradientColorType;

enum PowerpointMsoTextureType {
	PowerpointMsoTextureTypeTextureTypeTextureTypeUnset = '\003\360\377\376',
	PowerpointMsoTextureTypeTextureTypePresetTexture = '\003\361\000\001',
	PowerpointMsoTextureTypeTextureTypeUserDefinedTexture = '\003\361\000\002'
};
typedef enum PowerpointMsoTextureType PowerpointMsoTextureType;

enum PowerpointMsoPresetTexture {
	PowerpointMsoPresetTexturePresetTextureUnset = '\000e\377\376',
	PowerpointMsoPresetTextureTexturePapyrus = '\000f\000\001',
	PowerpointMsoPresetTextureTextureCanvas = '\000f\000\002',
	PowerpointMsoPresetTextureTextureDenim = '\000f\000\003',
	PowerpointMsoPresetTextureTextureWovenMat = '\000f\000\004',
	PowerpointMsoPresetTextureTextureWaterDroplets = '\000f\000\005',
	PowerpointMsoPresetTextureTexturePaperBag = '\000f\000\006',
	PowerpointMsoPresetTextureTextureFishFossil = '\000f\000\007',
	PowerpointMsoPresetTextureTextureSand = '\000f\000\010',
	PowerpointMsoPresetTextureTextureGreenMarble = '\000f\000\011',
	PowerpointMsoPresetTextureTextureWhiteMarble = '\000f\000\012',
	PowerpointMsoPresetTextureTextureBrownMarble = '\000f\000\013',
	PowerpointMsoPresetTextureTextureGranite = '\000f\000\014',
	PowerpointMsoPresetTextureTextureNewsprint = '\000f\000\015',
	PowerpointMsoPresetTextureTextureRecycledPaper = '\000f\000\016',
	PowerpointMsoPresetTextureTextureParchment = '\000f\000\017',
	PowerpointMsoPresetTextureTextureStationery = '\000f\000\020',
	PowerpointMsoPresetTextureTextureBlueTissuePaper = '\000f\000\021',
	PowerpointMsoPresetTextureTexturePinkTissuePaper = '\000f\000\022',
	PowerpointMsoPresetTextureTexturePurpleMesh = '\000f\000\023',
	PowerpointMsoPresetTextureTextureBouquet = '\000f\000\024',
	PowerpointMsoPresetTextureTextureCork = '\000f\000\025',
	PowerpointMsoPresetTextureTextureWalnut = '\000f\000\026',
	PowerpointMsoPresetTextureTextureOak = '\000f\000\027',
	PowerpointMsoPresetTextureTextureMediumWood = '\000f\000\030'
};
typedef enum PowerpointMsoPresetTexture PowerpointMsoPresetTexture;

enum PowerpointMsoPatternType {
	PowerpointMsoPatternTypePatternUnset = '\000f\377\376',
	PowerpointMsoPatternTypeFivePercentPattern = '\000g\000\001',
	PowerpointMsoPatternTypeTenPercentPattern = '\000g\000\002',
	PowerpointMsoPatternTypeTwentyPercentPattern = '\000g\000\003',
	PowerpointMsoPatternTypeTwentyFivePercentPattern = '\000g\000\004',
	PowerpointMsoPatternTypeThirtyPercentPattern = '\000g\000\005',
	PowerpointMsoPatternTypeFortyPercentPattern = '\000g\000\006',
	PowerpointMsoPatternTypeFiftyPercentPattern = '\000g\000\007',
	PowerpointMsoPatternTypeSixtyPercentPattern = '\000g\000\010',
	PowerpointMsoPatternTypeSeventyPercentPattern = '\000g\000\011',
	PowerpointMsoPatternTypeSeventyFivePercentPattern = '\000g\000\012',
	PowerpointMsoPatternTypeEightyPercentPattern = '\000g\000\013',
	PowerpointMsoPatternTypeNinetyPercentPattern = '\000g\000\014',
	PowerpointMsoPatternTypeDarkHorizontalPattern = '\000g\000\015',
	PowerpointMsoPatternTypeDarkVerticalPattern = '\000g\000\016',
	PowerpointMsoPatternTypeDarkDownwardDiagonalPattern = '\000g\000\017',
	PowerpointMsoPatternTypeDarkUpwardDiagonalPattern = '\000g\000\020',
	PowerpointMsoPatternTypeSmallCheckerBoardPattern = '\000g\000\021',
	PowerpointMsoPatternTypeTrellisPattern = '\000g\000\022',
	PowerpointMsoPatternTypeLightHorizontalPattern = '\000g\000\023',
	PowerpointMsoPatternTypeLightVerticalPattern = '\000g\000\024',
	PowerpointMsoPatternTypeLightDownwardDiagonalPattern = '\000g\000\025',
	PowerpointMsoPatternTypeLightUpwardDiagonalPattern = '\000g\000\026',
	PowerpointMsoPatternTypeSmallGridPattern = '\000g\000\027',
	PowerpointMsoPatternTypeDottedDiamondPattern = '\000g\000\030',
	PowerpointMsoPatternTypeWideDownwardDiagonal = '\000g\000\031',
	PowerpointMsoPatternTypeWideUpwardDiagonalPattern = '\000g\000\032',
	PowerpointMsoPatternTypeDashedUpwardDiagonalPattern = '\000g\000\033',
	PowerpointMsoPatternTypeDashedDownwardDiagonalPattern = '\000g\000\034',
	PowerpointMsoPatternTypeNarrowVerticalPattern = '\000g\000\035',
	PowerpointMsoPatternTypeNarrowHorizontalPattern = '\000g\000\036',
	PowerpointMsoPatternTypeDashedVerticalPattern = '\000g\000\037',
	PowerpointMsoPatternTypeDashedHorizontalPattern = '\000g\000 ',
	PowerpointMsoPatternTypeLargeConfettiPattern = '\000g\000!',
	PowerpointMsoPatternTypeLargeGridPattern = '\000g\000\"',
	PowerpointMsoPatternTypeHorizontalBrickPattern = '\000g\000#',
	PowerpointMsoPatternTypeLargeCheckerBoardPattern = '\000g\000$',
	PowerpointMsoPatternTypeSmallConfettiPattern = '\000g\000%',
	PowerpointMsoPatternTypeZigZagPattern = '\000g\000&',
	PowerpointMsoPatternTypeSolidDiamondPattern = '\000g\000\'',
	PowerpointMsoPatternTypeDiagonalBrickPattern = '\000g\000(',
	PowerpointMsoPatternTypeOutlinedDiamondPattern = '\000g\000)',
	PowerpointMsoPatternTypePlaidPattern = '\000g\000*',
	PowerpointMsoPatternTypeSpherePattern = '\000g\000+',
	PowerpointMsoPatternTypeWeavePattern = '\000g\000,',
	PowerpointMsoPatternTypeDottedGridPattern = '\000g\000-',
	PowerpointMsoPatternTypeDivotPattern = '\000g\000.',
	PowerpointMsoPatternTypeShinglePattern = '\000g\000/',
	PowerpointMsoPatternTypeWavePattern = '\000g\0000',
	PowerpointMsoPatternTypeHorizontalPattern = '\000g\0001',
	PowerpointMsoPatternTypeVerticalPattern = '\000g\0002',
	PowerpointMsoPatternTypeCrossPattern = '\000g\0003',
	PowerpointMsoPatternTypeDownwardDiagonalPattern = '\000g\0004',
	PowerpointMsoPatternTypeUpwardDiagonalPattern = '\000g\0005',
	PowerpointMsoPatternTypeDiagonalCrossPattern = '\000g\0005'
};
typedef enum PowerpointMsoPatternType PowerpointMsoPatternType;

enum PowerpointMsoPresetGradientType {
	PowerpointMsoPresetGradientTypePresetGradientUnset = '\000g\377\376',
	PowerpointMsoPresetGradientTypeGradientEarlySunset = '\000h\000\001',
	PowerpointMsoPresetGradientTypeGradientLateSunset = '\000h\000\002',
	PowerpointMsoPresetGradientTypeGradientNightfall = '\000h\000\003',
	PowerpointMsoPresetGradientTypeGradientDaybreak = '\000h\000\004',
	PowerpointMsoPresetGradientTypeGradientHorizon = '\000h\000\005',
	PowerpointMsoPresetGradientTypeGradientDesert = '\000h\000\006',
	PowerpointMsoPresetGradientTypeGradientOcean = '\000h\000\007',
	PowerpointMsoPresetGradientTypeGradientCalmWater = '\000h\000\010',
	PowerpointMsoPresetGradientTypeGradientFire = '\000h\000\011',
	PowerpointMsoPresetGradientTypeGradientFog = '\000h\000\012',
	PowerpointMsoPresetGradientTypeGradientMoss = '\000h\000\013',
	PowerpointMsoPresetGradientTypeGradientPeacock = '\000h\000\014',
	PowerpointMsoPresetGradientTypeGradientWheat = '\000h\000\015',
	PowerpointMsoPresetGradientTypeGradientParchment = '\000h\000\016',
	PowerpointMsoPresetGradientTypeGradientMahogany = '\000h\000\017',
	PowerpointMsoPresetGradientTypeGradientRainbow = '\000h\000\020',
	PowerpointMsoPresetGradientTypeGradientRainbow2 = '\000h\000\021',
	PowerpointMsoPresetGradientTypeGradientGold = '\000h\000\022',
	PowerpointMsoPresetGradientTypeGradientGold2 = '\000h\000\023',
	PowerpointMsoPresetGradientTypeGradientBrass = '\000h\000\024',
	PowerpointMsoPresetGradientTypeGradientChrome = '\000h\000\025',
	PowerpointMsoPresetGradientTypeGradientChrome2 = '\000h\000\026',
	PowerpointMsoPresetGradientTypeGradientSilver = '\000h\000\027',
	PowerpointMsoPresetGradientTypeGradientSapphire = '\000h\000\030'
};
typedef enum PowerpointMsoPresetGradientType PowerpointMsoPresetGradientType;

enum PowerpointMsoShadowType {
	PowerpointMsoShadowTypeShadowUnset = '\003_\377\376',
	PowerpointMsoShadowTypeShadow1 = '\003`\000\001',
	PowerpointMsoShadowTypeShadow2 = '\003`\000\002',
	PowerpointMsoShadowTypeShadow3 = '\003`\000\003',
	PowerpointMsoShadowTypeShadow4 = '\003`\000\004',
	PowerpointMsoShadowTypeShadow5 = '\003`\000\005',
	PowerpointMsoShadowTypeShadow6 = '\003`\000\006',
	PowerpointMsoShadowTypeShadow7 = '\003`\000\007',
	PowerpointMsoShadowTypeShadow8 = '\003`\000\010',
	PowerpointMsoShadowTypeShadow9 = '\003`\000\011',
	PowerpointMsoShadowTypeShadow10 = '\003`\000\012',
	PowerpointMsoShadowTypeShadow11 = '\003`\000\013',
	PowerpointMsoShadowTypeShadow12 = '\003`\000\014',
	PowerpointMsoShadowTypeShadow13 = '\003`\000\015',
	PowerpointMsoShadowTypeShadow14 = '\003`\000\016',
	PowerpointMsoShadowTypeShadow15 = '\003`\000\017',
	PowerpointMsoShadowTypeShadow16 = '\003`\000\020',
	PowerpointMsoShadowTypeShadow17 = '\003`\000\021',
	PowerpointMsoShadowTypeShadow18 = '\003`\000\022',
	PowerpointMsoShadowTypeShadow19 = '\003`\000\023',
	PowerpointMsoShadowTypeShadow20 = '\003`\000\024',
	PowerpointMsoShadowTypeShadow21 = '\003`\000\025',
	PowerpointMsoShadowTypeShadow22 = '\003`\000\026',
	PowerpointMsoShadowTypeShadow23 = '\003`\000\027',
	PowerpointMsoShadowTypeShadow24 = '\003`\000\030',
	PowerpointMsoShadowTypeShadow25 = '\003`\000\031',
	PowerpointMsoShadowTypeShadow26 = '\003`\000\032',
	PowerpointMsoShadowTypeShadow27 = '\003`\000\033',
	PowerpointMsoShadowTypeShadow28 = '\003`\000\034',
	PowerpointMsoShadowTypeShadow29 = '\003`\000\035',
	PowerpointMsoShadowTypeShadow30 = '\003`\000\036',
	PowerpointMsoShadowTypeShadow31 = '\003`\000\037',
	PowerpointMsoShadowTypeShadow32 = '\003`\000 ',
	PowerpointMsoShadowTypeShadow33 = '\003`\000!',
	PowerpointMsoShadowTypeShadow34 = '\003`\000\"',
	PowerpointMsoShadowTypeShadow35 = '\003`\000#',
	PowerpointMsoShadowTypeShadow36 = '\003`\000$',
	PowerpointMsoShadowTypeShadow37 = '\003`\000%',
	PowerpointMsoShadowTypeShadow38 = '\003`\000&',
	PowerpointMsoShadowTypeShadow39 = '\003`\000\'',
	PowerpointMsoShadowTypeShadow40 = '\003`\000(',
	PowerpointMsoShadowTypeShadow41 = '\003`\000)',
	PowerpointMsoShadowTypeShadow42 = '\003`\000*',
	PowerpointMsoShadowTypeShadow43 = '\003`\000+'
};
typedef enum PowerpointMsoShadowType PowerpointMsoShadowType;

enum PowerpointMsoPresetTextEffect {
	PowerpointMsoPresetTextEffectWordartFormatUnset = '\003\361\377\376',
	PowerpointMsoPresetTextEffectWordartFormat1 = '\003\362\000\000',
	PowerpointMsoPresetTextEffectWordartFormat2 = '\003\362\000\001',
	PowerpointMsoPresetTextEffectWordartFormat3 = '\003\362\000\002',
	PowerpointMsoPresetTextEffectWordartFormat4 = '\003\362\000\003',
	PowerpointMsoPresetTextEffectWordartFormat5 = '\003\362\000\004',
	PowerpointMsoPresetTextEffectWordartFormat6 = '\003\362\000\005',
	PowerpointMsoPresetTextEffectWordartFormat7 = '\003\362\000\006',
	PowerpointMsoPresetTextEffectWordartFormat8 = '\003\362\000\007',
	PowerpointMsoPresetTextEffectWordartFormat9 = '\003\362\000\010',
	PowerpointMsoPresetTextEffectWordartFormat10 = '\003\362\000\011',
	PowerpointMsoPresetTextEffectWordartFormat11 = '\003\362\000\012',
	PowerpointMsoPresetTextEffectWordartFormat12 = '\003\362\000\013',
	PowerpointMsoPresetTextEffectWordartFormat13 = '\003\362\000\014',
	PowerpointMsoPresetTextEffectWordartFormat14 = '\003\362\000\015',
	PowerpointMsoPresetTextEffectWordartFormat15 = '\003\362\000\016',
	PowerpointMsoPresetTextEffectWordartFormat16 = '\003\362\000\017',
	PowerpointMsoPresetTextEffectWordartFormat17 = '\003\362\000\020',
	PowerpointMsoPresetTextEffectWordartFormat18 = '\003\362\000\021',
	PowerpointMsoPresetTextEffectWordartFormat19 = '\003\362\000\022',
	PowerpointMsoPresetTextEffectWordartFormat20 = '\003\362\000\023',
	PowerpointMsoPresetTextEffectWordartFormat21 = '\003\362\000\024',
	PowerpointMsoPresetTextEffectWordartFormat22 = '\003\362\000\025',
	PowerpointMsoPresetTextEffectWordartFormat23 = '\003\362\000\026',
	PowerpointMsoPresetTextEffectWordartFormat24 = '\003\362\000\027',
	PowerpointMsoPresetTextEffectWordartFormat25 = '\003\362\000\030',
	PowerpointMsoPresetTextEffectWordartFormat26 = '\003\362\000\031',
	PowerpointMsoPresetTextEffectWordartFormat27 = '\003\362\000\032',
	PowerpointMsoPresetTextEffectWordartFormat28 = '\003\362\000\033',
	PowerpointMsoPresetTextEffectWordartFormat29 = '\003\362\000\034',
	PowerpointMsoPresetTextEffectWordartFormat30 = '\003\362\000\035',
	PowerpointMsoPresetTextEffectWordartFormat31 = '\003\362\000\036',
	PowerpointMsoPresetTextEffectWordartFormat32 = '\003\362\000\037',
	PowerpointMsoPresetTextEffectWordartFormat33 = '\003\362\000 ',
	PowerpointMsoPresetTextEffectWordartFormat34 = '\003\362\000!',
	PowerpointMsoPresetTextEffectWordartFormat35 = '\003\362\000\"',
	PowerpointMsoPresetTextEffectWordartFormat36 = '\003\362\000#',
	PowerpointMsoPresetTextEffectWordartFormat37 = '\003\362\000$',
	PowerpointMsoPresetTextEffectWordartFormat38 = '\003\362\000%',
	PowerpointMsoPresetTextEffectWordartFormat39 = '\003\362\000&',
	PowerpointMsoPresetTextEffectWordartFormat40 = '\003\362\000\'',
	PowerpointMsoPresetTextEffectWordartFormat41 = '\003\362\000(',
	PowerpointMsoPresetTextEffectWordartFormat42 = '\003\362\000)',
	PowerpointMsoPresetTextEffectWordartFormat43 = '\003\362\000*',
	PowerpointMsoPresetTextEffectWordartFormat44 = '\003\362\000+',
	PowerpointMsoPresetTextEffectWordartFormat45 = '\003\362\000,',
	PowerpointMsoPresetTextEffectWordartFormat46 = '\003\362\000-',
	PowerpointMsoPresetTextEffectWordartFormat47 = '\003\362\000.',
	PowerpointMsoPresetTextEffectWordartFormat48 = '\003\362\000/',
	PowerpointMsoPresetTextEffectWordartFormat49 = '\003\362\0000',
	PowerpointMsoPresetTextEffectWordartFormat50 = '\003\362\0001'
};
typedef enum PowerpointMsoPresetTextEffect PowerpointMsoPresetTextEffect;

enum PowerpointMsoPresetTextEffectShape {
	PowerpointMsoPresetTextEffectShapeTextEffectShapeUnset = '\000\227\377\376',
	PowerpointMsoPresetTextEffectShapePlainText = '\000\230\000\001',
	PowerpointMsoPresetTextEffectShapeStop = '\000\230\000\002',
	PowerpointMsoPresetTextEffectShapeTriangleUp = '\000\230\000\003',
	PowerpointMsoPresetTextEffectShapeTriangleDown = '\000\230\000\004',
	PowerpointMsoPresetTextEffectShapeChevronUp = '\000\230\000\005',
	PowerpointMsoPresetTextEffectShapeChevronDown = '\000\230\000\006',
	PowerpointMsoPresetTextEffectShapeRingInside = '\000\230\000\007',
	PowerpointMsoPresetTextEffectShapeRingOutside = '\000\230\000\010',
	PowerpointMsoPresetTextEffectShapeArchUpCurve = '\000\230\000\011',
	PowerpointMsoPresetTextEffectShapeArchDownCurve = '\000\230\000\012',
	PowerpointMsoPresetTextEffectShapeCircleCurve = '\000\230\000\013',
	PowerpointMsoPresetTextEffectShapeButtonCurve = '\000\230\000\014',
	PowerpointMsoPresetTextEffectShapeArchUpPour = '\000\230\000\015',
	PowerpointMsoPresetTextEffectShapeArchDownPour = '\000\230\000\016',
	PowerpointMsoPresetTextEffectShapeCirclePour = '\000\230\000\017',
	PowerpointMsoPresetTextEffectShapeButtonPour = '\000\230\000\020',
	PowerpointMsoPresetTextEffectShapeCurveUp = '\000\230\000\021',
	PowerpointMsoPresetTextEffectShapeCurveDown = '\000\230\000\022',
	PowerpointMsoPresetTextEffectShapeCanUp = '\000\230\000\023',
	PowerpointMsoPresetTextEffectShapeCanDown = '\000\230\000\024',
	PowerpointMsoPresetTextEffectShapeWave1 = '\000\230\000\025',
	PowerpointMsoPresetTextEffectShapeWave2 = '\000\230\000\026',
	PowerpointMsoPresetTextEffectShapeDoubleWave1 = '\000\230\000\027',
	PowerpointMsoPresetTextEffectShapeDoubleWave2 = '\000\230\000\030',
	PowerpointMsoPresetTextEffectShapeInflate = '\000\230\000\031',
	PowerpointMsoPresetTextEffectShapeDeflate = '\000\230\000\032',
	PowerpointMsoPresetTextEffectShapeInflateBottom = '\000\230\000\033',
	PowerpointMsoPresetTextEffectShapeDeflateBottom = '\000\230\000\034',
	PowerpointMsoPresetTextEffectShapeInflateTop = '\000\230\000\035',
	PowerpointMsoPresetTextEffectShapeDeflateTop = '\000\230\000\036',
	PowerpointMsoPresetTextEffectShapeDeflateInflate = '\000\230\000\037',
	PowerpointMsoPresetTextEffectShapeDeflateInflateDeflate = '\000\230\000 ',
	PowerpointMsoPresetTextEffectShapeFadeRight = '\000\230\000!',
	PowerpointMsoPresetTextEffectShapeFadeLeft = '\000\230\000\"',
	PowerpointMsoPresetTextEffectShapeFadeUp = '\000\230\000#',
	PowerpointMsoPresetTextEffectShapeFadeDown = '\000\230\000$',
	PowerpointMsoPresetTextEffectShapeSlantUp = '\000\230\000%',
	PowerpointMsoPresetTextEffectShapeSlantDown = '\000\230\000&',
	PowerpointMsoPresetTextEffectShapeCascadeUp = '\000\230\000\'',
	PowerpointMsoPresetTextEffectShapeCascadeDown = '\000\230\000('
};
typedef enum PowerpointMsoPresetTextEffectShape PowerpointMsoPresetTextEffectShape;

enum PowerpointMsoTextEffectAlignment {
	PowerpointMsoTextEffectAlignmentTextEffectAlignmentUnset = '\000\226\377\376',
	PowerpointMsoTextEffectAlignmentLeftTextEffectAlignment = '\000\227\000\001',
	PowerpointMsoTextEffectAlignmentCenteredTextEffectAlignment = '\000\227\000\002',
	PowerpointMsoTextEffectAlignmentRightTextEffectAlignment = '\000\227\000\003',
	PowerpointMsoTextEffectAlignmentJustifyTextEffectAlignment = '\000\227\000\004',
	PowerpointMsoTextEffectAlignmentWordJustifyTextEffectAlignment = '\000\227\000\005',
	PowerpointMsoTextEffectAlignmentStretchJustifyTextEffectAlignment = '\000\227\000\006'
};
typedef enum PowerpointMsoTextEffectAlignment PowerpointMsoTextEffectAlignment;

enum PowerpointMsoPresetLightingDirection {
	PowerpointMsoPresetLightingDirectionPresetLightingDirectionUnset = '\000\233\377\376',
	PowerpointMsoPresetLightingDirectionLightFromTopLeft = '\000\234\000\001',
	PowerpointMsoPresetLightingDirectionLightFromTop = '\000\234\000\002',
	PowerpointMsoPresetLightingDirectionLightFromTopRight = '\000\234\000\003',
	PowerpointMsoPresetLightingDirectionLightFromLeft = '\000\234\000\004',
	PowerpointMsoPresetLightingDirectionLightFromNone = '\000\234\000\005',
	PowerpointMsoPresetLightingDirectionLightFromRight = '\000\234\000\006',
	PowerpointMsoPresetLightingDirectionLightFromBottomLeft = '\000\234\000\007',
	PowerpointMsoPresetLightingDirectionLightFromBottom = '\000\234\000\010',
	PowerpointMsoPresetLightingDirectionLightFromBottomRight = '\000\234\000\011'
};
typedef enum PowerpointMsoPresetLightingDirection PowerpointMsoPresetLightingDirection;

enum PowerpointMsoPresetLightingSoftness {
	PowerpointMsoPresetLightingSoftnessLightingSoftnessUnset = '\000\234\377\376',
	PowerpointMsoPresetLightingSoftnessLightingDim = '\000\235\000\001',
	PowerpointMsoPresetLightingSoftnessLightingNormal = '\000\235\000\002',
	PowerpointMsoPresetLightingSoftnessLightingBright = '\000\235\000\003'
};
typedef enum PowerpointMsoPresetLightingSoftness PowerpointMsoPresetLightingSoftness;

enum PowerpointMsoPresetMaterial {
	PowerpointMsoPresetMaterialPresetMaterialUnset = '\000\235\377\376',
	PowerpointMsoPresetMaterialMatte = '\000\236\000\001',
	PowerpointMsoPresetMaterialPlastic = '\000\236\000\002',
	PowerpointMsoPresetMaterialMetal = '\000\236\000\003',
	PowerpointMsoPresetMaterialWireframe = '\000\236\000\004',
	PowerpointMsoPresetMaterialMatte2 = '\000\236\000\005',
	PowerpointMsoPresetMaterialPlastic2 = '\000\236\000\006',
	PowerpointMsoPresetMaterialMetal2 = '\000\236\000\007',
	PowerpointMsoPresetMaterialWarmMatte = '\000\236\000\010',
	PowerpointMsoPresetMaterialTranslucentPowder = '\000\236\000\011',
	PowerpointMsoPresetMaterialPowder = '\000\236\000\012',
	PowerpointMsoPresetMaterialDarkEdge = '\000\236\000\013',
	PowerpointMsoPresetMaterialSoftEdge = '\000\236\000\014',
	PowerpointMsoPresetMaterialMaterialClear = '\000\236\000\015',
	PowerpointMsoPresetMaterialFlat = '\000\236\000\016',
	PowerpointMsoPresetMaterialSoftMetal = '\000\236\000\017'
};
typedef enum PowerpointMsoPresetMaterial PowerpointMsoPresetMaterial;

enum PowerpointMsoPresetExtrusionDirection {
	PowerpointMsoPresetExtrusionDirectionPresetExtrusionDirectionUnset = '\000\231\377\376',
	PowerpointMsoPresetExtrusionDirectionExtrudeBottomRight = '\000\232\000\001',
	PowerpointMsoPresetExtrusionDirectionExtrudeBottom = '\000\232\000\002',
	PowerpointMsoPresetExtrusionDirectionExtrudeBottomLeft = '\000\232\000\003',
	PowerpointMsoPresetExtrusionDirectionExtrudeRight = '\000\232\000\004',
	PowerpointMsoPresetExtrusionDirectionExtrudeNone = '\000\232\000\005',
	PowerpointMsoPresetExtrusionDirectionExtrudeLeft = '\000\232\000\006',
	PowerpointMsoPresetExtrusionDirectionExtrudeTopRight = '\000\232\000\007',
	PowerpointMsoPresetExtrusionDirectionExtrudeTop = '\000\232\000\010',
	PowerpointMsoPresetExtrusionDirectionExtrudeTopLeft = '\000\232\000\011'
};
typedef enum PowerpointMsoPresetExtrusionDirection PowerpointMsoPresetExtrusionDirection;

enum PowerpointMsoPresetThreeDFormat {
	PowerpointMsoPresetThreeDFormatPresetThreeDFormatUnset = '\000\230\377\376',
	PowerpointMsoPresetThreeDFormatFormat1 = '\000\231\000\001',
	PowerpointMsoPresetThreeDFormatFormat2 = '\000\231\000\002',
	PowerpointMsoPresetThreeDFormatFormat3 = '\000\231\000\003',
	PowerpointMsoPresetThreeDFormatFormat4 = '\000\231\000\004',
	PowerpointMsoPresetThreeDFormatFormat5 = '\000\231\000\005',
	PowerpointMsoPresetThreeDFormatFormat6 = '\000\231\000\006',
	PowerpointMsoPresetThreeDFormatFormat7 = '\000\231\000\007',
	PowerpointMsoPresetThreeDFormatFormat8 = '\000\231\000\010',
	PowerpointMsoPresetThreeDFormatFormat9 = '\000\231\000\011',
	PowerpointMsoPresetThreeDFormatFormat10 = '\000\231\000\012',
	PowerpointMsoPresetThreeDFormatFormat11 = '\000\231\000\013',
	PowerpointMsoPresetThreeDFormatFormat12 = '\000\231\000\014',
	PowerpointMsoPresetThreeDFormatFormat13 = '\000\231\000\015',
	PowerpointMsoPresetThreeDFormatFormat14 = '\000\231\000\016',
	PowerpointMsoPresetThreeDFormatFormat15 = '\000\231\000\017',
	PowerpointMsoPresetThreeDFormatFormat16 = '\000\231\000\020',
	PowerpointMsoPresetThreeDFormatFormat17 = '\000\231\000\021',
	PowerpointMsoPresetThreeDFormatFormat18 = '\000\231\000\022',
	PowerpointMsoPresetThreeDFormatFormat19 = '\000\231\000\023',
	PowerpointMsoPresetThreeDFormatFormat20 = '\000\231\000\024'
};
typedef enum PowerpointMsoPresetThreeDFormat PowerpointMsoPresetThreeDFormat;

enum PowerpointMsoExtrusionColorType {
	PowerpointMsoExtrusionColorTypeExtrusionColorUnset = '\000\232\377\376',
	PowerpointMsoExtrusionColorTypeExtrusionColorAutomatic = '\000\233\000\001',
	PowerpointMsoExtrusionColorTypeExtrusionColorCustom = '\000\233\000\002'
};
typedef enum PowerpointMsoExtrusionColorType PowerpointMsoExtrusionColorType;

enum PowerpointMsoConnectorType {
	PowerpointMsoConnectorTypeConnectorTypeUnset = '\000h\377\376',
	PowerpointMsoConnectorTypeStraight = '\000i\000\001',
	PowerpointMsoConnectorTypeElbow = '\000i\000\002',
	PowerpointMsoConnectorTypeCurve = '\000i\000\003'
};
typedef enum PowerpointMsoConnectorType PowerpointMsoConnectorType;

enum PowerpointMsoHorizontalAnchor {
	PowerpointMsoHorizontalAnchorHorizontalAnchorUnset = '\000\236\377\376',
	PowerpointMsoHorizontalAnchorHorizontalAnchorNone = '\000\237\000\001',
	PowerpointMsoHorizontalAnchorHorizontalAnchorCenter = '\000\237\000\002'
};
typedef enum PowerpointMsoHorizontalAnchor PowerpointMsoHorizontalAnchor;

enum PowerpointMsoVerticalAnchor {
	PowerpointMsoVerticalAnchorVerticalAnchorUnset = '\000\237\377\376',
	PowerpointMsoVerticalAnchorAnchorTop = '\000\240\000\001',
	PowerpointMsoVerticalAnchorAnchorTopBaseline = '\000\240\000\002',
	PowerpointMsoVerticalAnchorAnchorMiddle = '\000\240\000\003',
	PowerpointMsoVerticalAnchorAnchorBottom = '\000\240\000\004',
	PowerpointMsoVerticalAnchorAnchorBottomBaseline = '\000\240\000\005'
};
typedef enum PowerpointMsoVerticalAnchor PowerpointMsoVerticalAnchor;

enum PowerpointMsoAutoShapeType {
	PowerpointMsoAutoShapeTypeAutoshapeShapeTypeUnset = '\000i\377\376',
	PowerpointMsoAutoShapeTypeAutoshapeRectangle = '\000j\000\001',
	PowerpointMsoAutoShapeTypeAutoshapeParallelogram = '\000j\000\002',
	PowerpointMsoAutoShapeTypeAutoshapeTrapezoid = '\000j\000\003',
	PowerpointMsoAutoShapeTypeAutoshapeDiamond = '\000j\000\004',
	PowerpointMsoAutoShapeTypeAutoshapeRoundedRectangle = '\000j\000\005',
	PowerpointMsoAutoShapeTypeAutoshapeOctagon = '\000j\000\006',
	PowerpointMsoAutoShapeTypeAutoshapeIsoscelesTriangle = '\000j\000\007',
	PowerpointMsoAutoShapeTypeAutoshapeRightTriangle = '\000j\000\010',
	PowerpointMsoAutoShapeTypeAutoshapeOval = '\000j\000\011',
	PowerpointMsoAutoShapeTypeAutoshapeHexagon = '\000j\000\012',
	PowerpointMsoAutoShapeTypeAutoshapeCross = '\000j\000\013',
	PowerpointMsoAutoShapeTypeAutoshapeRegularPentagon = '\000j\000\014',
	PowerpointMsoAutoShapeTypeAutoshapeCan = '\000j\000\015',
	PowerpointMsoAutoShapeTypeAutoshapeCube = '\000j\000\016',
	PowerpointMsoAutoShapeTypeAutoshapeBevel = '\000j\000\017',
	PowerpointMsoAutoShapeTypeAutoshapeFoldedCorner = '\000j\000\020',
	PowerpointMsoAutoShapeTypeAutoshapeSmileyFace = '\000j\000\021',
	PowerpointMsoAutoShapeTypeAutoshapeDonut = '\000j\000\022',
	PowerpointMsoAutoShapeTypeAutoshapeNoSymbol = '\000j\000\023',
	PowerpointMsoAutoShapeTypeAutoshapeBlockArc = '\000j\000\024',
	PowerpointMsoAutoShapeTypeAutoshapeHeart = '\000j\000\025',
	PowerpointMsoAutoShapeTypeAutoshapeLightningBolt = '\000j\000\026',
	PowerpointMsoAutoShapeTypeAutoshapeSun = '\000j\000\027',
	PowerpointMsoAutoShapeTypeAutoshapeMoon = '\000j\000\030',
	PowerpointMsoAutoShapeTypeAutoshapeArc = '\000j\000\031',
	PowerpointMsoAutoShapeTypeAutoshapeDoubleBracket = '\000j\000\032',
	PowerpointMsoAutoShapeTypeAutoshapeDoubleBrace = '\000j\000\033',
	PowerpointMsoAutoShapeTypeAutoshapePlaque = '\000j\000\034',
	PowerpointMsoAutoShapeTypeAutoshapeLeftBracket = '\000j\000\035',
	PowerpointMsoAutoShapeTypeAutoshapeRightBracket = '\000j\000\036',
	PowerpointMsoAutoShapeTypeAutoshapeLeftBrace = '\000j\000\037',
	PowerpointMsoAutoShapeTypeAutoshapeRightBrace = '\000j\000 ',
	PowerpointMsoAutoShapeTypeAutoshapeRightArrow = '\000j\000!',
	PowerpointMsoAutoShapeTypeAutoshapeLeftArrow = '\000j\000\"',
	PowerpointMsoAutoShapeTypeAutoshapeUpArrow = '\000j\000#',
	PowerpointMsoAutoShapeTypeAutoshapeDownArrow = '\000j\000$',
	PowerpointMsoAutoShapeTypeAutoshapeLeftRightArrow = '\000j\000%',
	PowerpointMsoAutoShapeTypeAutoshapeUpDownArrow = '\000j\000&',
	PowerpointMsoAutoShapeTypeAutoshapeQuadArrow = '\000j\000\'',
	PowerpointMsoAutoShapeTypeAutoshapeLeftRightUpArrow = '\000j\000(',
	PowerpointMsoAutoShapeTypeAutoshapeBentArrow = '\000j\000)',
	PowerpointMsoAutoShapeTypeAutoshapeUTurnArrow = '\000j\000*',
	PowerpointMsoAutoShapeTypeAutoshapeLeftUpArrow = '\000j\000+',
	PowerpointMsoAutoShapeTypeAutoshapeBentUpArrow = '\000j\000,',
	PowerpointMsoAutoShapeTypeAutoshapeCurvedRightArrow = '\000j\000-',
	PowerpointMsoAutoShapeTypeAutoshapeCurvedLeftArrow = '\000j\000.',
	PowerpointMsoAutoShapeTypeAutoshapeCurvedUpArrow = '\000j\000/',
	PowerpointMsoAutoShapeTypeAutoshapeCurvedDownArrow = '\000j\0000',
	PowerpointMsoAutoShapeTypeAutoshapeStripedRightArrow = '\000j\0001',
	PowerpointMsoAutoShapeTypeAutoshapeNotchedRightArrow = '\000j\0002',
	PowerpointMsoAutoShapeTypeAutoshapePentagon = '\000j\0003',
	PowerpointMsoAutoShapeTypeAutoshapeChevron = '\000j\0004',
	PowerpointMsoAutoShapeTypeAutoshapeRightArrowCallout = '\000j\0005',
	PowerpointMsoAutoShapeTypeAutoshapeLeftArrowCallout = '\000j\0006',
	PowerpointMsoAutoShapeTypeAutoshapeUpArrowCallout = '\000j\0007',
	PowerpointMsoAutoShapeTypeAutoshapeDownArrowCallout = '\000j\0008',
	PowerpointMsoAutoShapeTypeAutoshapeLeftRightArrowCallout = '\000j\0009',
	PowerpointMsoAutoShapeTypeAutoshapeUpDownArrowCallout = '\000j\000:',
	PowerpointMsoAutoShapeTypeAutoshapeQuadArrowCallout = '\000j\000;',
	PowerpointMsoAutoShapeTypeAutoshapeCircularArrow = '\000j\000<',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartProcess = '\000j\000=',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartAlternateProcess = '\000j\000>',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartDecision = '\000j\000\?',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartData = '\000j\000@',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartPredefinedProcess = '\000j\000A',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartInternalStorage = '\000j\000B',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartDocument = '\000j\000C',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartMultiDocument = '\000j\000D',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartTerminator = '\000j\000E',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartPreparation = '\000j\000F',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartManualInput = '\000j\000G',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartManualOperation = '\000j\000H',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartConnector = '\000j\000I',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartOffpageConnector = '\000j\000J',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartCard = '\000j\000K',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartPunchedTape = '\000j\000L',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartSummingJunction = '\000j\000M',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartOr = '\000j\000N',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartCollate = '\000j\000O',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartSort = '\000j\000P',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartExtract = '\000j\000Q',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartMerge = '\000j\000R',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartStoredData = '\000j\000S',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartDelay = '\000j\000T',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartSequentialAccessStorage = '\000j\000U',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartMagneticDisk = '\000j\000V',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartDirectAccessStorage = '\000j\000W',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartDisplay = '\000j\000X',
	PowerpointMsoAutoShapeTypeAutoshapeExplosionOne = '\000j\000Y',
	PowerpointMsoAutoShapeTypeAutoshapeExplosionTwo = '\000j\000Z',
	PowerpointMsoAutoShapeTypeAutoshapeFourPointStar = '\000j\000[',
	PowerpointMsoAutoShapeTypeAutoshapeFivePointStar = '\000j\000\\',
	PowerpointMsoAutoShapeTypeAutoshapeEightPointStar = '\000j\000]',
	PowerpointMsoAutoShapeTypeAutoshapeSixteenPointStar = '\000j\000^',
	PowerpointMsoAutoShapeTypeAutoshapeTwentyFourPointStar = '\000j\000_',
	PowerpointMsoAutoShapeTypeAutoshapeThirtyTwoPointStar = '\000j\000`',
	PowerpointMsoAutoShapeTypeAutoshapeUpRibbon = '\000j\000a',
	PowerpointMsoAutoShapeTypeAutoshapeDownRibbon = '\000j\000b',
	PowerpointMsoAutoShapeTypeAutoshapeCurvedUpRibbon = '\000j\000c',
	PowerpointMsoAutoShapeTypeAutoshapeCurvedDownRibbon = '\000j\000d',
	PowerpointMsoAutoShapeTypeAutoshapeVerticalScroll = '\000j\000e',
	PowerpointMsoAutoShapeTypeAutoshapeHorizontalScroll = '\000j\000f',
	PowerpointMsoAutoShapeTypeAutoshapeWave = '\000j\000g',
	PowerpointMsoAutoShapeTypeAutoshapeDoubleWave = '\000j\000h',
	PowerpointMsoAutoShapeTypeAutoshapeRectangularCallout = '\000j\000i',
	PowerpointMsoAutoShapeTypeAutoshapeRoundedRectangularCallout = '\000j\000j',
	PowerpointMsoAutoShapeTypeAutoshapeOvalCallout = '\000j\000k',
	PowerpointMsoAutoShapeTypeAutoshapeCloudCallout = '\000j\000l',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutOne = '\000j\000m',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutTwo = '\000j\000n',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutThree = '\000j\000o',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutFour = '\000j\000p',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutOneAccentBar = '\000j\000q',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutTwoAccentBar = '\000j\000r',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutThreeAccentBar = '\000j\000s',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutFourAccentBar = '\000j\000t',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutOneNoBorder = '\000j\000u',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutTwoNoBorder = '\000j\000v',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutThreeNoBorder = '\000j\000w',
	PowerpointMsoAutoShapeTypeAutoshapeLineCalloutFourNoBorder = '\000j\000x',
	PowerpointMsoAutoShapeTypeAutoshapeCalloutOneBorderAndAccentBar = '\000j\000y',
	PowerpointMsoAutoShapeTypeAutoshapeCalloutTwoBorderAndAccentBar = '\000j\000z',
	PowerpointMsoAutoShapeTypeAutoshapeCalloutThreeBorderAndAccentBar = '\000j\000{',
	PowerpointMsoAutoShapeTypeAutoshapeCalloutFourBorderAndAccentBar = '\000j\000|',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonCustom = '\000j\000}',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonHome = '\000j\000~',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonHelp = '\000j\000\177',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonInformation = '\000j\000\200',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonBackOrPrevious = '\000j\000\201',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonForwardOrNext = '\000j\000\202',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonBeginning = '\000j\000\203',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonEnd = '\000j\000\204',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonReturn = '\000j\000\205',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonDocument = '\000j\000\206',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonSound = '\000j\000\207',
	PowerpointMsoAutoShapeTypeAutoshapeActionButtonMovie = '\000j\000\210',
	PowerpointMsoAutoShapeTypeAutoshapeBalloon = '\000j\000\211',
	PowerpointMsoAutoShapeTypeAutoshapeNotPrimitive = '\000j\000\212',
	PowerpointMsoAutoShapeTypeAutoshapeFlowchartOfflineStorage = '\000j\000\213',
	PowerpointMsoAutoShapeTypeAutoshapeLeftRightRibbon = '\000j\000\214',
	PowerpointMsoAutoShapeTypeAutoshapeDiagonalStripe = '\000j\000\215',
	PowerpointMsoAutoShapeTypeAutoshapePie = '\000j\000\216',
	PowerpointMsoAutoShapeTypeAutoshapeNonIsoscelesTrapezoid = '\000j\000\217',
	PowerpointMsoAutoShapeTypeAutoshapeDecagon = '\000j\000\220',
	PowerpointMsoAutoShapeTypeAutoshapeHeptagon = '\000j\000\221',
	PowerpointMsoAutoShapeTypeAutoshapeDodecagon = '\000j\000\222',
	PowerpointMsoAutoShapeTypeAutoshapeSixPointsStar = '\000j\000\223',
	PowerpointMsoAutoShapeTypeAutoshapeSevenPointsStar = '\000j\000\224',
	PowerpointMsoAutoShapeTypeAutoshapeTenPointsStar = '\000j\000\225',
	PowerpointMsoAutoShapeTypeAutoshapeTwelvePointsStar = '\000j\000\226',
	PowerpointMsoAutoShapeTypeAutoshapeRoundOneRectangle = '\000j\000\227',
	PowerpointMsoAutoShapeTypeAutoshapeRoundTwoSameRectangle = '\000j\000\230',
	PowerpointMsoAutoShapeTypeAutoshapeRoundTwoDiagonalRectangle = '\000j\000\231',
	PowerpointMsoAutoShapeTypeAutoshapeSnipRoundRectangle = '\000j\000\232',
	PowerpointMsoAutoShapeTypeAutoshapeSnipOneRectangle = '\000j\000\233',
	PowerpointMsoAutoShapeTypeAutoshapeSnipTwoSameRectangle = '\000j\000\234',
	PowerpointMsoAutoShapeTypeAutoshapeSnipTwoDiagonalRectangle = '\000j\000\235',
	PowerpointMsoAutoShapeTypeAutoshapeFrame = '\000j\000\236',
	PowerpointMsoAutoShapeTypeAutoshapeHalfFrame = '\000j\000\237',
	PowerpointMsoAutoShapeTypeAutoshapeTear = '\000j\000\240',
	PowerpointMsoAutoShapeTypeAutoshapeChord = '\000j\000\241',
	PowerpointMsoAutoShapeTypeAutoshapeCorner = '\000j\000\242',
	PowerpointMsoAutoShapeTypeAutoshapeMathPlus = '\000j\000\243',
	PowerpointMsoAutoShapeTypeAutoshapeMathMinus = '\000j\000\244',
	PowerpointMsoAutoShapeTypeAutoshapeMathMultiply = '\000j\000\245',
	PowerpointMsoAutoShapeTypeAutoshapeMathDivide = '\000j\000\246',
	PowerpointMsoAutoShapeTypeAutoshapeMathEqual = '\000j\000\247',
	PowerpointMsoAutoShapeTypeAutoshapeMathNotEqual = '\000j\000\250',
	PowerpointMsoAutoShapeTypeAutoshapeCornerTabs = '\000j\000\251',
	PowerpointMsoAutoShapeTypeAutoshapeSquareTabs = '\000j\000\252',
	PowerpointMsoAutoShapeTypeAutoshapePlaqueTabs = '\000j\000\253',
	PowerpointMsoAutoShapeTypeAutoshapeGearSix = '\000j\000\254',
	PowerpointMsoAutoShapeTypeAutoshapeGearNine = '\000j\000\255',
	PowerpointMsoAutoShapeTypeAutoshapeFunnel = '\000j\000\256',
	PowerpointMsoAutoShapeTypeAutoshapePieWedge = '\000j\000\257',
	PowerpointMsoAutoShapeTypeAutoshapeLeftCircularArrow = '\000j\000\260',
	PowerpointMsoAutoShapeTypeAutoshapeLeftRightCircularArrow = '\000j\000\261',
	PowerpointMsoAutoShapeTypeAutoshapeSwooshArrow = '\000j\000\262',
	PowerpointMsoAutoShapeTypeAutoshapeCloud = '\000j\000\263',
	PowerpointMsoAutoShapeTypeAutoshapeChartX = '\000j\000\264',
	PowerpointMsoAutoShapeTypeAutoshapeChartStar = '\000j\000\265',
	PowerpointMsoAutoShapeTypeAutoshapeChartPlus = '\000j\000\266',
	PowerpointMsoAutoShapeTypeAutoshapeLineInverse = '\000j\000\267'
};
typedef enum PowerpointMsoAutoShapeType PowerpointMsoAutoShapeType;

enum PowerpointMsoShapeType {
	PowerpointMsoShapeTypeShapeTypeUnset = '\000\213\377\376',
	PowerpointMsoShapeTypeShapeTypeAuto = '\000\214\000\001',
	PowerpointMsoShapeTypeShapeTypeCallout = '\000\214\000\002',
	PowerpointMsoShapeTypeShapeTypeChart = '\000\214\000\003',
	PowerpointMsoShapeTypeShapeTypeComment = '\000\214\000\004',
	PowerpointMsoShapeTypeShapeTypeFreeForm = '\000\214\000\005',
	PowerpointMsoShapeTypeShapeTypeGroup = '\000\214\000\006',
	PowerpointMsoShapeTypeShapeTypeEmbeddedOLEControl = '\000\214\000\007',
	PowerpointMsoShapeTypeShapeTypeFormControl = '\000\214\000\010',
	PowerpointMsoShapeTypeShapeTypeLine = '\000\214\000\011',
	PowerpointMsoShapeTypeShapeTypeLinkedOLEObject = '\000\214\000\012',
	PowerpointMsoShapeTypeShapeTypeLinkedPicture = '\000\214\000\013',
	PowerpointMsoShapeTypeShapeTypeOLEControl = '\000\214\000\014',
	PowerpointMsoShapeTypeShapeTypePicture = '\000\214\000\015',
	PowerpointMsoShapeTypeShapeTypePlaceHolder = '\000\214\000\016',
	PowerpointMsoShapeTypeShapeTypeWordArt = '\000\214\000\017',
	PowerpointMsoShapeTypeShapeTypeMedia = '\000\214\000\020',
	PowerpointMsoShapeTypeShapeTypeTextBox = '\000\214\000\021',
	PowerpointMsoShapeTypeShapeTypeTable = '\000\214\000\022',
	PowerpointMsoShapeTypeShapeTypeCanvas = '\000\214\000\023',
	PowerpointMsoShapeTypeShapeTypeDiagram = '\000\214\000\024',
	PowerpointMsoShapeTypeShapeTypeInk = '\000\214\000\025',
	PowerpointMsoShapeTypeShapeTypeInkComment = '\000\214\000\026',
	PowerpointMsoShapeTypeShapeTypeSmartartGraphic = '\000\214\000\027',
	PowerpointMsoShapeTypeShapeTypeSlicer = '\000\214\000\030',
	PowerpointMsoShapeTypeShapeTypeWebVideo = '\000\214\000\031',
	PowerpointMsoShapeTypeShapeTypeContentApplication = '\000\214\000\032'
};
typedef enum PowerpointMsoShapeType PowerpointMsoShapeType;

enum PowerpointMsoColorType {
	PowerpointMsoColorTypeColorTypeUnset = '\000j\377\376',
	PowerpointMsoColorTypeRGB = '\000k\000\001',
	PowerpointMsoColorTypeScheme = '\000k\000\002'
};
typedef enum PowerpointMsoColorType PowerpointMsoColorType;

enum PowerpointMsoPictureColorType {
	PowerpointMsoPictureColorTypePictureColorTypeUnset = '\000\265\377\376',
	PowerpointMsoPictureColorTypePictureColorAutomatic = '\000\266\000\001',
	PowerpointMsoPictureColorTypePictureColorGrayScale = '\000\266\000\002',
	PowerpointMsoPictureColorTypePictureColorBlackAndWhite = '\000\266\000\003',
	PowerpointMsoPictureColorTypePictureColorWatermark = '\000\266\000\004'
};
typedef enum PowerpointMsoPictureColorType PowerpointMsoPictureColorType;

enum PowerpointMsoCalloutAngleType {
	PowerpointMsoCalloutAngleTypeAngleUnset = '\000k\377\376',
	PowerpointMsoCalloutAngleTypeAngleAutomatic = '\000l\000\001',
	PowerpointMsoCalloutAngleTypeAngle30 = '\000l\000\002',
	PowerpointMsoCalloutAngleTypeAngle45 = '\000l\000\003',
	PowerpointMsoCalloutAngleTypeAngle60 = '\000l\000\004',
	PowerpointMsoCalloutAngleTypeAngle90 = '\000l\000\005'
};
typedef enum PowerpointMsoCalloutAngleType PowerpointMsoCalloutAngleType;

enum PowerpointMsoCalloutDropType {
	PowerpointMsoCalloutDropTypeDropUnset = '\000l\377\376',
	PowerpointMsoCalloutDropTypeDropCustom = '\000m\000\001',
	PowerpointMsoCalloutDropTypeDropTop = '\000m\000\002',
	PowerpointMsoCalloutDropTypeDropCenter = '\000m\000\003',
	PowerpointMsoCalloutDropTypeDropBottom = '\000m\000\004'
};
typedef enum PowerpointMsoCalloutDropType PowerpointMsoCalloutDropType;

enum PowerpointMsoCalloutType {
	PowerpointMsoCalloutTypeCalloutUnset = '\000m\377\376',
	PowerpointMsoCalloutTypeCalloutOne = '\000n\000\001',
	PowerpointMsoCalloutTypeCalloutTwo = '\000n\000\002',
	PowerpointMsoCalloutTypeCalloutThree = '\000n\000\003',
	PowerpointMsoCalloutTypeCalloutFour = '\000n\000\004'
};
typedef enum PowerpointMsoCalloutType PowerpointMsoCalloutType;

enum PowerpointMsoTextOrientation {
	PowerpointMsoTextOrientationTextOrientationUnset = '\000\215\377\376',
	PowerpointMsoTextOrientationHorizontal = '\000\216\000\001',
	PowerpointMsoTextOrientationUpward = '\000\216\000\002',
	PowerpointMsoTextOrientationDownward = '\000\216\000\003',
	PowerpointMsoTextOrientationVerticalEastAsian = '\000\216\000\004',
	PowerpointMsoTextOrientationVertical = '\000\216\000\005',
	PowerpointMsoTextOrientationHorizontalRotatedEastAsian = '\000\216\000\006'
};
typedef enum PowerpointMsoTextOrientation PowerpointMsoTextOrientation;

enum PowerpointMsoScaleFrom {
	PowerpointMsoScaleFromScaleFromTopLeft = '\000o\000\000',
	PowerpointMsoScaleFromScaleFromMiddle = '\000o\000\001',
	PowerpointMsoScaleFromScaleFromBottomRight = '\000o\000\002'
};
typedef enum PowerpointMsoScaleFrom PowerpointMsoScaleFrom;

enum PowerpointMsoPresetCamera {
	PowerpointMsoPresetCameraPresetCameraUnset = '\000\256\377\376',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromTopLeft = '\000\257\000\001',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromTop = '\000\257\000\002',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromTopright = '\000\257\000\003',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromLeft = '\000\257\000\004',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromFront = '\000\257\000\005',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromRight = '\000\257\000\006',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromBottomLeft = '\000\257\000\007',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromBottom = '\000\257\000\010',
	PowerpointMsoPresetCameraCameraLegacyObliqueFromBottomRight = '\000\257\000\011',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromTopLeft = '\000\257\000\012',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromTop = '\000\257\000\013',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromTopRight = '\000\257\000\014',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromLeft = '\000\257\000\015',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromFront = '\000\257\000\016',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromRight = '\000\257\000\017',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromBottomLeft = '\000\257\000\020',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromBottom = '\000\257\000\021',
	PowerpointMsoPresetCameraCameraLegacyPerspectiveFromBottomRight = '\000\257\000\022',
	PowerpointMsoPresetCameraCameraOrthographic = '\000\257\000\023',
	PowerpointMsoPresetCameraCameraIsometricFromTopUp = '\000\257\000\024',
	PowerpointMsoPresetCameraCameraIsometricFromTopDown = '\000\257\000\025',
	PowerpointMsoPresetCameraCameraIsometricFromBottomUp = '\000\257\000\026',
	PowerpointMsoPresetCameraCameraIsometricFromBottomDown = '\000\257\000\027',
	PowerpointMsoPresetCameraCameraIsometricFromLeftUp = '\000\257\000\030',
	PowerpointMsoPresetCameraCameraIsometricFromLeftDown = '\000\257\000\031',
	PowerpointMsoPresetCameraCameraIsometricFromRightUp = '\000\257\000\032',
	PowerpointMsoPresetCameraCameraIsometricFromRightDown = '\000\257\000\033',
	PowerpointMsoPresetCameraCameraIsometricOffAxis1FromLeft = '\000\257\000\034',
	PowerpointMsoPresetCameraCameraIsometricOffAxis1FromRight = '\000\257\000\035',
	PowerpointMsoPresetCameraCameraIsometricOffAxis1FromTop = '\000\257\000\036',
	PowerpointMsoPresetCameraCameraIsometricOffAxis2FromLeft = '\000\257\000\037',
	PowerpointMsoPresetCameraCameraIsometricOffAxis2FromRight = '\000\257\000 ',
	PowerpointMsoPresetCameraCameraIsometricOffAxis2FromTop = '\000\257\000!',
	PowerpointMsoPresetCameraCameraIsometricOffAxis3FromLeft = '\000\257\000\"',
	PowerpointMsoPresetCameraCameraIsometricOffAxis3FromRight = '\000\257\000#',
	PowerpointMsoPresetCameraCameraIsometricOffAxis3FromBottom = '\000\257\000$',
	PowerpointMsoPresetCameraCameraIsometricOffAxis4FromLeft = '\000\257\000%',
	PowerpointMsoPresetCameraCameraIsometricOffAxis4FromRight = '\000\257\000&',
	PowerpointMsoPresetCameraCameraIsometricOffAxis4FromBottom = '\000\257\000\'',
	PowerpointMsoPresetCameraCameraObliqueFromTopLeft = '\000\257\000(',
	PowerpointMsoPresetCameraCameraObliqueFromTop = '\000\257\000)',
	PowerpointMsoPresetCameraCameraObliqueFromTopRight = '\000\257\000*',
	PowerpointMsoPresetCameraCameraObliqueFromLeft = '\000\257\000+',
	PowerpointMsoPresetCameraCameraObliqueFromRight = '\000\257\000,',
	PowerpointMsoPresetCameraCameraObliqueFromBottomLeft = '\000\257\000-',
	PowerpointMsoPresetCameraCameraObliqueFromBottom = '\000\257\000.',
	PowerpointMsoPresetCameraCameraObliqueFromBottomRight = '\000\257\000/',
	PowerpointMsoPresetCameraCameraPerspectiveFromFront = '\000\257\0000',
	PowerpointMsoPresetCameraCameraPerspectiveFromLeft = '\000\257\0001',
	PowerpointMsoPresetCameraCameraPerspectiveFromRight = '\000\257\0002',
	PowerpointMsoPresetCameraCameraPerspectiveFromAbove = '\000\257\0003',
	PowerpointMsoPresetCameraCameraPerspectiveFromBelow = '\000\257\0004',
	PowerpointMsoPresetCameraCameraPerspectiveFromAboveFacingLeft = '\000\257\0005',
	PowerpointMsoPresetCameraCameraPerspectiveFromAboveFacingRight = '\000\257\0006',
	PowerpointMsoPresetCameraCameraPerspectiveContrastingFacingLeft = '\000\257\0007',
	PowerpointMsoPresetCameraCameraPerspectiveContrastingFacingRight = '\000\257\0008',
	PowerpointMsoPresetCameraCameraPerspectiveHeroicFacingLeft = '\000\257\0009',
	PowerpointMsoPresetCameraCameraPerspectiveHeroicFacingRight = '\000\257\000:',
	PowerpointMsoPresetCameraCameraPerspectiveHeroicExtremeFacingLeft = '\000\257\000;',
	PowerpointMsoPresetCameraCameraPerspectiveHeroicExtremeFacingRight = '\000\257\000<',
	PowerpointMsoPresetCameraCameraPerspectiveRelaxed = '\000\257\000=',
	PowerpointMsoPresetCameraCameraPerspectiveRelaxedModerately = '\000\257\000>'
};
typedef enum PowerpointMsoPresetCamera PowerpointMsoPresetCamera;

enum PowerpointMsoLightRigType {
	PowerpointMsoLightRigTypeLightRigUnset = '\000\257\377\376',
	PowerpointMsoLightRigTypeLightRigFlat1 = '\000\260\000\001',
	PowerpointMsoLightRigTypeLightRigFlat2 = '\000\260\000\002',
	PowerpointMsoLightRigTypeLightRigFlat3 = '\000\260\000\003',
	PowerpointMsoLightRigTypeLightRigFlat4 = '\000\260\000\004',
	PowerpointMsoLightRigTypeLightRigNormal1 = '\000\260\000\005',
	PowerpointMsoLightRigTypeLightRigNormal2 = '\000\260\000\006',
	PowerpointMsoLightRigTypeLightRigNormal3 = '\000\260\000\007',
	PowerpointMsoLightRigTypeLightRigNormal4 = '\000\260\000\010',
	PowerpointMsoLightRigTypeLightRigHarsh1 = '\000\260\000\011',
	PowerpointMsoLightRigTypeLightRigHarsh2 = '\000\260\000\012',
	PowerpointMsoLightRigTypeLightRigHarsh3 = '\000\260\000\013',
	PowerpointMsoLightRigTypeLightRigHarsh4 = '\000\260\000\014',
	PowerpointMsoLightRigTypeLightRigThreePoint = '\000\260\000\015',
	PowerpointMsoLightRigTypeLightRigBalanced = '\000\260\000\016',
	PowerpointMsoLightRigTypeLightRigSoft = '\000\260\000\017',
	PowerpointMsoLightRigTypeLightRigHarsh = '\000\260\000\020',
	PowerpointMsoLightRigTypeLightRigFlood = '\000\260\000\021',
	PowerpointMsoLightRigTypeLightRigContrasting = '\000\260\000\022',
	PowerpointMsoLightRigTypeLightRigMorning = '\000\260\000\023',
	PowerpointMsoLightRigTypeLightRigSunrise = '\000\260\000\024',
	PowerpointMsoLightRigTypeLightRigSunset = '\000\260\000\025',
	PowerpointMsoLightRigTypeLightRigChilly = '\000\260\000\026',
	PowerpointMsoLightRigTypeLightRigFreezing = '\000\260\000\027',
	PowerpointMsoLightRigTypeLightRigFlat = '\000\260\000\030',
	PowerpointMsoLightRigTypeLightRigTwoPoint = '\000\260\000\031',
	PowerpointMsoLightRigTypeLightRigGlow = '\000\260\000\032',
	PowerpointMsoLightRigTypeLightRigBrightRoom = '\000\260\000\033'
};
typedef enum PowerpointMsoLightRigType PowerpointMsoLightRigType;

enum PowerpointMsoBevelType {
	PowerpointMsoBevelTypeBevelTypeUnset = '\000\260\377\376',
	PowerpointMsoBevelTypeBevelNone = '\000\261\000\001',
	PowerpointMsoBevelTypeBevelRelaxedInset = '\000\261\000\002',
	PowerpointMsoBevelTypeBevelCircle = '\000\261\000\003',
	PowerpointMsoBevelTypeBevelSlope = '\000\261\000\004',
	PowerpointMsoBevelTypeBevelCross = '\000\261\000\005',
	PowerpointMsoBevelTypeBevelAngle = '\000\261\000\006',
	PowerpointMsoBevelTypeBevelSoftRound = '\000\261\000\007',
	PowerpointMsoBevelTypeBevelConvex = '\000\261\000\010',
	PowerpointMsoBevelTypeBevelCoolSlant = '\000\261\000\011',
	PowerpointMsoBevelTypeBevelDivot = '\000\261\000\012',
	PowerpointMsoBevelTypeBevelRiblet = '\000\261\000\013',
	PowerpointMsoBevelTypeBevelHardEdge = '\000\261\000\014',
	PowerpointMsoBevelTypeBevelArtDeco = '\000\261\000\015'
};
typedef enum PowerpointMsoBevelType PowerpointMsoBevelType;

enum PowerpointMsoShadowStyle {
	PowerpointMsoShadowStyleShadowStyleUnset = '\000\261\377\376',
	PowerpointMsoShadowStyleShadowStyleInner = '\000\262\000\001',
	PowerpointMsoShadowStyleShadowStyleOuter = '\000\262\000\002'
};
typedef enum PowerpointMsoShadowStyle PowerpointMsoShadowStyle;

enum PowerpointMsoParagraphAlignment {
	PowerpointMsoParagraphAlignmentParagraphAlignmentUnset = '\000\346\377\376',
	PowerpointMsoParagraphAlignmentParagraphAlignLeft = '\000\347\000\000',
	PowerpointMsoParagraphAlignmentParagraphAlignCenter = '\000\347\000\001',
	PowerpointMsoParagraphAlignmentParagraphAlignRight = '\000\347\000\002',
	PowerpointMsoParagraphAlignmentParagraphAlignJustify = '\000\347\000\003',
	PowerpointMsoParagraphAlignmentParagraphAlignDistribute = '\000\347\000\004',
	PowerpointMsoParagraphAlignmentParagraphAlignThai = '\000\347\000\005',
	PowerpointMsoParagraphAlignmentParagraphAlignJustifyLow = '\000\347\000\006'
};
typedef enum PowerpointMsoParagraphAlignment PowerpointMsoParagraphAlignment;

enum PowerpointMsoTextStrike {
	PowerpointMsoTextStrikeStrikeUnset = '\000\263\377\376',
	PowerpointMsoTextStrikeNoStrike = '\000\264\000\000',
	PowerpointMsoTextStrikeSingleStrike = '\000\264\000\001',
	PowerpointMsoTextStrikeDoubleStrike = '\000\264\000\002'
};
typedef enum PowerpointMsoTextStrike PowerpointMsoTextStrike;

enum PowerpointMsoTextCaps {
	PowerpointMsoTextCapsCapsUnset = '\000\264\377\376',
	PowerpointMsoTextCapsNoCaps = '\000\265\000\000',
	PowerpointMsoTextCapsSmallCaps = '\000\265\000\001',
	PowerpointMsoTextCapsAllCaps = '\000\265\000\002'
};
typedef enum PowerpointMsoTextCaps PowerpointMsoTextCaps;

enum PowerpointMsoTextUnderlineType {
	PowerpointMsoTextUnderlineTypeUnderlineUnset = '\003\356\377\376',
	PowerpointMsoTextUnderlineTypeNoUnderline = '\003\357\000\000',
	PowerpointMsoTextUnderlineTypeUnderlineWordsOnly = '\003\357\000\001',
	PowerpointMsoTextUnderlineTypeUnderlineSingleLine = '\003\357\000\002',
	PowerpointMsoTextUnderlineTypeUnderlineDoubleLine = '\003\357\000\003',
	PowerpointMsoTextUnderlineTypeUnderlineHeavyLine = '\003\357\000\004',
	PowerpointMsoTextUnderlineTypeUnderlineDottedLine = '\003\357\000\005',
	PowerpointMsoTextUnderlineTypeUnderlineHeavyDottedLine = '\003\357\000\006',
	PowerpointMsoTextUnderlineTypeUnderlineDashLine = '\003\357\000\007',
	PowerpointMsoTextUnderlineTypeUnderlineHeavyDashLine = '\003\357\000\010',
	PowerpointMsoTextUnderlineTypeUnderlineLongDashLine = '\003\357\000\011',
	PowerpointMsoTextUnderlineTypeUnderlineHeavyLongDashLine = '\003\357\000\012',
	PowerpointMsoTextUnderlineTypeUnderlineDotDashLine = '\003\357\000\013',
	PowerpointMsoTextUnderlineTypeUnderlineHeavyDotDashLine = '\003\357\000\014',
	PowerpointMsoTextUnderlineTypeUnderlineDotDotDashLine = '\003\357\000\015',
	PowerpointMsoTextUnderlineTypeUnderlineHeavyDotDotDashLine = '\003\357\000\016',
	PowerpointMsoTextUnderlineTypeUnderlineWavyLine = '\003\357\000\017',
	PowerpointMsoTextUnderlineTypeUnderlineHeavyWavyLine = '\003\357\000\020',
	PowerpointMsoTextUnderlineTypeUnderlineWavyDoubleLine = '\003\357\000\021'
};
typedef enum PowerpointMsoTextUnderlineType PowerpointMsoTextUnderlineType;

enum PowerpointMsoTextTabAlign {
	PowerpointMsoTextTabAlignTabUnset = '\000\266\377\376',
	PowerpointMsoTextTabAlignLeftTab = '\000\267\000\000',
	PowerpointMsoTextTabAlignCenterTab = '\000\267\000\001',
	PowerpointMsoTextTabAlignRightTab = '\000\267\000\002',
	PowerpointMsoTextTabAlignDecimalTab = '\000\267\000\003'
};
typedef enum PowerpointMsoTextTabAlign PowerpointMsoTextTabAlign;

enum PowerpointMsoTextCharWrap {
	PowerpointMsoTextCharWrapCharacterWrapUnset = '\000\267\377\376',
	PowerpointMsoTextCharWrapNoCharacterWrap = '\000\270\000\000',
	PowerpointMsoTextCharWrapStandardCharacterWrap = '\000\270\000\001',
	PowerpointMsoTextCharWrapStrictCharacterWrap = '\000\270\000\002',
	PowerpointMsoTextCharWrapCustomCharacterWrap = '\000\270\000\003'
};
typedef enum PowerpointMsoTextCharWrap PowerpointMsoTextCharWrap;

enum PowerpointMsoTextFontAlign {
	PowerpointMsoTextFontAlignFontAlignmentUnset = '\000\270\377\376',
	PowerpointMsoTextFontAlignAutomaticAlignment = '\000\271\000\000',
	PowerpointMsoTextFontAlignTopAlignment = '\000\271\000\001',
	PowerpointMsoTextFontAlignCenterAlignment = '\000\271\000\002',
	PowerpointMsoTextFontAlignBaselineAlignment = '\000\271\000\003',
	PowerpointMsoTextFontAlignBottomAlignment = '\000\271\000\004'
};
typedef enum PowerpointMsoTextFontAlign PowerpointMsoTextFontAlign;

enum PowerpointMsoAutoSize {
	PowerpointMsoAutoSizeAutoSizeUnset = '\000\344\377\376',
	PowerpointMsoAutoSizeAutoSizeNone = '\000\345\000\000',
	PowerpointMsoAutoSizeShapeToFitText = '\000\345\000\001',
	PowerpointMsoAutoSizeTextToFitShape = '\000\345\000\002'
};
typedef enum PowerpointMsoAutoSize PowerpointMsoAutoSize;

enum PowerpointMsoPathFormat {
	PowerpointMsoPathFormatPathTypeUnset = '\000\272\377\376',
	PowerpointMsoPathFormatNoPathType = '\000\273\000\000',
	PowerpointMsoPathFormatPathType1 = '\000\273\000\001',
	PowerpointMsoPathFormatPathType2 = '\000\273\000\002',
	PowerpointMsoPathFormatPathType3 = '\000\273\000\003',
	PowerpointMsoPathFormatPathType4 = '\000\273\000\004'
};
typedef enum PowerpointMsoPathFormat PowerpointMsoPathFormat;

enum PowerpointMsoWarpFormat {
	PowerpointMsoWarpFormatWarpFormatUnset = '\000\273\377\376',
	PowerpointMsoWarpFormatWarpFormat1 = '\000\274\000\000',
	PowerpointMsoWarpFormatWarpFormat2 = '\000\274\000\001',
	PowerpointMsoWarpFormatWarpFormat3 = '\000\274\000\002',
	PowerpointMsoWarpFormatWarpFormat4 = '\000\274\000\003',
	PowerpointMsoWarpFormatWarpFormat5 = '\000\274\000\004',
	PowerpointMsoWarpFormatWarpFormat6 = '\000\274\000\005',
	PowerpointMsoWarpFormatWarpFormat7 = '\000\274\000\006',
	PowerpointMsoWarpFormatWarpFormat8 = '\000\274\000\007',
	PowerpointMsoWarpFormatWarpFormat9 = '\000\274\000\010',
	PowerpointMsoWarpFormatWarpFormat10 = '\000\274\000\011',
	PowerpointMsoWarpFormatWarpFormat11 = '\000\274\000\012',
	PowerpointMsoWarpFormatWarpFormat12 = '\000\274\000\013',
	PowerpointMsoWarpFormatWarpFormat13 = '\000\274\000\014',
	PowerpointMsoWarpFormatWarpFormat14 = '\000\274\000\015',
	PowerpointMsoWarpFormatWarpFormat15 = '\000\274\000\016',
	PowerpointMsoWarpFormatWarpFormat16 = '\000\274\000\017',
	PowerpointMsoWarpFormatWarpFormat17 = '\000\274\000\020',
	PowerpointMsoWarpFormatWarpFormat18 = '\000\274\000\021',
	PowerpointMsoWarpFormatWarpFormat19 = '\000\274\000\022',
	PowerpointMsoWarpFormatWarpFormat20 = '\000\274\000\023',
	PowerpointMsoWarpFormatWarpFormat21 = '\000\274\000\024',
	PowerpointMsoWarpFormatWarpFormat22 = '\000\274\000\025',
	PowerpointMsoWarpFormatWarpFormat23 = '\000\274\000\026',
	PowerpointMsoWarpFormatWarpFormat24 = '\000\274\000\027',
	PowerpointMsoWarpFormatWarpFormat25 = '\000\274\000\030',
	PowerpointMsoWarpFormatWarpFormat26 = '\000\274\000\031',
	PowerpointMsoWarpFormatWarpFormat27 = '\000\274\000\032',
	PowerpointMsoWarpFormatWarpFormat28 = '\000\274\000\033',
	PowerpointMsoWarpFormatWarpFormat29 = '\000\274\000\034',
	PowerpointMsoWarpFormatWarpFormat30 = '\000\274\000\035',
	PowerpointMsoWarpFormatWarpFormat31 = '\000\274\000\036',
	PowerpointMsoWarpFormatWarpFormat32 = '\000\274\000\037',
	PowerpointMsoWarpFormatWarpFormat33 = '\000\274\000 ',
	PowerpointMsoWarpFormatWarpFormat34 = '\000\274\000!',
	PowerpointMsoWarpFormatWarpFormat35 = '\000\274\000\"',
	PowerpointMsoWarpFormatWarpFormat36 = '\000\274\000#',
	PowerpointMsoWarpFormatWarpFormat37 = '\000\274\000$'
};
typedef enum PowerpointMsoWarpFormat PowerpointMsoWarpFormat;

enum PowerpointMsoTextChangeCase {
	PowerpointMsoTextChangeCaseCaseSentence = '\000\344\000\001',
	PowerpointMsoTextChangeCaseCaseLower = '\000\344\000\002',
	PowerpointMsoTextChangeCaseCaseUpper = '\000\344\000\003',
	PowerpointMsoTextChangeCaseCaseTitle = '\000\344\000\004',
	PowerpointMsoTextChangeCaseCaseToggle = '\000\344\000\005'
};
typedef enum PowerpointMsoTextChangeCase PowerpointMsoTextChangeCase;

enum PowerpointMsoDateTimeFormat {
	PowerpointMsoDateTimeFormatDateTimeFormatUnset = '\000\275\377\376',
	PowerpointMsoDateTimeFormatDateTimeFormatMdyy = '\000\276\000\001',
	PowerpointMsoDateTimeFormatDateTimeFormatDdddMMMMddyyyy = '\000\276\000\002',
	PowerpointMsoDateTimeFormatDateTimeFormatDMMMMyyyy = '\000\276\000\003',
	PowerpointMsoDateTimeFormatDateTimeFormatMMMMdyyyy = '\000\276\000\004',
	PowerpointMsoDateTimeFormatDateTimeFormatDMMMyy = '\000\276\000\005',
	PowerpointMsoDateTimeFormatDateTimeFormatMMMMyy = '\000\276\000\006',
	PowerpointMsoDateTimeFormatDateTimeFormatMMyy = '\000\276\000\007',
	PowerpointMsoDateTimeFormatDateTimeFormatMMddyyHmm = '\000\276\000\010',
	PowerpointMsoDateTimeFormatDateTimeFormatMMddyyhmmAMPM = '\000\276\000\011',
	PowerpointMsoDateTimeFormatDateTimeFormatHmm = '\000\276\000\012',
	PowerpointMsoDateTimeFormatDateTimeFormatHmmss = '\000\276\000\013',
	PowerpointMsoDateTimeFormatDateTimeFormatHmmAMPM = '\000\276\000\014',
	PowerpointMsoDateTimeFormatDateTimeFormatHmmssAMPM = '\000\276\000\015',
	PowerpointMsoDateTimeFormatDateTimeFormatFigureOut = '\000\276\000\016'
};
typedef enum PowerpointMsoDateTimeFormat PowerpointMsoDateTimeFormat;

enum PowerpointMsoSoftEdgeType {
	PowerpointMsoSoftEdgeTypeSoftEdgeUnset = '\000\277\377\376',
	PowerpointMsoSoftEdgeTypeNoSoftEdge = '\000\300\000\000',
	PowerpointMsoSoftEdgeTypeSoftEdgeType1 = '\000\300\000\001',
	PowerpointMsoSoftEdgeTypeSoftEdgeType2 = '\000\300\000\002',
	PowerpointMsoSoftEdgeTypeSoftEdgeType3 = '\000\300\000\003',
	PowerpointMsoSoftEdgeTypeSoftEdgeType4 = '\000\300\000\004',
	PowerpointMsoSoftEdgeTypeSoftEdgeType5 = '\000\300\000\005',
	PowerpointMsoSoftEdgeTypeSoftEdgeType6 = '\000\300\000\006'
};
typedef enum PowerpointMsoSoftEdgeType PowerpointMsoSoftEdgeType;

enum PowerpointMsoThemeColorSchemeIndex {
	PowerpointMsoThemeColorSchemeIndexFirstDarkSchemeColor = '\000\301\000\001',
	PowerpointMsoThemeColorSchemeIndexFirstLightSchemeColor = '\000\301\000\002',
	PowerpointMsoThemeColorSchemeIndexSecondDarkSchemeColor = '\000\301\000\003',
	PowerpointMsoThemeColorSchemeIndexSecondLightSchemeColor = '\000\301\000\004',
	PowerpointMsoThemeColorSchemeIndexFirstAccentSchemeColor = '\000\301\000\005',
	PowerpointMsoThemeColorSchemeIndexSecondAccentSchemeColor = '\000\301\000\006',
	PowerpointMsoThemeColorSchemeIndexThirdAccentSchemeColor = '\000\301\000\007',
	PowerpointMsoThemeColorSchemeIndexFourthAccentSchemeColor = '\000\301\000\010',
	PowerpointMsoThemeColorSchemeIndexFifthAccentSchemeColor = '\000\301\000\011',
	PowerpointMsoThemeColorSchemeIndexSixthAccentSchemeColor = '\000\301\000\012',
	PowerpointMsoThemeColorSchemeIndexHyperlinkSchemeColor = '\000\301\000\013',
	PowerpointMsoThemeColorSchemeIndexFollowedHyperlinkSchemeColor = '\000\301\000\014'
};
typedef enum PowerpointMsoThemeColorSchemeIndex PowerpointMsoThemeColorSchemeIndex;

enum PowerpointMsoThemeColorIndex {
	PowerpointMsoThemeColorIndexThemeColorUnset = '\000\301\377\376',
	PowerpointMsoThemeColorIndexNoThemeColor = '\000\302\000\000',
	PowerpointMsoThemeColorIndexFirstDarkThemeColor = '\000\302\000\001',
	PowerpointMsoThemeColorIndexFirstLightThemeColor = '\000\302\000\002',
	PowerpointMsoThemeColorIndexSecondDarkThemeColor = '\000\302\000\003',
	PowerpointMsoThemeColorIndexSecondLightThemeColor = '\000\302\000\004',
	PowerpointMsoThemeColorIndexFirstAccentThemeColor = '\000\302\000\005',
	PowerpointMsoThemeColorIndexSecondAccentThemeColor = '\000\302\000\006',
	PowerpointMsoThemeColorIndexThirdAccentThemeColor = '\000\302\000\007',
	PowerpointMsoThemeColorIndexFourthAccentThemeColor = '\000\302\000\010',
	PowerpointMsoThemeColorIndexFifthAccentThemeColor = '\000\302\000\011',
	PowerpointMsoThemeColorIndexSixthAccentThemeColor = '\000\302\000\012',
	PowerpointMsoThemeColorIndexHyperlinkThemeColor = '\000\302\000\013',
	PowerpointMsoThemeColorIndexFollowedHyperlinkThemeColor = '\000\302\000\014',
	PowerpointMsoThemeColorIndexFirstTextThemeColor = '\000\302\000\015',
	PowerpointMsoThemeColorIndexFirstBackgroundThemeColor = '\000\302\000\016',
	PowerpointMsoThemeColorIndexSecondTextThemeColor = '\000\302\000\017',
	PowerpointMsoThemeColorIndexSecondBackgroundThemeColor = '\000\302\000\020'
};
typedef enum PowerpointMsoThemeColorIndex PowerpointMsoThemeColorIndex;

enum PowerpointMsoFontLanguageIndex {
	PowerpointMsoFontLanguageIndexThemeFontLatin = '\000\303\000\001',
	PowerpointMsoFontLanguageIndexThemeFontComplexScript = '\000\303\000\002',
	PowerpointMsoFontLanguageIndexThemeFontHighAnsi = '\000\303\000\003',
	PowerpointMsoFontLanguageIndexThemeFontEastAsian = '\000\303\000\004'
};
typedef enum PowerpointMsoFontLanguageIndex PowerpointMsoFontLanguageIndex;

enum PowerpointMsoShapeStyleIndex {
	PowerpointMsoShapeStyleIndexShapeStyleUnset = '\000\303\377\376',
	PowerpointMsoShapeStyleIndexShapeNotAPreset = '\000\304\000\000',
	PowerpointMsoShapeStyleIndexShapePreset1 = '\000\304\000\001',
	PowerpointMsoShapeStyleIndexShapePreset2 = '\000\304\000\002',
	PowerpointMsoShapeStyleIndexShapePreset3 = '\000\304\000\003',
	PowerpointMsoShapeStyleIndexShapePreset4 = '\000\304\000\004',
	PowerpointMsoShapeStyleIndexShapePreset5 = '\000\304\000\005',
	PowerpointMsoShapeStyleIndexShapePreset6 = '\000\304\000\006',
	PowerpointMsoShapeStyleIndexShapePreset7 = '\000\304\000\007',
	PowerpointMsoShapeStyleIndexShapePreset8 = '\000\304\000\010',
	PowerpointMsoShapeStyleIndexShapePreset9 = '\000\304\000\011',
	PowerpointMsoShapeStyleIndexShapePreset10 = '\000\304\000\012',
	PowerpointMsoShapeStyleIndexShapePreset11 = '\000\304\000\013',
	PowerpointMsoShapeStyleIndexShapePreset12 = '\000\304\000\014',
	PowerpointMsoShapeStyleIndexShapePreset13 = '\000\304\000\015',
	PowerpointMsoShapeStyleIndexShapePreset14 = '\000\304\000\016',
	PowerpointMsoShapeStyleIndexShapePreset15 = '\000\304\000\017',
	PowerpointMsoShapeStyleIndexShapePreset16 = '\000\304\000\020',
	PowerpointMsoShapeStyleIndexShapePreset17 = '\000\304\000\021',
	PowerpointMsoShapeStyleIndexShapePreset18 = '\000\304\000\022',
	PowerpointMsoShapeStyleIndexShapePreset19 = '\000\304\000\023',
	PowerpointMsoShapeStyleIndexShapePreset20 = '\000\304\000\024',
	PowerpointMsoShapeStyleIndexShapePreset21 = '\000\304\000\025',
	PowerpointMsoShapeStyleIndexShapePreset22 = '\000\304\000\026',
	PowerpointMsoShapeStyleIndexShapePreset23 = '\000\304\000\027',
	PowerpointMsoShapeStyleIndexShapePreset24 = '\000\304\000\030',
	PowerpointMsoShapeStyleIndexShapePreset25 = '\000\304\000\031',
	PowerpointMsoShapeStyleIndexShapePreset26 = '\000\304\000\032',
	PowerpointMsoShapeStyleIndexShapePreset27 = '\000\304\000\033',
	PowerpointMsoShapeStyleIndexShapePreset28 = '\000\304\000\034',
	PowerpointMsoShapeStyleIndexShapePreset29 = '\000\304\000\035',
	PowerpointMsoShapeStyleIndexShapePreset30 = '\000\304\000\036',
	PowerpointMsoShapeStyleIndexShapePreset31 = '\000\304\000\037',
	PowerpointMsoShapeStyleIndexShapePreset32 = '\000\304\000 ',
	PowerpointMsoShapeStyleIndexShapePreset33 = '\000\304\000!',
	PowerpointMsoShapeStyleIndexShapePreset34 = '\000\304\000\"',
	PowerpointMsoShapeStyleIndexShapePreset35 = '\000\304\000#',
	PowerpointMsoShapeStyleIndexShapePreset36 = '\000\304\000$',
	PowerpointMsoShapeStyleIndexShapePreset37 = '\000\304\000%',
	PowerpointMsoShapeStyleIndexShapePreset38 = '\000\304\000&',
	PowerpointMsoShapeStyleIndexShapePreset39 = '\000\304\000\'',
	PowerpointMsoShapeStyleIndexShapePreset40 = '\000\304\000(',
	PowerpointMsoShapeStyleIndexShapePreset41 = '\000\304\000)',
	PowerpointMsoShapeStyleIndexShapePreset42 = '\000\304\000*',
	PowerpointMsoShapeStyleIndexLinePreset1 = '\000\304\'\021',
	PowerpointMsoShapeStyleIndexLinePreset2 = '\000\304\'\022',
	PowerpointMsoShapeStyleIndexLinePreset3 = '\000\304\'\023',
	PowerpointMsoShapeStyleIndexLinePreset4 = '\000\304\'\024',
	PowerpointMsoShapeStyleIndexLinePreset5 = '\000\304\'\025',
	PowerpointMsoShapeStyleIndexLinePreset6 = '\000\304\'\026',
	PowerpointMsoShapeStyleIndexLinePreset7 = '\000\304\'\027',
	PowerpointMsoShapeStyleIndexLinePreset8 = '\000\304\'\030',
	PowerpointMsoShapeStyleIndexLinePreset9 = '\000\304\'\031',
	PowerpointMsoShapeStyleIndexLinePreset10 = '\000\304\'\032',
	PowerpointMsoShapeStyleIndexLinePreset11 = '\000\304\'\033',
	PowerpointMsoShapeStyleIndexLinePreset12 = '\000\304\'\034',
	PowerpointMsoShapeStyleIndexLinePreset13 = '\000\304\'\035',
	PowerpointMsoShapeStyleIndexLinePreset14 = '\000\304\'\036',
	PowerpointMsoShapeStyleIndexLinePreset15 = '\000\304\'\037',
	PowerpointMsoShapeStyleIndexLinePreset16 = '\000\304\' ',
	PowerpointMsoShapeStyleIndexLinePreset17 = '\000\304\'!',
	PowerpointMsoShapeStyleIndexLinePreset18 = '\000\304\'\"',
	PowerpointMsoShapeStyleIndexLinePreset19 = '\000\304\'#',
	PowerpointMsoShapeStyleIndexLinePreset20 = '\000\304\'$',
	PowerpointMsoShapeStyleIndexLinePreset21 = '\000\304\'%'
};
typedef enum PowerpointMsoShapeStyleIndex PowerpointMsoShapeStyleIndex;

enum PowerpointMsoBackgroundStyleIndex {
	PowerpointMsoBackgroundStyleIndexBackgroundUnset = '\000\304\377\376',
	PowerpointMsoBackgroundStyleIndexBackgroundNotAPreset = '\000\305\000\000',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset1 = '\000\305\000\001',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset2 = '\000\305\000\002',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset3 = '\000\305\000\003',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset4 = '\000\305\000\004',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset5 = '\000\305\000\005',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset6 = '\000\305\000\006',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset7 = '\000\305\000\007',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset8 = '\000\305\000\010',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset9 = '\000\305\000\011',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset10 = '\000\305\000\012',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset11 = '\000\305\000\013',
	PowerpointMsoBackgroundStyleIndexBackgroundPreset12 = '\000\305\000\014'
};
typedef enum PowerpointMsoBackgroundStyleIndex PowerpointMsoBackgroundStyleIndex;

enum PowerpointMsoTextDirection {
	PowerpointMsoTextDirectionTextDirectionUnset = '\000\352\377\376',
	PowerpointMsoTextDirectionLeftToRight = '\000\353\000\001',
	PowerpointMsoTextDirectionRightToLeft = '\000\353\000\002'
};
typedef enum PowerpointMsoTextDirection PowerpointMsoTextDirection;

enum PowerpointMsoBulletType {
	PowerpointMsoBulletTypeBulletTypeUnset = '\000\347\377\376',
	PowerpointMsoBulletTypeBulletTypeNone = '\000\350\000\000',
	PowerpointMsoBulletTypeBulletTypeUnnumbered = '\000\350\000\001',
	PowerpointMsoBulletTypeBulletTypeNumbered = '\000\350\000\002',
	PowerpointMsoBulletTypePictureBulletType = '\000\350\000\003'
};
typedef enum PowerpointMsoBulletType PowerpointMsoBulletType;

enum PowerpointMsoNumberedBulletStyle {
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleUnset = '\000\350\377\376',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleAlphaLowercasePeriod = '\000\351\000\000',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleAlphaUppercasePeriod = '\000\351\000\001',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicRightParen = '\000\351\000\002',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicPeriod = '\000\351\000\003',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleRomanLowercaseParenBoth = '\000\351\000\004',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleRomanLowercaseParenRight = '\000\351\000\005',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleRomanLowercasePeriod = '\000\351\000\006',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleRomanUppercasePeriod = '\000\351\000\007',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleAlphaLowercaseParenBoth = '\000\351\000\010',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleAlphaLowercaseParenRight = '\000\351\000\011',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleAlphaUppercaseParenBoth = '\000\351\000\012',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleAlphaUppercaseParenRight = '\000\351\000\013',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicParenBoth = '\000\351\000\014',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicPlain = '\000\351\000\015',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleRomanUppercaseParenBoth = '\000\351\000\016',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleRomanUppercaseParenRight = '\000\351\000\017',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleSimplifiedChinesePlain = '\000\351\000\020',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleSimplifiedChinesePeriod = '\000\351\000\021',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleCircleNumberPlain = '\000\351\000\022',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleCircleNumberWhitePlain = '\000\351\000\023',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleCircleNumberBlackPlain = '\000\351\000\024',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleTraditionalChinesePlain = '\000\351\000\025',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleTraditionalChinesePeriod = '\000\351\000\026',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicAlphaDash = '\000\351\000\027',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicAbjadDash = '\000\351\000\030',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleHebrewAlphaDash = '\000\351\000\031',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleKanjiKoreanPlain = '\000\351\000\032',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleKanjiKoreanPeriod = '\000\351\000\033',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicDBPlain = '\000\351\000\034',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleArabicDBPeriod = '\000\351\000\035',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleThaiAlphaPeriod = '\000\351\000\036',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleThaiAlphaParenRight = '\000\351\000\037',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleThaiAlphaParenBoth = '\000\351\000 ',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleThaiNumberPeriod = '\000\351\000!',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleThaiNumberParenRight = '\000\351\000\"',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleThaiParenBoth = '\000\351\000#',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleHindiAlphaPeriod = '\000\351\000$',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleHindiNumberPeriod = '\000\351\000%',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleKanjiSimpifiedChineseDBPeriod = '\000\351\000&',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleHindiNumberParenRight = '\000\351\000\'',
	PowerpointMsoNumberedBulletStyleNumberedBulletStyleHindiAlpha1Period = '\000\351\000('
};
typedef enum PowerpointMsoNumberedBulletStyle PowerpointMsoNumberedBulletStyle;

enum PowerpointMsoTabStopType {
	PowerpointMsoTabStopTypeTabstopUnset = '\000\364\377\376',
	PowerpointMsoTabStopTypeTabstopLeft = '\000\365\000\001',
	PowerpointMsoTabStopTypeTabstopCenter = '\000\365\000\002',
	PowerpointMsoTabStopTypeTabstopRight = '\000\365\000\003',
	PowerpointMsoTabStopTypeTabstopDecimal = '\000\365\000\004'
};
typedef enum PowerpointMsoTabStopType PowerpointMsoTabStopType;

enum PowerpointMsoReflectionType {
	PowerpointMsoReflectionTypeReflectionUnset = '\003\351\377\376',
	PowerpointMsoReflectionTypeReflectionTypeNone = '\003\352\000\000',
	PowerpointMsoReflectionTypeReflectionType1 = '\003\352\000\001',
	PowerpointMsoReflectionTypeReflectionType2 = '\003\352\000\002',
	PowerpointMsoReflectionTypeReflectionType3 = '\003\352\000\003',
	PowerpointMsoReflectionTypeReflectionType4 = '\003\352\000\004',
	PowerpointMsoReflectionTypeReflectionType5 = '\003\352\000\005',
	PowerpointMsoReflectionTypeReflectionType6 = '\003\352\000\006',
	PowerpointMsoReflectionTypeReflectionType7 = '\003\352\000\007',
	PowerpointMsoReflectionTypeReflectionType8 = '\003\352\000\010',
	PowerpointMsoReflectionTypeReflectionType9 = '\003\352\000\011'
};
typedef enum PowerpointMsoReflectionType PowerpointMsoReflectionType;

enum PowerpointMsoTextureAlignment {
	PowerpointMsoTextureAlignmentTextureUnset = '\003\352\377\376',
	PowerpointMsoTextureAlignmentTextureTopLeft = '\003\353\000\000',
	PowerpointMsoTextureAlignmentTextureTop = '\003\353\000\001',
	PowerpointMsoTextureAlignmentTextureTopRight = '\003\353\000\002',
	PowerpointMsoTextureAlignmentTextureLeft = '\003\353\000\003',
	PowerpointMsoTextureAlignmentTextureCenter = '\003\353\000\004',
	PowerpointMsoTextureAlignmentTextureRight = '\003\353\000\005',
	PowerpointMsoTextureAlignmentTextureBottomLeft = '\003\353\000\006',
	PowerpointMsoTextureAlignmentTextureBotton = '\003\353\000\007',
	PowerpointMsoTextureAlignmentTextureBottomRight = '\003\353\000\010'
};
typedef enum PowerpointMsoTextureAlignment PowerpointMsoTextureAlignment;

enum PowerpointMsoBaselineAlignment {
	PowerpointMsoBaselineAlignmentTextBaselineAlignmentUnset = '\003\353\377\376',
	PowerpointMsoBaselineAlignmentTextBaselineAlignBaseline = '\003\354\000\001',
	PowerpointMsoBaselineAlignmentTextBaselineAlignTop = '\003\354\000\002',
	PowerpointMsoBaselineAlignmentTextBaselineAlignCenter = '\003\354\000\003',
	PowerpointMsoBaselineAlignmentTextBaselineAlignEastAsian50 = '\003\354\000\004',
	PowerpointMsoBaselineAlignmentTextBaselineAlignAutomatic = '\003\354\000\005'
};
typedef enum PowerpointMsoBaselineAlignment PowerpointMsoBaselineAlignment;

enum PowerpointMsoClipboardFormat {
	PowerpointMsoClipboardFormatClipboardFormatUnset = '\003\354\377\376',
	PowerpointMsoClipboardFormatNativeClipboardFormat = '\003\355\000\001',
	PowerpointMsoClipboardFormatHTMlClipboardFormat = '\003\355\000\002',
	PowerpointMsoClipboardFormatRTFClipboardFormat = '\003\355\000\003',
	PowerpointMsoClipboardFormatPlainTextClipboardFormat = '\003\355\000\004'
};
typedef enum PowerpointMsoClipboardFormat PowerpointMsoClipboardFormat;

enum PowerpointMsoTextRangeInsertPosition {
	PowerpointMsoTextRangeInsertPositionInsertBefore = '\003\356\000\000',
	PowerpointMsoTextRangeInsertPositionInsertAfter = '\003\356\000\001'
};
typedef enum PowerpointMsoTextRangeInsertPosition PowerpointMsoTextRangeInsertPosition;

enum PowerpointMsoPictureType {
	PowerpointMsoPictureTypeSaveAsDefault = '\003\362\377\376',
	PowerpointMsoPictureTypeSaveAsPNGFile = '\003\363\000\000',
	PowerpointMsoPictureTypeSaveAsBMPFile = '\003\363\000\001',
	PowerpointMsoPictureTypeSaveAsGIFFile = '\003\363\000\002',
	PowerpointMsoPictureTypeSaveAsJPGFile = '\003\363\000\003',
	PowerpointMsoPictureTypeSaveAsPDFFile = '\003\363\000\004'
};
typedef enum PowerpointMsoPictureType PowerpointMsoPictureType;

enum PowerpointMsoPictureEffectType {
	PowerpointMsoPictureEffectTypeNoEffect = '\003\364\000\000',
	PowerpointMsoPictureEffectTypeEffectBackgroundRemoval = '\003\364\000\001',
	PowerpointMsoPictureEffectTypeEffectBlur = '\003\364\000\002',
	PowerpointMsoPictureEffectTypeEffectBrightnessContrast = '\003\364\000\003',
	PowerpointMsoPictureEffectTypeEffectCement = '\003\364\000\004',
	PowerpointMsoPictureEffectTypeEffectCrisscrossEtching = '\003\364\000\005',
	PowerpointMsoPictureEffectTypeEffectChalkSketch = '\003\364\000\006',
	PowerpointMsoPictureEffectTypeEffectColorTemperature = '\003\364\000\007',
	PowerpointMsoPictureEffectTypeEffectCutout = '\003\364\000\010',
	PowerpointMsoPictureEffectTypeEffectFilmGrain = '\003\364\000\011',
	PowerpointMsoPictureEffectTypeEffectGlass = '\003\364\000\012',
	PowerpointMsoPictureEffectTypeEffectGlowDiffused = '\003\364\000\013',
	PowerpointMsoPictureEffectTypeEffectGlowEdges = '\003\364\000\014',
	PowerpointMsoPictureEffectTypeEffectLightScreen = '\003\364\000\015',
	PowerpointMsoPictureEffectTypeEffectLineDrawing = '\003\364\000\016',
	PowerpointMsoPictureEffectTypeEffectMarker = '\003\364\000\017',
	PowerpointMsoPictureEffectTypeEffectMosiaicBubbles = '\003\364\000\020',
	PowerpointMsoPictureEffectTypeEffectPaintBrush = '\003\364\000\021',
	PowerpointMsoPictureEffectTypeEffectPaintStrokes = '\003\364\000\022',
	PowerpointMsoPictureEffectTypeEffectPastelsSmooth = '\003\364\000\023',
	PowerpointMsoPictureEffectTypeEffectPencilGrayscale = '\003\364\000\024',
	PowerpointMsoPictureEffectTypeEffectPencilSketch = '\003\364\000\025',
	PowerpointMsoPictureEffectTypeEffectPhotocopy = '\003\364\000\026',
	PowerpointMsoPictureEffectTypeEffectPlasticWrap = '\003\364\000\027',
	PowerpointMsoPictureEffectTypeEffectSaturation = '\003\364\000\030',
	PowerpointMsoPictureEffectTypeEffectSharpenSoften = '\003\364\000\031',
	PowerpointMsoPictureEffectTypeEffectTexturizer = '\003\364\000\032',
	PowerpointMsoPictureEffectTypeEffectWatercolorSponge = '\003\364\000\033'
};
typedef enum PowerpointMsoPictureEffectType PowerpointMsoPictureEffectType;

enum PowerpointMsoSegmentType {
	PowerpointMsoSegmentTypeLine = '\000\217\000\000',
	PowerpointMsoSegmentTypeCurve = '\000\217\000\001'
};
typedef enum PowerpointMsoSegmentType PowerpointMsoSegmentType;

enum PowerpointMsoEditingType {
	PowerpointMsoEditingTypeAuto = '\000\220\000\000',
	PowerpointMsoEditingTypeCorner = '\000\220\000\001',
	PowerpointMsoEditingTypeSmooth = '\000\220\000\002',
	PowerpointMsoEditingTypeSymmetric = '\000\220\000\003'
};
typedef enum PowerpointMsoEditingType PowerpointMsoEditingType;

enum PowerpointMsoSmartArtNodePosition {
	PowerpointMsoSmartArtNodePositionDefaultNodePosition = '\003\365\000\001',
	PowerpointMsoSmartArtNodePositionAfterNode = '\003\365\000\002',
	PowerpointMsoSmartArtNodePositionBeforeNode = '\003\365\000\003',
	PowerpointMsoSmartArtNodePositionAboveNode = '\003\365\000\004',
	PowerpointMsoSmartArtNodePositionBelowNode = '\003\365\000\005'
};
typedef enum PowerpointMsoSmartArtNodePosition PowerpointMsoSmartArtNodePosition;

enum PowerpointMsoSmartArtNodeType {
	PowerpointMsoSmartArtNodeTypeDefaultNode = '\003\366\000\001',
	PowerpointMsoSmartArtNodeTypeAssistantNode = '\003\366\000\002'
};
typedef enum PowerpointMsoSmartArtNodeType PowerpointMsoSmartArtNodeType;

enum PowerpointMsoOrgChartLayoutType {
	PowerpointMsoOrgChartLayoutTypeOrgChartLayoutUnset = '\003\366\377\376',
	PowerpointMsoOrgChartLayoutTypeOrgChartLayoutStandard = '\003\367\000\001',
	PowerpointMsoOrgChartLayoutTypeOrgChartLayoutBothHanging = '\003\367\000\002',
	PowerpointMsoOrgChartLayoutTypeOrgChartLayoutLeftHanging = '\003\367\000\003',
	PowerpointMsoOrgChartLayoutTypeOrgChartLayoutRightHanging = '\003\367\000\004',
	PowerpointMsoOrgChartLayoutTypeOrgChartLayoutDefault = '\003\367\000\005'
};
typedef enum PowerpointMsoOrgChartLayoutType PowerpointMsoOrgChartLayoutType;

enum PowerpointMsoAlignCmd {
	PowerpointMsoAlignCmdAlignLefts = '\000\000\000\000',
	PowerpointMsoAlignCmdAlignCenters = '\000\000\000\001',
	PowerpointMsoAlignCmdAlignRights = '\000\000\000\002',
	PowerpointMsoAlignCmdAlignTops = '\000\000\000\003',
	PowerpointMsoAlignCmdAlignMiddles = '\000\000\000\004',
	PowerpointMsoAlignCmdAlignBottoms = '\000\000\000\005'
};
typedef enum PowerpointMsoAlignCmd PowerpointMsoAlignCmd;

enum PowerpointMsoDistributeCmd {
	PowerpointMsoDistributeCmdDistributeHorizontally = '\000\000\000\000',
	PowerpointMsoDistributeCmdDistributeVertically = '\000\000\000\001'
};
typedef enum PowerpointMsoDistributeCmd PowerpointMsoDistributeCmd;

enum PowerpointMsoOrientation {
	PowerpointMsoOrientationOrientationUnset = '\000\214\377\376',
	PowerpointMsoOrientationHorizontalOrientation = '\000\215\000\001',
	PowerpointMsoOrientationVerticalOrientation = '\000\215\000\002'
};
typedef enum PowerpointMsoOrientation PowerpointMsoOrientation;

enum PowerpointMsoZOrderCmd {
	PowerpointMsoZOrderCmdBringShapeToFront = '\000p\000\000',
	PowerpointMsoZOrderCmdSendShapeToBack = '\000p\000\001',
	PowerpointMsoZOrderCmdBringShapeForward = '\000p\000\002',
	PowerpointMsoZOrderCmdSendShapeBackward = '\000p\000\003',
	PowerpointMsoZOrderCmdBringShapeInFrontOfText = '\000p\000\004',
	PowerpointMsoZOrderCmdSendShapeBehindText = '\000p\000\005'
};
typedef enum PowerpointMsoZOrderCmd PowerpointMsoZOrderCmd;

enum PowerpointMsoScriptLanguage {
	PowerpointMsoScriptLanguageBringShapeToFront = '\000o\000\001',
	PowerpointMsoScriptLanguageSendShapeToBack = '\000o\000\002',
	PowerpointMsoScriptLanguageBringShapeForward = '\000o\000\003',
	PowerpointMsoScriptLanguageSendShapeBackward = '\000o\000\004'
};
typedef enum PowerpointMsoScriptLanguage PowerpointMsoScriptLanguage;

enum PowerpointMsoFlipCmd {
	PowerpointMsoFlipCmdFlipHorizontal = '\000q\000\000',
	PowerpointMsoFlipCmdFlipVertical = '\000q\000\001'
};
typedef enum PowerpointMsoFlipCmd PowerpointMsoFlipCmd;

enum PowerpointMsoTriState {
	PowerpointMsoTriStateTrue = '\000\240\377\377',
	PowerpointMsoTriStateFalse = '\000\241\000\000',
	PowerpointMsoTriStateCTrue = '\000\241\000\001',
	PowerpointMsoTriStateToggle = '\000\240\377\375',
	PowerpointMsoTriStateTriStateUnset = '\000\240\377\376'
};
typedef enum PowerpointMsoTriState PowerpointMsoTriState;

enum PowerpointMsoBlackWhiteMode {
	PowerpointMsoBlackWhiteModeBlackAndWhiteUnset = '\000\254\377\376',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeAutomatic = '\000\255\000\001',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeGrayScale = '\000\255\000\002',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeLightGrayScale = '\000\255\000\003',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeInverseGrayScale = '\000\255\000\004',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeGrayOutline = '\000\255\000\005',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeBlackTextAndLine = '\000\255\000\006',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeHighContrast = '\000\255\000\007',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeBlack = '\000\255\000\010',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeWhite = '\000\255\000\011',
	PowerpointMsoBlackWhiteModeBlackAndWhiteModeDontShow = '\000\255\000\012'
};
typedef enum PowerpointMsoBlackWhiteMode PowerpointMsoBlackWhiteMode;

enum PowerpointMsoBarPosition {
	PowerpointMsoBarPositionBarLeft = '\000r\000\000',
	PowerpointMsoBarPositionBarTop = '\000r\000\001',
	PowerpointMsoBarPositionBarRight = '\000r\000\002',
	PowerpointMsoBarPositionBarBottom = '\000r\000\003',
	PowerpointMsoBarPositionBarFloating = '\000r\000\004',
	PowerpointMsoBarPositionBarPopUp = '\000r\000\005',
	PowerpointMsoBarPositionBarMenu = '\000r\000\006'
};
typedef enum PowerpointMsoBarPosition PowerpointMsoBarPosition;

enum PowerpointMsoBarProtection {
	PowerpointMsoBarProtectionNoProtection = '\000s\000\000',
	PowerpointMsoBarProtectionNoCustomize = '\000s\000\001',
	PowerpointMsoBarProtectionNoResize = '\000s\000\002',
	PowerpointMsoBarProtectionNoMove = '\000s\000\004',
	PowerpointMsoBarProtectionNoChangeVisible = '\000s\000\010',
	PowerpointMsoBarProtectionNoChangeDock = '\000s\000\020',
	PowerpointMsoBarProtectionNoVerticalDock = '\000s\000 ',
	PowerpointMsoBarProtectionNoHorizontalDock = '\000s\000@'
};
typedef enum PowerpointMsoBarProtection PowerpointMsoBarProtection;

enum PowerpointMsoBarType {
	PowerpointMsoBarTypeNormalCommandBar = '\000t\000\000',
	PowerpointMsoBarTypeMenubarCommandBar = '\000t\000\001',
	PowerpointMsoBarTypePopupCommandBar = '\000t\000\002'
};
typedef enum PowerpointMsoBarType PowerpointMsoBarType;

enum PowerpointMsoControlType {
	PowerpointMsoControlTypeControlCustom = '\000u\000\000',
	PowerpointMsoControlTypeControlButton = '\000u\000\001',
	PowerpointMsoControlTypeControlEdit = '\000u\000\002',
	PowerpointMsoControlTypeControlDropDown = '\000u\000\003',
	PowerpointMsoControlTypeControlCombobox = '\000u\000\004',
	PowerpointMsoControlTypeButtonDropDown = '\000u\000\005',
	PowerpointMsoControlTypeSplitDropDown = '\000u\000\006',
	PowerpointMsoControlTypeOCXDropDown = '\000u\000\007',
	PowerpointMsoControlTypeGenericDropDown = '\000u\000\010',
	PowerpointMsoControlTypeGraphicDropDown = '\000u\000\011',
	PowerpointMsoControlTypeControlPopup = '\000u\000\012',
	PowerpointMsoControlTypeGraphicPopup = '\000u\000\013',
	PowerpointMsoControlTypeButtonPopup = '\000u\000\014',
	PowerpointMsoControlTypeSplitButtonPopup = '\000u\000\015',
	PowerpointMsoControlTypeSplitButtonMRUPopup = '\000u\000\016',
	PowerpointMsoControlTypeControlLabel = '\000u\000\017',
	PowerpointMsoControlTypeExpandingGrid = '\000u\000\020',
	PowerpointMsoControlTypeSplitExpandingGrid = '\000u\000\021',
	PowerpointMsoControlTypeControlGrid = '\000u\000\022',
	PowerpointMsoControlTypeControlGauge = '\000u\000\023',
	PowerpointMsoControlTypeGraphicCombobox = '\000u\000\024',
	PowerpointMsoControlTypeControlPane = '\000u\000\025',
	PowerpointMsoControlTypeActiveX = '\000u\000\026',
	PowerpointMsoControlTypeControlGroup = '\000u\000\027',
	PowerpointMsoControlTypeControlTab = '\000u\000\030',
	PowerpointMsoControlTypeControlSpinner = '\000u\000\031'
};
typedef enum PowerpointMsoControlType PowerpointMsoControlType;

enum PowerpointMsoButtonState {
	PowerpointMsoButtonStateButtonStateUp = '\000v\000\000',
	PowerpointMsoButtonStateButtonStateDown = '\000u\377\377',
	PowerpointMsoButtonStateButtonStateUnset = '\000v\000\002'
};
typedef enum PowerpointMsoButtonState PowerpointMsoButtonState;

enum PowerpointMsoControlOLEUsage {
	PowerpointMsoControlOLEUsageNeither = '\000w\000\000',
	PowerpointMsoControlOLEUsageServer = '\000w\000\001',
	PowerpointMsoControlOLEUsageClient = '\000w\000\002',
	PowerpointMsoControlOLEUsageBoth = '\000w\000\003'
};
typedef enum PowerpointMsoControlOLEUsage PowerpointMsoControlOLEUsage;

enum PowerpointMsoButtonStyle {
	PowerpointMsoButtonStyleButtonAutomatic = '\000x\000\000',
	PowerpointMsoButtonStyleButtonIcon = '\000x\000\001',
	PowerpointMsoButtonStyleButtonCaption = '\000x\000\002',
	PowerpointMsoButtonStyleButtonIconAndCaption = '\000x\000\003'
};
typedef enum PowerpointMsoButtonStyle PowerpointMsoButtonStyle;

enum PowerpointMsoComboStyle {
	PowerpointMsoComboStyleComboboxStyleNormal = '\000y\000\000',
	PowerpointMsoComboStyleComboboxStyleLabel = '\000y\000\001'
};
typedef enum PowerpointMsoComboStyle PowerpointMsoComboStyle;

enum PowerpointMsoMenuAnimation {
	PowerpointMsoMenuAnimationNone = '\000{\000\000',
	PowerpointMsoMenuAnimationRandom = '\000{\000\001',
	PowerpointMsoMenuAnimationUnfold = '\000{\000\002',
	PowerpointMsoMenuAnimationSlide = '\000{\000\003'
};
typedef enum PowerpointMsoMenuAnimation PowerpointMsoMenuAnimation;

enum PowerpointMsoHyperlinkType {
	PowerpointMsoHyperlinkTypeHyperlinkTypeTextRange = '\000\226\000\000',
	PowerpointMsoHyperlinkTypeHyperlinkTypeShape = '\000\226\000\001',
	PowerpointMsoHyperlinkTypeHyperlinkTypeInlineShape = '\000\226\000\002'
};
typedef enum PowerpointMsoHyperlinkType PowerpointMsoHyperlinkType;

enum PowerpointMsoExtraInfoMethod {
	PowerpointMsoExtraInfoMethodAppendString = '\000\256\000\000',
	PowerpointMsoExtraInfoMethodPostString = '\000\256\000\001'
};
typedef enum PowerpointMsoExtraInfoMethod PowerpointMsoExtraInfoMethod;

enum PowerpointMsoAnimationType {
	PowerpointMsoAnimationTypeIdle = '\000|\000\001',
	PowerpointMsoAnimationTypeGreeting = '\000|\000\002',
	PowerpointMsoAnimationTypeGoodbye = '\000|\000\003',
	PowerpointMsoAnimationTypeBeginSpeaking = '\000|\000\004',
	PowerpointMsoAnimationTypeCharacterSuccessMajor = '\000|\000\006',
	PowerpointMsoAnimationTypeGetAttentionMajor = '\000|\000\013',
	PowerpointMsoAnimationTypeGetAttentionMinor = '\000|\000\014',
	PowerpointMsoAnimationTypeSearching = '\000|\000\015',
	PowerpointMsoAnimationTypePrinting = '\000|\000\022',
	PowerpointMsoAnimationTypeGestureRight = '\000|\000\023',
	PowerpointMsoAnimationTypeWritingNotingSomething = '\000|\000\026',
	PowerpointMsoAnimationTypeWorkingAtSomething = '\000|\000\027',
	PowerpointMsoAnimationTypeThinking = '\000|\000\030',
	PowerpointMsoAnimationTypeSendingMail = '\000|\000\031',
	PowerpointMsoAnimationTypeListensToComputer = '\000|\000\032',
	PowerpointMsoAnimationTypeDisappear = '\000|\000\037',
	PowerpointMsoAnimationTypeAppear = '\000|\000 ',
	PowerpointMsoAnimationTypeGetArtsy = '\000|\000d',
	PowerpointMsoAnimationTypeGetTechy = '\000|\000e',
	PowerpointMsoAnimationTypeGetWizardy = '\000|\000f',
	PowerpointMsoAnimationTypeCheckingSomething = '\000|\000g',
	PowerpointMsoAnimationTypeLookDown = '\000|\000h',
	PowerpointMsoAnimationTypeLookDownLeft = '\000|\000i',
	PowerpointMsoAnimationTypeLookDownRight = '\000|\000j',
	PowerpointMsoAnimationTypeLookLeft = '\000|\000k',
	PowerpointMsoAnimationTypeLookRight = '\000|\000l',
	PowerpointMsoAnimationTypeLookUp = '\000|\000m',
	PowerpointMsoAnimationTypeLookUpLeft = '\000|\000n',
	PowerpointMsoAnimationTypeLookUpRight = '\000|\000o',
	PowerpointMsoAnimationTypeSaving = '\000|\000p',
	PowerpointMsoAnimationTypeGestureDown = '\000|\000q',
	PowerpointMsoAnimationTypeGestureLeft = '\000|\000r',
	PowerpointMsoAnimationTypeGestureUp = '\000|\000s',
	PowerpointMsoAnimationTypeEmptyTrash = '\000|\000t'
};
typedef enum PowerpointMsoAnimationType PowerpointMsoAnimationType;

enum PowerpointMsoButtonSetType {
	PowerpointMsoButtonSetTypeButtonNone = '\000}\000\000',
	PowerpointMsoButtonSetTypeButtonOk = '\000}\000\001',
	PowerpointMsoButtonSetTypeButtonCancel = '\000}\000\002',
	PowerpointMsoButtonSetTypeButtonsOkCancel = '\000}\000\003',
	PowerpointMsoButtonSetTypeButtonsYesNo = '\000}\000\004',
	PowerpointMsoButtonSetTypeButtonsYesNoCancel = '\000}\000\005',
	PowerpointMsoButtonSetTypeButtonsBackClose = '\000}\000\006',
	PowerpointMsoButtonSetTypeButtonsNextClose = '\000}\000\007',
	PowerpointMsoButtonSetTypeButtonsBackNextClose = '\000}\000\010',
	PowerpointMsoButtonSetTypeButtonsRetryCancel = '\000}\000\011',
	PowerpointMsoButtonSetTypeButtonsAbortRetryIgnore = '\000}\000\012',
	PowerpointMsoButtonSetTypeButtonsSearchClose = '\000}\000\013',
	PowerpointMsoButtonSetTypeButtonsBackNextSnooze = '\000}\000\014',
	PowerpointMsoButtonSetTypeButtonsTipsOptionsClose = '\000}\000\015',
	PowerpointMsoButtonSetTypeButtonsYesAllNoCancel = '\000}\000\016'
};
typedef enum PowerpointMsoButtonSetType PowerpointMsoButtonSetType;

enum PowerpointMsoIconType {
	PowerpointMsoIconTypeIconNone = '\000~\000\000',
	PowerpointMsoIconTypeIconApplication = '\000~\000\001',
	PowerpointMsoIconTypeIconAlert = '\000~\000\002',
	PowerpointMsoIconTypeIconTip = '\000~\000\003',
	PowerpointMsoIconTypeIconAlertCritical = '\000~\000e',
	PowerpointMsoIconTypeIconAlertWarning = '\000~\000g',
	PowerpointMsoIconTypeIconAlertInfo = '\000~\000h'
};
typedef enum PowerpointMsoIconType PowerpointMsoIconType;

enum PowerpointMsoWizardActType {
	PowerpointMsoWizardActTypeInactive = '\000\202\000\000',
	PowerpointMsoWizardActTypeActive = '\000\202\000\001',
	PowerpointMsoWizardActTypeSuspend = '\000\202\000\002',
	PowerpointMsoWizardActTypeResume = '\000\202\000\003'
};
typedef enum PowerpointMsoWizardActType PowerpointMsoWizardActType;

enum PowerpointMsoDocProperties {
	PowerpointMsoDocPropertiesPropertyTypeNumber = '\000\242\000\001',
	PowerpointMsoDocPropertiesPropertyTypeBoolean = '\000\242\000\002',
	PowerpointMsoDocPropertiesPropertyTypeDate = '\000\242\000\003',
	PowerpointMsoDocPropertiesPropertyTypeString = '\000\242\000\004',
	PowerpointMsoDocPropertiesPropertyTypeFloat = '\000\242\000\005'
};
typedef enum PowerpointMsoDocProperties PowerpointMsoDocProperties;

enum PowerpointMsoAutomationSecurity {
	PowerpointMsoAutomationSecurityMsoAutomationSecurityLow = '\000\243\000\001',
	PowerpointMsoAutomationSecurityMsoAutomationSecurityByUI = '\000\243\000\002',
	PowerpointMsoAutomationSecurityMsoAutomationSecurityForceDisable = '\000\243\000\003'
};
typedef enum PowerpointMsoAutomationSecurity PowerpointMsoAutomationSecurity;

enum PowerpointMsoScreenSize {
	PowerpointMsoScreenSizeResolution544x376 = '\000\204\000\000',
	PowerpointMsoScreenSizeResolution640x480 = '\000\204\000\001',
	PowerpointMsoScreenSizeResolution720x512 = '\000\204\000\002',
	PowerpointMsoScreenSizeResolution800x600 = '\000\204\000\003',
	PowerpointMsoScreenSizeResolution1024x768 = '\000\204\000\004',
	PowerpointMsoScreenSizeResolution1152x882 = '\000\204\000\005',
	PowerpointMsoScreenSizeResolution1152x900 = '\000\204\000\006',
	PowerpointMsoScreenSizeResolution1280x1024 = '\000\204\000\007',
	PowerpointMsoScreenSizeResolution1600x1200 = '\000\204\000\010',
	PowerpointMsoScreenSizeResolution1800x1440 = '\000\204\000\011',
	PowerpointMsoScreenSizeResolution1920x1200 = '\000\204\000\012'
};
typedef enum PowerpointMsoScreenSize PowerpointMsoScreenSize;

enum PowerpointMsoCharacterSet {
	PowerpointMsoCharacterSetArabicCharacterSet = '\000\205\000\001',
	PowerpointMsoCharacterSetCyrillicCharacterSet = '\000\205\000\002',
	PowerpointMsoCharacterSetEnglishCharacterSet = '\000\205\000\003',
	PowerpointMsoCharacterSetGreekCharacterSet = '\000\205\000\004',
	PowerpointMsoCharacterSetHebrewCharacterSet = '\000\205\000\005',
	PowerpointMsoCharacterSetJapaneseCharacterSet = '\000\205\000\006',
	PowerpointMsoCharacterSetKoreanCharacterSet = '\000\205\000\007',
	PowerpointMsoCharacterSetMultilingualUnicodeCharacterSet = '\000\205\000\010',
	PowerpointMsoCharacterSetSimplifiedChineseCharacterSet = '\000\205\000\011',
	PowerpointMsoCharacterSetThaiCharacterSet = '\000\205\000\012',
	PowerpointMsoCharacterSetTraditionalChineseCharacterSet = '\000\205\000\013',
	PowerpointMsoCharacterSetVietnameseCharacterSet = '\000\205\000\014'
};
typedef enum PowerpointMsoCharacterSet PowerpointMsoCharacterSet;

enum PowerpointMsoEncoding {
	PowerpointMsoEncodingEncodingThai = '\000\213\003j',
	PowerpointMsoEncodingEncodingJapaneseShiftJIS = '\000\213\003\244',
	PowerpointMsoEncodingEncodingSimplifiedChinese = '\000\213\003\250',
	PowerpointMsoEncodingEncodingKorean = '\000\213\003\265',
	PowerpointMsoEncodingEncodingBig5TraditionalChinese = '\000\213\003\266',
	PowerpointMsoEncodingEncodingLittleEndian = '\000\213\004\260',
	PowerpointMsoEncodingEncodingBigEndian = '\000\213\004\261',
	PowerpointMsoEncodingEncodingCentralEuropean = '\000\213\004\342',
	PowerpointMsoEncodingEncodingCyrillic = '\000\213\004\343',
	PowerpointMsoEncodingEncodingWestern = '\000\213\004\344',
	PowerpointMsoEncodingEncodingGreek = '\000\213\004\345',
	PowerpointMsoEncodingEncodingTurkish = '\000\213\004\346',
	PowerpointMsoEncodingEncodingHebrew = '\000\213\004\347',
	PowerpointMsoEncodingEncodingArabic = '\000\213\004\350',
	PowerpointMsoEncodingEncodingBaltic = '\000\213\004\351',
	PowerpointMsoEncodingEncodingVietnamese = '\000\213\004\352',
	PowerpointMsoEncodingEncodingISO88591Latin1 = '\000\213o\257',
	PowerpointMsoEncodingEncodingISO88592CentralEurope = '\000\213o\260',
	PowerpointMsoEncodingEncodingISO88593Latin3 = '\000\213o\261',
	PowerpointMsoEncodingEncodingISO88594Baltic = '\000\213o\262',
	PowerpointMsoEncodingEncodingISO88595Cyrillic = '\000\213o\263',
	PowerpointMsoEncodingEncodingISO88596Arabic = '\000\213o\264',
	PowerpointMsoEncodingEncodingISO88597Greek = '\000\213o\265',
	PowerpointMsoEncodingEncodingISO88598Hebrew = '\000\213o\266',
	PowerpointMsoEncodingEncodingISO88599Turkish = '\000\213o\267',
	PowerpointMsoEncodingEncodingISO885915Latin9 = '\000\213o\275',
	PowerpointMsoEncodingEncodingISO2022JapaneseNoHalfWidthKatakana = '\000\213\304,',
	PowerpointMsoEncodingEncodingISO2022JapaneseJISX02021984 = '\000\213\304-',
	PowerpointMsoEncodingEncodingISO2022JapaneseJISX02011989 = '\000\213\304.',
	PowerpointMsoEncodingEncodingISO2022KR = '\000\213\3041',
	PowerpointMsoEncodingEncodingISO2022CNTraditionalChinese = '\000\213\3043',
	PowerpointMsoEncodingEncodingISO2022CNSimplifiedChinese = '\000\213\3045',
	PowerpointMsoEncodingEncodingMacRoman = '\000\213\'\020',
	PowerpointMsoEncodingEncodingMacJapanese = '\000\213\'\021',
	PowerpointMsoEncodingEncodingMacTraditionalChinese = '\000\213\'\022',
	PowerpointMsoEncodingEncodingMacKorean = '\000\213\'\023',
	PowerpointMsoEncodingEncodingMacArabic = '\000\213\'\024',
	PowerpointMsoEncodingEncodingMacHebrew = '\000\213\'\025',
	PowerpointMsoEncodingEncodingMacGreek1 = '\000\213\'\026',
	PowerpointMsoEncodingEncodingMacCyrillic = '\000\213\'\027',
	PowerpointMsoEncodingEncodingMacSimplifiedChineseGB2312 = '\000\213\'\030',
	PowerpointMsoEncodingEncodingMacRomania = '\000\213\'\032',
	PowerpointMsoEncodingEncodingMacUkraine = '\000\213\'!',
	PowerpointMsoEncodingEncodingMacLatin2 = '\000\213\'-',
	PowerpointMsoEncodingEncodingMacIcelandic = '\000\213\'_',
	PowerpointMsoEncodingEncodingMacTurkish = '\000\213\'a',
	PowerpointMsoEncodingEncodingMacCroatia = '\000\213\'b',
	PowerpointMsoEncodingEncodingEBCDICUSCanada = '\000\213\000%',
	PowerpointMsoEncodingEncodingEBCDICInternational = '\000\213\001\364',
	PowerpointMsoEncodingEncodingEBCDICMultilingualROECELatin2 = '\000\213\003f',
	PowerpointMsoEncodingEncodingEBCDICGreekModern = '\000\213\003k',
	PowerpointMsoEncodingEncodingEBCDICTurkishLatin5 = '\000\213\004\002',
	PowerpointMsoEncodingEncodingEBCDICGermany = '\000\213O1',
	PowerpointMsoEncodingEncodingEBCDICDenmarkNorway = '\000\213O5',
	PowerpointMsoEncodingEncodingEBCDICFinlandSweden = '\000\213O6',
	PowerpointMsoEncodingEncodingEBCDICItaly = '\000\213O8',
	PowerpointMsoEncodingEncodingEBCDICLatinAmericaSpain = '\000\213O<',
	PowerpointMsoEncodingEncodingEBCDICUnitedKingdom = '\000\213O=',
	PowerpointMsoEncodingEncodingEBCDICJapaneseKatakanaExtended = '\000\213OB',
	PowerpointMsoEncodingEncodingEBCDICFrance = '\000\213OI',
	PowerpointMsoEncodingEncodingEBCDICArabic = '\000\213O\304',
	PowerpointMsoEncodingEncodingEBCDICGreek = '\000\213O\307',
	PowerpointMsoEncodingEncodingEBCDICHebrew = '\000\213O\310',
	PowerpointMsoEncodingEncodingEBCDICKoreanExtended = '\000\213Qa',
	PowerpointMsoEncodingEncodingEBCDICThai = '\000\213Qf',
	PowerpointMsoEncodingEncodingEBCDICIcelandic = '\000\213Q\207',
	PowerpointMsoEncodingEncodingEBCDICTurkish = '\000\213Q\251',
	PowerpointMsoEncodingEncodingEBCDICRussian = '\000\213Q\220',
	PowerpointMsoEncodingEncodingEBCDICSerbianBulgarian = '\000\213R!',
	PowerpointMsoEncodingEncodingEBCDICJapaneseKatakanaExtendedAndJapanese = '\000\213\306\362',
	PowerpointMsoEncodingEncodingEBCDICUSCanadaAndJapanese = '\000\213\306\363',
	PowerpointMsoEncodingEncodingEBCDICExtendedAndKorean = '\000\213\306\365',
	PowerpointMsoEncodingEncodingEBCDICSimplifiedChineseExtendedAndSimplifiedChinese = '\000\213\306\367',
	PowerpointMsoEncodingEncodingEBCDICUSCanadaAndTraditionalChinese = '\000\213\306\371',
	PowerpointMsoEncodingEncodingEBCDICJapaneseLatinExtendedAndJapanese = '\000\213\306\373',
	PowerpointMsoEncodingEncodingOEMUnitedStates = '\000\213\001\265',
	PowerpointMsoEncodingEncodingOEMGreek = '\000\213\002\341',
	PowerpointMsoEncodingEncodingOEMBaltic = '\000\213\003\007',
	PowerpointMsoEncodingEncodingOEMMultilingualLatinI = '\000\213\003R',
	PowerpointMsoEncodingEncodingOEMMultilingualLatinII = '\000\213\003T',
	PowerpointMsoEncodingEncodingOEMCyrillic = '\000\213\003W',
	PowerpointMsoEncodingEncodingOEMTurkish = '\000\213\003Y',
	PowerpointMsoEncodingEncodingOEMPortuguese = '\000\213\003\\',
	PowerpointMsoEncodingEncodingOEMIcelandic = '\000\213\003]',
	PowerpointMsoEncodingEncodingOEMHebrew = '\000\213\003^',
	PowerpointMsoEncodingEncodingOEMCanadianFrench = '\000\213\003_',
	PowerpointMsoEncodingEncodingOEMArabic = '\000\213\003`',
	PowerpointMsoEncodingEncodingOEMNordic = '\000\213\003a',
	PowerpointMsoEncodingEncodingOEMCyrillicII = '\000\213\003b',
	PowerpointMsoEncodingEncodingOEMModernGreek = '\000\213\003e',
	PowerpointMsoEncodingEncodingEUCJapanese = '\000\213\312\334',
	PowerpointMsoEncodingEncodingEUCChineseSimplifiedChinese = '\000\213\312\340',
	PowerpointMsoEncodingEncodingEUCKorean = '\000\213\312\355',
	PowerpointMsoEncodingEncodingEUCTaiwaneseTraditionalChinese = '\000\213\312\356',
	PowerpointMsoEncodingEncodingDevanagari = '\000\213\336\252',
	PowerpointMsoEncodingEncodingBengali = '\000\213\336\253',
	PowerpointMsoEncodingEncodingTamil = '\000\213\336\254',
	PowerpointMsoEncodingEncodingTelugu = '\000\213\336\255',
	PowerpointMsoEncodingEncodingAssamese = '\000\213\336\256',
	PowerpointMsoEncodingEncodingOriya = '\000\213\336\257',
	PowerpointMsoEncodingEncodingKannada = '\000\213\336\260',
	PowerpointMsoEncodingEncodingMalayalam = '\000\213\336\261',
	PowerpointMsoEncodingEncodingGujarati = '\000\213\336\262',
	PowerpointMsoEncodingEncodingPunjabi = '\000\213\336\263',
	PowerpointMsoEncodingEncodingArabicASMO = '\000\213\002\304',
	PowerpointMsoEncodingEncodingArabicTransparentASMO = '\000\213\002\320',
	PowerpointMsoEncodingEncodingKoreanJohab = '\000\213\005Q',
	PowerpointMsoEncodingEncodingTaiwanCNS = '\000\213N ',
	PowerpointMsoEncodingEncodingTaiwanTCA = '\000\213N!',
	PowerpointMsoEncodingEncodingTaiwanEten = '\000\213N\"',
	PowerpointMsoEncodingEncodingTaiwanIBM5550 = '\000\213N#',
	PowerpointMsoEncodingEncodingTaiwanTeletext = '\000\213N$',
	PowerpointMsoEncodingEncodingTaiwanWang = '\000\213N%',
	PowerpointMsoEncodingEncodingIA5IRV = '\000\213N\211',
	PowerpointMsoEncodingEncodingIA5German = '\000\213N\212',
	PowerpointMsoEncodingEncodingIA5Swedish = '\000\213N\213',
	PowerpointMsoEncodingEncodingIA5Norwegian = '\000\213N\214',
	PowerpointMsoEncodingEncodingUSASCII = '\000\213N\237',
	PowerpointMsoEncodingEncodingT61 = '\000\213O%',
	PowerpointMsoEncodingEncodingISO6937NonspacingAccent = '\000\213O-',
	PowerpointMsoEncodingEncodingKOI8R = '\000\213Q\202',
	PowerpointMsoEncodingEncodingExtAlphaLowercase = '\000\213R#',
	PowerpointMsoEncodingEncodingKOI8U = '\000\213Uj',
	PowerpointMsoEncodingEncodingEuropa3 = '\000\213qI',
	PowerpointMsoEncodingEncodingHZGBSimplifiedChinese = '\000\213\316\310',
	PowerpointMsoEncodingEncodingUTF7 = '\000\213\375\350',
	PowerpointMsoEncodingEncodingUTF8 = '\000\213\375\351'
};
typedef enum PowerpointMsoEncoding PowerpointMsoEncoding;

enum PowerpointReset {
	PowerpointResetCommandBar = 'msCB',
	PowerpointResetCommandBarControl = 'mCBC'
};
typedef enum PowerpointReset PowerpointReset;

enum PowerpointEPPWindowState {
	PowerpointEPPWindowStateWindowNormal = '\000\311\000\001',
	PowerpointEPPWindowStateWindowMinimized = '\000\311\000\002'
};
typedef enum PowerpointEPPWindowState PowerpointEPPWindowState;

enum PowerpointEPPArrangeStyle {
	PowerpointEPPArrangeStyleArrangeTiled = '\000\321\000\001',
	PowerpointEPPArrangeStyleArrangeCascade = '\000\321\000\002'
};
typedef enum PowerpointEPPArrangeStyle PowerpointEPPArrangeStyle;

enum PowerpointEPPViewType {
	PowerpointEPPViewTypeSlideView = '\000\312\000\001',
	PowerpointEPPViewTypeMasterView = '\000\312\000\002',
	PowerpointEPPViewTypePageView = '\000\312\000\003',
	PowerpointEPPViewTypeHandoutMasterView = '\000\312\000\004',
	PowerpointEPPViewTypeNotesMasterView = '\000\312\000\005',
	PowerpointEPPViewTypeOutlineView = '\000\312\000\006',
	PowerpointEPPViewTypeSlideSorterView = '\000\312\000\007',
	PowerpointEPPViewTypeTitleMasterView = '\000\312\000\010',
	PowerpointEPPViewTypeNormalView = '\000\312\000\011',
	PowerpointEPPViewTypePrintPreview = '\000\312\000\012',
	PowerpointEPPViewTypeThumbnailView = '\000\312\000\013'
};
typedef enum PowerpointEPPViewType PowerpointEPPViewType;

enum PowerpointEPPColorSchemeIndex {
	PowerpointEPPColorSchemeIndexSchemeColorUnset = '\000\362\377\376',
	PowerpointEPPColorSchemeIndexNotASchemeColor = '\000\363\000\000',
	PowerpointEPPColorSchemeIndexBackgroundScheme = '\000\363\000\001',
	PowerpointEPPColorSchemeIndexForegroundScheme = '\000\363\000\002',
	PowerpointEPPColorSchemeIndexShadowScheme = '\000\363\000\003',
	PowerpointEPPColorSchemeIndexTitleScheme = '\000\363\000\004',
	PowerpointEPPColorSchemeIndexFillScheme = '\000\363\000\005',
	PowerpointEPPColorSchemeIndexAccent1Scheme = '\000\363\000\006',
	PowerpointEPPColorSchemeIndexAccent2Scheme = '\000\363\000\007',
	PowerpointEPPColorSchemeIndexAccent3Scheme = '\000\363\000\010'
};
typedef enum PowerpointEPPColorSchemeIndex PowerpointEPPColorSchemeIndex;

enum PowerpointEPPSlideSizeType {
	PowerpointEPPSlideSizeTypeSlideSizeOnScreen = '\000\313\000\001',
	PowerpointEPPSlideSizeTypeSlideSizeLetterPaper = '\000\313\000\002',
	PowerpointEPPSlideSizeTypeSlideSizeA4Paper = '\000\313\000\003',
	PowerpointEPPSlideSizeTypeSlideSize35MM = '\000\313\000\004',
	PowerpointEPPSlideSizeTypeSlideSizeOverhead = '\000\313\000\005',
	PowerpointEPPSlideSizeTypeSlideSizeBanner = '\000\313\000\006',
	PowerpointEPPSlideSizeTypeSlideSizeCustom = '\000\313\000\007',
	PowerpointEPPSlideSizeTypeSlideSizeLedgerPaper = '\000\313\000\010',
	PowerpointEPPSlideSizeTypeSlideSizeA3Paper = '\000\313\000\011',
	PowerpointEPPSlideSizeTypeSlideSizeB4ISOPaper = '\000\313\000\012',
	PowerpointEPPSlideSizeTypeSlideSizeB5ISOPaper = '\000\313\000\013',
	PowerpointEPPSlideSizeTypeSlideSizeB4JISPaper = '\000\313\000\014',
	PowerpointEPPSlideSizeTypeSlideSizeB5JISPaper = '\000\313\000\015',
	PowerpointEPPSlideSizeTypeSlideSizeHagakiCard = '\000\313\000\016',
	PowerpointEPPSlideSizeTypeSlideSizeOnScreen16x9 = '\000\313\000\017',
	PowerpointEPPSlideSizeTypeSlideSizeOnScreen16x10 = '\000\313\000\020'
};
typedef enum PowerpointEPPSlideSizeType PowerpointEPPSlideSizeType;

enum PowerpointEPPSaveAsFileType {
	PowerpointEPPSaveAsFileTypeSaveAsPresentation = '\000\314\000\001',
	PowerpointEPPSaveAsFileTypeSaveAsTemplate = '\000\314\000\005',
	PowerpointEPPSaveAsFileTypeSaveAsRTF = '\000\314\000\006',
	PowerpointEPPSaveAsFileTypeSaveAsShow = '\000\314\000\007',
	PowerpointEPPSaveAsFileTypeSaveAsAddIn = '\000\314\000\010',
	PowerpointEPPSaveAsFileTypeSaveAsDefault = '\000\314\000\012',
	PowerpointEPPSaveAsFileTypeSaveAsHTML = '\000\314\000\013',
	PowerpointEPPSaveAsFileTypeSaveAsMovie = '\000\314\000\014',
	PowerpointEPPSaveAsFileTypeSaveAsPackage = '\000\314\000\015',
	PowerpointEPPSaveAsFileTypeSaveAsPDF = '\000\314\000\016',
	PowerpointEPPSaveAsFileTypeSaveAsOpenXMLPresentation = '\000\314\000\017',
	PowerpointEPPSaveAsFileTypeSaveAsOpenXMLPresentationMacroEnabled = '\000\314\000\020',
	PowerpointEPPSaveAsFileTypeSaveAsOpenXMLShow = '\000\314\000\021',
	PowerpointEPPSaveAsFileTypeSaveAsOpenXMLShowMacroEnabled = '\000\314\000\022',
	PowerpointEPPSaveAsFileTypeSaveAsOpenXMLTemplate = '\000\314\000\023',
	PowerpointEPPSaveAsFileTypeSaveAsOpenXMLTemplateMacroEnabled = '\000\314\000\024',
	PowerpointEPPSaveAsFileTypeSaveAsOpenXMLTheme = '\000\314\000\025',
	PowerpointEPPSaveAsFileTypeSaveAsGIF = '\000\314\000\026',
	PowerpointEPPSaveAsFileTypeSaveAsJPG = '\000\314\000\027',
	PowerpointEPPSaveAsFileTypeSaveAsPNG = '\000\314\000\030',
	PowerpointEPPSaveAsFileTypeSaveAsBMP = '\000\314\000\031',
	PowerpointEPPSaveAsFileTypeSaveAsTIF = '\000\314\000\032'
};
typedef enum PowerpointEPPSaveAsFileType PowerpointEPPSaveAsFileType;

enum PowerpointPpTextStyleType {
	PowerpointPpTextStyleTypeTextStyleDefault = '\001*\000\001',
	PowerpointPpTextStyleTypeTextStyleTitle = '\001*\000\002',
	PowerpointPpTextStyleTypeTextStyleBody = '\001*\000\003'
};
typedef enum PowerpointPpTextStyleType PowerpointPpTextStyleType;

enum PowerpointEPPSlideLayout {
	PowerpointEPPSlideLayoutSlideLayoutUnset = '\000\314\377\376',
	PowerpointEPPSlideLayoutSlideLayoutTitleSlide = '\000\315\000\001',
	PowerpointEPPSlideLayoutSlideLayoutTextSlide = '\000\315\000\002',
	PowerpointEPPSlideLayoutSlideLayoutTwoColumnText = '\000\315\000\003',
	PowerpointEPPSlideLayoutSlideLayoutTable = '\000\315\000\004',
	PowerpointEPPSlideLayoutSlideLayoutTextAndChart = '\000\315\000\005',
	PowerpointEPPSlideLayoutSlideLayoutChartAndText = '\000\315\000\006',
	PowerpointEPPSlideLayoutSlideLayoutOrgchart = '\000\315\000\007',
	PowerpointEPPSlideLayoutSlideLayoutChart = '\000\315\000\010',
	PowerpointEPPSlideLayoutSlideLayoutTextAndClipart = '\000\315\000\011',
	PowerpointEPPSlideLayoutSlideLayoutClipartAndText = '\000\315\000\012',
	PowerpointEPPSlideLayoutSlideLayoutTitleOnly = '\000\315\000\013',
	PowerpointEPPSlideLayoutSlideLayoutBlank = '\000\315\000\014',
	PowerpointEPPSlideLayoutSlideLayoutTextAndObject = '\000\315\000\015',
	PowerpointEPPSlideLayoutSlideLayoutObjectAndText = '\000\315\000\016',
	PowerpointEPPSlideLayoutSlideLayoutLargeObject = '\000\315\000\017',
	PowerpointEPPSlideLayoutSlideLayoutObject = '\000\315\000\020',
	PowerpointEPPSlideLayoutSlideLayoutMediaClip = '\000\315\000\021',
	PowerpointEPPSlideLayoutSlideLayoutMediaClipAndText = '\000\315\000\022',
	PowerpointEPPSlideLayoutSlideLayoutObjectOverText = '\000\315\000\023',
	PowerpointEPPSlideLayoutSlideLayoutTextOverObject = '\000\315\000\024',
	PowerpointEPPSlideLayoutSlideLayoutTextAndTwoObjects = '\000\315\000\025',
	PowerpointEPPSlideLayoutSlideLayoutTwoObjectsAndText = '\000\315\000\026',
	PowerpointEPPSlideLayoutSlideLayoutTwoObjectsOverText = '\000\315\000\027',
	PowerpointEPPSlideLayoutSlideLayoutFourObjects = '\000\315\000\030',
	PowerpointEPPSlideLayoutSlideLayoutVerticalText = '\000\315\000\031',
	PowerpointEPPSlideLayoutSlideLayoutClipartAndVerticalText = '\000\315\000\032',
	PowerpointEPPSlideLayoutSlideLayoutVerticalTitleAndText = '\000\315\000\033',
	PowerpointEPPSlideLayoutSlideLayoutVerticalTitleAndTextOverChart = '\000\315\000\034',
	PowerpointEPPSlideLayoutSlideLayoutTwoObjects = '\000\315\000\035',
	PowerpointEPPSlideLayoutSlideLayoutObjectAndTwoObjects = '\000\315\000\036',
	PowerpointEPPSlideLayoutSlideLayoutTwoObjectsAndObject = '\000\315\000\037',
	PowerpointEPPSlideLayoutSlideLayoutCustom = '\000\315\000 ',
	PowerpointEPPSlideLayoutSlideLayoutSectionHeader = '\000\315\000!',
	PowerpointEPPSlideLayoutSlideLayoutComparison = '\000\315\000\"',
	PowerpointEPPSlideLayoutSlideLayoutContentWithCaption = '\000\315\000#',
	PowerpointEPPSlideLayoutSlideLayoutPictureWithCaption = '\000\315\000$'
};
typedef enum PowerpointEPPSlideLayout PowerpointEPPSlideLayout;

enum PowerpointEPPEntryEffect {
	PowerpointEPPEntryEffectEntryEffectAirplaneLeft = '\000\366\017n',
	PowerpointEPPEntryEffectEntryEffectAirplaneRight = '\000\366\017o',
	PowerpointEPPEntryEffectEntryEffectAppear = '\000\366\017\004',
	PowerpointEPPEntryEffectEntryEffectBlindsHorizontal = '\000\366\003\001',
	PowerpointEPPEntryEffectEntryEffectBlindsVertical = '\000\366\003\002',
	PowerpointEPPEntryEffectEntryEffectBoxDown = '\000\366\017U',
	PowerpointEPPEntryEffectEntryEffectBoxIn = '\000\366\014\002',
	PowerpointEPPEntryEffectEntryEffectBoxLeft = '\000\366\017R',
	PowerpointEPPEntryEffectEntryEffectBoxOut = '\000\366\014\001',
	PowerpointEPPEntryEffectEntryEffectBoxRight = '\000\366\017T',
	PowerpointEPPEntryEffectEntryEffectBoxUp = '\000\366\017S',
	PowerpointEPPEntryEffectEntryEffectCheckerboardAcross = '\000\366\004\001',
	PowerpointEPPEntryEffectEntryEffectCheckerboardDown = '\000\366\004\002',
	PowerpointEPPEntryEffectEntryEffectCircle = '\000\366\017\005',
	PowerpointEPPEntryEffectEntryEffectCollapseAcross = '\000\366\015\027',
	PowerpointEPPEntryEffectEntryEffectCollapseBottom = '\000\366\015\033',
	PowerpointEPPEntryEffectEntryEffectCollapseLeft = '\000\366\015\030',
	PowerpointEPPEntryEffectEntryEffectCollapseRight = '\000\366\015\032',
	PowerpointEPPEntryEffectEntryEffectCollapseUp = '\000\366\015\031',
	PowerpointEPPEntryEffectEntryEffectCrush = '\000\366\017g',
	PowerpointEPPEntryEffectEntryEffectCombHorizontal = '\000\366\017\007',
	PowerpointEPPEntryEffectEntryEffectCombVertical = '\000\366\017\010',
	PowerpointEPPEntryEffectEntryEffectConveyorLeft = '\000\366\017*',
	PowerpointEPPEntryEffectEntryEffectConveyorRight = '\000\366\017+',
	PowerpointEPPEntryEffectEntryEffectCoverDown = '\000\366\005\004',
	PowerpointEPPEntryEffectEntryEffectCoverLeftDown = '\000\366\005\007',
	PowerpointEPPEntryEffectEntryEffectCoverLeftUp = '\000\366\005\005',
	PowerpointEPPEntryEffectEntryEffectCoverLeft = '\000\366\005\001',
	PowerpointEPPEntryEffectEntryEffectCoverRightDown = '\000\366\005\010',
	PowerpointEPPEntryEffectEntryEffectCoverRightUp = '\000\366\005\006',
	PowerpointEPPEntryEffectEntryEffectCoverRight = '\000\366\005\003',
	PowerpointEPPEntryEffectEntryEffectCoverUp = '\000\366\005\002',
	PowerpointEPPEntryEffectEntryEffectCrawlFromDown = '\000\366\015\020',
	PowerpointEPPEntryEffectEntryEffectCrawlFromLeft = '\000\366\015\015',
	PowerpointEPPEntryEffectEntryEffectCrawlFromRight = '\000\366\015\017',
	PowerpointEPPEntryEffectEntryEffectCrawlFromUp = '\000\366\015\016',
	PowerpointEPPEntryEffectEntryEffectCubeDown = '\000\366\017M',
	PowerpointEPPEntryEffectEntryEffectCubeLeft = '\000\366\017J',
	PowerpointEPPEntryEffectEntryEffectCubeRight = '\000\366\017K',
	PowerpointEPPEntryEffectEntryEffectCubeUp = '\000\366\017L',
	PowerpointEPPEntryEffectEntryEffectCurtains = '\000\366\017b',
	PowerpointEPPEntryEffectEntryEffectCutBlack = '\000\366\001\002',
	PowerpointEPPEntryEffectEntryEffectCut = '\000\366\001\001',
	PowerpointEPPEntryEffectEntryEffectDiamond = '\000\366\017\006',
	PowerpointEPPEntryEffectEntryEffectDissolve = '\000\366\006\001',
	PowerpointEPPEntryEffectEntryEffectDoorsHorizontal = '\000\366\017-',
	PowerpointEPPEntryEffectEntryEffectDoorsVertical = '\000\366\017,',
	PowerpointEPPEntryEffectEntryEffectDrapeLeft = '\000\366\017`',
	PowerpointEPPEntryEffectEntryEffectDrapeRight = '\000\366\017a',
	PowerpointEPPEntryEffectEntryEffectFadeBlack = '\000\366\007\001',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromBottomLeft = '\000\366\015$',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromBottomRight = '\000\366\015%',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromBottom = '\000\366\015!',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromLeft = '\000\366\015\036',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromRight = '\000\366\015 ',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromTopLeft = '\000\366\015\"',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromTopRight = '\000\366\015#',
	PowerpointEPPEntryEffectEntryEffectFadeFlyFromTop = '\000\366\015\037',
	PowerpointEPPEntryEffectEntryEffectFadeSmoothly = '\000\366\017\011',
	PowerpointEPPEntryEffectEntryEffectFade = '\000\366\017\011',
	PowerpointEPPEntryEffectEntryEffectFallOverLeft = '\000\366\017^',
	PowerpointEPPEntryEffectEntryEffectFallOverRight = '\000\366\017_',
	PowerpointEPPEntryEffectEntryEffectFerrisWheelLeft = '\000\366\017;',
	PowerpointEPPEntryEffectEntryEffectFerrisWheelRight = '\000\366\017<',
	PowerpointEPPEntryEffectEntryEffectFlashOnceFast = '\000\366\017\001',
	PowerpointEPPEntryEffectEntryEffectFlashOnceMedium = '\000\366\017\002',
	PowerpointEPPEntryEffectEntryEffectFlashOnceSlow = '\000\366\017\003',
	PowerpointEPPEntryEffectEntryEffectFlashbulb = '\000\366\017E',
	PowerpointEPPEntryEffectEntryEffectFlipDown = '\000\366\017D',
	PowerpointEPPEntryEffectEntryEffectFlipLeft = '\000\366\017A',
	PowerpointEPPEntryEffectEntryEffectFlipRight = '\000\366\017B',
	PowerpointEPPEntryEffectEntryEffectFlipUp = '\000\366\017C',
	PowerpointEPPEntryEffectEntryEffectFlyFromBottomLeft = '\000\366\015\007',
	PowerpointEPPEntryEffectEntryEffectFlyFromBottomRight = '\000\366\015\010',
	PowerpointEPPEntryEffectEntryEffectFlyFromBottom = '\000\366\015\004',
	PowerpointEPPEntryEffectEntryEffectFlyFromLeft = '\000\366\015\001',
	PowerpointEPPEntryEffectEntryEffectFlyFromRight = '\000\366\015\003',
	PowerpointEPPEntryEffectEntryEffectFlyFromTopLeft = '\000\366\015\005',
	PowerpointEPPEntryEffectEntryEffectFlyFromTopRight = '\000\366\015\006',
	PowerpointEPPEntryEffectEntryEffectFlyFromTop = '\000\366\015\002',
	PowerpointEPPEntryEffectEntryEffectFlyThroughInBounce = '\000\366\0174',
	PowerpointEPPEntryEffectEntryEffectFlyThroughIn = '\000\366\0172',
	PowerpointEPPEntryEffectEntryEffectFlyThroughOutBounce = '\000\366\0175',
	PowerpointEPPEntryEffectEntryEffectFlyThroughOut = '\000\366\0173',
	PowerpointEPPEntryEffectEntryEffectFracture = '\000\366\017f',
	PowerpointEPPEntryEffectEntryEffectGalleryLeft = '\000\366\017(',
	PowerpointEPPEntryEffectEntryEffectGalleryRight = '\000\366\017)',
	PowerpointEPPEntryEffectEntryEffectGlitterDiamondDown = '\000\366\017#',
	PowerpointEPPEntryEffectEntryEffectGlitterDiamondLeft = '\000\366\017 ',
	PowerpointEPPEntryEffectEntryEffectGlitterDiamondRight = '\000\366\017\"',
	PowerpointEPPEntryEffectEntryEffectGlitterDiamondUp = '\000\366\017!',
	PowerpointEPPEntryEffectEntryEffectGlitterHexagonDown = '\000\366\017\'',
	PowerpointEPPEntryEffectEntryEffectGlitterHexagonLeft = '\000\366\017$',
	PowerpointEPPEntryEffectEntryEffectGlitterHexagonRight = '\000\366\017&',
	PowerpointEPPEntryEffectEntryEffectGlitterHexagonUp = '\000\366\017%',
	PowerpointEPPEntryEffectEntryEffectHoneycomb = '\000\366\017:',
	PowerpointEPPEntryEffectEntryEffectMorphByObject = '\000\366\017r',
	PowerpointEPPEntryEffectEntryEffectMorphByWord = '\000\366\017s',
	PowerpointEPPEntryEffectEntryEffectMorphByChar = '\000\366\017t',
	PowerpointEPPEntryEffectEntryEffectNewsFlash = '\000\366\017\012',
	PowerpointEPPEntryEffectEntryEffectNone = '\000\366\000\000',
	PowerpointEPPEntryEffectEntryEffectOrbitDown = '\000\366\017Y',
	PowerpointEPPEntryEffectEntryEffectOrbitLeft = '\000\366\017V',
	PowerpointEPPEntryEffectEntryEffectOrbitRight = '\000\366\017X',
	PowerpointEPPEntryEffectEntryEffectOrbitUp = '\000\366\017W',
	PowerpointEPPEntryEffectEntryEffectOrigamiLeft = '\000\366\017p',
	PowerpointEPPEntryEffectEntryEffectOrigamiRight = '\000\366\017q',
	PowerpointEPPEntryEffectEntryEffectPageCurlDoubleLeft = '\000\366\017l',
	PowerpointEPPEntryEffectEntryEffectPageCurlDoubleRight = '\000\366\017m',
	PowerpointEPPEntryEffectEntryEffectPageCurlSingleLeft = '\000\366\017j',
	PowerpointEPPEntryEffectEntryEffectPageCurlSingleRight = '\000\366\017k',
	PowerpointEPPEntryEffectEntryEffectPanDown = '\000\366\017]',
	PowerpointEPPEntryEffectEntryEffectPanLeft = '\000\366\017Z',
	PowerpointEPPEntryEffectEntryEffectPanRight = '\000\366\017\\',
	PowerpointEPPEntryEffectEntryEffectPanUp = '\000\366\017[',
	PowerpointEPPEntryEffectEntryEffectPeekFromDown = '\000\366\015\012',
	PowerpointEPPEntryEffectEntryEffectPeekFromLeft = '\000\366\015\011',
	PowerpointEPPEntryEffectEntryEffectPeekFromRight = '\000\366\015\013',
	PowerpointEPPEntryEffectEntryEffectPeekFromUp = '\000\366\015\014',
	PowerpointEPPEntryEffectEntryEffectPeelOffLeft = '\000\366\017h',
	PowerpointEPPEntryEffectEntryEffectPeelOffRight = '\000\366\017i',
	PowerpointEPPEntryEffectEntryEffectPlus = '\000\366\017\013',
	PowerpointEPPEntryEffectEntryEffectPrestige = '\000\366\017e',
	PowerpointEPPEntryEffectEntryEffectPushDown = '\000\366\017\014',
	PowerpointEPPEntryEffectEntryEffectPushLeft = '\000\366\017\015',
	PowerpointEPPEntryEffectEntryEffectPushRight = '\000\366\017\016',
	PowerpointEPPEntryEffectEntryEffectPushUp = '\000\366\017\017',
	PowerpointEPPEntryEffectEntryEffectRandomBarsHorizontal = '\000\366\011\001',
	PowerpointEPPEntryEffectEntryEffectRandomBarsVertical = '\000\366\011\002',
	PowerpointEPPEntryEffectEntryEffectRandom = '\000\366\002\001',
	PowerpointEPPEntryEffectEntryEffectRevealBlackLeft = '\000\366\0178',
	PowerpointEPPEntryEffectEntryEffectRevealBlackRight = '\000\366\0179',
	PowerpointEPPEntryEffectEntryEffectRevealSmoothLeft = '\000\366\0176',
	PowerpointEPPEntryEffectEntryEffectRevealSmoothRight = '\000\366\0177',
	PowerpointEPPEntryEffectEntryEffectRippleCenter = '\000\366\017\033',
	PowerpointEPPEntryEffectEntryEffectRippleLeftDown = '\000\366\017\036',
	PowerpointEPPEntryEffectEntryEffectRippleLeftUp = '\000\366\017\035',
	PowerpointEPPEntryEffectEntryEffectRippleRightDown = '\000\366\017\037',
	PowerpointEPPEntryEffectEntryEffectRippleRightUp = '\000\366\017\034',
	PowerpointEPPEntryEffectEntryEffectRotateDown = '\000\366\017Q',
	PowerpointEPPEntryEffectEntryEffectRotateLeft = '\000\366\017N',
	PowerpointEPPEntryEffectEntryEffectRotateRight = '\000\366\017P',
	PowerpointEPPEntryEffectEntryEffectRotateUp = '\000\366\017O',
	PowerpointEPPEntryEffectEntryEffectShredRectangleIn = '\000\366\017H',
	PowerpointEPPEntryEffectEntryEffectShredRectangleOut = '\000\366\017I',
	PowerpointEPPEntryEffectEntryEffectShredStripsIn = '\000\366\017F',
	PowerpointEPPEntryEffectEntryEffectShredStripsOut = '\000\366\017G',
	PowerpointEPPEntryEffectEntryEffectSpinner = '\000\366\017\012',
	PowerpointEPPEntryEffectEntryEffectSpiral = '\000\366\015\035',
	PowerpointEPPEntryEffectEntryEffectSplitHorizontalIn = '\000\366\016\002',
	PowerpointEPPEntryEffectEntryEffectSplitHorizontalOut = '\000\366\016\001',
	PowerpointEPPEntryEffectEntryEffectSplitVerticalIn = '\000\366\016\004',
	PowerpointEPPEntryEffectEntryEffectSplitVerticalOut = '\000\366\016\003',
	PowerpointEPPEntryEffectEntryEffectStretchAcross = '\000\366\015\027',
	PowerpointEPPEntryEffectEntryEffectStretchDown = '\000\366\015\033',
	PowerpointEPPEntryEffectEntryEffectStretchLeft = '\000\366\015\030',
	PowerpointEPPEntryEffectEntryEffectStretchRight = '\000\366\015\032',
	PowerpointEPPEntryEffectEntryEffectStretchUp = '\000\366\015\031',
	PowerpointEPPEntryEffectEntryEffectStripsDownLeft = '\000\366\012\003',
	PowerpointEPPEntryEffectEntryEffectStripsDownRight = '\000\366\012\004',
	PowerpointEPPEntryEffectEntryEffectStripsLeftDown = '\000\366\012\007',
	PowerpointEPPEntryEffectEntryEffectStripsLeftUp = '\000\366\012\005',
	PowerpointEPPEntryEffectEntryEffectStripsRightDown = '\000\366\012\010',
	PowerpointEPPEntryEffectEntryEffectStripsRightUp = '\000\366\012\006',
	PowerpointEPPEntryEffectEntryEffectStripsUpLeft = '\000\366\012\001',
	PowerpointEPPEntryEffectEntryEffectStripsUpRight = '\000\366\012\002',
	PowerpointEPPEntryEffectEntryEffectSwitchDown = '\000\366\017@',
	PowerpointEPPEntryEffectEntryEffectSwitchLeft = '\000\366\017=',
	PowerpointEPPEntryEffectEntryEffectSwitchRight = '\000\366\017\?',
	PowerpointEPPEntryEffectEntryEffectSwitchUp = '\000\366\017>',
	PowerpointEPPEntryEffectEntryEffectSwivel = '\000\366\015\034',
	PowerpointEPPEntryEffectEntryEffectUncoverDown = '\000\366\010\004',
	PowerpointEPPEntryEffectEntryEffectUncoverLeftDown = '\000\366\010\007',
	PowerpointEPPEntryEffectEntryEffectUncoverLeftUp = '\000\366\010\005',
	PowerpointEPPEntryEffectEntryEffectUncoverLeft = '\000\366\010\001',
	PowerpointEPPEntryEffectEntryEffectUncoverRightDown = '\000\366\010\010',
	PowerpointEPPEntryEffectEntryEffectUncoverRightUp = '\000\366\010\006',
	PowerpointEPPEntryEffectEntryEffectUncoverRight = '\000\366\010\003',
	PowerpointEPPEntryEffectEntryEffectUncoverUp = '\000\366\010\002',
	PowerpointEPPEntryEffectEntryEffectUnset = '\000\365\377\376',
	PowerpointEPPEntryEffectEntryEffectVortexDown = '\000\366\017\032',
	PowerpointEPPEntryEffectEntryEffectVortexLeft = '\000\366\017\027',
	PowerpointEPPEntryEffectEntryEffectVortexRight = '\000\366\017\031',
	PowerpointEPPEntryEffectEntryEffectVortexUp = '\000\366\017\030',
	PowerpointEPPEntryEffectEntryEffectWarpIn = '\000\366\0170',
	PowerpointEPPEntryEffectEntryEffectWarpOut = '\000\366\0171',
	PowerpointEPPEntryEffectEntryEffectWedge = '\000\366\017\020',
	PowerpointEPPEntryEffectEntryEffectWheel1Spoke = '\000\366\017\021',
	PowerpointEPPEntryEffectEntryEffectWheel2Spokes = '\000\366\017\022',
	PowerpointEPPEntryEffectEntryEffectWheel3Spokes = '\000\366\017\023',
	PowerpointEPPEntryEffectEntryEffectWheel4Spokes = '\000\366\017\024',
	PowerpointEPPEntryEffectEntryEffectWheel8Spokes = '\000\366\017\025',
	PowerpointEPPEntryEffectEntryEffectWheelReverse1Spoke = '\000\366\017\026',
	PowerpointEPPEntryEffectEntryEffectWindLeft = '\000\366\017c',
	PowerpointEPPEntryEffectEntryEffectWindRight = '\000\366\017d',
	PowerpointEPPEntryEffectEntryEffectWindowHorizontal = '\000\366\017/',
	PowerpointEPPEntryEffectEntryEffectWindowVertical = '\000\366\017.',
	PowerpointEPPEntryEffectEntryEffectWipeDown = '\000\366\013\004',
	PowerpointEPPEntryEffectEntryEffectWipeLeft = '\000\366\013\001',
	PowerpointEPPEntryEffectEntryEffectWipeRight = '\000\366\013\003',
	PowerpointEPPEntryEffectEntryEffectWipeUp = '\000\366\013\002',
	PowerpointEPPEntryEffectEntryEffectZoomBottom = '\000\366\015\026',
	PowerpointEPPEntryEffectEntryEffectZoomCenter = '\000\366\015\025',
	PowerpointEPPEntryEffectEntryEffectZoomInSlightly = '\000\366\015\022',
	PowerpointEPPEntryEffectEntryEffectZoomIn = '\000\366\015\021',
	PowerpointEPPEntryEffectEntryEffectZoomOutSlightly = '\000\366\015\024',
	PowerpointEPPEntryEffectEntryEffectZoomOut = '\000\366\015\023'
};
typedef enum PowerpointEPPEntryEffect PowerpointEPPEntryEffect;

enum PowerpointEPPTextLevelEffect {
	PowerpointEPPTextLevelEffectAnimationLevelUnset = '\000\337\377\376',
	PowerpointEPPTextLevelEffectAnimateLevelNone = '\000\340\000\000',
	PowerpointEPPTextLevelEffectAnimateLevelFirstLevel = '\000\340\000\001',
	PowerpointEPPTextLevelEffectAnimateLevelSecondLevel = '\000\340\000\002',
	PowerpointEPPTextLevelEffectAnimateLevelThirdLevel = '\000\340\000\003',
	PowerpointEPPTextLevelEffectAnimateLevelFourthLevel = '\000\340\000\004',
	PowerpointEPPTextLevelEffectAnimateLevelFifthLevel = '\000\340\000\005',
	PowerpointEPPTextLevelEffectAnimateLevelAllLevels = '\000\340\000\020'
};
typedef enum PowerpointEPPTextLevelEffect PowerpointEPPTextLevelEffect;

enum PowerpointEPPTextUnitEffect {
	PowerpointEPPTextUnitEffectAnimationUnitUnset = '\000\340\377\376',
	PowerpointEPPTextUnitEffectTextUnitEffectByParagraph = '\000\341\000\000',
	PowerpointEPPTextUnitEffectTextUnitEffectByWord = '\000\341\000\001',
	PowerpointEPPTextUnitEffectTextUnitEffectByCharacter = '\000\341\000\002'
};
typedef enum PowerpointEPPTextUnitEffect PowerpointEPPTextUnitEffect;

enum PowerpointEPPChartUnitEffect {
	PowerpointEPPChartUnitEffectAnimationChartUnset = '\000\341\377\376',
	PowerpointEPPChartUnitEffectChartUnitEffectBySeries = '\000\342\000\001',
	PowerpointEPPChartUnitEffectChartUnitEffectByCategory = '\000\342\000\002',
	PowerpointEPPChartUnitEffectChartUnitEffectBySeriesElement = '\000\342\000\003'
};
typedef enum PowerpointEPPChartUnitEffect PowerpointEPPChartUnitEffect;

enum PowerpointEPPAfterEffect {
	PowerpointEPPAfterEffectAfterEffectUnset = '\000\363\377\376',
	PowerpointEPPAfterEffectAfterEffectNone = '\000\364\000\000',
	PowerpointEPPAfterEffectAfterEffectHide = '\000\364\000\001',
	PowerpointEPPAfterEffectAfterEffectDim = '\000\364\000\002'
};
typedef enum PowerpointEPPAfterEffect PowerpointEPPAfterEffect;

enum PowerpointEPPAdvanceMode {
	PowerpointEPPAdvanceModeAdvanceModeUnset = '\000\361\377\376',
	PowerpointEPPAdvanceModeAdvanceModeOnClick = '\000\362\000\001'
};
typedef enum PowerpointEPPAdvanceMode PowerpointEPPAdvanceMode;

enum PowerpointEPPSoundEffectType {
	PowerpointEPPSoundEffectTypeSoundEffectUnset = '\000\331\377\376',
	PowerpointEPPSoundEffectTypeSoundEffectNone = '\000\332\000\000',
	PowerpointEPPSoundEffectTypeSoundEffectStopPrevious = '\000\332\000\001',
	PowerpointEPPSoundEffectTypeSoundEffectFile = '\000\332\000\002'
};
typedef enum PowerpointEPPSoundEffectType PowerpointEPPSoundEffectType;

enum PowerpointEPPUpdateOption {
	PowerpointEPPUpdateOptionUpdateOptionUnset = '\000\336\377\376',
	PowerpointEPPUpdateOptionUpdateOptionManual = '\000\337\000\001'
};
typedef enum PowerpointEPPUpdateOption PowerpointEPPUpdateOption;

enum PowerpointEPPChangeCase {
	PowerpointEPPChangeCasePpCaseSentence = '\000\344\000\001',
	PowerpointEPPChangeCasePpCaseLower = '\000\344\000\002',
	PowerpointEPPChangeCasePpCaseUpper = '\000\344\000\003',
	PowerpointEPPChangeCasePpCaseTitle = '\000\344\000\004'
};
typedef enum PowerpointEPPChangeCase PowerpointEPPChangeCase;

enum PowerpointEPPDialogMode {
	PowerpointEPPDialogModeDialogModeUnset = '\000\357\377\376',
	PowerpointEPPDialogModeDialogModeModless = '\000\360\000\000',
	PowerpointEPPDialogModeDialogModeModal = '\000\360\000\001'
};
typedef enum PowerpointEPPDialogMode PowerpointEPPDialogMode;

enum PowerpointEPPDialogStyle {
	PowerpointEPPDialogStyleDialogStyleUnset = '\000\360\377\376',
	PowerpointEPPDialogStyleDialogStyleStandard = '\000\361\000\001'
};
typedef enum PowerpointEPPDialogStyle PowerpointEPPDialogStyle;

enum PowerpointEPPSlideShowPointerType {
	PowerpointEPPSlideShowPointerTypeSlideShowPointerNone = '\000\322\000\000',
	PowerpointEPPSlideShowPointerTypeSlideShowPointerArrow = '\000\322\000\001',
	PowerpointEPPSlideShowPointerTypeSlideShowPointerPen = '\000\322\000\002',
	PowerpointEPPSlideShowPointerTypeSlideShowPointerAlwaysHidden = '\000\322\000\003'
};
typedef enum PowerpointEPPSlideShowPointerType PowerpointEPPSlideShowPointerType;

enum PowerpointEPPSlideShowState {
	PowerpointEPPSlideShowStateSlideShowStateRunning = '\000\323\000\001',
	PowerpointEPPSlideShowStateSlideShowStatePaused = '\000\323\000\002',
	PowerpointEPPSlideShowStateSlideShowStateBlackScreen = '\000\323\000\003',
	PowerpointEPPSlideShowStateSlideShowStateWhiteScreen = '\000\323\000\004',
	PowerpointEPPSlideShowStateSlideShowStateDone = '\000\323\000\005'
};
typedef enum PowerpointEPPSlideShowState PowerpointEPPSlideShowState;

enum PowerpointEPPPlayerState {
	PowerpointEPPPlayerStatePlayerStatePlaying = '\000\365\000\000',
	PowerpointEPPPlayerStatePlayerStatePaused = '\000\365\000\001',
	PowerpointEPPPlayerStatePlayerStateStopped = '\000\365\000\002',
	PowerpointEPPPlayerStatePlayerStateNotReady = '\000\365\000\003'
};
typedef enum PowerpointEPPPlayerState PowerpointEPPPlayerState;

enum PowerpointEPPSlideShowAdvanceMode {
	PowerpointEPPSlideShowAdvanceModeSlideShowAdvanceManualAdvance = '\000\324\000\001',
	PowerpointEPPSlideShowAdvanceModeSlideShowAdvanceUseSlideTimings = '\000\324\000\002'
};
typedef enum PowerpointEPPSlideShowAdvanceMode PowerpointEPPSlideShowAdvanceMode;

enum PowerpointEPPPrintOutputType {
	PowerpointEPPPrintOutputTypePrintSlides = '\000\330\000\001',
	PowerpointEPPPrintOutputTypePrintTwoSlideHandouts = '\000\330\000\002',
	PowerpointEPPPrintOutputTypePrintThreeSlideHandouts = '\000\330\000\003',
	PowerpointEPPPrintOutputTypePrintSixSlideHandouts = '\000\330\000\004',
	PowerpointEPPPrintOutputTypePrintNotesPages = '\000\330\000\005',
	PowerpointEPPPrintOutputTypePrintOutline = '\000\330\000\006',
	PowerpointEPPPrintOutputTypePrintFourSlideHandouts = '\000\330\000\007',
	PowerpointEPPPrintOutputTypePrintNineSlideHandouts = '\000\330\000\010'
};
typedef enum PowerpointEPPPrintOutputType PowerpointEPPPrintOutputType;

enum PowerpointEPPPrintColorType {
	PowerpointEPPPrintColorTypePrintColor = '\000\327\000\001',
	PowerpointEPPPrintColorTypePrintBlackAndWhite = '\000\327\000\002'
};
typedef enum PowerpointEPPPrintColorType PowerpointEPPPrintColorType;

enum PowerpointEPPSelectionType {
	PowerpointEPPSelectionTypeSelectionTypeNone = '\000\316\000\000',
	PowerpointEPPSelectionTypeSelectionTypeSlides = '\000\316\000\001',
	PowerpointEPPSelectionTypeSelectionTypeShapes = '\000\316\000\002',
	PowerpointEPPSelectionTypeSelectionTypeText = '\000\316\000\003'
};
typedef enum PowerpointEPPSelectionType PowerpointEPPSelectionType;

enum PowerpointEPPDirection {
	PowerpointEPPDirectionDirectionUnset = '\000\352\377\376',
	PowerpointEPPDirectionLeftToRight = '\000\353\000\001'
};
typedef enum PowerpointEPPDirection PowerpointEPPDirection;

enum PowerpointEPPDateTimeFormat {
	PowerpointEPPDateTimeFormatUnset = '\000\342\377\376',
	PowerpointEPPDateTimeFormatMdyy = '\000\343\000\001',
	PowerpointEPPDateTimeFormatDdddMMMMddyyyy = '\000\343\000\002',
	PowerpointEPPDateTimeFormatMMMMyyyy = '\000\343\000\003',
	PowerpointEPPDateTimeFormatMMMMdyyyy = '\000\343\000\004',
	PowerpointEPPDateTimeFormatMMMyy = '\000\343\000\005',
	PowerpointEPPDateTimeFormatMMMMyy = '\000\343\000\006',
	PowerpointEPPDateTimeFormatMMyy = '\000\343\000\007',
	PowerpointEPPDateTimeFormatMMddyyHmm = '\000\343\000\010',
	PowerpointEPPDateTimeFormatMddyyhmmAMPM = '\000\343\000\011',
	PowerpointEPPDateTimeFormatHmm = '\000\343\000\012',
	PowerpointEPPDateTimeFormatHmmss = '\000\343\000\013',
	PowerpointEPPDateTimeFormatHmmAMPM = '\000\343\000\014',
	PowerpointEPPDateTimeFormatHmmssAMPM = '\000\343\000\015'
};
typedef enum PowerpointEPPDateTimeFormat PowerpointEPPDateTimeFormat;

enum PowerpointEPPTransitionSpeed {
	PowerpointEPPTransitionSpeedTransitionSpeedUnset = '\000\330\377\376',
	PowerpointEPPTransitionSpeedTransistionSpeedSlow = '\000\331\000\001',
	PowerpointEPPTransitionSpeedTransistionSpeedMedium = '\000\331\000\002'
};
typedef enum PowerpointEPPTransitionSpeed PowerpointEPPTransitionSpeed;

enum PowerpointEPPMouseActivation {
	PowerpointEPPMouseActivationMouseActivationMouseClick = '\000\372\000\001',
	PowerpointEPPMouseActivationMouseActivationMouseOver = '\000\372\000\002'
};
typedef enum PowerpointEPPMouseActivation PowerpointEPPMouseActivation;

enum PowerpointEPPActionType {
	PowerpointEPPActionTypeActionTypeUnset = '\000\345\377\376',
	PowerpointEPPActionTypeActionTypeNone = '\000\346\000\000',
	PowerpointEPPActionTypeActionTypeNextSlide = '\000\346\000\001',
	PowerpointEPPActionTypeActionTypePreviousSlide = '\000\346\000\002',
	PowerpointEPPActionTypeActionTypeFirstSlide = '\000\346\000\003',
	PowerpointEPPActionTypeActionTypeLastSlide = '\000\346\000\004',
	PowerpointEPPActionTypeActionTypeLastSlideViewed = '\000\346\000\005',
	PowerpointEPPActionTypeActionTypeEndShow = '\000\346\000\006',
	PowerpointEPPActionTypeActionTypeHyperlinkAction = '\000\346\000\007',
	PowerpointEPPActionTypeActionTypeRunMacro = '\000\346\000\010',
	PowerpointEPPActionTypeActionTypeRunProgram = '\000\346\000\011',
	PowerpointEPPActionTypeActionTypeNamedSlideshowAction = '\000\346\000\012',
	PowerpointEPPActionTypeActionTypeOLEVerb = '\000\346\000\013'
};
typedef enum PowerpointEPPActionType PowerpointEPPActionType;

enum PowerpointEPPPlaceholderType {
	PowerpointEPPPlaceholderTypePlaceholderTypeUnset = '\000\332\377\376',
	PowerpointEPPPlaceholderTypePlaceholderTypeTitlePlaceholder = '\000\333\000\001',
	PowerpointEPPPlaceholderTypePlaceholderTypeBodyPlaceholder = '\000\333\000\002',
	PowerpointEPPPlaceholderTypePlaceholderTypeCenterTitlePlaceholder = '\000\333\000\003',
	PowerpointEPPPlaceholderTypePlaceholderTypeSubtitlePlaceholder = '\000\333\000\004',
	PowerpointEPPPlaceholderTypePlaceholderTypeVerticalTitlePlaceholder = '\000\333\000\005',
	PowerpointEPPPlaceholderTypePlaceholderTypeVerticalBodyPlaceholder = '\000\333\000\006',
	PowerpointEPPPlaceholderTypePlaceholderTypeObjectPlaceholder = '\000\333\000\007',
	PowerpointEPPPlaceholderTypePlaceholderTypeChartPlaceholder = '\000\333\000\010',
	PowerpointEPPPlaceholderTypePlaceholderTypeBitmapPlaceholder = '\000\333\000\011',
	PowerpointEPPPlaceholderTypePlaceholderTypeMediaClipPlaceholder = '\000\333\000\012',
	PowerpointEPPPlaceholderTypePlaceholderTypeOrgChartPlaceholder = '\000\333\000\013',
	PowerpointEPPPlaceholderTypePlaceholderTypeTablePlaceholder = '\000\333\000\014',
	PowerpointEPPPlaceholderTypePlaceholderTypeSlideNumberPlaceholder = '\000\333\000\015',
	PowerpointEPPPlaceholderTypePlaceholderTypeHeaderPlaceholder = '\000\333\000\016',
	PowerpointEPPPlaceholderTypePlaceholderTypeFooterPlaceholder = '\000\333\000\017',
	PowerpointEPPPlaceholderTypePlaceholderTypeDatePlaceholder = '\000\333\000\020',
	PowerpointEPPPlaceholderTypePlaceholderTypeVerticalObjectPlaceholder = '\000\333\000\021',
	PowerpointEPPPlaceholderTypePlaceholderTypePicturePlaceholder = '\000\333\000\022'
};
typedef enum PowerpointEPPPlaceholderType PowerpointEPPPlaceholderType;

enum PowerpointEPPSlideShowType {
	PowerpointEPPSlideShowTypeSlideShowTypeSpeaker = '\000\325\000\001',
	PowerpointEPPSlideShowTypeSlideShowTypeWindow = '\000\325\000\002',
	PowerpointEPPSlideShowTypeSlideShowTypeKiosk = '\000\325\000\003',
	PowerpointEPPSlideShowTypeSlideShowTypePresenter = '\000\325\000\005'
};
typedef enum PowerpointEPPSlideShowType PowerpointEPPSlideShowType;

enum PowerpointEPPPrintRangeType {
	PowerpointEPPPrintRangeTypePrintRangeAll = '\000\367\000\001',
	PowerpointEPPPrintRangeTypePrintRangeSelection = '\000\367\000\002',
	PowerpointEPPPrintRangeTypePrintRangeCurrent = '\000\367\000\003',
	PowerpointEPPPrintRangeTypePrintRangeSlideRange = '\000\367\000\004',
	PowerpointEPPPrintRangeTypePrintSection = '\000\367\000\005'
};
typedef enum PowerpointEPPPrintRangeType PowerpointEPPPrintRangeType;

enum PowerpointEPPAutoSize {
	PowerpointEPPAutoSizePpAutoSizemixed = '\000\344\377\376',
	PowerpointEPPAutoSizePpAutoSizeNone = '\000\345\000\000',
	PowerpointEPPAutoSizePpAutoSizeShapeToFitText = '\000\345\000\001',
	PowerpointEPPAutoSizePpAutoSizeTextToFitShape = '\000\345\000\002'
};
typedef enum PowerpointEPPAutoSize PowerpointEPPAutoSize;

enum PowerpointEPPMediaType {
	PowerpointEPPMediaTypeMediaTypeUnset = '\000\333\377\376',
	PowerpointEPPMediaTypeMediaTypeOther = '\000\334\000\001',
	PowerpointEPPMediaTypeMediaTypeSound = '\000\334\000\002',
	PowerpointEPPMediaTypeMediaTypeMovie = '\000\334\000\003'
};
typedef enum PowerpointEPPMediaType PowerpointEPPMediaType;

enum PowerpointEPPSoundFormatType {
	PowerpointEPPSoundFormatTypeSoundFormatUnset = '\000\367\377\376',
	PowerpointEPPSoundFormatTypeSoundFormatNone = '\000\370\000\000',
	PowerpointEPPSoundFormatTypeSoundFormatWAV = '\000\370\000\001',
	PowerpointEPPSoundFormatTypeSoundFormatMIDI = '\000\370\000\002'
};
typedef enum PowerpointEPPSoundFormatType PowerpointEPPSoundFormatType;

enum PowerpointEPPFarEastLineBreakLevel {
	PowerpointEPPFarEastLineBreakLevelEastAsianLineBreakNormal = '\000\354\000\001',
	PowerpointEPPFarEastLineBreakLevelEastAsianLineBreakStrict = '\000\354\000\002',
	PowerpointEPPFarEastLineBreakLevelEastAsianLineBreakCustom = '\000\354\000\003'
};
typedef enum PowerpointEPPFarEastLineBreakLevel PowerpointEPPFarEastLineBreakLevel;

enum PowerpointEPPSlideShowRangeType {
	PowerpointEPPSlideShowRangeTypeSlideShowRangeShowAll = '\000\326\000\001',
	PowerpointEPPSlideShowRangeTypeSlideShowRange = '\000\326\000\002',
	PowerpointEPPSlideShowRangeTypeSlideShowRangeNamedSlideshow = '\000\326\000\003'
};
typedef enum PowerpointEPPSlideShowRangeType PowerpointEPPSlideShowRangeType;

enum PowerpointEPPFrameColors {
	PowerpointEPPFrameColorsFrameColorsBrowserColors = '\000\317\000\001',
	PowerpointEPPFrameColorsFrameColorsPresentationSchemeTextColor = '\000\317\000\002',
	PowerpointEPPFrameColorsFrameColorsPresentationSchemeAccentColor = '\000\317\000\003',
	PowerpointEPPFrameColorsFrameColorsWhiteTextOnBlack = '\000\317\000\004',
	PowerpointEPPFrameColorsFrameColorsBlackTextOnWhite = '\000\317\000\005'
};
typedef enum PowerpointEPPFrameColors PowerpointEPPFrameColors;

enum PowerpointEPPMovieOptimization {
	PowerpointEPPMovieOptimizationMovieOptimizationNormal = '\000\317\377\376',
	PowerpointEPPMovieOptimizationMovieOptimizationSize = '\000\320\000\001',
	PowerpointEPPMovieOptimizationMovieOptimizationSpeed = '\000\320\000\002',
	PowerpointEPPMovieOptimizationMovieOptimizationQuality = '\000\320\000\003'
};
typedef enum PowerpointEPPMovieOptimization PowerpointEPPMovieOptimization;

enum PowerpointEPPBulletType {
	PowerpointEPPBulletTypePpBulletmixed = '\000\347\377\376',
	PowerpointEPPBulletTypePpBulletNone = '\000\350\000\000',
	PowerpointEPPBulletTypePpBulletUnnumbered = '\000\350\000\001',
	PowerpointEPPBulletTypePpBulletNumbered = '\000\350\000\002',
	PowerpointEPPBulletTypePpBulletPicture = '\000\350\000\003'
};
typedef enum PowerpointEPPBulletType PowerpointEPPBulletType;

enum PowerpointEPPNumberedBulletStyle {
	PowerpointEPPNumberedBulletStylePpBulletStylemixed = '\000\350\377\376',
	PowerpointEPPNumberedBulletStylePpBulletAlphaLCPeriod = '\000\351\000\000',
	PowerpointEPPNumberedBulletStylePpBulletAlphaUCPeriod = '\000\351\000\001',
	PowerpointEPPNumberedBulletStylePpBulletArabicParenRight = '\000\351\000\002',
	PowerpointEPPNumberedBulletStylePpBulletArabicPeriod = '\000\351\000\003',
	PowerpointEPPNumberedBulletStylePpBulletRomanLCParenBoth = '\000\351\000\004',
	PowerpointEPPNumberedBulletStylePpBulletRomanLCParenRight = '\000\351\000\005',
	PowerpointEPPNumberedBulletStylePpBulletRomanLCPeriod = '\000\351\000\006',
	PowerpointEPPNumberedBulletStylePpBulletRomanUCPeriod = '\000\351\000\007',
	PowerpointEPPNumberedBulletStylePpBulletAlphaLCParenBoth = '\000\351\000\010',
	PowerpointEPPNumberedBulletStylePpBulletAlphaLCParenRight = '\000\351\000\011',
	PowerpointEPPNumberedBulletStylePpBulletAlphaUCParenBoth = '\000\351\000\012',
	PowerpointEPPNumberedBulletStylePpBulletAlphaUCParenRight = '\000\351\000\013',
	PowerpointEPPNumberedBulletStylePpBulletArabicParenBoth = '\000\351\000\014',
	PowerpointEPPNumberedBulletStylePpBulletArabicPlain = '\000\351\000\015',
	PowerpointEPPNumberedBulletStylePpBulletRomanUCParenBoth = '\000\351\000\016',
	PowerpointEPPNumberedBulletStylePpBulletRomanUCParenRight = '\000\351\000\017',
	PowerpointEPPNumberedBulletStylePpBulletSimpChinPlain = '\000\351\000\020',
	PowerpointEPPNumberedBulletStylePpBulletSimpChinPeriod = '\000\351\000\021',
	PowerpointEPPNumberedBulletStylePpBulletCircleNumDBPlain = '\000\351\000\022',
	PowerpointEPPNumberedBulletStylePpBulletCircleNumWDWhitePlain = '\000\351\000\023',
	PowerpointEPPNumberedBulletStylePpBulletCircleNumWDBlackPlain = '\000\351\000\024',
	PowerpointEPPNumberedBulletStylePpBulletTradChinPlain = '\000\351\000\025',
	PowerpointEPPNumberedBulletStylePpBulletTradChinPeriod = '\000\351\000\026',
	PowerpointEPPNumberedBulletStylePpBulletArabicAlphaDash = '\000\351\000\027',
	PowerpointEPPNumberedBulletStylePpBulletArabicAbjadDash = '\000\351\000\030',
	PowerpointEPPNumberedBulletStylePpBulletHebrewAlphaDash = '\000\351\000\031',
	PowerpointEPPNumberedBulletStylePpBulletKanjiKoreanPlain = '\000\351\000\032',
	PowerpointEPPNumberedBulletStylePpBulletKanjiKoreanPeriod = '\000\351\000\033',
	PowerpointEPPNumberedBulletStylePpBulletArabicDBPlain = '\000\351\000\034'
};
typedef enum PowerpointEPPNumberedBulletStyle PowerpointEPPNumberedBulletStyle;

enum PowerpointEPPShapeFormat {
	PowerpointEPPShapeFormatShapeFormatGIF = '\000\335\000\000',
	PowerpointEPPShapeFormatShapeFormatJPEG = '\000\335\000\001',
	PowerpointEPPShapeFormatShapeFormatPNG = '\000\335\000\002',
	PowerpointEPPShapeFormatShapeFormatPICT = '\000\335\000\003'
};
typedef enum PowerpointEPPShapeFormat PowerpointEPPShapeFormat;

enum PowerpointEPPExportMode {
	PowerpointEPPExportModeExportModeRelativeToSlide = '\000\336\000\001',
	PowerpointEPPExportModeExportModeClipRelativeToSlide = '\000\336\000\001',
	PowerpointEPPExportModeExportModeScaleToFit = '\000\336\000\002',
	PowerpointEPPExportModeExportModeScaleXY = '\000\336\000\003'
};
typedef enum PowerpointEPPExportMode PowerpointEPPExportMode;

enum PowerpointPpBorderType {
	PowerpointPpBorderTypeTopBorder = '\001\032\000\001',
	PowerpointPpBorderTypeLeftBorder = '\001\032\000\002',
	PowerpointPpBorderTypeBottomBorder = '\001\032\000\003',
	PowerpointPpBorderTypeRightBorder = '\001\032\000\004',
	PowerpointPpBorderTypeDiagonalDownBorder = '\001\032\000\005',
	PowerpointPpBorderTypeDiagonalUpBorder = '\001\032\000\006'
};
typedef enum PowerpointPpBorderType PowerpointPpBorderType;

enum PowerpointEPPCheckInVersionType {
	PowerpointEPPCheckInVersionTypeMinorVersion = '\002\304\000\000',
	PowerpointEPPCheckInVersionTypeMajorVersion = '\002\304\000\001',
	PowerpointEPPCheckInVersionTypeOverwriteCurrentVersion = '\002\304\000\002'
};
typedef enum PowerpointEPPCheckInVersionType PowerpointEPPCheckInVersionType;

enum PowerpointIppPageLayout {
	PowerpointIppPageLayoutPageLayoutNormal = '\000\355\000\000',
	PowerpointIppPageLayoutPageLayoutFullScreen = '\000\355\000\001'
};
typedef enum PowerpointIppPageLayout PowerpointIppPageLayout;

enum PowerpointIppButtonsType {
	PowerpointIppButtonsTypeRegular = '\000\356\000\001',
	PowerpointIppButtonsTypeFancy = '\000\356\000\002',
	PowerpointIppButtonsTypeTextOnly = '\000\356\000\003'
};
typedef enum PowerpointIppButtonsType PowerpointIppButtonsType;

enum PowerpointIppNavBarPlacement {
	PowerpointIppNavBarPlacementBarPlacementTop = '\000\357\000\001',
	PowerpointIppNavBarPlacementBarPlacementBottom = '\000\357\000\002'
};
typedef enum PowerpointIppNavBarPlacement PowerpointIppNavBarPlacement;

enum PowerpointMsoAnimEffect {
	PowerpointMsoAnimEffectAnimationTypeCustom = '\001\002\000\000',
	PowerpointMsoAnimEffectAnimationTypeAppear = '\001\002\000\001',
	PowerpointMsoAnimEffectAnimationTypeFly = '\001\002\000\002',
	PowerpointMsoAnimEffectAnimationTypeBlinds = '\001\002\000\003',
	PowerpointMsoAnimEffectAnimationTypeBox = '\001\002\000\004',
	PowerpointMsoAnimEffectAnimationTypeCheckerboard = '\001\002\000\005',
	PowerpointMsoAnimEffectAnimationTypeCircle = '\001\002\000\006',
	PowerpointMsoAnimEffectAnimationTypeCrawl = '\001\002\000\007',
	PowerpointMsoAnimEffectAnimationTypeDiamond = '\001\002\000\010',
	PowerpointMsoAnimEffectAnimationTypeDissolve = '\001\002\000\011',
	PowerpointMsoAnimEffectAnimationTypeFade = '\001\002\000\012',
	PowerpointMsoAnimEffectAnimationTypeFlashOnce = '\001\002\000\013',
	PowerpointMsoAnimEffectAnimationTypePeek = '\001\002\000\014',
	PowerpointMsoAnimEffectAnimationTypePlus = '\001\002\000\015',
	PowerpointMsoAnimEffectAnimationTypeRandomBars = '\001\002\000\016',
	PowerpointMsoAnimEffectAnimationTypeSpiral = '\001\002\000\017',
	PowerpointMsoAnimEffectAnimationTypeSplit = '\001\002\000\020',
	PowerpointMsoAnimEffectAnimationTypeStretch = '\001\002\000\021',
	PowerpointMsoAnimEffectAnimationTypeStrips = '\001\002\000\022',
	PowerpointMsoAnimEffectAnimationTypeSwivel = '\001\002\000\023',
	PowerpointMsoAnimEffectAnimationTypeWedge = '\001\002\000\024',
	PowerpointMsoAnimEffectAnimationTypeWheel = '\001\002\000\025',
	PowerpointMsoAnimEffectAnimationTypeWipe = '\001\002\000\026',
	PowerpointMsoAnimEffectAnimationTypeZoom = '\001\002\000\027',
	PowerpointMsoAnimEffectAnimationTypeRandomEffect = '\001\002\000\030',
	PowerpointMsoAnimEffectAnimationTypeBoomerang = '\001\002\000\031',
	PowerpointMsoAnimEffectAnimationTypeBounce = '\001\002\000\032',
	PowerpointMsoAnimEffectAnimationTypeColorReveal = '\001\002\000\033',
	PowerpointMsoAnimEffectAnimationTypeCredits = '\001\002\000\034',
	PowerpointMsoAnimEffectAnimationTypeEaseIn = '\001\002\000\035',
	PowerpointMsoAnimEffectAnimationTypeFloat = '\001\002\000\036',
	PowerpointMsoAnimEffectAnimationTypeGrowAndTurn = '\001\002\000\037',
	PowerpointMsoAnimEffectAnimationTypeLightSpeed = '\001\002\000 ',
	PowerpointMsoAnimEffectAnimationTypePinwheel = '\001\002\000!',
	PowerpointMsoAnimEffectAnimationTypeRiseUp = '\001\002\000\"',
	PowerpointMsoAnimEffectAnimationTypeSwish = '\001\002\000#',
	PowerpointMsoAnimEffectAnimationTypeThinLine = '\001\002\000$',
	PowerpointMsoAnimEffectAnimationTypeUnfold = '\001\002\000%',
	PowerpointMsoAnimEffectAnimationTypeWhip = '\001\002\000&',
	PowerpointMsoAnimEffectAnimationTypeAscend = '\001\002\000\'',
	PowerpointMsoAnimEffectAnimationTypeCenterRevolve = '\001\002\000(',
	PowerpointMsoAnimEffectAnimationTypeFadedSwivel = '\001\002\000)',
	PowerpointMsoAnimEffectAnimationTypeDescend = '\001\002\000*',
	PowerpointMsoAnimEffectAnimationTypeSling = '\001\002\000+',
	PowerpointMsoAnimEffectAnimationTypeSpinner = '\001\002\000,',
	PowerpointMsoAnimEffectAnimationTypeStretchy = '\001\002\000-',
	PowerpointMsoAnimEffectAnimationTypeZip = '\001\002\000.',
	PowerpointMsoAnimEffectAnimationTypeArcUp = '\001\002\000/',
	PowerpointMsoAnimEffectAnimationTypeFadeZoom = '\001\002\0000',
	PowerpointMsoAnimEffectAnimationTypeGlide = '\001\002\0001',
	PowerpointMsoAnimEffectAnimationTypeExpand = '\001\002\0002',
	PowerpointMsoAnimEffectAnimationTypeFlip = '\001\002\0003',
	PowerpointMsoAnimEffectAnimationTypeShimmer = '\001\002\0004',
	PowerpointMsoAnimEffectAnimationTypeFold = '\001\002\0005',
	PowerpointMsoAnimEffectAnimationTypeChangeFillColor = '\001\002\0006',
	PowerpointMsoAnimEffectAnimationTypeChangeFont = '\001\002\0007',
	PowerpointMsoAnimEffectAnimationTypeChangeFontColor = '\001\002\0008',
	PowerpointMsoAnimEffectAnimationTypeChangeFontSize = '\001\002\0009',
	PowerpointMsoAnimEffectAnimationTypeChangeFontStyle = '\001\002\000:',
	PowerpointMsoAnimEffectAnimationTypeGrowShrink = '\001\002\000;',
	PowerpointMsoAnimEffectAnimationTypeChangeLineColor = '\001\002\000<',
	PowerpointMsoAnimEffectAnimationTypeSpin = '\001\002\000=',
	PowerpointMsoAnimEffectAnimationTypeTransparency = '\001\002\000>',
	PowerpointMsoAnimEffectAnimationTypeBoldFlash = '\001\002\000\?',
	PowerpointMsoAnimEffectAnimationTypeBlast = '\001\002\000@',
	PowerpointMsoAnimEffectAnimationTypeBoldReveal = '\001\002\000A',
	PowerpointMsoAnimEffectAnimationTypeBrushOnColor = '\001\002\000B',
	PowerpointMsoAnimEffectAnimationTypeBrushOnUnderline = '\001\002\000C',
	PowerpointMsoAnimEffectAnimationTypeColorBlend = '\001\002\000D',
	PowerpointMsoAnimEffectAnimationTypeColorWave = '\001\002\000E',
	PowerpointMsoAnimEffectAnimationTypeComplementaryColor = '\001\002\000F',
	PowerpointMsoAnimEffectAnimationTypeComplementaryColor2 = '\001\002\000G',
	PowerpointMsoAnimEffectAnimationTypeConstrastingColor = '\001\002\000H',
	PowerpointMsoAnimEffectAnimationTypeDarken = '\001\002\000I',
	PowerpointMsoAnimEffectAnimationTypeDesaturate = '\001\002\000J',
	PowerpointMsoAnimEffectAnimationTypeFlashBulb = '\001\002\000K',
	PowerpointMsoAnimEffectAnimationTypeFlicker = '\001\002\000L',
	PowerpointMsoAnimEffectAnimationTypeGrowWithColor = '\001\002\000M',
	PowerpointMsoAnimEffectAnimationTypeLighten = '\001\002\000N',
	PowerpointMsoAnimEffectAnimationTypeStyleEmphasis = '\001\002\000O',
	PowerpointMsoAnimEffectAnimationTypeTeeter = '\001\002\000P',
	PowerpointMsoAnimEffectAnimationTypeVerticalGrow = '\001\002\000Q',
	PowerpointMsoAnimEffectAnimationTypeWave = '\001\002\000R',
	PowerpointMsoAnimEffectAnimationTypeMediaPlay = '\001\002\000S',
	PowerpointMsoAnimEffectAnimationTypeMediaPause = '\001\002\000T',
	PowerpointMsoAnimEffectAnimationTypeMediaStop = '\001\002\000U',
	PowerpointMsoAnimEffectAnimationTypeCirclePath = '\001\002\000V',
	PowerpointMsoAnimEffectAnimationTypeRightTrianglePath = '\001\002\000W',
	PowerpointMsoAnimEffectAnimationTypeDiamondPath = '\001\002\000X',
	PowerpointMsoAnimEffectAnimationTypeHexagonPath = '\001\002\000Y',
	PowerpointMsoAnimEffectAnimationType5PointStarPath = '\001\002\000Z',
	PowerpointMsoAnimEffectAnimationTypeCrescentMoonPath = '\001\002\000[',
	PowerpointMsoAnimEffectAnimationTypeSquarePath = '\001\002\000\\',
	PowerpointMsoAnimEffectAnimationTypeTrapezoidPath = '\001\002\000]',
	PowerpointMsoAnimEffectAnimationTypeHeartPath = '\001\002\000^',
	PowerpointMsoAnimEffectAnimationTypeOctagonPath = '\001\002\000_',
	PowerpointMsoAnimEffectAnimationType6PointStarPath = '\001\002\000`',
	PowerpointMsoAnimEffectAnimationTypeFootballPath = '\001\002\000a',
	PowerpointMsoAnimEffectAnimationTypeEqualTrianglePath = '\001\002\000b',
	PowerpointMsoAnimEffectAnimationTypeParallelogramPath = '\001\002\000c',
	PowerpointMsoAnimEffectAnimationTypePentagonPath = '\001\002\000d',
	PowerpointMsoAnimEffectAnimationType4PointStarPath = '\001\002\000e',
	PowerpointMsoAnimEffectAnimationType8PointStarPath = '\001\002\000f',
	PowerpointMsoAnimEffectAnimationTypeTeardropPath = '\001\002\000g',
	PowerpointMsoAnimEffectAnimationTypePointyStarPath = '\001\002\000h',
	PowerpointMsoAnimEffectAnimationTypeCurvedSquarePath = '\001\002\000i',
	PowerpointMsoAnimEffectAnimationTypeCurvedXPath = '\001\002\000j',
	PowerpointMsoAnimEffectAnimationTypeVerticalFigure8Path = '\001\002\000k',
	PowerpointMsoAnimEffectAnimationTypeCurvyStarPath = '\001\002\000l',
	PowerpointMsoAnimEffectAnimationTypeLoopDeLoopPath = '\001\002\000m',
	PowerpointMsoAnimEffectAnimationTypeBuzzsawPath = '\001\002\000n',
	PowerpointMsoAnimEffectAnimationTypeHorizontalFigure8Path = '\001\002\000o',
	PowerpointMsoAnimEffectAnimationTypePeanutPath = '\001\002\000p',
	PowerpointMsoAnimEffectAnimationTypeFigure8FourPath = '\001\002\000q',
	PowerpointMsoAnimEffectAnimationTypeNeutronPath = '\001\002\000r',
	PowerpointMsoAnimEffectAnimationTypeSwooshPath = '\001\002\000s',
	PowerpointMsoAnimEffectAnimationTypeBeanPath = '\001\002\000t',
	PowerpointMsoAnimEffectAnimationTypePlusPath = '\001\002\000u',
	PowerpointMsoAnimEffectAnimationTypeInvertedTrianglePath = '\001\002\000v',
	PowerpointMsoAnimEffectAnimationTypeInvertedSquarePath = '\001\002\000w',
	PowerpointMsoAnimEffectAnimationTypeLeftPath = '\001\002\000x',
	PowerpointMsoAnimEffectAnimationTypeTurnRightPath = '\001\002\000y',
	PowerpointMsoAnimEffectAnimationTypeArcDownPath = '\001\002\000z',
	PowerpointMsoAnimEffectAnimationTypeZigzagPath = '\001\002\000{',
	PowerpointMsoAnimEffectAnimationTypeSCurve2Path = '\001\002\000|',
	PowerpointMsoAnimEffectAnimationTypeSineWavePath = '\001\002\000}',
	PowerpointMsoAnimEffectAnimationTypeBounceLeftPath = '\001\002\000~',
	PowerpointMsoAnimEffectAnimationTypeDownPath = '\001\002\000\177',
	PowerpointMsoAnimEffectAnimationTypeTurnUpPath = '\001\002\000\200',
	PowerpointMsoAnimEffectAnimationTypeArcUpPath = '\001\002\000\201',
	PowerpointMsoAnimEffectAnimationTypeHeartbeatPath = '\001\002\000\202',
	PowerpointMsoAnimEffectAnimationTypeSpiralRightPath = '\001\002\000\203',
	PowerpointMsoAnimEffectAnimationTypeWavePath = '\001\002\000\204',
	PowerpointMsoAnimEffectAnimationTypeCurvyLeftPath = '\001\002\000\205',
	PowerpointMsoAnimEffectAnimationTypeDiagonalDownRightPath = '\001\002\000\206',
	PowerpointMsoAnimEffectAnimationTypeTurnDownPath = '\001\002\000\207',
	PowerpointMsoAnimEffectAnimationTypeArcLeftPath = '\001\002\000\210',
	PowerpointMsoAnimEffectAnimationTypeFunnelPath = '\001\002\000\211',
	PowerpointMsoAnimEffectAnimationTypeSpringPath = '\001\002\000\212',
	PowerpointMsoAnimEffectAnimationTypeBounceRightPath = '\001\002\000\213',
	PowerpointMsoAnimEffectAnimationTypeSpiralLeftPath = '\001\002\000\214',
	PowerpointMsoAnimEffectAnimationTypeDiagonalUpRightPath = '\001\002\000\215',
	PowerpointMsoAnimEffectAnimationTypeTurnUpRightPath = '\001\002\000\216',
	PowerpointMsoAnimEffectAnimationTypeArcRightPath = '\001\002\000\217',
	PowerpointMsoAnimEffectAnimationTypeSCurve1Path = '\001\002\000\220',
	PowerpointMsoAnimEffectAnimationTypeDecayingWavePath = '\001\002\000\221',
	PowerpointMsoAnimEffectAnimationTypeCurvyRightPath = '\001\002\000\222',
	PowerpointMsoAnimEffectAnimationTypeStairsDownPath = '\001\002\000\223',
	PowerpointMsoAnimEffectAnimationTypeUpPath = '\001\002\000\224',
	PowerpointMsoAnimEffectAnimationTypeRightPath = '\001\002\000\225'
};
typedef enum PowerpointMsoAnimEffect PowerpointMsoAnimEffect;

enum PowerpointMsoAnimateByLevel {
	PowerpointMsoAnimateByLevelTextByNoLevels = '\001\001\000\000',
	PowerpointMsoAnimateByLevelTextByAllLevels = '\001\001\000\001',
	PowerpointMsoAnimateByLevelTextByFirstLevel = '\001\001\000\002',
	PowerpointMsoAnimateByLevelTextBySecondLevel = '\001\001\000\003',
	PowerpointMsoAnimateByLevelTextByThirdLevel = '\001\001\000\004',
	PowerpointMsoAnimateByLevelTextByFourthLevel = '\001\001\000\005',
	PowerpointMsoAnimateByLevelTextByFifthLevel = '\001\001\000\006',
	PowerpointMsoAnimateByLevelChartAllAtOnce = '\001\001\000\007',
	PowerpointMsoAnimateByLevelChartByCategory = '\001\001\000\010',
	PowerpointMsoAnimateByLevelChartByCtageoryElements = '\001\001\000\011',
	PowerpointMsoAnimateByLevelChartBySeries = '\001\001\000\012',
	PowerpointMsoAnimateByLevelChartBySeriesElements = '\001\001\000\013'
};
typedef enum PowerpointMsoAnimateByLevel PowerpointMsoAnimateByLevel;

enum PowerpointMsoAnimTriggerType {
	PowerpointMsoAnimTriggerTypeNoTrigger = '\001\000\000\000',
	PowerpointMsoAnimTriggerTypeOnPageClick = '\001\000\000\001',
	PowerpointMsoAnimTriggerTypeWithPrevious = '\001\000\000\002',
	PowerpointMsoAnimTriggerTypeAfterPrevious = '\001\000\000\003',
	PowerpointMsoAnimTriggerTypeOnShapeClick = '\001\000\000\004'
};
typedef enum PowerpointMsoAnimTriggerType PowerpointMsoAnimTriggerType;

enum PowerpointMsoAnimAfterEffect {
	PowerpointMsoAnimAfterEffectNoAfterEffect = '\000\377\000\000',
	PowerpointMsoAnimAfterEffectDim = '\000\377\000\001',
	PowerpointMsoAnimAfterEffectHide = '\000\377\000\002',
	PowerpointMsoAnimAfterEffectHideOnNextClick = '\000\377\000\003'
};
typedef enum PowerpointMsoAnimAfterEffect PowerpointMsoAnimAfterEffect;

enum PowerpointMsoAnimTextUnitEffect {
	PowerpointMsoAnimTextUnitEffectByParagraph = '\000\376\000\000',
	PowerpointMsoAnimTextUnitEffectByCharacter = '\000\376\000\001',
	PowerpointMsoAnimTextUnitEffectByWord = '\000\376\000\002'
};
typedef enum PowerpointMsoAnimTextUnitEffect PowerpointMsoAnimTextUnitEffect;

enum PowerpointMsoAnimEffectRestart {
	PowerpointMsoAnimEffectRestartRestartAlways = '\000\375\000\001',
	PowerpointMsoAnimEffectRestartRestartWhenOff = '\000\375\000\002',
	PowerpointMsoAnimEffectRestartNeverRestart = '\000\375\000\003'
};
typedef enum PowerpointMsoAnimEffectRestart PowerpointMsoAnimEffectRestart;

enum PowerpointMsoAnimEffectAfter {
	PowerpointMsoAnimEffectAfterAfterFreeze = '\000\374\000\001',
	PowerpointMsoAnimEffectAfterAfterRemove = '\000\374\000\002',
	PowerpointMsoAnimEffectAfterAfterHold = '\000\374\000\003',
	PowerpointMsoAnimEffectAfterAfterTransition = '\000\374\000\004'
};
typedef enum PowerpointMsoAnimEffectAfter PowerpointMsoAnimEffectAfter;

enum PowerpointMsoAnimDirection {
	PowerpointMsoAnimDirectionNoDirection = '\000\371\000\000',
	PowerpointMsoAnimDirectionUp = '\000\371\000\001',
	PowerpointMsoAnimDirectionRight = '\000\371\000\002',
	PowerpointMsoAnimDirectionDown = '\000\371\000\003',
	PowerpointMsoAnimDirectionLeft = '\000\371\000\004',
	PowerpointMsoAnimDirectionOrdinalMask = '\000\371\000\005',
	PowerpointMsoAnimDirectionUpLeft = '\000\371\000\006',
	PowerpointMsoAnimDirectionUpRight = '\000\371\000\007',
	PowerpointMsoAnimDirectionDownRight = '\000\371\000\010',
	PowerpointMsoAnimDirectionDownLeft = '\000\371\000\011',
	PowerpointMsoAnimDirectionTop = '\000\371\000\012',
	PowerpointMsoAnimDirectionBottom = '\000\371\000\013',
	PowerpointMsoAnimDirectionTopLeft = '\000\371\000\014',
	PowerpointMsoAnimDirectionTopRight = '\000\371\000\015',
	PowerpointMsoAnimDirectionBottomRight = '\000\371\000\016',
	PowerpointMsoAnimDirectionBottomLeft = '\000\371\000\017',
	PowerpointMsoAnimDirectionHorizontal = '\000\371\000\020',
	PowerpointMsoAnimDirectionVertical = '\000\371\000\021',
	PowerpointMsoAnimDirectionAcross = '\000\371\000\022',
	PowerpointMsoAnimDirectionInward = '\000\371\000\023',
	PowerpointMsoAnimDirectionOut = '\000\371\000\024',
	PowerpointMsoAnimDirectionClockwise = '\000\371\000\025',
	PowerpointMsoAnimDirectionCounterclockwise = '\000\371\000\026',
	PowerpointMsoAnimDirectionHorizontalIn = '\000\371\000\027',
	PowerpointMsoAnimDirectionHorizontalOut = '\000\371\000\030',
	PowerpointMsoAnimDirectionVerticalIn = '\000\371\000\031',
	PowerpointMsoAnimDirectionVerticalOut = '\000\371\000\032',
	PowerpointMsoAnimDirectionSlightly = '\000\371\000\033',
	PowerpointMsoAnimDirectionCenter = '\000\371\000\034',
	PowerpointMsoAnimDirectionInSlightly = '\000\371\000\035',
	PowerpointMsoAnimDirectionInCenter = '\000\371\000\036',
	PowerpointMsoAnimDirectionInBottom = '\000\371\000\037',
	PowerpointMsoAnimDirectionOutSlightly = '\000\371\000 ',
	PowerpointMsoAnimDirectionOutCenter = '\000\371\000!',
	PowerpointMsoAnimDirectionOutBottom = '\000\371\000\"',
	PowerpointMsoAnimDirectionFontBold = '\000\371\000#',
	PowerpointMsoAnimDirectionFontItalic = '\000\371\000$',
	PowerpointMsoAnimDirectionFontUnderline = '\000\371\000%',
	PowerpointMsoAnimDirectionFontStrikethrough = '\000\371\000&',
	PowerpointMsoAnimDirectionFontShadow = '\000\371\000\'',
	PowerpointMsoAnimDirectionFontAllCaps = '\000\371\000(',
	PowerpointMsoAnimDirectionInstant = '\000\371\000)',
	PowerpointMsoAnimDirectionGradual = '\000\371\000*',
	PowerpointMsoAnimDirectionCycleClockwise = '\000\371\000+',
	PowerpointMsoAnimDirectionCycleCounterclockwise = '\000\371\000,'
};
typedef enum PowerpointMsoAnimDirection PowerpointMsoAnimDirection;

enum PowerpointMsoAnimType {
	PowerpointMsoAnimTypeAnimationTypeNone = '\001\003\000\000',
	PowerpointMsoAnimTypeAnimationTypeMotion = '\001\003\000\001',
	PowerpointMsoAnimTypeAnimationTypeColor = '\001\003\000\002',
	PowerpointMsoAnimTypeAnimationTypeScale = '\001\003\000\003',
	PowerpointMsoAnimTypeAnimationTypeRotation = '\001\003\000\004',
	PowerpointMsoAnimTypeAnimationTypeProperty = '\001\003\000\005',
	PowerpointMsoAnimTypeAnimationTypeCommand = '\001\003\000\006',
	PowerpointMsoAnimTypeAnimationTypeFilter = '\001\003\000\007',
	PowerpointMsoAnimTypeAnimationTypeSet = '\001\003\000\010'
};
typedef enum PowerpointMsoAnimType PowerpointMsoAnimType;

enum PowerpointMsoAnimAdditive {
	PowerpointMsoAnimAdditiveNoAdditive = '\001\007\000\001',
	PowerpointMsoAnimAdditiveMotion = '\001\007\000\002'
};
typedef enum PowerpointMsoAnimAdditive PowerpointMsoAnimAdditive;

enum PowerpointMsoAnimAccumulate {
	PowerpointMsoAnimAccumulateNoAccumulate = '\001\004\000\001',
	PowerpointMsoAnimAccumulateAlways = '\001\004\000\002'
};
typedef enum PowerpointMsoAnimAccumulate PowerpointMsoAnimAccumulate;

enum PowerpointMsoAnimProperty {
	PowerpointMsoAnimPropertyNoProperty = '\001\005\000\000',
	PowerpointMsoAnimPropertyX = '\001\005\000\001',
	PowerpointMsoAnimPropertyY = '\001\005\000\002',
	PowerpointMsoAnimPropertyWidth = '\001\005\000\003',
	PowerpointMsoAnimPropertyHeight = '\001\005\000\004',
	PowerpointMsoAnimPropertyOpacity = '\001\005\000\005',
	PowerpointMsoAnimPropertyRotation = '\001\005\000\006',
	PowerpointMsoAnimPropertyColors = '\001\005\000\007',
	PowerpointMsoAnimPropertyVisibility = '\001\005\000\010',
	PowerpointMsoAnimPropertyTextFontBold = '\001\005\000d',
	PowerpointMsoAnimPropertyTextFontColor = '\001\005\000e',
	PowerpointMsoAnimPropertyTextFontEmboss = '\001\005\000f',
	PowerpointMsoAnimPropertyTextFontItalic = '\001\005\000g',
	PowerpointMsoAnimPropertyTextFontName = '\001\005\000h',
	PowerpointMsoAnimPropertyTextFontShadow = '\001\005\000i',
	PowerpointMsoAnimPropertyTextFontSize = '\001\005\000j',
	PowerpointMsoAnimPropertyTextFontSubscript = '\001\005\000k',
	PowerpointMsoAnimPropertyTextFontSuperscript = '\001\005\000l',
	PowerpointMsoAnimPropertyTextFontUnderline = '\001\005\000m',
	PowerpointMsoAnimPropertyTextFontStrikethrough = '\001\005\000n',
	PowerpointMsoAnimPropertyTextBulletCharacter = '\001\005\000o',
	PowerpointMsoAnimPropertyTextBulletFontName = '\001\005\000p',
	PowerpointMsoAnimPropertyTextBulletNumber = '\001\005\000q',
	PowerpointMsoAnimPropertyTextBulletColor = '\001\005\000r',
	PowerpointMsoAnimPropertyTextBulletRelativeSize = '\001\005\000s',
	PowerpointMsoAnimPropertyTextBulletStyle = '\001\005\000t',
	PowerpointMsoAnimPropertyTextBulletType = '\001\005\000u',
	PowerpointMsoAnimPropertyShapePictureContrast = '\001\005\003\350',
	PowerpointMsoAnimPropertyShapePictureBrightness = '\001\005\003\351',
	PowerpointMsoAnimPropertyShapePictureGamma = '\001\005\003\352',
	PowerpointMsoAnimPropertyShapePictureGrayscale = '\001\005\003\353',
	PowerpointMsoAnimPropertyShapeFillOn = '\001\005\003\354',
	PowerpointMsoAnimPropertyShapeFillColor = '\001\005\003\355',
	PowerpointMsoAnimPropertyShapeFillOpacity = '\001\005\003\356',
	PowerpointMsoAnimPropertyShapeFillBackColor = '\001\005\003\357',
	PowerpointMsoAnimPropertyShapeLineOn = '\001\005\003\360',
	PowerpointMsoAnimPropertyShapeLineColor = '\001\005\003\361',
	PowerpointMsoAnimPropertyShapeShadowOn = '\001\005\003\362',
	PowerpointMsoAnimPropertyShapeShadowType = '\001\005\003\363',
	PowerpointMsoAnimPropertyShapeShadowColor = '\001\005\003\364',
	PowerpointMsoAnimPropertyShapeShadowOpacity = '\001\005\003\365',
	PowerpointMsoAnimPropertyShapeShadowOffsetX = '\001\005\003\366',
	PowerpointMsoAnimPropertyShapeShadowOffsetY = '\001\005\003\367'
};
typedef enum PowerpointMsoAnimProperty PowerpointMsoAnimProperty;

enum PowerpointMsoAnimCommandType {
	PowerpointMsoAnimCommandTypeEvent = '\001\006\000\000',
	PowerpointMsoAnimCommandTypeCall = '\001\006\000\001',
	PowerpointMsoAnimCommandTypeVerb = '\001\006\000\002'
};
typedef enum PowerpointMsoAnimCommandType PowerpointMsoAnimCommandType;

enum PowerpointMsoAnimFilterEffectType {
	PowerpointMsoAnimFilterEffectTypeNoFilterEffectType = '\001\010\000\000',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeBarn = '\001\010\000\001',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeBlinds = '\001\010\000\002',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeBox = '\001\010\000\003',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeCheckerboard = '\001\010\000\004',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeCircle = '\001\010\000\005',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeDiamond = '\001\010\000\006',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeDissolve = '\001\010\000\007',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeFade = '\001\010\000\010',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeImage = '\001\010\000\011',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypePixelate = '\001\010\000\012',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypePlus = '\001\010\000\013',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeRandomBar = '\001\010\000\014',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeSlide = '\001\010\000\015',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeStretch = '\001\010\000\016',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeStrips = '\001\010\000\017',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeWedge = '\001\010\000\020',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeWheel = '\001\010\000\021',
	PowerpointMsoAnimFilterEffectTypeFilterEffectTypeWipe = '\001\010\000\022'
};
typedef enum PowerpointMsoAnimFilterEffectType PowerpointMsoAnimFilterEffectType;

enum PowerpointMsoAnimFilterEffectSubtype {
	PowerpointMsoAnimFilterEffectSubtypeNoEffectSubtype = '\001\011\000\000',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeInVertical = '\001\011\000\001',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeOutVertical = '\001\011\000\002',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeInHorizontal = '\001\011\000\003',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeOutHorizontal = '\001\011\000\004',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeHorizontal = '\001\011\000\005',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeVertical = '\001\011\000\006',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeInward = '\001\011\000\007',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeOut = '\001\011\000\010',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeAcross = '\001\011\000\011',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeFromLeft = '\001\011\000\012',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeFromRight = '\001\011\000\013',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeFromTop = '\001\011\000\014',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeFromBottom = '\001\011\000\015',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeDownLeft = '\001\011\000\016',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeUpLeft = '\001\011\000\017',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeDownRight = '\001\011\000\020',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeUpRight = '\001\011\000\021',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeSpoke1 = '\001\011\000\022',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeSpokes2 = '\001\011\000\023',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeSpokes3 = '\001\011\000\024',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeSpokes4 = '\001\011\000\025',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeSpokes8 = '\001\011\000\026',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeLeft = '\001\011\000\027',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeRight = '\001\011\000\030',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeDown = '\001\011\000\031',
	PowerpointMsoAnimFilterEffectSubtypeFilterEffectSubtypeUp = '\001\011\000\032'
};
typedef enum PowerpointMsoAnimFilterEffectSubtype PowerpointMsoAnimFilterEffectSubtype;

enum PowerpointGetPlayerFrom {
	PowerpointGetPlayerFromView = 'pVEW',
	PowerpointGetPlayerFromSlideShowView = 'PSSv'
};
typedef enum PowerpointGetPlayerFrom PowerpointGetPlayerFrom;

enum PowerpointPasteObject {
	PowerpointPasteObjectView = 'pVEW',
	PowerpointPasteObjectPresentation = 'pptP'
};
typedef enum PowerpointPasteObject PowerpointPasteObject;

enum PowerpointApplyTheme {
	PowerpointApplyThemeSlide = 'pSLD',
	PowerpointApplyThemeMaster = 'pMtr',
	PowerpointApplyThemePresentation = 'pptP'
};
typedef enum PowerpointApplyTheme PowerpointApplyTheme;

enum PowerpointOneColorGradient {
	PowerpointOneColorGradientShape = 'pShp',
	PowerpointOneColorGradientFillFormat = 'pFFm'
};
typedef enum PowerpointOneColorGradient PowerpointOneColorGradient;

enum PowerpointTwoColorGradient {
	PowerpointTwoColorGradientShape = 'pShp',
	PowerpointTwoColorGradientFillFormat = 'pFFm'
};
typedef enum PowerpointTwoColorGradient PowerpointTwoColorGradient;

enum PowerpointAutomaticLength {
	PowerpointAutomaticLengthCallout = 'cD00',
	PowerpointAutomaticLengthCalloutFormat = 'cCoF'
};
typedef enum PowerpointAutomaticLength PowerpointAutomaticLength;

enum PowerpointBeginConnect {
	PowerpointBeginConnectConnector = 'cD01',
	PowerpointBeginConnectConnectorFormat = 'pCxF'
};
typedef enum PowerpointBeginConnect PowerpointBeginConnect;

enum PowerpointBeginDisconnect {
	PowerpointBeginDisconnectConnector = 'cD01',
	PowerpointBeginDisconnectConnectorFormat = 'pCxF'
};
typedef enum PowerpointBeginDisconnect PowerpointBeginDisconnect;

enum PowerpointCustomLength {
	PowerpointCustomLengthCallout = 'cD00',
	PowerpointCustomLengthCalloutFormat = 'cCoF'
};
typedef enum PowerpointCustomLength PowerpointCustomLength;

enum PowerpointCustomDrop {
	PowerpointCustomDropCallout = 'cD00',
	PowerpointCustomDropCalloutFormat = 'cCoF'
};
typedef enum PowerpointCustomDrop PowerpointCustomDrop;

enum PowerpointEndConnect {
	PowerpointEndConnectConnector = 'cD01',
	PowerpointEndConnectConnectorFormat = 'pCxF'
};
typedef enum PowerpointEndConnect PowerpointEndConnect;

enum PowerpointEndDisconnect {
	PowerpointEndDisconnectConnector = 'cD01',
	PowerpointEndDisconnectConnectorFormat = 'pCxF'
};
typedef enum PowerpointEndDisconnect PowerpointEndDisconnect;

enum PowerpointPatterned {
	PowerpointPatternedShape = 'pShp',
	PowerpointPatternedFillFormat = 'pFFm'
};
typedef enum PowerpointPatterned PowerpointPatterned;

enum PowerpointGetActionSettingFor {
	PowerpointGetActionSettingForShape = 'pShp',
	PowerpointGetActionSettingForShapeRange = 'ShpR'
};
typedef enum PowerpointGetActionSettingFor PowerpointGetActionSettingFor;

enum PowerpointSolid {
	PowerpointSolidShape = 'pShp',
	PowerpointSolidFillFormat = 'pFFm'
};
typedef enum PowerpointSolid PowerpointSolid;

enum PowerpointResetRotation {
	PowerpointResetRotationShape = 'pShp',
	PowerpointResetRotationThreeDFormat = 'D3Df'
};
typedef enum PowerpointResetRotation PowerpointResetRotation;

enum PowerpointUserPicture {
	PowerpointUserPictureShape = 'pShp',
	PowerpointUserPictureFillFormat = 'pFFm'
};
typedef enum PowerpointUserPicture PowerpointUserPicture;

enum PowerpointUserTextured {
	PowerpointUserTexturedShape = 'pShp',
	PowerpointUserTexturedFillFormat = 'pFFm'
};
typedef enum PowerpointUserTextured PowerpointUserTextured;

enum PowerpointZOrder {
	PowerpointZOrderShape = 'pShp',
	PowerpointZOrderShapeRange = 'ShpR'
};
typedef enum PowerpointZOrder PowerpointZOrder;

enum PowerpointPresetTextured {
	PowerpointPresetTexturedShape = 'pShp',
	PowerpointPresetTexturedFillFormat = 'pFFm'
};
typedef enum PowerpointPresetTextured PowerpointPresetTextured;

enum PowerpointPresetGradient {
	PowerpointPresetGradientShape = 'pShp',
	PowerpointPresetGradientFillFormat = 'pFFm'
};
typedef enum PowerpointPresetGradient PowerpointPresetGradient;

enum PowerpointApply {
	PowerpointApplyShape = 'pShp',
	PowerpointApplyShapeRange = 'ShpR'
};
typedef enum PowerpointApply PowerpointApply;

enum PowerpointFlip {
	PowerpointFlipShape = 'pShp',
	PowerpointFlipShapeRange = 'ShpR'
};
typedef enum PowerpointFlip PowerpointFlip;

enum PowerpointPickUp {
	PowerpointPickUpShape = 'pShp',
	PowerpointPickUpShapeRange = 'ShpR'
};
typedef enum PowerpointPickUp PowerpointPickUp;

enum PowerpointRerouteConnections {
	PowerpointRerouteConnectionsShape = 'pShp',
	PowerpointRerouteConnectionsShapeRange = 'ShpR'
};
typedef enum PowerpointRerouteConnections PowerpointRerouteConnections;

enum PowerpointSetShapesDefaultProperties {
	PowerpointSetShapesDefaultPropertiesShape = 'pShp',
	PowerpointSetShapesDefaultPropertiesShapeRange = 'ShpR'
};
typedef enum PowerpointSetShapesDefaultProperties PowerpointSetShapesDefaultProperties;

@protocol PowerpointGenericMethods

- (void) closeSaving:(PowerpointSaveOptions)saving savingIn:(NSURL *)savingIn;  // Close a document.
- (void) saveIn:(NSURL *)in_ as:(id)as;  // Save a document.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) duplicateTo:(SBObject *)to withProperties:(NSDictionary *)withProperties;  // Copy an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (BOOL) canCheckOutFileName:(NSString *)fileName;  // Returns True if PowerPoint can check out a specified presentation from a server.
- (void) checkOutFileName:(NSString *)fileName;  // Copies a specified presentation from a server to a local computer for editing. Returns a String that represents the local path and file name of the presentation checked out.
- (void) quit;

@end



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface PowerpointApplication : SBApplication

- (SBElementArray<PowerpointDocument *> *) documents;
- (SBElementArray<PowerpointWindow *> *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (id) open:(id)x;  // Open a document.
- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quitSaving:(PowerpointSaveOptions)saving;  // Quit the application.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) reset:(id)x;  // Resets a built-in command bar or command bar control to its default configuration.
- (void) applyTheme:(id)x fileName:(NSString *)fileName;  // Applies a theme or design template to the specified slide, master or presentation
- (void) arrangeWindows:(PowerpointEPPArrangeStyle)x;  // Arrange Document Windows
- (PowerpointPlayer *) getPlayerFrom:(id)x for:(PowerpointShape *)for_;  // get a player from a shape inside a slide show view
- (void) insertTheText:(NSString *)theText at:(SBObject *)at;
- (void) pasteObject:(id)x;
- (PowerpointAddIn *) registerAddIn:(NSString *)x;
- (NSInteger) runVBMacroMacroName:(NSString *)macroName listOfParameters:(NSArray<NSString *> *)listOfParameters;  // Runs a Visual Basic macro.
- (void) apply:(id)x;
- (void) automaticLength:(id)x;
- (void) beginConnect:(id)x connectedShape:(PowerpointShape *)connectedShape connectionSite:(NSInteger)connectionSite;
- (void) beginDisconnect:(id)x;
- (void) customDrop:(id)x dropAmount:(double)dropAmount;
- (void) customLength:(id)x length:(double)length;
- (void) endConnect:(id)x connectedShape:(PowerpointShape *)connectedShape connectionSite:(NSInteger)connectionSite;
- (void) endDisconnect:(id)x;
- (void) flip:(id)x direction:(PowerpointMsoFlipCmd)direction;
- (PowerpointActionSetting *) getActionSettingFor:(id)x event:(PowerpointEPPMouseActivation)event;
- (void) oneColorGradient:(id)x style:(PowerpointMsoGradientStyle)style variant:(NSInteger)variant degree:(double)degree;
- (void) patterned:(id)x pattern:(PowerpointMsoPatternType)pattern;
- (void) pickUp:(id)x;
- (void) presetGradient:(id)x style:(PowerpointMsoGradientStyle)style variant:(NSInteger)variant gradientType:(PowerpointMsoPresetGradientType)gradientType;
- (void) presetTextured:(id)x texture:(PowerpointMsoPresetTexture)texture;
- (void) rerouteConnections:(id)x;
- (void) resetRotation:(id)x;  // Resets the extrusion rotation around the x-axis and the y-axis to zero so that the front of the extrusion faces forward. This method doesn't reset the rotation around the z-axis.
- (void) setShapesDefaultProperties:(id)x;
- (void) solid:(id)x;
- (void) twoColorGradient:(id)x style:(PowerpointMsoGradientStyle)style variant:(NSInteger)variant;
- (void) userPicture:(id)x pictureFile:(NSString *)pictureFile;
- (void) userTextured:(id)x textureFile:(NSString *)textureFile;
- (void) zOrder:(id)x zOrderPosition:(PowerpointMsoZOrderCmd)zOrderPosition;

@end

// A document.
@interface PowerpointDocument : SBObject <PowerpointGenericMethods>

@property (copy, readonly) NSString *name;  // Its name.
@property (readonly) BOOL modified;  // Has it been modified since the last save?
@property (copy, readonly) NSURL *file;  // Its location on disk, if it has one.


@end

// A window.
@interface PowerpointWindow : SBObject <PowerpointGenericMethods>

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
@property (copy, readonly) PowerpointDocument *document;  // The document whose contents are displayed in the window.
@property (readonly) NSInteger entryIndex;  // the number of the window
@property NSPoint position;  // upper left coordinates of the window
@property (readonly) BOOL titled;  // Does the window have a title bar?
@property (readonly) BOOL floating;  // Does the window float?
@property (readonly) BOOL modal;  // Is the window modal?
@property (readonly) BOOL collapsable;  // Is the window collapasable?
@property BOOL collapsed;  // Is the window collapsed?
@property (readonly) BOOL sheet;  // Is this window a sheet window?


@end



/*
 * Microsoft Office Suite
 */

// A control within a command bar.
@interface PowerpointCommandBarControl : SBObject <PowerpointGenericMethods>

@property BOOL beginGroup;  // Returns or sets if the command bar control appears at the beginning of a group of controls on the command bar.
@property (readonly) BOOL builtIn;  // Returns true if the command bar control is a built-in command bar control.
@property (readonly) PowerpointMsoControlType controlType;  // Returns the type of the command bar control.
@property (copy) NSString *descriptionText;  // Returns or sets the description for a command bar control.  The description is not displayed to the user, but it can be useful for documenting the behavior of a control.
@property BOOL enabled;  // Returns or sets if the command bar control is enabled.
@property (readonly) NSInteger entry_index;  // Returns the index number for this command bar control.
@property NSInteger height;  // Returns or sets the height of a command bar control.
@property NSInteger helpContextID;  // Returns or sets the help context ID number for the Help topic attached to the command bar control.
@property (copy) NSString *helpFile;  // Returns or sets the file name for the help topic attached to the command bar.  To use this property, you must also set the help context ID property.
- (NSInteger) id;  // Returns the id for a built-in command bar control.
@property (readonly) NSInteger leftPosition;  // Returns the left position of the command bar control.
@property (copy) NSString *name;  // Returns or sets the caption text for a command bar control.
@property (copy) NSString *parameter;  // Returns or sets a string that is used to execute a command.
@property NSInteger priority;  // Returns or sets the priority of a command bar control. A controls priority determines whether the control can be dropped from a docked command bar if the command bar controls can not fit in a single row.  Valid priority number are 0 through 7.
@property (copy) NSString *tag;  // Returns or sets information about the command bar control, such as data that can be used as an argument in procedures, or information that identifies the control.
@property (copy) NSString *tooltipText;  // Returns or sets the text displayed in a command bar controls tooltip.
@property (readonly) NSInteger top;  // Returns the top position of a command bar control.
@property BOOL visible;  // Returns or sets if the command bar control is visible.
@property NSInteger width;  // Returns or sets the width in pixels of the command bar control.

- (void) execute;  // Runs the procedure or built-in command assigned to the specified command bar control.

@end

// A button control within a command bar.
@interface PowerpointCommandBarButton : PowerpointCommandBarControl

@property (readonly) BOOL buttonFaceIsDefault;  // Returns if the face of a command bar button control is the original built-in face.
@property PowerpointMsoButtonState buttonState;  // Returns or set the appearance of a command bar button control.  The property is read-only for built-in command bar buttons.
@property PowerpointMsoButtonStyle buttonStyle;  // Returns or sets the way a command button control is displayed.
@property NSInteger faceId;  // Returns or sets the Id number for the face of the command bar button control.


@end

// A combobox menu control within a command bar.
@interface PowerpointCommandBarCombobox : PowerpointCommandBarControl

@property PowerpointMsoComboStyle comboboxStyle;  // Returns or sets the way a command bar combobox control is displayed.
@property (copy) NSString *comboboxText;  // Returns or sets the text in the display or edit portion of the command bar combobox control.
@property NSInteger dropDownLines;  // Returns or sets the number of lines in a command bar control combobox control.  The combobox control must be a custom control.
@property NSInteger dropDownWidth;  // Returns or sets the width in pixels of the list for the specified command bar combobox control.  An error occurs if you attempt to set this property for a built-in combobox control.
@property NSInteger listIndex;

- (void) addItemToComboboxComboboxItem:(NSString *)comboboxItem entry_index:(NSInteger)entry_index;  // Add a new string to a custom combobox control.
- (void) clearCombobox;  // Clear all of the strings form a custom combobox.
- (NSString *) getComboboxItemEntry_index:(NSInteger)entry_index;  // Return the string at the given index within a combobox.
- (NSInteger) getCountOfComboboxItems;  // Return the number of strings within a combobox.
- (void) removeAnItemFromComboboxEntry_index:(NSInteger)entry_index;  // Remove a string from a custom combobox.
- (void) setComboboxItemEntry_index:(NSInteger)entry_index comboboxItem:(NSString *)comboboxItem;  // Set the string an a given index for a custom combobox.

@end

// A popup menu control within a command bar.
@interface PowerpointCommandBarPopup : PowerpointCommandBarControl

- (SBElementArray<PowerpointCommandBarControl *> *) commandBarControls;


@end

// Toolbars used in all of the Office applications.
@interface PowerpointCommandBar : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointCommandBarControl *> *) commandBarControls;

@property PowerpointMsoBarPosition barPosition;  // Returns or sets the position of the command bar.
@property (readonly) PowerpointMsoBarType barType;  // Returns the type of this command bar.
@property (readonly) BOOL builtIn;  // True if the command bar is built-in.
@property (copy, readonly) NSString *context;  // Returns or sets a string that determines where a command bar will be saved.
@property (readonly) BOOL embeddable;  // Returns if the command bar can be displayed inside the document window.
@property BOOL embedded;  // Returns or sets if the command bar will be displayed inside the document window.
@property BOOL enabled;  // Returns or set if the command bar is enabled.
@property (readonly) NSInteger entry_index;  // The index of the command bar.
@property NSInteger height;  // Returns or sets the height of the command bar.
@property NSInteger leftPosition;  // Returns or sets the left position of the command bar.
@property (copy) NSString *localName;  // Returns or sets the name of the command bar in the localized language of the application.  An error is returned when trying to set the local name of a built-in command bar.
@property (copy) NSString *name;  // Returns or sets the name of the command bar.
@property (copy) NSArray<NSAppleEventDescriptor *> *protection;  // Returns or sets the way a command bar is protected from user customization.  It accepts a list of the following items: no protection, no customize, no resize, no move, no change visible, no change dock, no vertical dock, no horizontal dock.
@property NSInteger rowIndex;  // Returns or sets the docking order of a command bar in relation to other command bars in the same docking area.  Can be an integer greater than zero.
@property NSInteger top;  // Returns or sets the top position of a command bar.
@property BOOL visible;  // Returns or sets if the command bar is visible.
@property NSInteger width;  // Returns or sets the width in pixels of the command bar.


@end

@interface PowerpointDocumentProperty : SBObject <PowerpointGenericMethods>

@property (copy) NSNumber *documentPropertyType;  // Returns or sets the document property type.
@property (copy) NSString *linkSource;  // Returns or sets the source of a lined custom document property.
@property BOOL linkToContent;  // True if the value of the document property is lined to the content of the container document.  False if the value is static.  This only applies to custom document properties.  For built-in properties this is always false.
@property (copy) NSString *name;  // Returns or sets the name of the document property.
@property (copy) NSString *value;  // Returns or sets the value of the document property.


@end

@interface PowerpointCustomDocumentProperty : PowerpointDocumentProperty


@end

@interface PowerpointWebPageFont : SBObject <PowerpointGenericMethods>

@property (copy) NSString *fixedWidthFont;  // Returns or sets the fixed-width font setting.
@property double fixedWidthFontSize;  // Returns or sets the fixed-width font size.  You can enter half-point sizes; if you enter other fractional point sizes, they are rounded up or down to the nearest half-point.
@property (copy) NSString *proportionalFont;  // Returns or sets the proportional font setting.
@property double proportionalFontSize;  // Returns or sets the proportional font size.  You can enter half-point sizes; if you enter other fractional point sizes, they are rounded up or down to the nearest half-point.


@end



/*
 * Microsoft PowerPoint Suite
 */

@interface PowerpointActionSetting : SBObject <PowerpointGenericMethods>

@property PowerpointEPPActionType action;
@property (copy) NSString *actionSettingToRun;
@property (copy, readonly) PowerpointSoundEffect *actionSoundEffect;
@property (copy) NSString *actionVerb;
@property BOOL animateAction;
@property (copy, readonly) PowerpointHyperlink *hyperlink;
@property (copy) NSString *slideShowName;


@end

@interface PowerpointAddIn : SBObject <PowerpointGenericMethods>

@property BOOL autoLoad;
@property (copy, readonly) NSString *fullName;
@property BOOL loaded;
@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *path;
@property BOOL registered;
@property (readonly) BOOL registeredInHKLM;


@end

@interface PowerpointAnimationBehavior : SBObject <PowerpointGenericMethods>

@property PowerpointMsoAnimAccumulate accumulate;
@property PowerpointMsoAnimAdditive additive;
@property PowerpointMsoAnimType animationBehaviorType;
@property (copy, readonly) PowerpointColorsEffect *colorsEffect;
@property (copy, readonly) PowerpointCommandEffect *commandEffect;
@property (copy, readonly) PowerpointFilterEffect *filterEffect;
@property (copy, readonly) PowerpointMotionEffect *motionEffect;
@property (copy, readonly) PowerpointPropertyEffect *propertyEffect;
@property (copy, readonly) PowerpointRotatingEffect *rotatingEffect;
@property (copy, readonly) PowerpointScaleEffect *scaleEffect;
@property (copy, readonly) PowerpointSetEffect *setEffect;
@property (copy, readonly) PowerpointTiming *timing;


@end

@interface PowerpointAnimationPoint : SBObject <PowerpointGenericMethods>

@property (copy) NSString *formula;
@property double time;
@property (copy) SBObject *value;


@end

@interface PowerpointAnimationSettings : SBObject <PowerpointGenericMethods>

@property double advanceTime;
@property PowerpointEPPAfterEffect afterEffect;
@property BOOL animate;
@property BOOL animateBackground;
@property BOOL animateTextInReverse;
@property NSInteger animationOrder;
@property (copy, readonly) PowerpointPlaySettings *animationPlaySettings;
@property (copy, readonly) PowerpointSoundEffect *animationSoundEffect;
@property PowerpointEPPChartUnitEffect chartUnitEffect;
@property (copy) NSArray<NSNumber *> *dimColor;
@property PowerpointMsoThemeColorIndex dimColorThemeIndex;
@property PowerpointEPPEntryEffect entryEffect;
@property PowerpointEPPTextLevelEffect textLevelEffect;
@property PowerpointEPPTextUnitEffect textUnitEffect;


@end

// An AppleScript object representing the Microsoft POWERPOINT application.
@interface PowerpointApplication (MicrosoftPowerPointSuite)

- (SBElementArray<PowerpointPresentation *> *) presentations;
- (SBElementArray<PowerpointDocumentWindow *> *) documentWindows;
- (SBElementArray<PowerpointSlideShowWindow *> *) slideShowWindows;
- (SBElementArray<PowerpointCommandBar *> *) commandBars;
- (SBElementArray<PowerpointAddIn *> *) addIns;

@property (copy, readonly) NSString *Version;
@property (copy, readonly) PowerpointPresentation *activePresentation;
@property (copy, readonly) NSString *activePrinter;
@property (copy, readonly) PowerpointDocumentWindow *activeWindow;
@property (copy, readonly) PowerpointAutocorrect *autocorrectObject;  // Returns the autocorrect object
@property PowerpointMsoAutomationSecurity automationSecurity;
@property (copy, readonly) NSString *build;
@property (copy, readonly) NSString *caption;
@property PowerpointEPPSaveAsFileType defaultSaveFormat;
@property (copy, readonly) PowerpointDefaultWebOptions *defaultWebOptionsObject;
@property (copy, readonly) NSString *name;
@property (copy, readonly) NSString *path;
@property (copy, readonly) PowerpointPreferences *preferenceObject;
@property (copy, readonly) PowerpointSaveAsMovieSettings *saveAsMovieSettingsObject;
@property BOOL startUpDialog;

@end

// Represents a single autocorrect entry.
@interface PowerpointAutocorrectEntry : SBObject <PowerpointGenericMethods>

@property (copy, readonly) NSString *autocorrectValue;  // Returns the value of the auto correct entry.
@property (readonly) NSInteger entry_index;  // Returns the index for the position of the object in its container element list.
@property (copy, readonly) NSString *name;  // Returns the name of the auto correct entry.


@end

// Represents the autocorrect functionality in PowerPoint.
@interface PowerpointAutocorrect : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointAutocorrectEntry *> *) autocorrectEntries;
- (SBElementArray<PowerpointFirstLetterException *> *) firstLetterExceptions;
- (SBElementArray<PowerpointTwoInitialCapsException *> *) twoInitialCapsExceptions;

@property BOOL correctDays;  // Returns if PowerPoint automatically capitalizes the first letter of days of the week.
@property BOOL correctInitialCaps;  // Returns if PowerPoint automatically makes the second letter lowercase if the first two letters of a word are typed in uppercase. For example, POwerPoint is corrected to PowerPoint.
@property BOOL correctSentenceCaps;  // Returns if PowerPoint automatically capitalizes the first letter in each sentence.
@property BOOL replaceText;  // Returns if Microsoft PowerPoint automatically replaces specified text with entries from the autocorrect list.


@end

// Represents an interface for broadcasting presentations
@interface PowerpointBroadcast : SBObject <PowerpointGenericMethods>

- (void) endSession;  // End a running broadcast session.
- (NSString *) getAttendeeURL;
- (BOOL) getIsBroadcasting;  // Returns true if the current presentation is being broadcast.
- (void) startServerUrl:(NSString *)serverUrl;  // Starts broadcasting to the given URL.

@end

@interface PowerpointBulletFormat : SBObject <PowerpointGenericMethods>

@property (copy) NSString *bulletCharacter;  // Returns or sets the Unicode character value that is used for bullets in the specified text.
@property (copy, readonly) PowerpointFont *bulletFont;  // Returns a font object that represents character formatting for a bullet format object.
@property (readonly) NSInteger bulletNumber;  // Returns the bullet number of a paragraph.
@property NSInteger bulletStartValue;
@property PowerpointMsoNumberedBulletStyle bulletStyle;  // Returns or sets a constant that represents the style of a bullet.
@property PowerpointMsoBulletType bulletType;  // Returns or sets a constant that represents the type of bullet.
@property double relativeSize;  // Returns or sets the bullet size relative to the size of the first text character in the paragraph.
@property BOOL useTextColor;  // Determines whether the specified bullets are set to the color of the first text character in the paragraph.
@property BOOL useTextFont;  // Determines whether the specified bullets are set to the font of the first text character in the paragraph.
@property BOOL visible;  // Returns or sets a value that specifies whether the bullet is visible.

- (void) setBulletPicturePictureFile:(NSString *)pictureFile;  // Sets the graphics file to be used for bullets in a bulleted list.

@end

@interface PowerpointColorScheme : SBObject <PowerpointGenericMethods>

- (NSArray<NSNumber *> *) getColorFromAt:(PowerpointEPPColorSchemeIndex)at;
- (void) setColorForAt:(PowerpointEPPColorSchemeIndex)at toColor:(NSArray<NSNumber *> *)toColor;

@end

@interface PowerpointColorsEffect : SBObject <PowerpointGenericMethods>

@property (copy) NSArray<NSNumber *> *by_color;
@property PowerpointMsoThemeColorIndex by_colorThemeIndex;  // Returns an object that represents a change to the color of the object by the specified number, expressed in RGB format.
@property (copy) NSArray<NSNumber *> *from_color;
@property PowerpointMsoThemeColorIndex from_colorThemeIndex;  // Returns or sets an object that represents the starting RGB color value of an animation behavior.
@property (copy) NSArray<NSNumber *> *to_color;
@property PowerpointMsoThemeColorIndex to_colorThemeIndex;  // Returns or sets an object that represents the RGB color value of an animation behavior.


@end

@interface PowerpointCommandEffect : SBObject <PowerpointGenericMethods>

@property (copy) NSString *command;
@property PowerpointMsoAnimCommandType type;


@end

@interface PowerpointCustomLayout : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointShape *> *) shapes;

@property (copy, readonly) PowerpointShape *background;
@property (copy, readonly) PowerpointDesign *design;
@property BOOL displayMasterShapes;
@property BOOL followMasterBackground;
@property (copy, readonly) PowerpointHeadersAndFooters *headersAndFooters;
@property (readonly) double height;
@property (copy, readonly) PowerpointThemeColorScheme *themeColorScheme;  // Returns the color scheme of a custom layout.
@property (copy, readonly) PowerpointTimeline *timeline;
@property (readonly) double width;


@end

@interface PowerpointDefaultWebOptions : SBObject <PowerpointGenericMethods>

@property BOOL allowPNG;
@property BOOL alwaysSaveInDefaultEncoding;
@property BOOL checkIfOfficeIsHTMLEditor;
@property PowerpointMsoEncoding encoding;
@property BOOL updateLinksOnSave;


@end

@interface PowerpointDesign : SBObject <PowerpointGenericMethods>

@property (copy, readonly) PowerpointMaster *slideMaster;


@end

@interface PowerpointDocumentWindow : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointPane *> *) panes;

@property (readonly) BOOL active;
@property (copy, readonly) PowerpointPane *activePane;
@property BOOL blackAndWhite;
@property (copy, readonly) NSString *caption;
@property (readonly) NSInteger entry_index;
@property double height;
@property double leftPosition;
@property (copy, readonly) PowerpointPresentation *presentation;
@property (copy, readonly) PowerpointSelection *selection;  // Represents the selection in the specified document window.
@property NSInteger splitHorizontal;
@property NSInteger splitVertical;
@property double top;
@property (copy, readonly) PowerpointView *view;
@property PowerpointEPPViewType viewType;
@property double width;

- (void) collapseSectionAtPosition:(NSInteger)atPosition;
- (void) expandSectionAtPosition:(NSInteger)atPosition;
- (BOOL) getIsExpandedOfSectionAtPosition:(NSInteger)atPosition;
- (void) launchSpellerOn;

@end

@interface PowerpointEffectInformation : SBObject <PowerpointGenericMethods>

@property (readonly) PowerpointMsoAnimAfterEffect afterEffectInformation;
@property (readonly) BOOL animateBackgroundInformation;
@property (readonly) BOOL animateTextInReverseInformation;
@property (readonly) PowerpointMsoAnimateByLevel buildByLevel;
@property (copy, readonly) NSArray<NSNumber *> *dim;
@property (copy, readonly) PowerpointPlaySettings *playSettingsInformation;
@property (copy, readonly) PowerpointSoundEffect *soundEffectInformation;
@property (readonly) PowerpointMsoAnimTextUnitEffect textUnitEffectInformation;


@end

@interface PowerpointEffectParameters : SBObject <PowerpointGenericMethods>

@property double amount;
@property (copy, readonly) NSArray<NSNumber *> *color2;
@property (readonly) PowerpointMsoThemeColorIndex color2ColorThemeIndex;  // Returns an object that represents the color on which to end a color-cycle animation.
@property PowerpointMsoAnimDirection direction;
@property (copy) NSString *font2;
@property BOOL relative;
@property double size2;


@end

@interface PowerpointEffect : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointAnimationBehavior *> *) animationBehaviors;

@property PowerpointMsoAnimEffect animationEffectType;
@property (copy, readonly) PowerpointEffectInformation *effectInformation;
@property (copy, readonly) PowerpointEffectParameters *effectParameters;
@property BOOL exitAnimation;
@property (copy, readonly) NSString *name;
@property (copy) PowerpointShape *shape;
@property NSInteger targetParagraph;
@property (readonly) NSInteger textRangeLength;
@property (readonly) NSInteger textRangeStart;
@property (copy, readonly) PowerpointTiming *timing;

- (PowerpointAnimationBehavior *) addBehaviorType:(PowerpointMsoAnimType)type;  // add an animation behavior

@end

@interface PowerpointFilterEffect : SBObject <PowerpointGenericMethods>

@property PowerpointMsoAnimFilterEffectType filterType;
@property BOOL reveal;
@property PowerpointMsoAnimFilterEffectSubtype subtype;


@end

// Represents an abbreviation excluded from automatic correction.
@interface PowerpointFirstLetterException : SBObject <PowerpointGenericMethods>

@property (readonly) NSInteger entry_index;  // Returns the index for the position of the object in its container element list.
@property (copy, readonly) NSString *name;  // Returns the name of the FirstLetterException.


@end

// Contains font attributes, such as font name, size, and color, for an object.
@interface PowerpointFont : SBObject <PowerpointGenericMethods>

@property (copy) NSString *ASCIIName;  // Returns or sets the font used for Latin text; characters with character codes from 0 through 127.
@property BOOL autoRotateNumbers;  // Returns or sets a value that specifies whether the numbers in a numbered list should be rotated when the text is rotated.
@property double baseLineOffset;  // Returns or sets a value specifying the horizontaol offset of the selected font.
@property BOOL bold;  // Returns or sets a value specifying whether the font should be bold.
@property PowerpointMsoTextCaps capsType;  // Returns or sets a value specifying how the text should be capitalized.
@property (copy) NSString *eastAsianName;  // Returns or sets the font name used for Asian text.
@property (readonly) BOOL embedable;  // Returns a value indicating whether the font can be embedded in a page.
@property (readonly) BOOL embedded;  // Returns a value specifying whether the font is embedded in a page.
@property BOOL emboss;
@property BOOL equalizeCharacterHeight;  // Returns or sets a value specifying whether the text should have the same horizontal height.
@property (copy, readonly) PowerpointFillFormat *fillFormat;  // Returns a value specifying the fill formatting for text.
@property (copy) NSArray<NSNumber *> *fontColor;
@property PowerpointMsoThemeColorIndex fontColorThemeIndex;  // Returns or sets the color for the specified font.
@property (copy) NSString *fontName;  // Returns or sets a value specifying the font to use for a selection.
@property (copy) NSString *fontNameOther;  // Returns or sets the font used for characters whose character set numbers are greater than 127.
@property double fontSize;
@property (copy, readonly) PowerpointGlowFormat *glowFormat;  // Returns a value specifying the glow formatting of the text.
@property (copy) NSArray<NSNumber *> *highlightColor;  // Returns or sets the text highlight color for object.
@property PowerpointMsoThemeColorIndex highlightColorThemeIndex;  // Returns or sets the specified text highlight color for object.
@property BOOL italic;
@property double kerning;  // Returns or sets a value specifying the amount of spacing between text characters.
@property (copy, readonly) PowerpointLineFormat *lineFormat;  // Returns a value specifiying the line formatting of the text.
@property (copy, readonly) PowerpointReflectionFormat *reflectionFormat;  // Returns a value specifying the reflection formatting of the text.
@property (copy, readonly) PowerpointShadowFormat *shadowFormat;  // Returns the value specifying the type of shadow effect for the selection of text.
@property PowerpointMsoSoftEdgeType softEdgeFormat;  // Returns or sets a value specifying the soft edge fromatting of the text.
@property double spacing;  // Returns or sets a value specifying the spacing between characters in a selection of text.
@property PowerpointMsoTextStrike strikeType;  // Returns or sets a value specifying the strike format used for a selection of text.
@property BOOL subscript;  // Returns or sets a value specifying that the selected text should be displayed a subscript.
@property BOOL superscript;  // Returns or sets a value specifying that the selected text should be displayed a superscript.
@property double transparency;
@property BOOL underline;
@property (copy) NSArray<NSNumber *> *underlineColor;  // Returns or sets the 24-bit color of the underline for the specified font object.
@property PowerpointMsoThemeColorIndex underlineColorThemeIndex;  // Returns a value specifying the color of the underline for the selected text.
@property PowerpointMsoTextUnderlineType underlineStyle;  // Returns or sets a value specifying the underline style for the selected text.
@property PowerpointMsoPresetTextEffect wordArtStylesFormat;  // Returns or sets a value specifying the text effect for the selected text.


@end

@interface PowerpointHeaderOrFooter : SBObject <PowerpointGenericMethods>

@property PowerpointEPPDateTimeFormat dateFormat;
@property (copy) NSString *headerFooterText;
@property BOOL useDateFormat;
@property BOOL visible;


@end

@interface PowerpointHeadersAndFooters : SBObject <PowerpointGenericMethods>

@property (copy, readonly) PowerpointHeaderOrFooter *dateAndTime;
@property BOOL displayHeadersFootersOnTitleSlide;
@property (copy, readonly) PowerpointHeaderOrFooter *footer;
@property (copy, readonly) PowerpointHeaderOrFooter *header;
@property (copy, readonly) PowerpointHeaderOrFooter *slideNumber;


@end

@interface PowerpointHyperlink : SBObject <PowerpointGenericMethods>

@property (copy) NSString *hyperlinkAddress;
@property (copy) NSString *hyperlinkSubAddress;
@property (copy, readonly) id hyperlinkType;


@end

@interface PowerpointMaster : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointShape *> *) shapes;
- (SBElementArray<PowerpointHyperlink *> *) hyperlinks;
- (SBElementArray<PowerpointCustomLayout *> *) customLayouts;

@property (copy, readonly) PowerpointShape *background;
@property (copy, readonly) PowerpointColorScheme *colorScheme;
@property (copy, readonly) PowerpointDesign *design;
@property (copy, readonly) PowerpointHeadersAndFooters *headersAndFooters;
@property (readonly) double height;
@property (copy, readonly) PowerpointOfficeTheme *theme;
@property (copy, readonly) PowerpointTimeline *timeline;
@property (readonly) double width;

- (PowerpointTextStyle *) getTextStyleFromAt:(PowerpointPpTextStyleType)at;

@end

@interface PowerpointMotionEffect : SBObject <PowerpointGenericMethods>

@property double byX;
@property double byY;
@property double fromX;
@property double fromY;
@property (copy) NSString *path;
@property double toX;
@property double toY;


@end

@interface PowerpointNamedSlideShow : SBObject <PowerpointGenericMethods>

@property (copy, readonly) NSString *name;
@property (readonly) NSInteger numberOfSlides;
@property (copy, readonly) NSArray<NSNumber *> *slideIDs;


@end

@interface PowerpointPageSetup : SBObject <PowerpointGenericMethods>

@property NSInteger firstSlideNumber;
@property PowerpointMsoOrientation notesOrientation;
@property PowerpointMsoOrientation slideOrientation;
@property PowerpointEPPSlideSizeType slideSize;
@property double slideWidth;


@end

@interface PowerpointPane : SBObject <PowerpointGenericMethods>

@property (readonly) BOOL active;
@property (readonly) PowerpointEPPViewType paneViewType;


@end

@interface PowerpointParagraphFormat : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointTabStop *> *) tabStops;

@property PowerpointMsoParagraphAlignment alignment;
@property PowerpointMsoBaselineAlignment baselineAlignment;  // Returns or sets a constant that represents the vertical position of fonts in a paragraph.
@property (copy, readonly) PowerpointBulletFormat *bulletFormat;
@property BOOL eastAsianLineBreakControl;
@property double firstLineIndent;  // Returns or sets the value, in points, for a first line or hanging indent.
@property BOOL hangingPunctuation;  // Determines whether hanging punctuation is enabled for the specified paragraphs.
@property NSInteger indentLevel;  // Returns or sets a value representing the indent level assigned to text in the selected paragraph.
@property double leftIndent;  // Returns or sets a value that represents the left indent value, in points, for the specified paragraphs.
@property BOOL lineRuleAfter;  // Determines whether line spacing after the last line in each paragraph is set to a specific number of points or lines.
@property BOOL lineRuleBefore;  // Determines whether line spacing before the first line in each paragraph is set to a specific number of points or lines.
@property BOOL lineRuleWithin;  // Determines whether line spacing between base lines is set to a specific number of points or lines.
@property double rightIndent;  // Returns or sets the right indent, in points, for the specified paragraphs.
@property double spaceAfter;  // Returns or sets the spacing, in points, after the specified paragraphs.
@property double spaceBefore;  // Returns or sets the spacing, in points, before the specified paragraphs.
@property double spaceWithin;  // Returns or sets the amount of space between base lines in the specified paragraph, in points or lines.
@property PowerpointMsoTextDirection textDirection;  // Returns or sets the text direction for the specified paragraph.
@property BOOL wordWrap;  // Determines whether the application wraps the Latin text in the middle of a word in the specified paragraphs.


@end

@interface PowerpointPlaySettings : SBObject <PowerpointGenericMethods>

@property BOOL hideWhileNotPlaying;
@property BOOL loopUntilStopped;
@property BOOL pauseAnimation;
@property BOOL playOnEntry;
@property BOOL rewindMove;
@property NSInteger stopAfterSlides;


@end

// Represents an interface for playing movies
@interface PowerpointPlayer : SBObject <PowerpointGenericMethods>

@property NSInteger currentPosition;
@property (readonly) PowerpointEPPPlayerState playerState;

- (void) goToNextBookmarkForPlayer;  // Advance the player to the next bookmark.
- (void) goToPreviousBookmarkForPlayer;  // Rewind the player to the previous bookmark.
- (void) pausePlayer;  // Pause playback.
- (void) playPlayer;  // Begin or resume playback.
- (void) stopPlayer;  // Stop playback.

@end

@interface PowerpointPreferences : SBObject <PowerpointGenericMethods>

@property NSInteger alwaysSuggestCorrections;
@property NSInteger appendDOSExtentions;
@property NSInteger autoFit;
@property NSInteger autoRecoveryFrequency;
@property NSInteger backgroundSpelling;
@property NSInteger compressFile;
@property NSInteger defaultView;
@property NSInteger dragDrop;
@property NSInteger endBlankSlide;
@property NSInteger filePropertiesPrompt;
@property NSInteger hideSpellingErrors;
@property NSInteger ignoreNumbersInWords;
@property NSInteger ignoreUppercase;
@property NSInteger optionBitmap;
@property NSInteger rulerUnits;
@property NSInteger saveAutoRecovery;
@property NSInteger showVerticalRuler;
@property NSInteger slideShowControl;
@property NSInteger slideShowRightMouse;
@property NSInteger smartCutPaste;
@property NSInteger smartQuotes;
@property NSInteger undoLevelCount;
@property (copy) NSString *userInitials;
@property (copy) NSString *userName;
@property NSInteger wordSelection;


@end

@interface PowerpointPresentation : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointSlide *> *) slides;
- (SBElementArray<PowerpointColorScheme *> *) colorSchemes;
- (SBElementArray<PowerpointFont *> *) fonts;
- (SBElementArray<PowerpointDocumentWindow *> *) documentWindows;
- (SBElementArray<PowerpointDocumentProperty *> *) documentProperties;
- (SBElementArray<PowerpointCustomDocumentProperty *> *) customDocumentProperties;
- (SBElementArray<PowerpointDesign *> *) designs;

@property (copy, readonly) PowerpointBroadcast *broadcast;
@property (copy, readonly) PowerpointShape *defaultShape;
@property PowerpointEPPFarEastLineBreakLevel eastAsianLineBreakLevel;  // Returns or sets the East Asian line break control level for the specified paragraph.
@property (copy, readonly) NSString *fullName;
@property (copy, readonly) PowerpointMaster *handoutMaster;
@property (readonly) BOOL hasTitleMaster;
@property (readonly) BOOL isProtected;  // Returns true if the presentation is protected by Information Rights Management.
@property PowerpointMsoTextDirection layoutDirection;
@property (copy, readonly) NSString *name;
@property (copy) NSString *noLineBreakAfter;
@property (copy) NSString *noLineBreakBefore;
@property (copy, readonly) PowerpointMaster *notesMaster;
@property (copy, readonly) PowerpointPageSetup *pageSetup;
@property (copy) NSString *password;  // The password for opening the presentation
@property (copy, readonly) NSString *path;
@property (copy, readonly) PowerpointPrintOptions *printOptions;
@property (readonly) BOOL readOnly;
@property (copy, readonly) PowerpointSaveAsMovieSettings *saveAsMovieSettings;
@property BOOL saved;
@property (copy, readonly) PowerpointSectionProperties *sectionProperties;
@property (copy, readonly) PowerpointMaster *slideMaster;
@property (copy, readonly) PowerpointSlideShowSettings *slideShowSettings;
@property (copy, readonly) PowerpointSlideShowWindow *slideShowWindow;
@property (copy, readonly) NSString *templateName;
@property (copy, readonly) PowerpointMaster *titleMaster;
@property (copy, readonly) PowerpointWebOptions *webOptions;
@property (copy) NSString *writePassword;  // The password for saving changes to the presentation

- (PowerpointDesign *) addDesignDesignName:(NSString *)DesignName index:(NSInteger)index;  // add a new design
- (void) applyTemplateFileName:(NSString *)fileName;  // Applies a theme or design template to the specified slide, master or presentation
- (BOOL) canCheckIn;  // Returns True if PowerPoint can check in a specified presentation to a server.
- (void) checkInSaveChanges:(BOOL)saveChanges comments:(NSString *)comments makePublic:(BOOL)makePublic;  // Returns a presentation from a local computer to a server, and sets the local file to read-only so that it cannot be edited locally.
- (void) checkInWithVersionSaveChanges:(BOOL)saveChanges comments:(NSString *)comments makePublic:(BOOL)makePublic versionType:(PowerpointEPPCheckInVersionType)versionType;  // Returns a presentation from a local computer to a server, and sets the local file to read-only so that it cannot be edited locally.
- (void) printOutFrom:(NSInteger)from to:(NSInteger)to printToFile:(NSString *)printToFile copies:(NSInteger)copies collate:(BOOL)collate showDialog:(BOOL)showDialog;
- (void) redoTimes:(NSInteger)times;
- (void) undoTimes:(NSInteger)times;
- (void) updateLinks;

@end

@interface PowerpointPresenterTool : SBObject <PowerpointGenericMethods>

@property (copy, readonly) PowerpointSlide *currentPresenterSlide;
@property (readonly) NSInteger currentSlideInShow;
@property (readonly) double elapsedTime;
@property (readonly) NSInteger maxSlidesInShow;
@property (copy) NSString *notesText;
@property NSInteger notesZoom;
@property (readonly) BOOL slideMiniature;

- (void) endShow;
- (void) next;
- (void) pauseTimer;
- (void) previous;
- (void) resetTimer;
- (void) startTimer;
- (void) swapDisplays;
- (void) toggleSlideMiniature;

@end

@interface PowerpointPresenterViewWindow : SBObject <PowerpointGenericMethods>

@property (readonly) BOOL active;
@property (readonly) double height;
@property (copy, readonly) PowerpointPresentation *presentation;
@property (copy, readonly) PowerpointPresenterTool *presenterTool;
@property (readonly) double width;


@end

@interface PowerpointPrintOptions : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointPrintRange *> *) printRanges;

@property (copy, readonly) NSString *activePrinter;
@property BOOL collate;
@property BOOL fitToPage;
@property BOOL frameSlides;
@property NSInteger numberOfCopies;
@property PowerpointEPPPrintOutputType outputType;
@property PowerpointEPPPrintColorType printColorType;
@property BOOL printFontsAsGraphics;
@property BOOL printHiddenSlides;
@property PowerpointEPPPrintRangeType rangeType;
@property NSInteger sectionIndex;
@property (copy) NSString *slideShowName;


@end

@interface PowerpointPrintRange : SBObject <PowerpointGenericMethods>

@property (readonly) NSInteger rangeEnd;
@property (readonly) NSInteger rangeStart;


@end

@interface PowerpointPropertyEffect : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointAnimationPoint *> *) animationPoints;

@property (copy, readonly) id ending;
@property PowerpointMsoAnimProperty propertySetEffect;
@property (copy, readonly) id starting;


@end

@interface PowerpointRotatingEffect : SBObject <PowerpointGenericMethods>

@property double rotating;


@end

@interface PowerpointRulerLevel : SBObject <PowerpointGenericMethods>

@property double firstMargin;  // Returns or sets the first-line indent for the specified outline level, in points.
@property double leftMargin;  // Returns or sets the left indent for the specified outline level, in points.


@end

// Represents the ruler for the text in the specified shape or for all text in the specified text style. Contains tab stops and the indentation settings for text outline levels.
@interface PowerpointRuler : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointTabStop *> *) tabStops;
- (SBElementArray<PowerpointRulerLevel *> *) rulerLevels;


@end

@interface PowerpointSaveAsMovieSettings : SBObject <PowerpointGenericMethods>

@property BOOL autoLoopEnabled;
@property (copy) NSString *backgroundSoundTrackFile;
@property NSInteger backgroundTrackSegmentEnd;
@property NSInteger backgroundTrackSegmentStart;
@property NSInteger backgroundTrackStart;
@property BOOL createMoviePreview;
@property BOOL forceAllInline;
@property BOOL includeNarrationAndSounds;
@property (copy) NSString *movieActors;
@property (copy) NSString *movieAuthor;
@property (copy) NSString *movieCopyright;
@property NSInteger movieFrameHeight;
@property NSInteger movieFrameWidth;
@property (copy) NSString *movieProducer;
@property PowerpointEPPMovieOptimization optimization;
@property BOOL showMovieController;
@property (copy) NSString *transitionDescription;
@property BOOL useSingleTransition;


@end

@interface PowerpointScaleEffect : SBObject <PowerpointGenericMethods>

@property double byX;
@property double byY;
@property double fromX;
@property double fromY;
@property double toX;
@property double toY;


@end

@interface PowerpointSectionProperties : SBObject <PowerpointGenericMethods>

- (void) deleteSectionAtPosition:(NSInteger)atPosition deletingSlides:(BOOL)deletingSlides;
- (NSInteger) getCountOfSections;
- (NSInteger) getFirstSlideOfSectionAtPosition:(NSInteger)atPosition;
- (NSString *) getIdOfSectionAtPosition:(NSInteger)atPosition;
- (NSString *) getNameOfSectionAtPosition:(NSInteger)atPosition;
- (NSInteger) getSlideCountOfSectionAtPosition:(NSInteger)atPosition;
- (NSInteger) insertSectionBeforeSection:(NSInteger)beforeSection beforeSlide:(NSInteger)beforeSlide titled:(NSString *)titled;
- (void) moveSectionAtPosition:(NSInteger)atPosition toPosition:(NSInteger)toPosition;
- (void) renameSectionAtPosition:(NSInteger)atPosition to:(NSString *)to;

@end

// Represents the selection in the specified document window
@interface PowerpointSelection : SBObject <PowerpointGenericMethods>

@property (copy, readonly) PowerpointShapeRange *childShapeRange;  // Returns the child shapes of a selection.
@property (readonly) BOOL hasChildShapeRange;  // Returns whether the selection contains child shapes.
@property (readonly) PowerpointEPPSelectionType selectionType;  // Represents the type of objects in a selection.
@property (copy, readonly) PowerpointShapeRange *shapeRange;  // Returns a collection of shapes selected on the specified slide.
@property (copy, readonly) PowerpointSlideRange *slideRange;  // Returns a collection of selected slides.
@property (copy, readonly) PowerpointTextRange *textRange;  // Returns the text and text properties of the selected text.

- (void) unselect;  // Cancels the current selection.

@end

@interface PowerpointSequence : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointEffect *> *) effects;

- (PowerpointEffect *) addEffectFor:(PowerpointShape *)for_ fx:(PowerpointMsoAnimEffect)fx level:(PowerpointMsoAnimateByLevel)level trigger:(PowerpointMsoAnimTriggerType)trigger index:(NSInteger)index;  // add an effect for a shape
- (PowerpointEffect *) convertToTextUnitEffectEffect:(PowerpointEffect *)Effect unit:(PowerpointMsoAnimTextUnitEffect)unit;  // convert an effect to a text unit effect

@end

@interface PowerpointSetEffect : SBObject <PowerpointGenericMethods>

@property (copy) id ending;
@property PowerpointMsoAnimProperty propertySetEffect;


@end

// A collection that represents a notes page or a slide range, which is a set of slides that can contain a single slide to as many as all slides in a presentation.
@interface PowerpointSlideRange : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointSlide *> *) slides;
- (SBElementArray<PowerpointShape *> *) shapes;
- (SBElementArray<PowerpointHyperlink *> *) hyperlinks;

@property (copy) PowerpointColorScheme *colorScheme;  // Returns or sets the color scheme for the specified slide, slide range, or slide master.
@property (copy) PowerpointCustomLayout *customLayout;  // Returns the custom layout associated with the specified range of slides.
@property (copy) PowerpointDesign *design;
@property BOOL displayMasterShapes;  // Determines whether the specified range of slides displays the background objects on the slide master.
@property BOOL followMasterBackground;  // Determines whether the range of slides follows the slide master background.
@property (copy, readonly) PowerpointHeadersAndFooters *headersAndFooters;  // Returns a collection that represents the header, footer, date and time, and slide number associated with the slide, slide master, or range of slides.
@property PowerpointEPPSlideLayout layout;  // Returns or sets the slide layout.
@property (copy, readonly) PowerpointSlideRange *notesPage;  // Returns a slide range object that represents the notes pages for the specified slide or range of slides.
@property (readonly) NSInteger printSteps;
@property (readonly) NSInteger slideID;
@property (readonly) NSInteger slideIndex;
@property (copy, readonly) PowerpointMaster *slideMaster;  // Returns the slide master.
@property (readonly) NSInteger slideNumber;  // Returns the slide number.
@property (copy, readonly) PowerpointSlideShowTransition *slideShowTransitions;  // Returns the special effects for the specified slide transition.
@property (copy, readonly) PowerpointTimeline *timeline;  // Returns the animation timeline for the slide.


@end

@interface PowerpointSlideShowSettings : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointNamedSlideShow *> *) namedSlideShows;

@property PowerpointEPPSlideShowAdvanceMode advanceMode;
@property NSInteger endingSlide;
@property BOOL loopUntilStopped;
@property (copy) NSArray<NSNumber *> *pointerColor;
@property PowerpointMsoThemeColorIndex pointerColorThemeIndex;  // Returns or sets the color of  default pointer color for a presentation.
@property PowerpointEPPSlideShowRangeType rangeType;
@property PowerpointEPPSlideShowType showType;
@property (readonly) BOOL showWithAnimation;
@property BOOL showWithNarration;
@property BOOL showWithPresenter;
@property (copy) NSString *slideShowName;
@property NSInteger startingSlide;

- (PowerpointSlideShowWindow *) runSlideShow;

@end

@interface PowerpointSlideShowTransition : SBObject <PowerpointGenericMethods>

@property BOOL advanceOnClick;
@property BOOL advanceOnTime;
@property double advanceTime;
@property PowerpointEPPEntryEffect entryEffect;
@property BOOL hidden;
@property BOOL loopSoundUntilNext;
@property (copy, readonly) PowerpointSoundEffect *soundEffectTransition;
@property double transitionDuration;


@end

@interface PowerpointSlideShowView : SBObject <PowerpointGenericMethods>

@property BOOL accelerationsEnabled;
@property (readonly) NSInteger currentShowPosition;
@property (readonly) BOOL isNamedShow;
@property (copy, readonly) PowerpointSlide *lastSlideViewed;
@property (copy) NSArray<NSNumber *> *pointerColor;
@property PowerpointMsoThemeColorIndex pointerColorThemeIndex;  // Returns or sets the color of temporary pointer color for a view of a slide show.
@property PowerpointEPPSlideShowPointerType pointerType;
@property (readonly) double presentationElapsedTime;
@property (copy, readonly) PowerpointSlide *slide;
@property double slideElapsedTime;
@property (copy, readonly) NSString *slideShowName;
@property PowerpointEPPSlideShowState slideState;
@property (readonly) NSInteger zoom;

- (void) exitSlideShow;
- (void) goToFirstSlide;
- (void) goToLastSlide;
- (void) goToNextSlide;
- (void) goToPreviousSlide;
- (void) resetSlideTime;

@end

@interface PowerpointSlideShowWindow : SBObject <PowerpointGenericMethods>

@property (readonly) BOOL active;
@property NSRect bounds;
@property double height;
@property (readonly) BOOL isFullScreen;
@property double leftPosition;
@property (copy, readonly) PowerpointPresentation *presentation;
@property (copy, readonly) PowerpointSlideShowView *slideshowView;
@property double top;
@property double width;


@end

@interface PowerpointSlide : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointShape *> *) shapes;
- (SBElementArray<PowerpointHyperlink *> *) hyperlinks;

@property (copy, readonly) PowerpointShape *background;
@property (copy) PowerpointColorScheme *colorScheme;
@property (copy) PowerpointCustomLayout *customLayout;
@property (copy) PowerpointDesign *design;
@property BOOL displayMasterShapes;
@property BOOL followMasterBackground;
@property (copy, readonly) PowerpointHeadersAndFooters *headersAndFooters;
@property PowerpointEPPSlideLayout layout;
@property (copy, readonly) PowerpointSlide *notesPage;
@property (readonly) NSInteger printSteps;
@property (readonly) NSInteger sectionIndex;
@property (readonly) NSInteger sectionNumber;
@property (readonly) NSInteger slideID;
@property (readonly) NSInteger slideIndex;
@property (copy, readonly) PowerpointMaster *slideMaster;
@property (readonly) NSInteger slideNumber;
@property (copy, readonly) PowerpointSlideShowTransition *slideShowTransition;
@property (copy, readonly) PowerpointTimeline *timeline;

- (void) applyThemeColorSchemeFileName:(NSString *)fileName;  // Applies a theme color to the specified slide.
- (void) copyObject;
- (void) cutObject;
- (void) moveToStartOfSectionAtPosition:(NSInteger)atPosition;

@end

@interface PowerpointSoundEffect : SBObject <PowerpointGenericMethods>

@property (copy, readonly) NSString *name;
@property PowerpointEPPSoundEffectType soundType;

- (void) importSoundFileSoundFileName:(NSString *)soundFileName;
- (void) playSoundEffect;

@end

// Represents a single tab stop.
@interface PowerpointTabStop : SBObject <PowerpointGenericMethods>

@property double tabPosition;  // Returns or sets the position of a tab stop relative to the left margin.
@property PowerpointMsoTabStopType tabStopType;  // Returns or sets the type of the tab stop object.


@end

@interface PowerpointTextStyleLevel : SBObject <PowerpointGenericMethods>

@property (copy, readonly) PowerpointFont *font;
@property (copy, readonly) PowerpointParagraphFormat *paragraphFormat;


@end

@interface PowerpointTextStyle : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointTextStyleLevel *> *) textStyleLevels;

@property (copy, readonly) PowerpointRuler *ruler;
@property (copy, readonly) PowerpointTextFrame *textFrame;


@end

@interface PowerpointTimeline : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointSequence *> *) sequences;

@property (copy, readonly) PowerpointSequence *mainSequence;

- (PowerpointSequence *) addSequenceIndex:(NSInteger)index;  // add an interactive sequence

@end

@interface PowerpointTiming : SBObject <PowerpointGenericMethods>

@property double acceleration;
@property BOOL autoreverse;
@property double deceleration;
@property double duration;
@property NSInteger repeatCount;
@property double repeatDuration;
@property PowerpointMsoAnimEffectRestart restart;
@property BOOL rewind;
@property BOOL smoothEnd;
@property BOOL smoothStart;
@property double speed;


@end

// Represents a single initial-capital autocorrect exception.
@interface PowerpointTwoInitialCapsException : SBObject <PowerpointGenericMethods>

@property (readonly) NSInteger entry_index;  // Returns the index for the position of the object in its container element list.
@property (copy, readonly) NSString *name;  // Returns the name of the TwoInitialCapsException.


@end

@interface PowerpointView : SBObject <PowerpointGenericMethods>

@property BOOL displaySlideMiniature;
@property (copy) PowerpointSlide *slide;
@property (readonly) PowerpointEPPViewType viewType;
@property NSInteger zoom;
@property BOOL zoomToFit;

- (void) goToSlideNumber:(NSInteger)number;

@end

@interface PowerpointWebOptions : SBObject <PowerpointGenericMethods>

@property BOOL allowPNG;
@property PowerpointMsoEncoding encoding;


@end



/*
 * Drawing Suite
 */

@interface PowerpointAdjustment : SBObject <PowerpointGenericMethods>

@property double adjustment_value;


@end

@interface PowerpointCalloutFormat : SBObject <PowerpointGenericMethods>

@property BOOL accent;
@property PowerpointMsoCalloutAngleType angle;
@property BOOL autoAttach;
@property (readonly) BOOL autoLength;
@property BOOL border;
@property (readonly) double calloutFormatLength;
@property PowerpointMsoCalloutType calloutType;
@property (readonly) double drop;
@property (readonly) PowerpointMsoCalloutDropType dropType;
@property double gap;

- (void) presetDropDropType:(PowerpointMsoCalloutDropType)dropType;

@end

@interface PowerpointConnectorFormat : SBObject <PowerpointGenericMethods>

@property (readonly) BOOL beginConnected;
@property (copy, readonly) PowerpointShape *beginConnectedShape;
@property (readonly) NSInteger beginConnectionSite;
@property PowerpointMsoConnectorType connectorType;
@property (readonly) BOOL endConnected;
@property (copy, readonly) PowerpointShape *endConnectedShape;
@property (readonly) NSInteger endConnectionSite;


@end

// Represents fill formatting for a shape. A shape can have a solid, gradient, texture, pattern, picture, or semi-transparent fill.
@interface PowerpointFillFormat : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointGradientStop *> *) gradientStops;

@property (copy) NSArray<NSNumber *> *backColor;
@property PowerpointMsoThemeColorIndex backColorThemeIndex;  // Returns or sets the specified fill background color.
@property (readonly) PowerpointMsoFillType fillFormatType;
@property (copy) NSArray<NSNumber *> *foreColor;
@property PowerpointMsoThemeColorIndex foreColorThemeIndex;  // Returns or sets the specified foreground fill or solid color.
@property (readonly) PowerpointMsoGradientColorType gradientColorType;
@property (readonly) double gradientDegree;
@property (readonly) PowerpointMsoGradientStyle gradientStyle;
@property (readonly) NSInteger gradientVariant;
@property (readonly) PowerpointMsoPatternType pattern;
@property (readonly) PowerpointMsoPresetGradientType presetGradientType;
@property (readonly) PowerpointMsoPresetTexture presetTexture;
@property BOOL rotateWithObject;  // Returns or sets whether the fill rotates with the specified shape.
@property PowerpointMsoTextureAlignment textureAlignment;  // Returns or sets the texture alignment for the specified object.
@property double textureHorizontalScale;  // Returns or sets the texture alignment for the specified object.
@property (copy, readonly) NSString *textureName;
@property double textureOffsetX;  // Returns or sets the texture alignment for the specified object.
@property double textureOffsetY;  // Returns or sets the texture alignment for the specified object.
@property BOOL textureTile;  // Returns the texture tile style for the specified fill.
@property double textureVerticalScale;  // Returns or sets the texture alignment for the specified object.
@property double transparency;
@property BOOL visible;

- (void) deleteGradientStopStopIndex:(NSInteger)stopIndex;  // Removes a gradient stop.
- (void) insertGradientStopCustomColor:(NSArray<NSNumber *> *)customColor position:(double)position transparency:(double)transparency stopIndex:(NSInteger)stopIndex;  // Adds a stop to a gradient.

@end

// Represents the glow formatting for a shape or range of shapes
@interface PowerpointGlowFormat : SBObject <PowerpointGenericMethods>

@property (copy) NSArray<NSNumber *> *color;  // Returns or sets the color for the specified glow format.
@property PowerpointMsoThemeColorIndex colorThemeIndex;  // Returns or sets the color for the specified glow format.
@property double radius;  // Returns or sets the length of the radius for the specified glow format.


@end

// Represents one gradient stop.
@interface PowerpointGradientStop : SBObject <PowerpointGenericMethods>

@property (copy) NSArray<NSNumber *> *color;  // Returns or sets the color for the specified the gradient stop.
@property PowerpointMsoThemeColorIndex colorThemeIndex;  // Returns or sets the color for the specified gradient stop.
@property double position;  // Returns or sets the position for the specified gradient stop expressed as a percent.
@property double transparency;  // Returns or sets a value representing the transparency of the gradient fill expressed as a percent.


@end

@interface PowerpointLineFormat : SBObject <PowerpointGenericMethods>

@property (copy) NSArray<NSNumber *> *backColor;
@property PowerpointMsoThemeColorIndex backColorThemeIndex;  // Returns or sets the background color for a patterned line.
@property PowerpointMsoArrowheadLength beginArrowHeadLength;
@property PowerpointMsoArrowheadStyle beginArrowheadStyle;
@property PowerpointMsoArrowheadWidth beginArrowheadWidth;
@property PowerpointMsoLineDashStyle dashStyle;
@property PowerpointMsoArrowheadLength endArrowheadLength;
@property PowerpointMsoArrowheadStyle endArrowheadStyle;
@property PowerpointMsoArrowheadWidth endArrowheadWidth;
@property (copy) NSArray<NSNumber *> *foreColor;
@property PowerpointMsoThemeColorIndex foreColorThemeIndex;  // Returns or sets the foreground color for the line.
@property PowerpointMsoPatternType lineFormatPatterned;
@property PowerpointMsoLineStyle lineStyle;
@property double lineWeight;
@property double transparency;


@end

@interface PowerpointLinkFormat : SBObject <PowerpointGenericMethods>

@property PowerpointEPPUpdateOption autoUpdate;
@property (copy) NSString *sourceFullName;


@end

// Represents a Microsoft Office theme.
@interface PowerpointOfficeTheme : SBObject <PowerpointGenericMethods>

@property (copy, readonly) PowerpointThemeColorScheme *themeColorScheme;  // Returns the color scheme of a Microsoft Office theme.
@property (copy, readonly) PowerpointThemeEffectScheme *themeEffectScheme;  // Returns the effects scheme of a Microsoft Office theme.
@property (copy, readonly) PowerpointThemeFontScheme *themeFontScheme;  // Returns the font scheme of a Microsoft Office theme.


@end

@interface PowerpointPictureFormat : SBObject <PowerpointGenericMethods>

@property double brightness;  // Returns or sets the brightness of the specified picture. The value for this property must be a number from 0.0, dimmest to 1.0, brightest.
@property PowerpointMsoPictureColorType colorType;  // Returns or sets the type of color transformation applied to the specified picture.
@property double contrast;  // Returns or sets the contrast for the specified picture. The value for this property must be a number from 0.0, the least contrast to 1.0, the greatest contrast.
@property double cropBottom;  // Returns or sets the number of points that are cropped off the bottom of the specified picture.
@property double cropLeft;  // Returns or sets the number of points that are cropped off the left side of the specified picture.
@property double cropRight;  // Returns or sets the number of points that are cropped off the right side of the specified picture.
@property double cropTop;  // Returns or sets the number of points that are cropped off the top of the specified picture.
@property (copy) NSArray<NSNumber *> *transparencyColor;  // Returns or sets the transparent color for the specified picture as aRGB color. For this property to take effect, the transparent background property must be set to true.
@property BOOL transparentBackground;  // Returns or sets if the parts of the picture that are defined with a transparent color actually appear transparent.


@end

@interface PowerpointPlaceholderFormat : SBObject <PowerpointGenericMethods>

@property (readonly) PowerpointMsoShapeType containedType;
@property (copy) NSString *placeholderName;
@property (readonly) PowerpointEPPPlaceholderType placeholderType;


@end

// Represents the reflection effect in Office graphics.
@interface PowerpointReflectionFormat : SBObject <PowerpointGenericMethods>

@property PowerpointMsoReflectionType reflectionType;  // Returns or sets the type of the reflection format object.


@end

@interface PowerpointShadowFormat : SBObject <PowerpointGenericMethods>

@property double blur;
@property (copy) NSArray<NSNumber *> *foreColor;
@property PowerpointMsoThemeColorIndex foreColorThemeIndex;  // Returns or sets the foreground color for the shadow format.
@property BOOL obscured;
@property double offsetX;
@property double offsetY;
@property BOOL rotateWithShape;  // Returns or sets whether to rotate the shadow when rotating the shape.
@property PowerpointMsoShadowStyle shadowStyle;  // Returns or sets the style of shadow formatting to apply to a shape.
@property PowerpointMsoShadowType shadowType;
@property double size;  // Returns or sets the width of the shadow.
@property double transparency;
@property BOOL visible;


@end

// A collection that represents a set of shapes on a document.
@interface PowerpointShapeRange : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointAdjustment *> *) adjustments;
- (SBElementArray<PowerpointShape *> *) shapes;

@property (copy, readonly) PowerpointAnimationSettings *animationSettings;  // Returns all the special effects that you can apply to the animation of the specified shape.
@property PowerpointMsoAutoShapeType autoShapeType;  // Returns or sets the shape type for AutoShapes other than a line, freeform drawing, or connector.
@property PowerpointMsoBackgroundStyleIndex backgroundStyle;  // Returns or sets the background style for the specified object.
@property PowerpointMsoBlackWhiteMode blackAndWhiteMode;  // Returns or sets a value that indicates how the specified shape appears when the presentation is viewed in black-and-white mode.
@property (copy, readonly) PowerpointCalloutFormat *calloutFormat;  // Returns callout formatting properties for the specified line callout shapes.
@property (readonly) BOOL child;  // Returns whether all shapes in a shape range are child shapes of the same parent.
@property (readonly) NSInteger connectionSiteCount;  // Returns the number of connection sites on the specified shape.
@property (copy, readonly) PowerpointFillFormat *fillFormat;  // Returns the fill format properties for the specified object.
@property (copy, readonly) PowerpointGlowFormat *glowFormat;  // Returns the glow format for the specified range of shapes.
@property (readonly) BOOL hasChild;
@property (readonly) BOOL hasTable;  // Returns whether the specified shape is a table.
@property (readonly) BOOL hasTextFrame;  // Returns whether the specified shape has a text frame.
@property double height;  // Returns or sets the height of the specified object.
@property (readonly) BOOL horizontalFlip;  // Returns whether the specified shape is flipped around the horizontal axis.
@property (readonly) BOOL isConnector;  // Determines whether the specified shape is a connector.
@property double leftPosition;  // Returns or sets a value equal to the distance from the left edge of the leftmost shape in the shape range to the left edge of the slide.
@property (copy, readonly) PowerpointLineFormat *lineFormat;  // Returns line format properties for the specified line or shape border.
@property (copy, readonly) PowerpointLinkFormat *linkFormat;  // Returns the properties for linked OLE objects.
@property BOOL lockAspectRatio;  // Determines whether the specified shape retains its original proportions when you resize it.
@property (readonly) PowerpointEPPMediaType mediaType;  // Returns the OLE media type.
@property (copy) NSString *name;  // Identifies the shape on a slide.
@property (copy, readonly) PowerpointReflectionFormat *reflectionFormat;  // Returns the reflection format for the specified range of shapes.
@property double rotation;  // Returns or sets the number of degrees that the specified shape is rotated around the z-axis.
@property (copy, readonly) PowerpointShadowFormat *shadowFormat;  // Returns shadow formatting for specified shapes.
@property PowerpointMsoShapeStyleIndex shapeStyle;  // Returns or sets the shape style index for the specified object.
@property (readonly) PowerpointMsoShapeType shapeType;  // Represents the type of shape or shapes in a range of shapes.
@property (copy, readonly) PowerpointSoftEdgeFormat *softEdgeFormat;  // Returns the soft edge format for the specified range of shapes.
@property (copy, readonly) PowerpointTextFrame *textFrame;  // Returns the alignment and anchoring properties for the specified shape or master text style.
@property (copy, readonly) PowerpointThreeDFormat *threeDFormat;  // Returns 3-D effect formatting properties for the specified shape.
@property double top;  // Returns or sets a value equal to the distance from the top edge of the topmost shape in the shape range to the top edge of the document.
@property (readonly) BOOL verticalFlip;  // Determines whether the specified shape is flipped around the vertical axis.
@property BOOL visible;  // Returns or sets the visibility of the specified object or the formatting applied to the specified object.
@property double width;  // Returns or sets the width of the specified object.
@property (readonly) NSInteger zOrderPosition;  // Returns the position of the specified shape in the z-order.

- (void) alignAlignType:(PowerpointMsoAlignCmd)alignType relativeToSlide:(BOOL)relativeToSlide;  // Aligns the shapes in the specified range of shapes.
- (void) copyShapeRange;
- (void) cutShapeRange;
- (void) distributeDistributeType:(PowerpointMsoDistributeCmd)distributeType relativeToSlide:(BOOL)relativeToSlide;  // Evenly distributes the shapes in the specified range of shapes. You can specify whether you want to distribute the shapes horizontally or vertically and whether you want to distribute them over the entire slide or over the space they originally occupy.
- (PowerpointShape *) group;  // Groups the shapes in the specified shape range.
- (PowerpointShape *) regroup;  // Regroups the group that the specified shape range belonged to previously.
- (PowerpointShapeRange *) ungroup;  // Ungroups any grouped shapes in the specified shape or range of shapes.

@end

@interface PowerpointShape : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointShape *> *) shapes;
- (SBElementArray<PowerpointCallout *> *) callouts;
- (SBElementArray<PowerpointConnector *> *) connectors;
- (SBElementArray<PowerpointPicture *> *) pictures;
- (SBElementArray<PowerpointLineShape *> *) lineShapes;
- (SBElementArray<PowerpointPlaceHolder *> *) placeHolders;
- (SBElementArray<PowerpointTextBox *> *) textBoxes;
- (SBElementArray<PowerpointComment *> *) comments;
- (SBElementArray<PowerpointShapeTable *> *) shapeTables;
- (SBElementArray<PowerpointAdjustment *> *) adjustments;

@property (copy, readonly) PowerpointAnimationSettings *animationSettings;
@property PowerpointMsoAutoShapeType autoShapeType;
@property PowerpointMsoBackgroundStyleIndex backgroundStyle;  // Returns or sets the background style.
@property PowerpointMsoBlackWhiteMode blackAndWhiteMode;
@property (readonly) BOOL child;  // True if the shape is a child shape.
@property (readonly) NSInteger connectionSiteCount;
@property (copy, readonly) PowerpointFillFormat *fillFormat;  // Returns a fill format object that contains fill formatting properties for the specified shape.
@property (copy, readonly) PowerpointGlowFormat *glowFormat;  // Returns the formatting properties for a glow effect.
@property (readonly) BOOL hasTable;
@property (readonly) BOOL hasTextFrame;
@property double height;
@property (readonly) BOOL horizontalFlip;
@property (readonly) BOOL isConnector;
@property double leftPosition;
@property (copy, readonly) PowerpointLineFormat *lineFormat;
@property (copy, readonly) PowerpointLinkFormat *linkFormat;
@property BOOL lockAspectRatio;
@property (readonly) PowerpointEPPMediaType mediaType;
@property (copy) NSString *name;
@property (copy, readonly) PowerpointReflectionFormat *reflectionFormat;  // Returns the formatting properties for a reflection effect.
@property double rotation;
@property (copy, readonly) PowerpointShadowFormat *shadowFormat;
@property PowerpointMsoShapeStyleIndex shapeStyle;  // Returns or sets the shape style corresponding to the Quick Styles.
@property (readonly) PowerpointMsoShapeType shapeType;
@property (copy, readonly) PowerpointSoftEdgeFormat *softEdgeFormat;  // Returns the formatting properties for a soft edge effect.
@property (copy, readonly) PowerpointTextFrame *textFrame;
@property (copy, readonly) PowerpointThreeDFormat *threeDFormat;  // Returns a threeD format object that contains 3-D-effect formatting properties for the specified shape.
@property double top;
@property (readonly) BOOL verticalFlip;
@property BOOL visible;
@property double width;
@property (copy, readonly) PowerpointWordArtFormat *wordArtFormat;  // Returns the formatting properties for a word art effect.
@property (readonly) NSInteger zOrderPosition;

- (void) copyShape;
- (void) cutShape;
- (void) saveAsPicturePictureType:(PowerpointMsoPictureType)pictureType fileName:(NSString *)fileName;  // Saves the shape in the requested file using the stated graphic format

@end

@interface PowerpointCallout : PowerpointShape

@property (readonly) PowerpointMsoCalloutType calloutType;
@property (copy, readonly) PowerpointCalloutFormat *calloutFormat;


@end

@interface PowerpointComment : PowerpointShape


@end

@interface PowerpointConnector : PowerpointShape

@property (copy, readonly) PowerpointConnectorFormat *connectorFormat;
@property (readonly) PowerpointMsoConnectorType connectorType;


@end

// The line shape uses begin line X, begin line Y, end line X, and end line Y when created
@interface PowerpointLineShape : PowerpointShape

@property double beginLineX;
@property double beginLineY;
@property double endLineX;
@property double endLineY;


@end

@interface PowerpointMediaObject : PowerpointShape

@property (copy, readonly) NSString *fileName;


@end

@interface PowerpointMedia2Object : PowerpointShape

@property (copy, readonly) NSString *fileName;
@property (readonly) BOOL linkToFile;
@property (readonly) BOOL saveWithDocument;


@end

@interface PowerpointPicture : PowerpointShape

@property (copy, readonly) NSString *fileName;
@property (readonly) BOOL linkToFile;
@property (copy, readonly) PowerpointPictureFormat *pictureFormat;
@property (readonly) BOOL saveWithDocument;

- (void) scaleHeightFactor:(double)factor relativeToOriginalSize:(BOOL)relativeToOriginalSize scale:(PowerpointMsoScaleFrom)scale;
- (void) scaleWidthFactor:(double)factor relativeToOriginalSize:(BOOL)relativeToOriginalSize scale:(PowerpointMsoScaleFrom)scale;

@end

@interface PowerpointPlaceHolder : PowerpointShape

@property (copy, readonly) PowerpointPlaceholderFormat *placeHolderFormat;
@property (readonly) PowerpointEPPPlaceholderType placeholderType;


@end

@interface PowerpointShapeTable : PowerpointShape

@property (readonly) NSInteger numberOfColumns;
@property (readonly) NSInteger numberOfRows;
@property (copy, readonly) PowerpointTable *tableObject;


@end

// Represents the soft edge formatting for a shape or range of shapes
@interface PowerpointSoftEdgeFormat : SBObject <PowerpointGenericMethods>

@property PowerpointMsoSoftEdgeType softEdgeType;  // Returns or sets the type soft edge format object.


@end

@interface PowerpointTextBox : PowerpointShape

@property (readonly) PowerpointMsoTextOrientation textOrientation;


@end

// Represents a single text column.
@interface PowerpointTextColumn : SBObject <PowerpointGenericMethods>

@property NSInteger columnNumber;  // Returns or sets the index of the text column object.
@property double spacing;  // Returns or sets the spacing between text columns in a text column object.
@property PowerpointMsoTextDirection textDirection;  // Returns or sets the direction of text in the text column object.


@end

@interface PowerpointTextFrame : SBObject <PowerpointGenericMethods>

@property PowerpointMsoAutoSize autoSize;
@property (readonly) BOOL hasText;  // Returns whether the specified text frame has text.
@property PowerpointMsoHorizontalAnchor horizontalAnchor;
@property double marginBottom;
@property double marginLeft;
@property double marginRight;
@property double marginTop;
@property (readonly) PowerpointMsoTextOrientation orientation;
@property PowerpointMsoPathFormat pathFormat;  // Returns or sets the path type for the specified text frame.
@property (copy, readonly) PowerpointRuler *ruler;
@property (copy, readonly) PowerpointTextColumn *textColumn;  // Returns the text column object that represents the columns within the text frame.
@property PowerpointMsoTextOrientation textOrientation;
@property (copy, readonly) PowerpointTextRange *textRange;
@property (copy, readonly) PowerpointThreeDFormat *threeDFormat;  // Returns the 3-D effect formatting properties for the specified text.
@property PowerpointMsoVerticalAnchor verticalAnchor;
@property PowerpointMsoWarpFormat warpFormat;  // Returns or sets the warp type for the specified text frame.
@property (readonly) PowerpointMsoPresetTextEffect wordArtStylesFormat;  // Returns or sets a value specifying the text effect for the selected text.
@property BOOL wordWrap;  // Returns or sets text break lines within or past the boundaries of the shape.
@property PowerpointMsoPresetTextEffect wordartFormat;  // Returns or sets the WordArt type for the specified text frame.


@end

// Represents the color scheme of an Office Theme
@interface PowerpointThemeColorScheme : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointThemeColor *> *) themeColors;

- (NSArray<NSNumber *> *) getCustomColorName:(NSString *)name;  // Returns the custom color for the specified Microsoft Office theme.
- (void) loadThemeColorSchemeFileName:(NSString *)fileName;  // Loads the color scheme of a Microsoft Office theme from a file.
- (void) saveThemeColorSchemeFileName:(NSString *)fileName;  // Saves the color scheme of a Microsoft Office theme to a file.

@end

// Represents a color in the color scheme of a Microsoft Office 2007 theme.
@interface PowerpointThemeColor : SBObject <PowerpointGenericMethods>

@property (copy) NSArray<NSNumber *> *RGB;  // Returns or sets a value of a color in the color scheme of a Microsoft Office theme.
@property (readonly) PowerpointMsoThemeColorSchemeIndex themeColorSchemeIndex;  // Returns the index value a color scheme of a Microsoft Office theme.


@end

// Represents the effect scheme of a Microsoft Office theme.
@interface PowerpointThemeEffectScheme : SBObject <PowerpointGenericMethods>

- (void) loadThemeEffectSchemeFileName:(NSString *)fileName;  // Loads the effects scheme of a Microsoft Office theme from a file.

@end

// Represents the font scheme of a Microsoft Office theme.
@interface PowerpointThemeFontScheme : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointMinorThemeFont *> *) minorThemeFonts;
- (SBElementArray<PowerpointMajorThemeFont *> *) majorThemeFonts;

- (void) loadThemeFontSchemeFileName:(NSString *)fileName;  // Loads the font scheme of a Microsoft Office theme from a file.
- (void) saveThemeFontSchemeFileName:(NSString *)fileName;  // Saves the font scheme of a Microsoft Office theme to a file.

@end

// Represents a container for the font schemes of a Microsoft Office theme.
@interface PowerpointThemeFont : SBObject <PowerpointGenericMethods>

@property (copy) NSString *name;  // Returns or sets a value specifying the font to use for a selection.


@end

// Represents a container for the font schemes of a Microsoft Office theme.
@interface PowerpointMajorThemeFont : PowerpointThemeFont


@end

// Represents a container for the font schemes of a Microsoft Office theme.
@interface PowerpointMinorThemeFont : PowerpointThemeFont


@end

// Represents a shape's three-dimensional formatting.
@interface PowerpointThreeDFormat : SBObject <PowerpointGenericMethods>

@property double ZDistance;  // Returns or sets a Single that represents the distance from the center of an object or text.
@property double bevelBottomDepth;  // Returns or sets the depth/height of the bottom bevel.
@property double bevelBottomInset;  // Returns or sets the inset size/width for the bottom bevel.
@property PowerpointMsoBevelType bevelBottomType;  // Returns or sets the bevel type for the bottom bevel.
@property double bevelTopDepth;  // Returns or sets the depth/height of the top bevel.
@property double bevelTopInset;  // Returns or sets the inset size/width for the top bevel.
@property PowerpointMsoBevelType bevelTopType;  // Returns or sets the bevel type for the top bevel.
@property (copy) NSArray<NSNumber *> *contourColor;  // Returns or sets the color of the contour of an object or text.
@property PowerpointMsoThemeColorIndex contourColorThemeIndex;  // Returns or sets the color for the specified contour.
@property double contourWidth;  // Returns or sets the width of the contour of an object or text.
@property double depth;  // Returns or sets the depth of the shape's extrusion.
@property (copy) NSArray<NSNumber *> *extrusionColor;  // Returns or sets a RGB color that represents the color of the shape's extrusion.
@property PowerpointMsoThemeColorIndex extrusionColorThemeIndex;  // Returns or sets the color for the specified extrusion.
@property PowerpointMsoExtrusionColorType extrusionColorType;  // Returns or sets a value that indicates what will determine the extrusion color.
@property double fieldOfView;  // Returns or sets the amount of perspective for an object or text.
@property double lightAngle;  // Returns or sets the angle of the lighting.
@property BOOL perspective;  // Returns or sets if the extrusion appears in perspective that is, if the walls of the extrusion narrow toward a vanishing point. If false, the extrusion is a parallel, or orthographic, projection that is, if the walls don't narrow toward a vanishing point.
@property PowerpointMsoPresetCamera presetCamera;  // Returns a constant that represents the camera preset.
@property PowerpointMsoPresetExtrusionDirection presetExtrusionDirection;  // Returns or sets the direction taken by the extrusion's sweep path leading away from the extruded shape, the front face of the extrusion.
@property PowerpointMsoPresetLightingDirection presetLightingDirection;  // Returns or sets the position of the light source relative to the extrusion.
@property PowerpointMsoLightRigType presetLightingRig;  // Returns a constant that represents the lighting preset.
@property PowerpointMsoPresetLightingSoftness presetLightingSoftness;  // Returns or sets the intensity of the extrusion lighting.
@property PowerpointMsoPresetMaterial presetMaterial;  // Returns or sets the extrusion surface material.
@property PowerpointMsoPresetThreeDFormat presetThreeDFormat;  // Returns or sets the preset extrusion format. Each preset extrusion format contains a set of preset values for the various properties of the extrusion.
@property BOOL projectText;  // Returns or sets whether text on a shape rotates with shape.
@property double rotationX;  // Returns or sets the rotation of the extruded shape around the x-axis in degrees. A positive value indicates upward rotation; a negative value indicates downward rotation.
@property double rotationY;  // Returns or sets the rotation of the extruded shape around the y-axis, in degrees. A positive value indicates rotation to the left; a negative value indicates rotation to the right.
@property double rotationZ;  // Returns or sets the rotation of the extruded shape around the z-axis, in degrees. A positive value indicates clockwise rotation; a negative value indicates anti-clockwise rotation.
@property BOOL visible;  // Returns or sets if the specified object, or the formatting applied to it, is visible.


@end

@interface PowerpointWordArtFormat : SBObject <PowerpointGenericMethods>

@property BOOL fontBold;
@property BOOL fontItalic;
@property (copy) NSString *fontName;
@property double fontSize;
@property BOOL kernedPairs;
@property BOOL normalizedHeight;
@property PowerpointMsoPresetTextEffectShape presetShape;
@property BOOL rotatedChars;
@property PowerpointMsoTextEffectAlignment textAlignment;
@property double tracking;
@property PowerpointMsoPresetTextEffect wordArtStylesFormat;  // Returns or sets a value specifying the text effect for the selected text.
@property (copy) NSString *wordArtText;

- (void) toggleVerticalText;

@end



/*
 * Text Suite
 */

@interface PowerpointTextRange : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointCharacter *> *) characters;
- (SBElementArray<PowerpointWord *> *) words;
- (SBElementArray<PowerpointSentence *> *) sentences;
- (SBElementArray<PowerpointLine *> *) lines;
- (SBElementArray<PowerpointParagraph *> *) paragraphs;
- (SBElementArray<PowerpointTextFlow *> *) textFlows;

@property (readonly) double boundsHeight;
@property (readonly) double boundsWidth;
@property (copy) NSString *content;
@property (copy, readonly) PowerpointFont *font;
@property NSInteger indentLevel;
@property (readonly) double leftBounds;
@property (readonly) NSInteger offset;
@property (copy, readonly) PowerpointParagraphFormat *paragraphFormat;
@property (readonly) NSInteger textLength;
@property (readonly) double topBounds;

- (void) addPeriodsTo;
- (void) changeCaseTo:(PowerpointMsoTextChangeCase)to;
- (void) copyTextRange;
- (void) cutTextRange;
- (NSArray<NSNumber *> *) getRotatedTextBounds;  // Returns back a list containing the four point of the text bounds as follows  {x1, y1}, {x2, y2}, {x3, y3}, {x4, y4} }
- (PowerpointActionSetting *) getTextActionSettingResult:(PowerpointEPPMouseActivation)result;
- (void) insertTextTextRangeInsertWhere:(PowerpointMsoTextRangeInsertPosition)insertWhere newText:(NSString *)newText;  // Adds text to existing text.
- (void) pasteTextRange;
- (void) removePeriodsFrom;

@end

@interface PowerpointCharacter : PowerpointTextRange


@end

@interface PowerpointLine : PowerpointTextRange


@end

@interface PowerpointParagraph : PowerpointTextRange


@end

@interface PowerpointSentence : PowerpointTextRange


@end

@interface PowerpointTextFlow : PowerpointTextRange


@end

@interface PowerpointWord : PowerpointTextRange


@end



/*
 * Table Suite
 */

@interface PowerpointCell : SBObject <PowerpointGenericMethods>

@property (readonly) BOOL selected;
@property (copy, readonly) PowerpointShape *shape;

- (PowerpointLineFormat *) getBorderEdge:(PowerpointPpBorderType)edge;
- (void) mergeMergeWith:(PowerpointCell *)mergeWith;
- (void) splitNumberOfRows:(NSInteger)numberOfRows numberOfColumns:(NSInteger)numberOfColumns;

@end

@interface PowerpointColumn : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointCell *> *) cells;

@property double width;


@end

@interface PowerpointRow : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointCell *> *) cells;

@property double height;


@end

@interface PowerpointTable : SBObject <PowerpointGenericMethods>

- (SBElementArray<PowerpointColumn *> *) columns;
- (SBElementArray<PowerpointRow *> *) rows;

@property PowerpointMsoTextDirection tableDirection;

- (PowerpointCell *) getCellFromRow:(NSInteger)row column:(NSInteger)column;

@end

