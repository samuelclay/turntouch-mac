//
//  TTDFUView.m
//  Turn Touch Remote
//
//  Created by Samuel Clay on 11/4/15.
//  Copyright © 2015 Turn Touch. All rights reserved.
//

#import "TTDFUView.h"
#import "TTDFUDeviceView.h"
#import "SSZipArchive.h"
#import "UnzipFirmware.h"
#import "DFUHelper.h"
#include "DFUHelper.h"

@interface TTDFUView ()

/*!
 * This property is set when the device has been selected on the Scanner View Controller.
 */
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (strong, nonatomic) DFUOperations *dfuOperations;
@property (strong, nonatomic) DFUHelper *dfuHelper;

@property BOOL isTransferring;
@property BOOL isTransfered;
@property BOOL isTransferCancelled;
@property BOOL isConnected;
@property BOOL isErrorKnown;

@end

@implementation TTDFUView

@synthesize selectedPeripheral;
@synthesize dfuOperations;

- (instancetype)initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        appDelegate = (TTAppDelegate *)[NSApp delegate];
        [self setOrientation:NSUserInterfaceLayoutOrientationVertical];
        [self setAlignment:NSLayoutAttributeCenterX];
        [self setSpacing:0];
        [self setWantsLayer:YES];
        [self setHuggingPriority:NSLayoutPriorityDefaultHigh
                  forOrientation:NSLayoutConstraintOrientationVertical];
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        [self registerAsObserver];

        PACKETS_NOTIFICATION_INTERVAL = [[[NSUserDefaults standardUserDefaults] valueForKey:@"dfu_number_of_packets"] intValue];
        NSLog(@"PACKETS_NOTIFICATION_INTERVAL %d",PACKETS_NOTIFICATION_INTERVAL);
        dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
        self.dfuHelper = [[DFUHelper alloc] initWithData:dfuOperations];
    }

    return self;
}

- (void)registerAsObserver {
    [appDelegate.bluetoothMonitor addObserver:self
                                   forKeyPath:@"nicknamedConnectedCount"
                                      options:0 context:nil];
}

- (void) observeValueForKeyPath:(NSString*)keyPath
                       ofObject:(id)object
                         change:(NSDictionary*)change
                        context:(void*)context {
    if ([keyPath isEqual:NSStringFromSelector(@selector(nicknamedConnectedCount))]) {
        [self setNeedsDisplay:YES];
        [self drawStackView];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"nicknamedConnectedCount"];
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    [self drawBackground];
}

- (void)drawBackground {
    [NSColorFromRGB(0xEDDF31) set];
    NSRectFill(self.bounds);
}

- (void)drawStackView {
    NSMutableArray *dfuDeviceViews = [NSMutableArray array];
    NSArray *devices = appDelegate.bluetoothMonitor.foundDevices.nicknamedConnected;
    [self removeConstraints:[self constraints]];

    for (TTDevice *device in devices) {
        TTDFUDeviceView *deviceView = [[TTDFUDeviceView alloc] initWithDevice:device];
        [dfuDeviceViews addObject:deviceView];
    }
    
    [self setViews:dfuDeviceViews inGravity:NSStackViewGravityTop];
    
    for (TTDFUDeviceView *deviceView in self.views) {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:deviceView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:0 multiplier:1.0 constant:40]];
    }
}


#pragma mark Device Selection Delegate

-(void)centralManager:(CBCentralManager *)manager didPeripheralSelected:(CBPeripheral *)peripheral {
    selectedPeripheral = peripheral;
    [dfuOperations setCentralManager:manager];
    //    deviceName.text = peripheral.name;
    dfuOperations.bleOperations.bluetoothPeripheral = peripheral;
    [dfuOperations.bleOperations.bluetoothPeripheral setDelegate:dfuOperations.bleOperations];
    [dfuOperations.bleOperations centralManager:manager didConnectPeripheral:peripheral];
}

#pragma mark - DFU

-(void)performDFU:(TTDevice *)device {
    currentDevice = device;
    [self centralManager:appDelegate.bluetoothMonitor.manager didPeripheralSelected:device.peripheral];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self disableOtherButtons];
        //        uploadStatus.hidden = NO;
        //        progress.hidden = NO;
        //        progressLabel.hidden = NO;
        //        uploadButton.enabled = NO;
    });
    
    [self prepareFirmware];
//    [self.dfuHelper checkAndPerformDFU];
}

- (void)prepareFirmware {
    NSString *filePath = [NSString stringWithFormat:@"%@/firmwares/nrf51_01.zip",
                          [[NSBundle mainBundle] resourcePath]];
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    self.dfuHelper.selectedFileURL = fileUrl;
    [self.dfuHelper setFirmwareType:FIRMWARE_TYPE_APPLICATION];
    
    NSString *selectedFileName = [[fileUrl path] lastPathComponent];
    NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
    self.dfuHelper.selectedFileSize = fileData.length;
    NSLog(@" ---> Upgrading with %@", selectedFileName);
    
    self.dfuHelper.isSelectedFileZipped = YES;
    self.dfuHelper.isManifestExist = NO;
    [self.dfuHelper unzipFiles:self.dfuHelper.selectedFileURL];
}

- (void) clearUI {
    selectedPeripheral = nil;
}

-(void)disableOtherButtons {
    //    selectFileButton.enabled = NO;
    //    selectFileTypeButton.enabled = NO;
    //    connectButton.enabled = NO;
}

-(void)enableOtherButtons {
    //    selectFileButton.enabled = YES;
    //    selectFileTypeButton.enabled = YES;
    //    connectButton.enabled = YES;
}

-(void)enableUploadButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.selectedFileSize > 0) {
            if ([self.dfuHelper isValidFileSelected]) {
                NSLog(@" valid file selected");
            } else {
                NSLog(@"Valid file not available in zip file");
                //                [Utility showAlert:[self.dfuHelper getFileValidationMessage]];
                return;
            }
        }
        if (self.dfuHelper.isDfuVersionExist) {
            if (selectedPeripheral && self.dfuHelper.selectedFileSize > 0 && self.isConnected && self.dfuHelper.dfuVersion >= 1) {
                if ([self.dfuHelper isInitPacketFileExist]) {
                    //                    uploadButton.enabled = YES;
                }
                else {
                    //                    [Utility showAlert:[self.dfuHelper getInitPacketFileValidationMessage]];
                }
            }
            else {
                NSLog(@"cant enable Upload button");
            }
        }
        else {
            if (selectedPeripheral && self.dfuHelper.selectedFileSize > 0 && self.isConnected) {
                //                uploadButton.enabled = YES;
            }
            else {
                NSLog(@"cant enable Upload button");
            }
        }
        
    });
}

#pragma mark DFUOperations delegate methods

-(void)onDeviceConnected:(CBPeripheral *)peripheral {
    NSLog(@"onDeviceConnected %@",peripheral.name);
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = NO;
    [self enableUploadButton];
}

-(void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral {
    NSLog(@"onDeviceConnectedWithVersion %@",peripheral.name);
    self.isConnected = YES;
    self.dfuHelper.isDfuVersionExist = YES;
    [self enableUploadButton];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral {
    NSLog(@"device disconnected %@",peripheral.name);
    self.isTransferring = NO;
    self.isConnected = NO;
    
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.dfuHelper.dfuVersion >= 2) {
            [self clearUI];
            
            self.isTransferCancelled = NO;
            self.isTransfered = NO;
            self.isErrorKnown = NO;
            
            [self returnBluetoothManager];
        } else {
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [dfuOperations connectDevice:peripheral];
            });
            
        }
    });
}

-(void)onReadDFUVersion:(int)version {
    NSLog(@"onReadDFUVersion %d",version);
    self.dfuHelper.dfuVersion = version;
    NSLog(@"DFU Version: %d",self.dfuHelper.dfuVersion);
    if (self.dfuHelper.dfuVersion == 1) {
//        [dfuOperations setAppToBootloaderMode];
    }
    [self enableUploadButton];
}

- (void)onNotifyBeginForControlPoint {
    NSLog(@"Notifying for control point, begin...");
    [dfuOperations setAppToBootloaderMode];
}

-(void)onDFUStarted {
    NSLog(@"onDFUStarted");
    self.isTransferring = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //        uploadButton.enabled = YES;
        //        [uploadButton setTitle:@"Cancel" forState:UIControlStateNormal];
        //        NSString *uploadStatusMessage = [self.dfuHelper getUploadStatusMessage];
        //        if ([Utility isApplicationStateInactiveORBackground]) {
        //            [Utility showBackgroundNotification:uploadStatusMessage];
        //        } else {
        //            uploadStatus.text = uploadStatusMessage;
        //        }
    });
}

-(void)onDFUCancelled {
    NSLog(@"onDFUCancelled");
    self.isTransferring = NO;
    self.isTransferCancelled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enableOtherButtons];
        [self returnBluetoothManager];
    });
}

-(void)onSoftDeviceUploadStarted {
    NSLog(@"onSoftDeviceUploadStarted");
}

-(void)onSoftDeviceUploadCompleted {
    NSLog(@"onSoftDeviceUploadCompleted");
}

-(void)onBootloaderUploadStarted {
    NSLog(@"onBootloaderUploadStarted");
    dispatch_async(dispatch_get_main_queue(), ^{
        //        if ([Utility isApplicationStateInactiveORBackground]) {
        //            [Utility showBackgroundNotification:@"uploading bootloader ..."];
        //        }
        //        else {
        //            uploadStatus.text = @"uploading bootloader ...";
        //        }
    });
    
}

-(void)onBootloaderUploadCompleted {
    NSLog(@"onBootloaderUploadCompleted");
}

-(void)onTransferPercentage:(int)percentage {
    NSLog(@"onTransferPercentage %d",percentage);
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        //        progressLabel.text = [NSString stringWithFormat:@"%d %%", percentage];
        //        [progress setProgress:((float)percentage/100.0) animated:YES];
    });
}

-(void)onSuccessfulFileTranferred {
    NSLog(@"OnSuccessfulFileTransferred");
    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isTransferring = NO;
        self.isTransfered = YES;
        [self returnBluetoothManager];
        //        NSString* message = [NSString stringWithFormat:@"%lu bytes transfered in %lu seconds", (unsigned long)dfuOperations.binFileSize, (unsigned long)dfuOperations.uploadTimeInSeconds];
        //        if ([Utility isApplicationStateInactiveORBackground]) {
        //            [Utility showBackgroundNotification:message];
        //        }
        //        else {
        //            [Utility showAlert:message];
        //        }
        
    });
}

-(void)onError:(NSString *)errorMessage {
    NSLog(@"OnError %@",errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        //        [Utility showAlert:errorMessage];
        [self clearUI];
    });
}

- (void)returnBluetoothManager {
    NSLog(@" ---> Returning Bluetooth Monitor");
    [appDelegate.bluetoothMonitor.manager setDelegate:appDelegate.bluetoothMonitor];
}

@end
